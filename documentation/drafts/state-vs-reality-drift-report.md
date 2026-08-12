# Tendril V0 State vs. Reality Drift Report

Status: PASS

Audit type: Static, read-only source audit

Execution report: `runtime/reports/agent-tasks/R000063_20260812T135353Z_inspect-plan-vs-reality-drift.md`

## 1. Scope and Rating Method

This report compares:

- P9 and P10 in `documentation/main/PROJECT_BUILD_MANIFEST.md`.
- The intended V0 contracts in `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`.
- The defects recorded in `documentation/drafts/code-review-v0-implementation.md`.
- The live first-party sources in `product/tendril/api/` and `product/tendril/gui/`.

Ratings mean:

- **PASS:** the requested feature is implemented in source with its essential requested behavior.
- **PARTIAL:** a recognizable implementation exists, but required behavior, integrity, or state synchronization is incomplete.
- **FAIL:** code exists but contradicts or breaks the essential requested behavior.
- **MISSING:** no implementation was found.

This is a static audit. No API or Godot runtime tests were performed, so PASS means source-level implementation evidence, not independently verified runtime behavior.

## 2. Executive Findings

The implementation has advanced beyond the prior review in several important areas: node PATCH is now merge-based, SQLite connections are per-operation and closed, supersedes traversal detects cycles, composite named inputs render as enabled target slots, file and composite node UI paths exist, and cook responses now highlight traversed nodes.

The live product still does not fully satisfy the V0 architecture. Of the 15 specifically requested features, 3 rate PASS and 12 rate PARTIAL. The most consequential remaining drift is:

- The backend accepts invalid and cycle-forming edges instead of enforcing a DAG.
- Forked composite nodes lose incoming dataflow, and fork creation is non-atomic.
- GREEN formatting prefixes only the first line rather than producing a complete Markdown blockquote.
- The frontend can connect only into composite nodes; monitor input ports are declared in state but not enabled visually.
- Editing text does not synchronize `_node_data`, so locking can overwrite the latest edit with stale content.
- Shared `HTTPRequest` objects and global cook context remain unsafe for overlapping actions.
- Node movement and fork offsets remain frontend-only and are not persisted.
- Semantic edge types can be toggled but receive no required RED/GREEN/supersedes visual styles.
- The required LOD strategy, semantic gravity, Extraction/Compression spawn actions, dynamic input removal, and edge deletion are absent.

## 3. Manifest and Architecture Drift

### 3.1 P9 Completion Claim - PARTIAL

The manifest marks P9 complete and specifically claims CRUD, recursive cooking with cycle detection, file reading with error handling, `/workspace`, forking, and absolute imports (`documentation/main/PROJECT_BUILD_MANIFEST.md:525-551`). Core route and store implementations exist (`product/tendril/api/main.py:27-88`; `product/tendril/api/graph.py:76-290`).

The completion claim overstates reality:

- There are no DELETE routes, so the claimed node/edge CRUD set is incomplete (`product/tendril/api/main.py:27-88`).
- `add_edge()` validates only endpoint-node existence, not named ports, input cardinality, duplicate relations, self-loops, ordinary cycles, or supersedes invariants (`product/tendril/api/graph.py:116-142`). The persisted graph is therefore not structurally a DAG despite the P9 purpose (`documentation/main/PROJECT_BUILD_MANIFEST.md:533-541`).
- File error handling catches only `FileNotFoundError`; permission, directory, decoding, size, and containment failures remain uncontrolled (`product/tendril/api/graph.py:210-219`).
- Imports are written as top-level `from graph` and `from models`, not package-qualified absolute imports (`product/tendril/api/main.py:4-5`; `product/tendril/api/graph.py:8`). This works when the API directory itself is placed on `sys.path`, but does not support importing `product.tendril.api.main` as a package.

### 3.2 P10 Current-Focus Claim - PARTIAL

The manifest says the functional loop "spawn, edit, connect, cook, monitor, lock, fork" is implemented and identifies persistence, semantic edge typing, and composite nodes as next (`documentation/main/PROJECT_BUILD_MANIFEST.md:849-862`). The loop's code paths exist, including text/file/composite spawning, PATCH editing, named-port connections, cook, monitor creation, lock, and fork (`product/tendril/gui/main.gd:313-448`, `product/tendril/gui/main.gd:595-868`).

