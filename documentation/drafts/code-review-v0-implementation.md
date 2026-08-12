# Tendril V0 Implementation Code Review

## Review Scope

This review compares the proposed V0 architecture with the current FastAPI, SQLite, and Godot implementation. It is a static, read-only review; no fixes were implemented and no runtime tests were performed.

The implementation demonstrates the intended end-to-end shape: persisted nodes and edges, recursive cooking, semantic edge types, locking and forking, workspace hydration, GraphEdit rendering, HTTP-driven mutations, and monitor creation. However, the current functional loop has multiple correctness defects that can erase persisted node fields, prevent graph connections in the UI, desynchronize frontend and backend state, hang cook requests, or return unhandled server errors. These should be treated as V0 blockers rather than deferred V1 polish.

### Severity Summary

| Severity | Finding |
| --- | --- |
| Critical | Frontend PATCH requests replace complete nodes with default-valued omitted fields, destroying ports, position, properties, and sometimes current text. |
| Critical | Every rendered GraphNode has an output slot but no input slot, so normal GraphEdit connection dragging cannot target a node. |
| High | A cycle in `supersedes` edges makes `_resolve_supersedes()` loop forever. |
| High | One process-global SQLite connection is used without an application lifecycle, thread strategy, or close path. |
| High | Edge creation does not validate ports, cardinality, duplicates, DAG cycles, or supersedes invariants. |
| High | Forking a composite does not preserve its incoming dataflow, so the superseding composite cooks with empty inputs. |
| High | Shared `HTTPRequest` nodes and global request context make overlapping actions fail or route responses to the wrong local state. |
| Medium | Recursive cooking can exceed Python's recursion limit and repeats shared upstream work without memoization. |
| Medium | File sources permit arbitrary local file reads and handle only `FileNotFoundError`. |
| Medium | The frontend does not persist node movement and does not render named ports or semantic edge styles. |

## 1. Architectural Alignment

### DAG Traversal and Cooking

The backend partially implements the architecture's recursive upstream cooking model. `GraphStore.cook()` snapshots all edges, recursively evaluates upstream nodes for each composite input, supplies an empty string for an unconnected input, substitutes `{{port_name}}` placeholders, and records traversed node and edge IDs (`product/tendril/api/graph.py:153-239`). A composite-only dataflow cycle is detected through the `visiting` set and becomes HTTP 400 through `main.py` (`graph.py:176-219`, `main.py:46-53`).

The graph is not actually constrained to be a DAG. `add_edge()` accepts self-edges and cycle-forming edges, and cycle detection occurs only when a cook traverses composite nodes (`graph.py:95-120`). This means invalid graphs persist successfully and fail later. A cycle formed entirely by `supersedes` edges is worse: `_resolve_supersedes()` has no visited set and never terminates (`graph.py:158-171`).

The recursive implementation has no depth guard or iterative traversal. A sufficiently deep valid chain can raise `RecursionError`, which is not translated to a controlled API response. Shared upstream subgraphs are reevaluated for every downstream input because there is no per-cook memoization, producing avoidable repeated database reads, file reads, and potentially exponential work in reconvergent graphs.

### Node and Edge Schemas

The Pydantic models correctly constrain node and semantic types with `Literal`, use independent default factories for mutable collections, represent V0 positions with a 3D-ready `Position3D`, and match the architecture's basic Node/Port/Properties JSON shape (`product/tendril/api/models.py:8-62`).

They do not enforce operator invariants. Examples include duplicate or empty port names; a text source with inputs or no `text_out`; a composite with arbitrary outputs; a monitor with outputs; duplicate node IDs supplied by clients; and unrestricted position values. Pydantic's default extra-field behavior also does not provide a strict contract. Most importantly, the same complete `Node` and `Edge` models are used for PATCH endpoints. Omitted fields therefore become model defaults instead of remaining unchanged (`models.py:32-56`, `main.py:28-31`, `main.py:69-72`). The API calls these operations PATCH, but they behave as full replacement for nodes and as a semantic-only update requiring an otherwise complete edge body for edges.

SQLite does not reinforce the Pydantic constraints. It stores ports and properties as JSON text and has no semantic type check, lock boolean check, foreign keys, port integrity constraints, or useful uniqueness constraints beyond IDs (`product/tendril/api/migrations.sql:4-24`).

