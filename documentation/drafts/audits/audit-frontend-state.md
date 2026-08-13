# Frontend State and Signals Audit

## Audit Scope

Audited artifacts:

- `product/tendril/gui/main.gd` (914 lines)
- `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md` (78 lines)

This is a static, read-only code audit. No fixes were implemented and the Godot client was not executed. The architecture's governing frontend constraint is the thin-client mandate at `tendril-v0-architecture.md:15`: Godot is a projection of backend API state, with state changes dispatched through `HTTPRequest`. Position payloads must include X/Y and `z: 0.0` (`tendril-v0-architecture.md:49`), and composite operators must support dynamic input addition and removal (`tendril-v0-architecture.md:21-23`).

## Severity Scale

- **Critical:** Immediate data loss, security impact, or application-wide failure under ordinary operation.
- **High:** Credible backend/UI divergence, incorrect graph mutation, or data loss under common concurrent actions.
- **Medium:** Defect requiring a particular failure path or interaction pattern, or a material reliability/memory risk.
- **Low:** Limited correctness or UX impact with straightforward recovery.

No Critical finding was identified in the inspected code.

## Executive Assessment

`main.gd` correctly creates a distinct `HTTPRequest` node for each operation and normally frees it after completion. This avoids the Godot error caused by reusing an `HTTPRequest` while it is busy. The more serious collision surface is application state: requests are not versioned, serialized, or associated with a workspace generation, so valid callbacks can complete out of order and apply stale results.

The frontend is not consistently a projection of authoritative backend state. Text and node positions change visually before PATCH confirmation, several successful callbacks trust requested values rather than response values, and failures generally print an error without restoring or reloading state. The most consequential concrete path is text editing followed by locking: successful text PATCHes never update `_node_data[...]["content"]`, while lock PATCHes send that stale cached content back to the backend.

Signal connections are not visibly connected multiple times to the same live control. Global signals are connected once in `_ready()`, and per-node signals are connected once when each new control is constructed. Duplicate API calls can still arise from signal behavior because text `focus_exited` does not check whether content changed, teardown can force focus loss, and no operation has an in-flight guard.

## State Model

The script maintains several overlapping state layers:

| State | Definition | Role and risk |
| --- | --- | --- |
| `_node_data` | `main.gd:28` | Intended backend snapshot for ports, properties, type, lock state, content, and position. It is only partially updated by callbacks and can become stale. |
| `_textedits` | `main.gd:29` | Live `TextEdit` controls keyed by node ID. Their text can differ from `_node_data` and the backend. |
| `_lineedits` | `main.gd:30` | Live file-path controls keyed by node ID. Responses write back into these controls without request ordering. |
| `_graphnodes` | `main.gd:31` | Live `GraphNode` controls keyed by node ID. Nodes move immediately, before persistence succeeds. |
| `_edge_data` | `main.gd:32`, `main.gd:296` | Partial edge snapshot keyed only by source and target node IDs, not ports or edge ID. Parallel edges collide. |
| `_pending_position_saves` | `main.gd:33` | Latest drag position per node for the current move gesture. It is cleared when requests are sent, not when persistence succeeds. |
| `_context_node_id` and dialog IDs | `main.gd:16`, `main.gd:22`, `main.gd:26` | Shared mutable targets for menus/dialogs. They are not request identities. |
| `_cooking_node_id` | `main.gd:18` | A single global identity shared by every concurrent cook and monitor request. This causes concrete cross-request attribution errors. |

## Findings

### F-01: Overlapping workspace fetches can replace newer UI state with an older response

- **Severity:** High
- **Lines:** `main.gd:84-85`, `main.gd:260-303`, `main.gd:733-737`
- **Area:** HTTP lifecycle, state desynchronization

Every successful edge creation starts `fetch_workspace()`, and there is no generation counter, cancellation, serialization, or stale-response check. If two GET requests overlap, whichever callback runs last calls `_clear_graph()` and becomes the displayed state, even if that response represents an earlier snapshot. The clear/rebuild also replaces all control instances while unrelated PATCH, lock, fork, monitor, or cook callbacks remain in flight. Those callbacks can subsequently mutate dictionaries or controls belonging to the newer render generation.

This conflicts with the backend-authoritative projection flow because callback arrival order, rather than backend version or request intent, determines the rendered snapshot.

### F-02: Successful text PATCHes never update the cached content used by later operations

- **Severity:** High
- **Lines:** `main.gd:625-646`, `main.gd:740-762`
- **Area:** State desynchronization