The claim is only partially true as a usable authoritative loop:

- Only composite input slots are enabled; monitor nodes declare `text_in` but render through the generic output-only branch (`product/tendril/gui/main.gd:135-164`, `product/tendril/gui/main.gd:184-191`, `product/tendril/gui/main.gd:837-843`).
- Text edits are sent but successful responses do not update `_node_data.content`; lock subsequently sends the stale cached value (`product/tendril/gui/main.gd:649-668`, `product/tendril/gui/main.gd:716-738`).
- Cook and monitor creation depend on one global `_cooking_node_id` and shared request objects (`product/tendril/gui/main.gd:15-27`, `product/tendril/gui/main.gd:807-868`).
- Semantic types persist but semantic noodle styles are absent; every visual connection uses plain `connect_node()` (`product/tendril/gui/main.gd:272-295`, `product/tendril/gui/main.gd:741-781`).
- Composite nodes are already implemented rather than merely "next," including dynamic input addition and template editing (`product/tendril/gui/main.gd:85-103`, `product/tendril/gui/main.gd:419-438`, `product/tendril/gui/main.gd:451-592`).
- Backend SQLite persistence already exists, so listing persistence as next is ambiguous unless this refers specifically to GUI movement/state correctness (`product/tendril/api/graph.py:11-35`, `product/tendril/api/graph.py:76-168`).

### 3.3 Additional V0 Architecture Gaps

- **LOD - MISSING:** every non-file, non-composite node immediately creates a heavy `TextEdit`; there is no zoom/focus thumbnail strategy (`product/tendril/gui/main.gd:155-164` versus architecture `tendril-v0-architecture.md:15-16`).
- **Semantic gravity - MISSING:** positions use the required `z: 0.0`, but there is no stable-node ground snapping or canopy/ground behavior (`product/tendril/gui/main.gd:385-438`, `product/tendril/gui/main.gd:829-843` versus architecture `tendril-v0-architecture.md:46-56`).
- **Extraction and Compression creation - MISSING:** titles and generic rendering support these types, but the canvas menu and spawn handlers create only Text, File Source, and Composite nodes (`product/tendril/gui/main.gd:242-250`, `product/tendril/gui/main.gd:313-382`, `product/tendril/gui/main.gd:385-438`).
- **Dynamic input removal - MISSING:** the architecture requires add/remove dynamic ports, while the GUI only adds inputs (`tendril-v0-architecture.md:21-26`; `product/tendril/gui/main.gd:451-527`).
- **Edge deletion - MISSING:** no API DELETE endpoint or GUI disconnection handler exists (`product/tendril/api/main.py:22-88`; `product/tendril/gui/main.gd:44-78`).
- **Locked file-source default - FAIL:** architecture says File Source spawns read-only/stable, but GUI creation omits `is_locked`, so the model default is false and the `LineEdit` remains editable (`tendril-v0-architecture.md:24-26`; `product/tendril/api/models.py:32-40`; `product/tendril/gui/main.gd:398-416`).
- **Thin-client authority - PARTIAL:** all durable mutations use HTTP, but optimistic/local rendering and missing synchronization allow divergence (`product/tendril/gui/main.gd:441-448`, `product/tendril/gui/main.gd:649-668`, `product/tendril/gui/main.gd:789-804`, `product/tendril/gui/main.gd:849-868`).

## 4. Required Backend Feature Ratings

### B1. SQLite Persistence - PASS

Evidence:

- `GraphStore` opens SQLite connections to a configured path and applies migrations (`product/tendril/api/graph.py:11-35`).
- Nodes and edges are inserted, read, updated, and hydrated from SQL rows (`product/tendril/api/graph.py:36-168`).
- Tables persist complete V0 node state and edge records (`product/tendril/api/migrations.sql:4-24`).
- The store now opens and closes a connection per serialized operation rather than retaining one global connection (`product/tendril/api/graph.py:14-29`).

Limitations not sufficient to reduce this specific presence rating:

- The default database path remains working-directory-relative (`product/tendril/api/graph.py:12-13`).
- Schema integrity remains weak: no foreign keys, semantic checks, lock checks, or edge uniqueness constraints (`product/tendril/api/migrations.sql:4-24`).

### B2. Partial PATCH Updates - PASS

Evidence:

