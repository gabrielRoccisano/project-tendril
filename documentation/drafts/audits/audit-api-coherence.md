# Tendril V0 API and Code Coherence Audit

## Audit Result

**FAIL**

The backend is structurally close to the V0 node and edge design, but it does not satisfy the authoritative semantic-type contract, does not atomically fork nodes, and has concurrency and error-handling gaps that can violate locked-node immutability or surface ordinary conflicts as server errors. The recursive cook path detects direct dataflow cycles and follows simple `supersedes` chains, but malformed or ambiguous graphs are not handled robustly.

## Scope And Method

Compared the API implementation in:

- `product/tendril/api/main.py`
- `product/tendril/api/graph.py`
- `product/tendril/api/models.py`
- `product/tendril/api/migrations.sql`

against `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, especially the functional node model, cook rules, semantic types, immutability/forking rules, spatial contract, and Node Object JSON example.

Ratings mean:

- **PASS:** implementation matches the specified behavior for the cited concern.
- **PARTIAL:** core behavior exists, but an important contract or failure path is incomplete.
- **FAIL:** implementation contradicts or cannot guarantee the specified behavior.

## Findings

### Critical

#### F-01: Authoritative edge semantic types are rejected and legacy names remain active

**Rating: FAIL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:37-38` requires `text` and `memory_consolidation`.
- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:53-56` repeats `text`, `memory_consolidation`, and `supersedes` as the edge styles.
- Model: `product/tendril/api/models.py:43-47` instead accepts only `narrative_context`, `stable_reference`, and `supersedes`.
- Cook renderer: `product/tendril/api/graph.py:247-250` applies GREEN formatting only to `stable_reference`.

Requests using either authoritative semantic type fail Pydantic validation before reaching storage. Conversely, legacy values prohibited by the current architecture are accepted and persisted. Even if a `memory_consolidation` value already existed in SQLite, the cook implementation would not render it as GREEN. This is direct API and execution-contract drift.

**Required direction, not implemented by this audit:** Replace legacy values with `text` and `memory_consolidation`, and make the cook renderer branch on `memory_consolidation`.

#### F-02: Locked-node mutation is vulnerable to a check/write race

**Rating: FAIL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:40-43` requires backend-enforced immutable history and rejection of modification to locked node text.
- Implementation: `product/tendril/api/graph.py:98-101` reads and checks the node through `get_node()`.
- Implementation: `product/tendril/api/graph.py:112-119` acquires a separate lock and connection for the subsequent update.

`get_node()` releases `_lock` before `update_node()` later reacquires it for the write. Another request can lock the node between those operations, after which the stale first request overwrites it, potentially including content. The lock serializes individual database contexts but not the complete read-check-write invariant. Locked-node rejection works in a single-threaded sequence, but it is not strict under concurrent requests.

**Required direction, not implemented by this audit:** Perform the lock-state check and conditional update in one lock-held transaction, ideally using an update condition such as `WHERE id = ? AND is_locked = 0` and checking affected rows.

#### F-03: Fork creation and `supersedes` edge creation are not atomic

**Rating: FAIL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:40-44` defines forking as one backend operation that duplicates properties, unlocks the copy, and automatically creates the history edge.
- Implementation: `product/tendril/api/graph.py:276-281` reads the original and commits the new node via `add_node()`.
- Implementation: `product/tendril/api/graph.py:286-294` creates and commits the `supersedes` edge through a second `add_edge()` call.

The two writes use separate connections and transactions. If edge creation fails after node insertion, the API leaves an orphan fork with no history edge while returning an error. Concurrent modification of the original can also occur between the initial read and writes. This violates the operation's all-or-nothing integrity.

**Required direction, not implemented by this audit:** Insert the fork and history edge under one lock, one connection, and one transaction.

### High

#### F-04: `cook()` follows a simple `supersedes` chain but silently chooses one branch

**Rating: PARTIAL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:43-44` requires rerouting a superseded node to the superseding node.
- Implementation: `product/tendril/api/graph.py:189-206` repeatedly resolves an outgoing `supersedes` edge and detects cycles within that chain.
- Implementation: `product/tendril/api/graph.py:197-203` stops at the first matching edge.
- Schema: `product/tendril/api/migrations.sql:17-24` has no uniqueness rule limiting a node to one outgoing `supersedes` edge.