### Immutability and Forking

The basic locked-node guard is present: any node update is rejected with HTTP 409 when the persisted node is locked (`graph.py:81-93`, `main.py:28-35`). Forking deep-copies the node, assigns a new ID, unlocks it, persists it, and creates a `supersedes` edge (`graph.py:241-261`). Cooking follows outgoing supersedes edges before evaluating a node (`graph.py:158-179`).

The overall immutability model is not sound yet:

- Node insertion and supersedes-edge insertion are separate transactions. If edge creation fails, the fork leaves an unlinked duplicate (`graph.py:246-259`).
- The API permits arbitrary clients to create, change, and repurpose `supersedes` edges through generic edge endpoints. It does not enforce one successor per node, prevent branching or cycles, or reserve that type for the fork operation (`main.py:38-43`, `main.py:69-74`).
- Edge semantics around locked nodes remain mutable. If immutable history includes graph relationships, changing an existing edge rewrites that history even though node text is protected.
- `_resolve_supersedes()` picks the first successor in an unordered edge query when multiple successors exist, so the selected current version is not deterministic (`graph.py:160-168`).
- A forked composite receives copied input declarations but no copied incoming edges. Downstream traversal reroutes from the old composite to the new one, then the new composite finds no edges targeting its inputs and cooks empty strings (`graph.py:197-227`, `graph.py:241-259`). Leaf-node forks retain content and therefore mask this issue.

### Semantic Edge Types

The schema restricts semantic types to `narrative_context`, `stable_reference`, and `supersedes` (`models.py:43-56`). The cook path excludes supersedes edges from ordinary composite inputs and distinguishes GREEN from RED by prefixing stable text (`graph.py:203-216`). This is a minimal semantic distinction, but it does not implement the architecture's richer contract of passing semantic metadata alongside text to a semantic-aware renderer. Multiline GREEN content prefixes only its first line, and all non-GREEN data edges are implicitly rendered as RED.

The frontend can toggle persisted edges between RED and GREEN, but visual rendering does not distinguish them. All GraphEdit connections use the same default style, and supersedes is displayed as GREEN in the edge menu because every non-RED type falls into the GREEN label branch (`product/tendril/gui/main.gd:155-167`, `main.gd:187-195`, `main.gd:311-351`). This does not meet the specified RED dashed, GREEN solid, and supersedes metallic visual language.

## 2. Backend Review (Python/FastAPI)

### Pydantic Models

Strengths:

- `Literal` rejects unknown node and semantic edge types before store access.
- `Field(default_factory=...)` avoids shared mutable defaults.
- Position, port, properties, and cook response structures are explicit and serializable.

Deficiencies:

- No dedicated create and patch request models exist. Node PATCH silently resets omitted `is_locked`, position, inputs, outputs, and properties to defaults.
- Edge PATCH requires source and target fields even though `GraphStore.update_edge()` ignores all fields except `semantic_type` (`models.py:50-56`, `graph.py:122-136`). This forces the GUI to send meaningless empty identifiers (`main.gd:324-339`).
- Port names allow empty strings, duplicates, whitespace-only values, and template-hostile names.
- The models do not validate per-node-type input/output contracts.
- Client-supplied IDs are accepted without format or length constraints. Empty IDs trigger server generation, while duplicate non-empty IDs raise uncaught SQLite integrity errors.
- Extra request fields are not explicitly forbidden, weakening typo detection and API contract enforcement.

### SQLite Persistence

SQL injection risk is low in the reviewed operations because all values are passed through SQLite placeholders. Static SQL statements are not assembled from request values (`graph.py:64-69`, `graph.py:74-76`, `graph.py:98-119`, `graph.py:128-132`).

Connection and integrity handling need substantial work:

- `GraphStore` creates one long-lived connection at module import and never closes it (`graph.py:9-19`, `main.py:6-7`). There is no FastAPI lifespan hook.
- SQLite's default `check_same_thread=True` makes the connection unsafe if endpoint execution, tests, or future sync handlers use another thread. Keeping all endpoints `async` currently tends to keep operations on the event-loop thread, but it also means synchronous SQLite and file I/O block that event loop.
- A single connection has no explicit serialization policy for overlapping requests. Moving calls to worker threads without redesigning connection ownership would immediately expose thread errors.
- The relative default database path, `tendril.db`, depends on process working directory rather than application configuration (`graph.py:10-12`).
- The schema declares no foreign keys. Application-level node existence checks and edge insertion are separate statements, so integrity is not transactionally guaranteed (`graph.py:95-107`, `migrations.sql:17-24`).
- Duplicate IDs, database lock failures, malformed persisted JSON, migration read failures, and migration SQL failures are not mapped to controlled API errors.
- `fork_node()` is not atomic across node and edge creation.