- `NodePatch` makes every mutable node field optional (`product/tendril/api/main.py:8-15`).
- The endpoint passes only explicitly supplied, non-null fields (`product/tendril/api/main.py:40-49`).
- `GraphStore.update_node()` deep-copies the persisted node and applies only fields in that patch dictionary (`product/tendril/api/graph.py:98-114`).
- Locked nodes remain protected (`product/tendril/api/graph.py:99-101`).

Residual contract gaps:

- Explicit null cannot be represented because `exclude_none=True` discards it (`product/tendril/api/main.py:43-45`). This currently affects no field that is intentionally nullable.
- Edge PATCH still uses the complete `Edge` model even though only `semantic_type` is changed (`product/tendril/api/main.py:83-88`; `product/tendril/api/graph.py:144-159`).

### B3. Cycle Detection in `cook()` - PARTIAL

Evidence of implementation:

- Supersedes traversal now tracks visited nodes and raises `ValueError` on a loop (`product/tendril/api/graph.py:183-200`).
- Recursive composite traversal checks the active `visiting` set (`product/tendril/api/graph.py:202-227`).
- Cook converts `ValueError` to HTTP 400 (`product/tendril/api/main.py:60-67`).

Drift:

- Cycles are accepted and persisted during edge creation; detection happens only later if a cook reaches them (`product/tendril/api/graph.py:116-142`).
- Only composite evaluation enters `visiting`, so this is operator-specific recursion protection rather than general DAG enforcement (`product/tendril/api/graph.py:221-260`).
- There is no iterative traversal or depth bound; a deep valid chain can still raise `RecursionError` (`product/tendril/api/graph.py:202-263`).

### B4. `file_source` Disk Reading - PARTIAL

Evidence of implementation:

- Cook resolves a path from `content` or template and calls `Path.read_text()` (`product/tendril/api/graph.py:210-219`).
- Empty paths return empty text and missing paths return a stable error string (`product/tendril/api/graph.py:213-219`).

Drift:

- Only `FileNotFoundError` is handled. Permission errors, directories, decoding errors, oversized files, and other I/O failures escape (`product/tendril/api/graph.py:216-219`).
- Any readable process-local path can be requested; there is no workspace-root containment or authorization policy (`product/tendril/api/graph.py:213-217`).
- Synchronous file I/O is called directly from async API request handling (`product/tendril/api/main.py:60-67`; `product/tendril/api/graph.py:216-217`).

### B5. `/workspace` Endpoint - PASS

Evidence:

- `GET /workspace` returns `store.get_workspace()` (`product/tendril/api/main.py:78-80`).
- The store selects and converts all nodes and edges (`product/tendril/api/graph.py:161-168`).

Residual gap:

- There is no explicit response model or controlled handling for malformed persisted JSON (`product/tendril/api/main.py:78-80`; `product/tendril/api/graph.py:36-50`).

### B6. `/fork` Endpoint - PARTIAL

Evidence of implementation:

- `POST /nodes/{node_id}/fork` exists and maps missing nodes to 404 (`product/tendril/api/main.py:70-75`).
- The store deep-copies the node, creates a new ID, unlocks it, and creates a `supersedes` edge (`product/tendril/api/graph.py:270-290`).
- Cook follows outgoing supersedes edges (`product/tendril/api/graph.py:183-203`).

Drift:

- Node insertion and supersedes insertion use separate transactions and connections; failure can leave an unlinked fork (`product/tendril/api/graph.py:270-288`).
- Incoming dataflow is not copied. A forked composite retains its input declarations but receives no incoming edges, so supersedes rerouting leads to empty composite inputs (`product/tendril/api/graph.py:229-256`, `product/tendril/api/graph.py:270-290`).
- Generic edge creation and PATCH allow clients to create or repurpose supersedes edges without enforcing one successor or acyclic immutable history (`product/tendril/api/main.py:52-57`, `product/tendril/api/main.py:83-88`).
- If multiple successors exist, traversal chooses the first edge from an unordered query (`product/tendril/api/graph.py:173-176`, `product/tendril/api/graph.py:190-199`).

### B7. Semantic Edge Formatting, GREEN as Blockquotes - PARTIAL

Evidence of implementation:

- Edge semantic types are constrained to `narrative_context`, `stable_reference`, and `supersedes` (`product/tendril/api/models.py:43-56`).
- Composite cooking excludes supersedes and formats stable references differently (`product/tendril/api/graph.py:229-245`).