A single well-formed chain is routed correctly, including when reached from a dataflow edge. However, multiple outgoing history edges are legal in storage and resolution depends on unspecified SQLite row order. The current-state decision is then nondeterministic rather than rejected as an invalid history graph.

**Required direction, not implemented by this audit:** Enforce a single successor per superseded node or define and validate explicit branching semantics.

#### F-05: Supersedes rerouting does not retarget dataflow edge matching

**Rating: PARTIAL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:43-44` requires dynamic rerouting to the superseding node.
- Implementation: `product/tendril/api/graph.py:208-210` replaces the requested node ID with the superseding ID before cooking.
- Implementation: `product/tendril/api/graph.py:238-243` then looks for incoming edges whose `target_node_id` equals the resolved node ID.

If the originally requested composite node is superseded and the copied node has no duplicated incoming dataflow edges, the resolved fork is cooked with all inputs empty. The architecture says properties are copied, but does not explicitly say dataflow edges are copied or rewritten. Therefore the implementation does follow node history, yet it can discard the original upstream context when rerouting a composite. The contract needs either inherited incoming connections during cook or explicit edge duplication during fork.

#### F-06: Edge endpoint ports are not validated

**Rating: FAIL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:18-29` defines named input/output ports as the functional dataflow interface.
- Implementation: `product/tendril/api/graph.py:125-133` verifies only that endpoint nodes exist.
- Implementation: `product/tendril/api/graph.py:135-147` persists arbitrary source and target port names.

An edge may reference a nonexistent source output or target input. `cook()` silently ignores a nonexistent target port, while it never verifies the source port at all. This permits structurally invalid graphs and causes missing data to look like an ordinary unconnected input.

**Required direction, not implemented by this audit:** Validate both port names and their input/output direction when creating an edge.

#### F-07: Missing upstream nodes are not handled gracefully inside `cook()`

**Rating: PARTIAL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:34-35` requires missing/unconnected inputs to be handled gracefully as empty strings.
- Implementation: `product/tendril/api/graph.py:214` fetches every traversed node and propagates `KeyError` if it is absent.
- API mapping: `product/tendril/api/main.py:60-67` converts any cook `KeyError` to a generic root-level `404 node not found`.

Unconnected declared inputs correctly become empty strings at `graph.py:235-252`, which passes that part of the contract. Missing graph references should normally be prevented by edge creation and there is no deletion endpoint, but malformed or externally altered SQLite state causes the entire cook to fail rather than treating the input as empty. The API error also does not identify the missing upstream node.

#### F-08: Cycle handling can misclassify converging history/dataflow paths

**Rating: PARTIAL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:34-35` requires cycle detection.
- Implementation: `product/tendril/api/graph.py:189-206` detects loops confined to a `supersedes` chain.
- Implementation: `product/tendril/api/graph.py:208-214` checks the resolved node against the active dataflow recursion set.

Ordinary recursive cycles through composite-node inputs are detected correctly, and the active node is removed after successful traversal at `graph.py:254`. However, because aliases are resolved before the recursion check, a history edge that resolves an upstream node to an already-active composite is reported as a cycle even if the stored dataflow graph itself is acyclic. This may be the safest failure, but history/dataflow interaction is not validated separately and can produce ambiguous diagnostics.

### Medium

#### F-09: Node JSON has one extra top-level field relative to the specified shape

**Rating: PARTIAL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:58-77` specifies `id`, `type`, `is_locked`, `position`, `inputs`, `outputs`, and `properties`.
- Model: `product/tendril/api/models.py:32-40` includes all of those fields and additionally exposes top-level `content` at line 36.

The position and port structures match the JSON example: `Position3D` has `x`, `y`, and `z` at `models.py:8-11`, and `Port` has only `name` at `models.py:14-15`. `NodeProperties.template` also matches at `models.py:28-29`. No field from the displayed Node Object is missing, but `content` is an undocumented extra field and is operationally required by several node types in `graph.py:219-230`. The architecture's functional descriptions imply storage for user text but do not place it in the formal object shape, so either the contract or model is incomplete.

#### F-10: Pydantic models accept unspecified extra JSON fields silently

**Rating: PARTIAL**

**Evidence:**

- Contract: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:58-77` presents a concrete API state shape.
- Models: `product/tendril/api/models.py:8-62` and `product/tendril/api/main.py:8-15` do not configure `extra="forbid"`.