`_on_textedit_focus_exited()` sends the current `TextEdit.text`, but `_on_patch_response()` only logs failures and never stores the confirmed content in `_node_data`. `_lock_node()` later constructs its request from `_node_data[node_id]["content"]`. A normal edit, focus loss, successful PATCH, and immediate lock can therefore send the pre-edit content in the lock PATCH and overwrite the user's confirmed edit. Concurrent processing makes the result worse: if lock reaches the backend first, the text PATCH can be rejected because the node is now locked; if text reaches it first, the stale lock body can restore old content.

This is a concrete data-loss path, not merely a stale display risk.

### F-03: Failed text and position PATCHes leave optimistic UI state in place

- **Severity:** High
- **Lines:** `main.gd:625-646`, `main.gd:648-693`
- **Area:** State desynchronization, position persistence

Text is edited directly in the live `TextEdit`, and a node is moved directly by `GraphEdit`, before backend confirmation. On a non-200 response, both callbacks only print an error and return. There is no rollback to `_node_data`, no authoritative refetch, no visible dirty/error state, and no retry. After failure, the canvas can show text or position that does not exist in the backend. For position failures, the pending save has already been discarded at `main.gd:660`, so there is no automatic later retry.

### F-04: Concurrent cook requests use one mutable global node identity

- **Severity:** High
- **Lines:** `main.gd:836-844`, `main.gd:847-879`, `main.gd:882-901`
- **Area:** HTTP async collision, state desynchronization

`_cook_node()` overwrites `_cooking_node_id` for every request, but the cook callback is not bound to the requested node ID. `_spawn_monitor_node()` and the later monitor-created callback both read the current global value. If node A and node B are cooked before A's monitor workflow completes, A's compiled result can be positioned beside B and connected from B. The monitor POST introduces a second asynchronous interval during which the global can change again.

The resulting monitor node content, position, visual noodle, and backend edge can all be attributed to different source nodes.

### F-05: Composite PATCHes can lose updates and callbacks can apply stale composite state

- **Severity:** High
- **Lines:** `main.gd:462-484`, `main.gd:487-511`, `main.gd:531-546`, `main.gd:549-572`
- **Area:** Composite logic, HTTP async collision

Both add-input and edit-template operations PATCH complete copies of `inputs` and `properties` derived from the current `_node_data` snapshot. Neither marks an operation in flight. Two rapid input additions can each start from the same old input array, so the backend's later full-array write can discard the other addition. An input addition and template edit can similarly overwrite each other's properties or inputs. Their callbacks are also unversioned, so an older response arriving later can replace newer `_node_data` and rebuild older ports.

This is especially risky because the UI intentionally waits for success before adding a composite row, but request concurrency defeats that otherwise conservative behavior.

### F-06: Fork rendering draws a data connection without resolving valid named ports

- **Severity:** High
- **Lines:** `main.gd:818-833`
- **Area:** Composite/port logic, state desynchronization

After the backend fork succeeds, the frontend directly calls `connect_node(original_id, 0, new_id, 0)`. It does not inspect named ports, validate the target slot, store the returned supersedes edge in `_edge_data`, or fetch authoritative workspace state. Text-source and file-source nodes have zero inputs, so target port 0 does not exist. For composite nodes, target port 0 is a data input, but the architecture defines a fork relationship as a distinct `supersedes` edge rather than an ordinary context-flow connection (`tendril-v0-architecture.md:40-44`, `tendril-v0-architecture.md:56`).

This bypasses the otherwise correct named-port guard in `_on_connection_request()` and can attempt to draw a noodle to a non-existent or semantically wrong port.

### F-07: Rebuilding composite rows does not reconcile existing noodles

- **Severity:** High
- **Lines:** `main.gd:200-215`, `main.gd:500-511`
- **Area:** Composite/port logic

`_rebuild_composite_input_rows()` removes and recreates input-row controls, but it never inspects or disconnects GraphEdit connections targeting removed, renamed, reordered, or now-out-of-range input indices. Adding only at the end preserves old indices in the simplest case. However, the callback explicitly accepts the backend's returned input array, which may differ from the requested array, and concurrent callbacks can restore older arrays. Existing visual connections can therefore point at a different named input or a slot that no longer exists.

New user-drawn connections are guarded by `_port_name_at()` (`main.gd:696-720`), but that guard does not repair existing connections after dynamic port changes.

### F-08: Dynamic composite input removal is absent

- **Severity:** Medium
- **Lines:** `main.gd:5-13`, `main.gd:341-344`, `main.gd:439-511`
- **Area:** Composite/port logic

The architecture requires users to dynamically add and remove named input ports (`tendril-v0-architecture.md:21-23`). The menu and handlers implement only add-input and template-edit operations. There is no remove-port menu action, request, or connection cleanup path. This is a missing V0 behavior rather than a leak by itself, but it also means the code has never established safe noodle cleanup semantics for port deletion.

### F-09: Parallel edges between the same node pair overwrite each other in local state