Drift:

- GREEN formatting uses `"> " + raw + "\n"`, which prefixes only the first line. A multiline stable value is not a complete Markdown blockquote (`product/tendril/api/graph.py:240-244`).
- Semantic metadata is not passed to a renderer; formatting is hardcoded in traversal (`product/tendril/api/graph.py:229-256`).
- RED is simply raw text, and there is no extensible semantic-template contract (`product/tendril/api/graph.py:241-255`).

## 5. Required Frontend Feature Ratings

### F1. Text Source Node UI - PARTIAL

Evidence of implementation:

- The canvas menu exposes Text Node creation (`product/tendril/gui/main.gd:313-323`).
- Creation posts `text_source` with 3D-ready `z: 0.0` position and `text_out` (`product/tendril/gui/main.gd:385-395`).
- Generic node rendering creates an inline `TextEdit`, saves on focus exit, and exposes an output slot (`product/tendril/gui/main.gd:155-164`, `product/tendril/gui/main.gd:649-663`).

Drift:

- The successful PATCH response does not update `_node_data.content` (`product/tendril/gui/main.gd:649-668`). Locking later sends stale cached content and can overwrite the latest edit (`product/tendril/gui/main.gd:716-738`).
- Request-start errors and transport `result` are ignored (`product/tendril/gui/main.gd:658-668`).
- There is no LOD replacement for the always-live `TextEdit` (`product/tendril/gui/main.gd:155-164`).

### F2. File Source Node UI with Path `LineEdit` - PARTIAL

Evidence of implementation:

- File Source appears in the canvas menu and has a dedicated create path (`product/tendril/gui/main.gd:313-323`, `product/tendril/gui/main.gd:398-416`).
- Rendering uses a path `LineEdit` and persists changes through node PATCH (`product/tendril/gui/main.gd:145-154`, `product/tendril/gui/main.gd:595-646`).
- Successful response data is synchronized back into local state and the widget (`product/tendril/gui/main.gd:625-646`).

Drift:

- Architecture says file sources spawn read-only/stable, but creation omits `is_locked`; the backend default is unlocked (`tendril-v0-architecture.md:24-26`; `product/tendril/api/models.py:32-40`; `product/tendril/gui/main.gd:398-416`).
- The same shared `_http_patch` object also has a permanent generic callback and serves lock/edge operations, leaving concurrency hazards (`product/tendril/gui/main.gd:15-22`, `product/tendril/gui/main.gd:65-66`, `product/tendril/gui/main.gd:612-622`).

### F3. Composite Text Node UI, Dynamic Ports and Template Editing - PARTIAL

Evidence of implementation:

- Composite creation declares `combined_text` and an empty template (`product/tendril/gui/main.gd:419-438`).
- Rendering creates an output row and named enabled input rows (`product/tendril/gui/main.gd:135-144`, `product/tendril/gui/main.gd:184-191`).
- Right-click actions expose Add Input Port and Edit Template for unlocked composites (`product/tendril/gui/main.gd:326-382`).
- Input addition validates non-empty/non-duplicate names locally, PATCHes the input array, synchronizes the response, and rebuilds rows (`product/tendril/gui/main.gd:451-527`).
- Template editing uses a multiline `TextEdit`, PATCHes properties, and synchronizes the response (`product/tendril/gui/main.gd:530-592`).
- Connections resolve visual indices to persisted named ports (`product/tendril/gui/main.gd:671-706`).

Drift:

- Dynamic removal is absent despite the architecture's add/remove requirement (`tendril-v0-architecture.md:21-26`; `product/tendril/gui/main.gd:451-527`).
- Port-name validity is only a frontend convention; the backend accepts empty, duplicate, whitespace, and template-hostile names (`product/tendril/api/models.py:14-15`; `product/tendril/api/main.py:8-15`).
- Rebuilding input rows does not explicitly remap or reconnect existing visual edges (`product/tendril/gui/main.gd:194-209`).

### F4. Node Locking/Baking and Visual Port Colors - PARTIAL

Evidence of implementation:

- Unlocked nodes expose Lock/Bake in the right-click menu (`product/tendril/gui/main.gd:326-337`).
- Lock sends `is_locked: true`; successful response updates local state and applies style (`product/tendril/gui/main.gd:716-738`).
- Locked style makes editors read-only, applies a green matte panel, labels the node `[BAKED]`, and recolors output and composite input ports (`product/tendril/gui/main.gd:212-239`).
- Initial port colors distinguish unlocked red from locked green (`product/tendril/gui/main.gd:134-164`).