### DAG Engine

Cycle detection works for ordinary cycles encountered while recursively evaluating composites: a repeated composite in the active traversal raises `ValueError`, and the endpoint returns 400. It is not robust at graph boundaries:

- Invalid cyclic edges are accepted rather than rejected with 400 or 409 at creation time.
- Supersedes cycles bypass the `visiting` set and hang indefinitely.
- Only composites enter `visiting`; this matches the current evaluation behavior of leaf operators, but it couples correctness to hardcoded node-type branches rather than a general graph algorithm.
- `visiting.discard(nid)` is not protected by `finally`. An exception aborts the request, so this does not corrupt another request's local set, but structured cleanup would make the algorithm safer to evolve.
- Deep acyclic graphs can overflow the Python stack.
- Reconvergent graphs receive no cached node result, so identical upstream nodes are cooked repeatedly.
- If multiple data edges feed the same target port, the first edge returned by an unordered `SELECT *` wins and remaining edges are silently ignored (`graph.py:200-217`).
- Source and target port names are never checked against their nodes, so an accepted edge can be permanently ignored by cooking.

### Error Handling

The explicit 404 mapping for missing nodes and edges is appropriate, as are 409 for locked-node updates and 400 for cook-time cycle errors (`main.py:20-74`). FastAPI/Pydantic also provides 422 for malformed request bodies.

Several important failures become incorrect or unhelpful responses:

- Creating an edge with a missing endpoint returns 400, although 404 for the missing resource or 409 for an invalid relation would be more precise.
- Duplicate node/edge IDs raise `sqlite3.IntegrityError` and return 500 rather than 409.
- File sources catch only `FileNotFoundError`. Permission denial, directory paths, decoding errors, transient I/O errors, and oversized files return 500 or block the server (`graph.py:181-190`).
- Arbitrary absolute or relative file paths are accepted. Any unauthenticated client able to reach the API can request readable local files through a file-source node and cook them. A configured workspace root and path containment policy are needed before this is exposed beyond a trusted local process.
- Invalid persisted JSON or values fail during workspace reads/cooks without a controlled data-corruption response.
- Endpoints catch broad `KeyError`, which can misclassify an internal dictionary-key defect as a user-facing 404.
- Error causes are returned as raw exception strings in some 400/409 responses, producing inconsistent details and potentially exposing internals.

## 3. Frontend Review (Godot 4 / GDScript)

### Async HTTP

`HTTPRequest` is asynchronous and does not block the Godot main thread. The implementation creates separate request nodes for broad operation categories and uses `CONNECT_ONE_SHOT` for most operation-specific callbacks (`main.gd:23-44`). This is directionally correct but not concurrency-safe.

- Each `HTTPRequest` supports only one in-flight request. Rapid edits, repeated cooks, monitor creation during another node create, or an edge operation during another edge request can return `ERR_BUSY`. Every call ignores the immediate error returned by `request()`.
- Most one-shot signals are connected after `request()` starts (`main.gd:230-231`, `main.gd:275-276`, `main.gd:355-356`, `main.gd:379-380`, `main.gd:411-412`). Besides making request ownership harder to reason about, a failed start leaves a callback connected; that callback can consume a later request's response.
- `_http_patch` has a permanent generic callback plus temporary bound callbacks. A lock or edge toggle invokes both. If a second action is attached while another is in flight, the wrong bound callback can process the first response (`main.gd:33-35`, `main.gd:294-300`, `main.gd:333-339`).
- Callback `result` values are ignored. DNS, connection, TLS, timeout, and body download failures therefore collapse into response-code logging rather than actionable handling.
- Global `_cooking_node_id` is used to place and connect the monitor. It is safe only while exactly one cook can be outstanding; a scalable request design should bind node identity to the callback (`main.gd:377-424`).
- The final monitor-edge request has no response callback, no immediate error check, and no state reconciliation (`main.gd:423-433`).