- **Severity:** High
- **Lines:** `main.gd:295-302`, `main.gd:346-354`, `main.gd:765-775`
- **Area:** State desynchronization, composite logic

`_edge_data` uses `source_node_id + "|" + target_node_id` as its key. Dynamic named ports permit multiple valid edges between the same two nodes, but later edges overwrite earlier entries regardless of source port, target port, or edge ID. GraphEdit may render every connection loaded at `main.gd:292-293`, while context menus and semantic toggling can see only one. The visual graph and local edge metadata therefore disagree.

### F-10: Edge toggle requests send blank endpoint and port identities

- **Severity:** High
- **Lines:** `main.gd:778-805`
- **Area:** State integrity

The edge PATCH body includes empty `source_node_id`, `source_port_name`, `target_node_id`, and `target_port_name` values solely to change `semantic_type`. If the backend treats those fields as replacement values, the request corrupts the edge; if it validates them, the toggle fails. On success, the callback ignores the response body and writes the requested type into local state, so backend canonicalization is not reflected.

The local semantic values also use `narrative_context` and `stable_reference` (`main.gd:299`, `main.gd:727`, `main.gd:771-784`), while the architecture specifies `text`, `memory_consolidation`, and `supersedes` (`tendril-v0-architecture.md:37-44`, `tendril-v0-architecture.md:53-56`). This is an explicit contract drift.

### F-11: In-flight HTTPRequest nodes have no timeout and can remain indefinitely

- **Severity:** Medium
- **Lines:** `main.gd:51-68`, `main.gd:71-81`
- **Area:** HTTP lifecycle, memory retention

The normal ownership pattern is sound: each call creates a new request, adds it as a child, uses a one-shot completion connection, frees it on request-start failure, and frees it after completion. Requests are never reused while busy, so there is no same-node waiting-state collision.

However, no timeout is configured. A request that starts successfully but never completes remains a child indefinitely, retaining its bound callback arguments and any copied arrays/dictionaries. Repeated stalled requests can accumulate nodes and retained state. The generic helper also does not invoke the operation callback when `request.request()` fails to start, so optimistic operations receive no operation-specific recovery path.

### F-12: Cook dialogs leak when dismissed without confirmation

- **Severity:** Medium
- **Lines:** `main.gd:904-914`
- **Area:** Memory leak, signal handling

Every successful cook creates and adds a new `AcceptDialog`. The dialog is queued for deletion only by its `confirmed` signal. Closing through cancel, Escape, or the window close action does not emit `confirmed`; the hidden dialog remains a child and retains its label and potentially large compiled text. Repeated non-confirm dismissal accumulates controls and text memory.

### F-13: Position persistence is correctly shaped but is not fully authoritative or durable

- **Severity:** Medium
- **Lines:** `main.gd:648-693`
- **Area:** Position persistence

The drag-end batching is correctly structured for one movement gesture: `dragged` stores the latest `to` value per node, and `end_node_move` sends one PATCH per pending node. The payload correctly uses graph-space X and Y and hardcodes Z to `0.0` at `main.gd:664-666`, matching the architecture contract.

The callback nevertheless records the requested vector instead of parsing the backend response. Any server normalization is ignored. Multiple drag gestures can also leave multiple position PATCHes in flight; callbacks update `_node_data` in response order, not operation order. Finally, `_clear_graph()` does not clear `_pending_position_saves` (`main.gd:109-119`), so a workspace rebuild during a drag can later send a pending position associated with a replaced control generation.

### F-14: Text focus signals cause redundant PATCHes and may PATCH during graph teardown

- **Severity:** Medium
- **Lines:** `main.gd:109-119`, `main.gd:161-169`, `main.gd:625-640`
- **Area:** Signal handling, duplicate API calls

Each `TextEdit.focus_exited` is connected only once, but its handler sends a PATCH unconditionally. Unlike the file-path handler's equality check at `main.gd:583-585`, merely focusing and leaving unchanged text causes another API call. A node can be refocused while its prior PATCH is still in flight, creating duplicate or out-of-order writes.

`_clear_graph()` removes focused controls without disconnecting or suppressing `focus_exited`. If Godot emits focus loss during removal, a workspace refresh can dispatch a text PATCH from the control being destroyed while the authoritative graph is being rebuilt. Because text content is not compared to `_node_data`, even unchanged teardown is capable of creating unnecessary writes.

### F-15: File-path responses can overwrite newer local edits out of order

- **Severity:** Medium
- **Lines:** `main.gd:575-623`
- **Area:** State desynchronization, signal handling

The file-path handler correctly avoids a PATCH when the control matches cached content. It does not prevent a second changed value from being sent while the first is pending. Each callback writes its own returned/requested path into both `_node_data` and the live `LineEdit`. A slower older response can therefore replace a newer value in the control and cache. No sequence number links the response to the latest edit.