Under default Pydantic behavior, unknown request fields are ignored rather than rejected. The declared serialized shapes are stable, but malformed or drifted clients can believe unsupported fields were persisted. This weakens exact contract enforcement for Node, Edge, nested position/port/properties, and PATCH payloads.

#### F-11: `PATCH /edges/{id}` accepts a full Edge body but updates only one field

**Rating: FAIL**

**Evidence:**

- API: `product/tendril/api/main.py:83-88` declares the request body as a complete `Edge` and passes it to the store.
- Store: `product/tendril/api/graph.py:150-165` ignores every supplied field except `semantic_type`.

The endpoint requires clients to send IDs and endpoints that it silently discards. Its response is read back from storage, so it can differ materially from the accepted body without a validation error. No edge PATCH contract is documented in the architecture, but the implemented API is internally incoherent and prone to client mistakes.

#### F-12: Database constraint failures are not mapped to deliberate HTTP errors

**Rating: FAIL**

**Evidence:**

- API: `product/tendril/api/main.py:27-29` does not catch duplicate node IDs.
- API: `product/tendril/api/main.py:52-57` catches missing endpoint nodes but not duplicate edge IDs or other SQLite integrity errors.
- Storage: `product/tendril/api/graph.py:81-86` and `product/tendril/api/graph.py:135-147` can raise `sqlite3.IntegrityError` on duplicate primary keys.
- Schema: `product/tendril/api/migrations.sql:5` and `product/tendril/api/migrations.sql:18` define those primary keys.

Ordinary client conflicts can escape as unhandled 500 responses. The API should consistently translate storage conflicts to a documented 4xx response without exposing database exception text.

#### F-13: File-source error handling covers only one expected read failure

**Rating: PARTIAL**

**Evidence:**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:23-26` requires file-source cook behavior.
- Implementation: `product/tendril/api/graph.py:216-225` returns a stable marker for `FileNotFoundError` only.

Permission failures, directory paths, invalid encodings, and other `OSError`/`UnicodeError` cases propagate as unhandled server errors. Missing files are handled, but disk reading is not robust across normal operational failure modes.

#### F-14: SQLite does not enforce graph referential or semantic integrity

**Rating: PARTIAL**

**Evidence:**

- Schema: `product/tendril/api/migrations.sql:17-24` stores edge endpoints and semantic types as unconstrained text with no foreign keys or checks.
- Storage validation: `product/tendril/api/graph.py:125-147` checks node existence only at insertion time.

The application prevents missing endpoint nodes during ordinary edge creation, but the database cannot preserve that invariant against direct modification or future deletion code. It also cannot prevent unknown semantic types, self-inconsistent history edges, or more than one history successor. Pydantic currently provides semantic validation at API entry, but it validates the wrong vocabulary (F-01).

### Passing Controls

#### P-01: Declared V0 node types match the architecture

**Rating: PASS**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:23-29` lists text source, file source, composite text, extraction, compression, and monitor.
- Model: `product/tendril/api/models.py:18-25` declares exactly those six serialized node-type values.

#### P-02: Core Node Object nested shapes match

**Rating: PASS**

- Architecture: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:60-77` defines the core Node Object.
- Model: `product/tendril/api/models.py:8-15`, `product/tendril/api/models.py:28-40` includes every displayed field and matching nested `position`, port, and `properties.template` structures.

This PASS concerns presence and nested shape only; the undocumented extra `content` field remains F-09.

#### P-03: Unconnected composite inputs become empty strings

**Rating: PASS**

- Requirement: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:34-35`.
- Implementation: `product/tendril/api/graph.py:235-252` initializes each input to `""` and preserves that value when no matching edge exists.

#### P-04: Recursive dataflow cycle detection exists

**Rating: PASS**

- Requirement: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:34-35`.
- Implementation: `product/tendril/api/graph.py:187`, `product/tendril/api/graph.py:211-212`, and `product/tendril/api/graph.py:232-254` maintain an active recursion set for composite nodes and reject re-entry.

This PASS covers direct recursive dataflow cycles; supersedes ambiguity and mixed-path semantics remain F-04 and F-08.

#### P-05: Simple `supersedes` chains reroute to the current node and detect history loops

**Rating: PASS**

- Requirement: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:43-44`.
- Implementation: `product/tendril/api/graph.py:189-206` walks outgoing `supersedes` edges until the current node and rejects revisiting a history node.