Drift:

- Lock sends cached `_node_data.content`, which text edits do not update, so it can overwrite a recent edit (`product/tendril/gui/main.gd:649-668`, `product/tendril/gui/main.gd:716-722`).
- The architecture's live emissive/pulsing style and stable-node ground snapping are not implemented (`product/tendril/gui/main.gd:128-181`, `product/tendril/gui/main.gd:212-239`).
- Calling `_apply_locked_style()` more than once appends repeated `[BAKED]` text (`product/tendril/gui/main.gd:232-233`).

### F5. Node Forking with Supersedes Noodles - PARTIAL

Evidence of implementation:

- Double-clicking a locked node calls the backend fork endpoint (`product/tendril/gui/main.gd:352-355`, `product/tendril/gui/main.gd:784-786`).
- Successful response spawns an unlocked duplicate offset to the right and draws a connection from the original (`product/tendril/gui/main.gd:789-804`).

Drift:

- The fork's visual offset is not PATCHed, so backend position remains the original position (`product/tendril/gui/main.gd:796-804`; `product/tendril/api/graph.py:270-275`).
- The locally drawn supersedes connection is not added to `_edge_data` and receives no distinct metallic/silver style (`product/tendril/gui/main.gd:789-804`).
- The generic target node has no left input slot unless it is composite, so the raw index-zero visual connection does not reliably map to a valid displayed supersedes target (`product/tendril/gui/main.gd:135-164`, `product/tendril/gui/main.gd:803-804`).
- Backend fork integrity and composite dataflow defects remain as described in B6.

### F6. Monitor Node Spawning on Cook - PARTIAL

Evidence of implementation:

- A successful cook reads `compiled_text`, highlights provenance, shows a dialog, and calls monitor creation (`product/tendril/gui/main.gd:807-826`).
- The GUI posts a `monitor` node with `text_in`, no outputs, compiled content, and a right-offset position (`product/tendril/gui/main.gd:829-846`).
- It spawns the returned node and posts an edge from the cooked node to the monitor (`product/tendril/gui/main.gd:849-868`).

Drift:

- Monitor rendering falls into the generic branch, which ignores declared inputs and enables a right/output slot even though monitor outputs are empty (`product/tendril/gui/main.gd:155-164`, `product/tendril/gui/main.gd:837-843`).
- The visual connection is drawn before the edge POST succeeds, and the edge request has no callback, immediate-error check, or reconciliation (`product/tendril/gui/main.gd:856-868`).
- One global `_cooking_node_id` can associate overlapping cook or node-create responses with the wrong source (`product/tendril/gui/main.gd:27`, `product/tendril/gui/main.gd:807-868`).
- `_http_node` is shared with ordinary node creation, so monitor creation can collide with another spawn (`product/tendril/gui/main.gd:15-17`, `product/tendril/gui/main.gd:385-448`, `product/tendril/gui/main.gd:829-846`).

### F7. Semantic Edge Toggling through Right-Click Menu - PARTIAL

Evidence of implementation:

- The node right-click menu lists outgoing edges with RED/GREEN labels (`product/tendril/gui/main.gd:326-350`).
- Selection toggles `narrative_context` and `stable_reference`, PATCHes the backend edge, and updates local semantic data on success (`product/tendril/gui/main.gd:741-781`).

Drift:

- Supersedes is shown as GREEN because every non-RED type uses the GREEN label and toggles to RED, allowing provenance edges to be repurposed (`product/tendril/gui/main.gd:339-347`, `product/tendril/gui/main.gd:741-760`).
- No visual noodle style changes after toggle; all connections remain default GraphEdit lines (`product/tendril/gui/main.gd:272-295`, `product/tendril/gui/main.gd:772-779`).
- `_edge_data` is keyed by source/target node pair, so parallel edges overwrite one another (`product/tendril/gui/main.gd:288-295`).
- Edge PATCH still requires fabricated empty endpoint fields because the API uses the complete Edge request model (`product/tendril/gui/main.gd:754-769`; `product/tendril/api/main.py:83-88`).

### F8. Input-Port Enabled Fix Using `set_slot` - PARTIAL

Evidence of implementation:

- Composite input rows call `set_slot(..., true, ..., false, ...)`, enabling left-side target slots (`product/tendril/gui/main.gd:184-191`).
- Workspace hydration and connection creation resolve named ports instead of hardcoding `text_out`/`text_in` (`product/tendril/gui/main.gd:272-286`, `product/tendril/gui/main.gd:671-706`).

Drift:

- Only composites render enabled left slots. The generic branch still disables left and enables right for all Text, Extraction, Compression, and Monitor nodes regardless of declared port arrays (`product/tendril/gui/main.gd:135-164`).
- Monitor creation declares `text_in`, but the rendered monitor cannot expose it (`product/tendril/gui/main.gd:155-164`, `product/tendril/gui/main.gd:837-843`).
- The slot layout is still type-special-cased rather than generated from the API's named input/output arrays (`product/tendril/gui/main.gd:118-191`).

## 6. Prior Code-Review Bug Recheck

In this table, `api/` and `gui/` are exact paths relative to `product/tendril/`.

| # | Prior finding | Current state | Live evidence |
| --- | --- | --- | --- |
| 1 | Editing destroys unrelated persisted fields | **FIXED** | Optional `NodePatch`, `exclude_unset`, and merge update preserve omitted fields (`api/main.py:8-15`, `api/main.py:40-49`, `api/graph.py:98-114`). |
| 2 | Locking can erase latest text | **OPEN** | Text PATCH never updates `_node_data.content`; lock sends that stale value (`gui/main.gd:649-668`, `gui/main.gd:716-722`). The unrelated-field reset half is fixed, but latest text can still be overwritten. |
| 3 | Connection dragging has no valid targets | **PARTIALLY FIXED** | Composite inputs now enable left slots (`gui/main.gd:184-191`), but monitor and all generic nodes still use output-only slots (`gui/main.gd:135-164`). |
| 4 | Supersedes cycle hangs cooking | **FIXED** | `_resolve_supersedes()` tracks visited nodes and raises `ValueError`; endpoint maps it to 400 (`api/graph.py:183-200`, `api/main.py:60-67`). |
| 5 | Invalid edges persist | **OPEN** | `add_edge()` checks endpoint-node existence only; no port, cardinality, duplicate, self-loop, cycle, or supersedes validation (`api/graph.py:116-142`). |
| 6 | Forked composites lose dataflow | **OPEN** | Fork copies node only and creates supersedes; incoming edges are not copied (`api/graph.py:270-290`). Composite cook finds edges targeting the new ID (`api/graph.py:229-245`). |
| 7 | SQLite connection ownership unsafe | **FIXED** | Each lock-serialized context opens and closes its connection (`api/graph.py:14-29`). Synchronous calls still block async handlers, but the original global-unclosed/thread-ownership defect is removed. |
| 8 | Overlapping UI operations misroute callbacks | **OPEN** | Request objects remain shared by category, callbacks are often connected after dispatch, `_http_patch` has permanent and temporary callbacks, and cook identity is global (`gui/main.gd:15-27`, `gui/main.gd:65-66`, `gui/main.gd:385-438`, `gui/main.gd:612-622`, `gui/main.gd:807-868`). |
| 9 | Deep DAG can crash cooking | **OPEN** | Recursive `_cook_node()` remains unbounded and `RecursionError` is not mapped (`api/graph.py:202-263`, `api/main.py:60-67`). |
| 10 | Shared subgraphs repeat work | **OPEN** | No result memo exists; every matching input recursively calls `_cook_node()` (`api/graph.py:229-245`). |
| 11 | File sources expose local files | **OPEN** | Arbitrary `Path(file_path).read_text()` with only `FileNotFoundError` handling remains (`api/graph.py:210-219`). |
| 12 | Duplicate IDs return 500 | **OPEN** | Client IDs remain accepted and `sqlite3.IntegrityError` is not caught by create routes (`api/models.py:32-33`, `api/models.py:50-51`, `api/graph.py:76-87`, `api/graph.py:116-142`, `api/main.py:27-29`, `api/main.py:52-57`). |
| 13 | Multiple superseding nodes nondeterministic | **OPEN** | Generic edges permit multiple successors and resolver takes the first unordered fetched edge (`api/graph.py:173-199`). |
| 14 | Edge toggling can rewrite provenance | **OPEN** | Generic edge PATCH changes any edge semantic type; GUI treats supersedes as non-RED and toggles it to RED (`api/main.py:83-88`, `api/graph.py:144-159`, `gui/main.gd:339-347`, `gui/main.gd:741-769`). |
| 15 | Positions are not durable | **OPEN** | No movement signal/PATCH exists; fork offset changes response JSON only (`gui/main.gd:44-78`, `gui/main.gd:789-804`). |
| 16 | Parallel edges disappear from frontend | **OPEN** | `_edge_data` remains keyed by `source_node_id + "|" + target_node_id` (`gui/main.gd:288-295`). |
| 17 | Monitor can show nonexistent edge | **OPEN** | GUI connects before unobserved edge POST result; no callback or refresh follows (`gui/main.gd:849-868`). |
| 18 | GREEN multiline formatting incomplete | **OPEN** | Only one `"> "` prefix is prepended to the whole raw string (`api/graph.py:240-244`). |
| 19 | Cook hardcodes operator behavior | **OPEN** | One nested `_cook_node()` branches directly on every node type (`api/graph.py:202-260`). |
| 20 | Error semantics/UI recovery inconsistent | **OPEN** | Edge missing endpoints still map to 400, duplicate IDs remain uncaught, raw exception strings are returned, and GUI generally prints errors (`api/main.py:40-88`; `gui/main.gd:253-260`, `gui/main.gd:666-668`, `gui/main.gd:709-712`). |
| 21 | DB path/backend URL hardcoded | **OPEN** | Relative `tendril.db` default and fixed localhost URL remain (`api/graph.py:12-13`; `gui/main.gd:3`). |