### F-16: Successful callbacks often trust requested values rather than authoritative response state

- **Severity:** Medium
- **Lines:** `main.gd:500-510`, `main.gd:562-572`, `main.gd:613-622`, `main.gd:677-693`, `main.gd:796-803`
- **Area:** State desynchronization

Composite and file callbacks fall back to requested values when a 200 response is invalid or incomplete; position ignores the response body entirely; edge toggle applies the requested type rather than the returned edge. A transport-level success code is consequently treated as sufficient authority even when the returned representation cannot be established. This weakens the thin-client contract and can preserve a local state the backend did not accept exactly.

### F-17: Repeated lock responses can apply locked styling more than once

- **Severity:** Low
- **Lines:** `main.gd:218-246`, `main.gd:740-762`
- **Area:** Signal/action idempotency

There is no in-flight lock guard. Two rapid lock actions can both succeed and call `_apply_locked_style()`, which appends `" [BAKED]"` every time and creates a new `StyleBoxFlat` each time. The old override should be released when replaced, so this is not a persistent stylebox leak, but the title mutation is non-idempotent and visibly duplicates state.

## Signal Connection Assessment

No direct duplicate signal connection bug was found in the inspected construction paths:

- `_ready()` connects `id_pressed`, `connection_request`, `popup_request`, and `end_node_move` once at `main.gd:36-48`.
- Composite dialog `confirmed` signals are connected once when the dialogs are created at `main.gd:88-106`.
- Every `GraphNode`, `TextEdit`, and `LineEdit` is newly instantiated before its per-node signal is connected at `main.gd:131-171`.
- `_clear_graph()` frees old node/control instances and clears their lookup dictionaries at `main.gd:109-119`; it does not reconnect signals on an existing instance.
- Dynamically rebuilt composite input rows are labels and have no custom signal connections (`main.gd:190-213`).

The signal-related defects are instead redundant event-triggered requests, focus-loss effects during teardown, absence of in-flight guards, and global mutable callback context.

## Composite Port Safety Assessment

New user-drawn noodles receive a valid local safety check. `_port_name_at()` rejects out-of-range indices, and `_on_connection_request()` refuses to POST if either named port cannot be resolved (`main.gd:696-730`). Workspace loading similarly connects an edge only if both named ports exist (`main.gd:279-293`).

That protection is incomplete because fork rendering bypasses it, dynamic rebuilds do not reconcile old noodles, removal is not implemented, and `_edge_data` cannot represent parallel named-port edges. The UI therefore prevents one class of new invalid connection but does not maintain that invariant as ports and graph state evolve.

## HTTPRequest Lifecycle Conclusion

- Dynamic instantiation: **Yes**, one node per request at `main.gd:58`.
- Same-node reuse while waiting: **No**; the helper does not reuse HTTPRequest nodes.
- Free on start failure: **Yes**, at `main.gd:66-68`.
- Free on completion: **Yes**, at `main.gd:71-81`, after callback dispatch.
- One-shot completion signal: **Yes**, at `main.gd:60-63`.
- Timeout/cancellation: **No**, producing indefinite retention risk for stalled requests.
- Application-level collision protection: **No**; operation identities, versions, generations, and in-flight guards are absent.

## Position Persistence Conclusion

Drag-end batching and payload shape are correct. The latest `dragged` position is retained per moved node and sent when `end_node_move` fires, with exact `x`, `y`, and `z: 0.0` fields. It is gesture-end batching rather than a timer debounce, which is appropriate for avoiding a PATCH on every drag signal.

Persistence is still unreliable on failure or overlap: the UI is optimistic, pending state is discarded before confirmation, callbacks can arrive out of order, response coordinates are ignored, and workspace rebuild does not clear pending drag data.

## Prioritized Remediation Direction

No remediation was implemented. Based on impact, the first design decisions should address:

1. Per-operation request identity/generation and stale callback rejection, especially workspace, cook/monitor, composite, and position flows.
2. A single backend-authoritative PATCH reconciliation rule, including explicit failure rollback/refetch behavior.
3. Correct synchronization of text content before locking so a lock cannot restore stale content.
4. Named-port/edge identity throughout rendering, fork handling, parallel-edge storage, and composite rebuild cleanup.
5. Request and dialog lifetime limits.

## Audit Result

**PASS**: The requested static audit was completed and covers HTTP request lifecycle, state desynchronization, signal connections, position persistence, and composite port behavior. PASS means the audit deliverable was produced; it does not mean the frontend is defect-free. The audit identified 17 findings: 9 High, 7 Medium, 1 Low, and 0 Critical.