### State Management

The frontend violates the thin-client authoritative-state flow in several ways.

The most destructive issue is node PATCH construction. The backend accepts a complete `Node`, not a partial patch. Text focus loss sends only `type` and `content` (`main.gd:244-258`), causing Pydantic defaults to reset position to zero, clear all ports, clear the template, and unlock the node before `GraphStore.update_node()` writes every column. Locking sends only `type`, stale local `content`, and `is_locked` (`main.gd:286-300`), producing the same destructive resets while locking the result.

Local content is never updated after a successful edit. `_node_data[node_id]["content"]` remains the value loaded when the node spawned (`main.gd:92-98`, `main.gd:244-264`). If the user edits text and then locks the node, `_lock_node()` sends the stale content and overwrites the edit. A failed PATCH also leaves the editor showing unsaved text with no rollback or workspace refresh.

Other desynchronization paths include:

- Dragged node positions are never sent to the backend. The frontend changes visually, but a workspace refresh restores the old position.
- Fork response handling changes the returned position only in local JSON and never PATCHes that new position. The backend fork remains at the original node's exact position (`main.gd:359-374`).
- The fork's locally drawn supersedes connection is not inserted into `_edge_data` and is not hydrated from the authoritative workspace until a later fetch.
- Monitor creation draws a connection before edge creation succeeds, then sends the edge without processing its response (`main.gd:415-433`).
- Node and edge creation generally mutate local state directly rather than consistently refreshing from backend state; edge creation is the exception and fetches the workspace.
- `_edge_data` is keyed only by `source_node_id|target_node_id`, so multiple ports or parallel edges between the same node pair overwrite one another (`main.gd:160-167`).

### GraphEdit Integration

GraphEdit is used for its intended canvas, popup, and connection-request mechanisms, but the slot mapping does not implement the API graph.

- `_spawn_graph_node()` creates one child row and calls `set_slot(0, false, ..., true, ...)`: left/input is disabled and right/output is enabled for every node (`main.gd:75-85`). Consequently, no node exposes a target input connector and normal connection dragging cannot complete. Monitors incorrectly expose an output; composite inputs are not rendered; source and target capabilities do not follow node definitions.
- Connection requests ignore `from_port`, `to_port`, and `_node_data` port arrays. Every edge is persisted as `text_out` to `text_in` (`main.gd:266-276`). This is incompatible with composite named inputs, `combined_text`, `stable_text`, and `compressed_narrative`.
- Workspace hydration also maps every edge to visual port index zero, regardless of persisted port names (`main.gd:155-159`).
- The UI does not implement connection deletion, dynamic ports, composite template editing, or all specified node creation types.
- Semantic edges are stored locally but not rendered with RED/GREEN/supersedes styles.
- Every node always creates a heavy `TextEdit`; the required LOD strategy is absent (`main.gd:75-82`).
- Locked nodes receive read-only styling, but unlocked nodes do not implement the specified live/pulsing visual state, and stable locked nodes do not snap toward the ground semantic region.
- The graph clear path removes GraphNode children but does not explicitly clear GraphEdit connections before rebuilding (`main.gd:51-59`). Depending on GraphEdit's pruning behavior, explicit connection clearing is safer and makes workspace replacement deterministic.
- Cook output uses a plain Label inside an `AcceptDialog` without a scroll container, which will be awkward or clipped for large context packets (`main.gd:436-446`).

## 4. Bugs & Vulnerabilities

### Critical

1. **Editing a node destroys unrelated persisted fields.** A text edit PATCH clears ports, template, and position and resets lock state because the request body is partial while the server writes a complete default-filled Node.
2. **Locking can erase the user's latest text.** Local `_node_data.content` is not updated after edit, and lock sends that stale value while also clearing ports, template, and position.
3. **Connection dragging has no valid targets.** All GraphNodes disable their left slot. The advertised spawn-edit-connect-cook loop cannot be completed through the rendered UI.

### High