Summary: 3 FIXED, 1 PARTIALLY FIXED, 17 OPEN.

## 7. Feature Rating Summary

| Area | Feature | Rating |
| --- | --- | --- |
| Backend | SQLite persistence | PASS |
| Backend | Partial PATCH updates | PASS |
| Backend | Cycle detection in `cook()` | PARTIAL |
| Backend | `file_source` disk reading | PARTIAL |
| Backend | `/workspace` endpoint | PASS |
| Backend | `/fork` endpoint | PARTIAL |
| Backend | Semantic edge formatting, GREEN blockquotes | PARTIAL |
| Frontend | Text Source Node UI | PARTIAL |
| Frontend | File Source Node UI with path `LineEdit` | PARTIAL |
| Frontend | Composite Text Node UI with dynamic ports/template | PARTIAL |
| Frontend | Node Locking/Baking and port colors | PARTIAL |
| Frontend | Node Forking with supersedes noodles | PARTIAL |
| Frontend | Monitor Node spawning on Cook | PARTIAL |
| Frontend | Semantic Edge Toggling through right-click menu | PARTIAL |
| Frontend | Input-port enabled `set_slot` fix | PARTIAL |

Totals: 3 PASS, 12 PARTIAL, 0 FAIL, 0 MISSING.

## 8. Recommended Correction Order

These are findings, not work authorized by this audit:

1. Fix stale text synchronization before lock and redesign request ownership so each operation has bound context and checked dispatch/result handling.
2. Enforce edge, port, cardinality, cycle, and supersedes invariants transactionally; make fork atomic and preserve composite dataflow.
3. Render every GraphNode slot from authoritative named input/output arrays, including monitor input-only behavior.
4. Persist movement and fork positions; reconcile node/edge state from successful backend responses or workspace refreshes.
5. Implement complete semantic behavior: multiline GREEN blockquotes, protected supersedes semantics, and distinct RED/GREEN/supersedes noodle styles.
6. Add controlled file-root and I/O policy, iterative or bounded cooking, memoization, and API error normalization.
7. Complete remaining V0 architecture gaps: Extraction/Compression spawn actions, input removal, edge deletion, LOD, and semantic gravity.

## 9. Verification

- All seven requested backend features are rated with exact source references.
- All eight requested frontend features are rated with exact source references.
- All 21 prior code-review findings are individually rechecked.
- Manifest/architecture drift beyond the requested checklist is recorded separately.
- This execution modified no code and no accepted documentation.
- Runtime behavior was not tested; all conclusions are static source findings.

## 10. Audit Result

PASS

The comprehensive read-only audit and detailed drift report were completed. PASS describes completion of the audit task, not conformance of the implementation; the implementation itself remains materially PARTIAL relative to the V0 plan.