This PASS assumes a single well-formed history successor; branching remains F-04.

#### P-06: Sequential PATCH requests reject every patch to a locked node

**Rating: PASS**

- Requirement: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:40-43` explicitly requires rejection of locked-node text modification.
- Implementation: `product/tendril/api/graph.py:98-101` rejects the patch before any field mutation.
- API: `product/tendril/api/main.py:40-49` maps the rejection to HTTP 409.

The implementation is stricter than the minimum wording because it rejects all fields, not only text. That strictness protects immutable history in sequential use. Concurrent enforcement remains F-02.

#### P-07: Forks deep-copy node state and unlock the new node

**Rating: PASS**

- Requirement: `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md:43`.
- Implementation: `product/tendril/api/graph.py:276-280` performs a deep model copy, gives it a new ID, and sets `is_locked` false.
- Implementation: `product/tendril/api/graph.py:286-293` constructs an original-to-new `supersedes` edge.

Property duplication and edge direction match the architecture. Transactional atomicity remains F-03.

#### P-08: SQL statements use parameter binding

**Rating: PASS**

- Implementation: `product/tendril/api/graph.py:81-85`, `product/tendril/api/graph.py:91-93`, `product/tendril/api/graph.py:114-119`, `product/tendril/api/graph.py:126-147`, and `product/tendril/api/graph.py:152-164` use `?` placeholders for all request-derived values.

No SQL injection path was identified in the audited code. Static migration execution at `graph.py:31-34` reads a bundled SQL file rather than user input.

#### P-09: Connections are closed deterministically

**Rating: PASS**

- Implementation: `product/tendril/api/graph.py:22-29` wraps each connection in a context manager whose `finally` block closes it.
- All audited database operations use `_connection()` at `graph.py:33`, `graph.py:79`, `graph.py:90`, `graph.py:112`, `graph.py:125`, `graph.py:151`, `graph.py:168`, and `graph.py:180`.

Connections are scoped per store operation, not literally one shared FastAPI request context. They are nevertheless opened on demand and closed on success or exception.

#### P-10: The SQLite lock protects individual connection contexts

**Rating: PASS**

- Implementation: `product/tendril/api/graph.py:12-15` creates one `threading.Lock` per `GraphStore`.
- Implementation: `product/tendril/api/graph.py:22-29` holds it for the complete lifetime of each connection and transaction context.

This safely serializes database contexts within the single global store instantiated at `product/tendril/api/main.py:18-19`. It does not make multi-context operations atomic (F-02 and F-03), and separate worker processes or separately instantiated stores would not share the lock.

## Contract Matrix

| Area | Rating | Contract status |
|---|---|---|
| Node fields | PARTIAL | All displayed fields exist; undocumented `content` is extra. |
| Nested position/ports/properties | PASS | Shapes match the V0 Node Object example. |
| Node types | PASS | All six V0 values match. |
| Semantic edge types | FAIL | Legacy values replace authoritative `text` / `memory_consolidation`. |
| Unconnected inputs | PASS | Empty strings are supplied. |
| Dataflow cycle detection | PASS | Recursive composite cycles are rejected. |
| Supersedes traversal | PARTIAL | Linear chains work; branching and connection inheritance are unresolved. |
| Missing-node handling | PARTIAL | Root 404 exists; malformed upstream references abort cook generically. |
| Locked-node rejection | PARTIAL | Sequential rejection works; concurrent check/write race breaks strictness. |
| Fork property duplication | PASS | Deep copy and unlock are correct. |
| Fork atomicity | FAIL | Node and edge commit separately. |
| SQL injection resistance | PASS | Request values are parameterized. |
| Connection lifecycle | PASS | Connections close in `finally`. |
| Thread lock use | PARTIAL | Individual contexts serialize; logical multi-step operations do not. |
| API/storage error mapping | FAIL | Integrity and several file I/O failures become unhandled 500s. |

## Conclusion

The backend demonstrates the intended V0 structure, but it is not coherent with the current architecture contract. The most immediate blocker is semantic vocabulary drift: current clients using `text` and `memory_consolidation` cannot create valid edges. The most serious integrity issues are non-atomic forking and the unlocked interval between lock-state checking and node update. Cook traversal is serviceable for a well-formed linear-history graph, but endpoint-port validation, history branching constraints, inherited composite connections, and malformed upstream references need explicit contracts and enforcement.

No fixes were implemented as part of this audit.