4. **A supersedes cycle hangs cooking.** For example, edges `A supersedes B` and `B supersedes A` cause `_resolve_supersedes("A")` to loop forever instead of returning 400.
5. **Invalid edges persist.** The backend accepts nonexistent port names, self-loops, duplicate edges, multiple edges into one input, and cycles. Some are ignored; others fail or hang only during cook.
6. **Forked composites lose their dataflow.** Incoming edges still target the old node while cook reroutes to the new node, whose named inputs are all unconnected.
7. **SQLite connection ownership is unsafe.** A global unclosed connection combined with synchronous access from async endpoints blocks concurrency and is incompatible with thread offloading without further redesign.
8. **Overlapping UI operations can misroute callbacks.** Reused HTTPRequest nodes reject simultaneous requests, ignored `request()` errors leave callbacks queued, and global operation state can associate a response with the wrong action.

### Medium

9. **Deep valid DAGs can crash cooking.** Recursive evaluation has no depth limit or iterative fallback; `RecursionError` becomes 500.
10. **Shared subgraphs can cause excessive repeated work.** No cook-result memoization exists.
11. **File sources expose local files.** There is no root allowlist, path containment, size limit, or authorization boundary. Error handling covers only missing files.
12. **Duplicate IDs return 500.** Client-controlled IDs can collide with existing primary keys and trigger uncaught integrity errors.
13. **Multiple superseding nodes are nondeterministic.** Cooking follows whichever outgoing supersedes edge SQLite happens to return first.
14. **Edge toggling can rewrite provenance.** Any edge, including supersedes, can be converted to another semantic type through the generic PATCH endpoint.
15. **Positions are not durable.** Node movement and the local offset applied after fork are never persisted.
16. **Parallel edges disappear from frontend state.** `_edge_data`'s node-pair key cannot represent multiple ports or semantics between the same nodes.
17. **Monitor creation can show a nonexistent edge.** The UI connects immediately and never verifies the backend edge request.
18. **GREEN formatting is incomplete.** Only the first line receives a blockquote prefix, so multiline stable references are semantically misrendered.

### Low / Maintainability

19. The cook engine hardcodes operator behavior in one nested function instead of defining operator contracts, making type-specific validation and extension harder.
20. API error bodies and status semantics are inconsistent, and the Godot UI only prints failures rather than presenting recoverable user state.
21. The database path and backend URL are hardcoded relative/local defaults rather than explicit configuration.

## 5. Recommendations for V1

These recommendations should begin with V0 correctness before adding V1 scale:

1. **Make mutations explicit and non-destructive.** Introduce dedicated `NodeCreate`, `NodePatch`, `EdgeCreate`, and `EdgePatch` models; apply only fields explicitly set; enforce node-type/port invariants; return 409 for ID and relationship conflicts. Update Godot from the successful server response or refetch authoritative workspace state.
2. **Enforce graph and provenance integrity transactionally.** Validate endpoint ports, input cardinality, duplicates, and cycles before edge insertion. Reserve supersedes creation for an atomic fork transaction, enforce one acyclic successor chain, define edge immutability around locked history, and preserve composite upstream dataflow when forking.
3. **Replace recursive ad hoc cooking with a bounded execution plan.** Build an iterative topological traversal, include supersedes-cycle detection, memoize each resolved node once per cook, define deterministic handling for every input, and impose graph depth/size/file-size limits with structured errors.
4. **Adopt safe persistence and file-access lifecycles.** Configure an absolute workspace database path, use FastAPI lifespan startup/shutdown, choose per-request connections or an explicitly serialized database layer, add foreign keys and constraints, and confine file sources to an authorized workspace root with comprehensive I/O handling.
5. **Rebuild frontend request and GraphEdit mapping around authoritative IDs and ports.** Give each in-flight mutation its own request context (or a queue), connect callbacks before dispatch, handle immediate and transport errors, render slots from named input/output arrays, map visual indices to port names, persist movement, represent edges by edge ID, render semantic styles, and add LOD for large text nodes.

## Conclusion

The code is a useful vertical prototype but does not yet safely implement the V0 architecture. The backend's basic model and cook path are recognizable, and parameterized SQL avoids direct injection, but graph validity, immutable provenance, persistence lifecycle, and error boundaries remain incomplete. The frontend uses nonblocking Godot HTTP primitives, yet its request reuse, full-replacement PATCH mismatch, hardcoded slots, and optimistic local mutations violate the architecture's thin-client and authoritative-backend requirements. The critical and high findings should be resolved and covered by backend API tests plus Godot functional-loop tests before V1 expansion.
