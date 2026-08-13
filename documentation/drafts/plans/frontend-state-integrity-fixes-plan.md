# Frontend State Integrity Fixes Plan

Status: PROPOSED

## Scope

Modify only `product/tendril/gui/main.gd` in the implementation task that follows this plan. The frontend must render only backend-confirmed state. Do not change the backend contract in this task.

This plan addresses all nine High audit findings and the related Medium findings that affect stale callbacks, request failures, signal-triggered writes, and object lifetime.

## Invariants

- `_node_data` and `_edge_data` contain only backend-confirmed values.
- A response may update UI state only when it belongs to the current workspace generation and the latest revision for its resource.
- A failed request restores the control from the last confirmed cache value and shows a visible error.
- Workspace responses are accepted only in request order.
- Callback context is bound per request. Do not read mutable globals such as `_cooking_node_id` in asynchronous callbacks.
- Each live control has at most one connection for every signal used by the script.

## 1. Add Request State And Error Helpers

Remove `_cooking_node_id` and add these variables after the existing dictionaries. A revision is tracked per resource key; workspace revision also serves as the render generation.

```gdscript
var _workspace_revision := 0
var _applied_workspace_revision := 0
var _node_revisions: Dictionary = {}
var _edge_revisions: Dictionary = {}
var _suppress_editor_signals := false


func _next_node_revision(node_id: String) -> int:
	var revision := int(_node_revisions.get(node_id, 0)) + 1
	_node_revisions[node_id] = revision
	return revision


func _is_current_node_revision(node_id: String, revision: int) -> bool:
	return int(_node_revisions.get(node_id, 0)) == revision


func _next_edge_revision(edge_id: String) -> int:
	var revision := int(_edge_revisions.get(edge_id, 0)) + 1
	_edge_revisions[edge_id] = revision
	return revision


func _is_current_edge_revision(edge_id: String, revision: int) -> bool:
	return int(_edge_revisions.get(edge_id, 0)) == revision


func _request_failed(result: int, response_code: int) -> bool:
	return result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300


func _show_request_error(operation: String, result: int, response_code: int, body: PackedByteArray) -> void:
	var detail := body.get_string_from_utf8().strip_edges()
	if detail.is_empty():
		detail = "Transport result %d, HTTP status %d" % [result, response_code]
	var dialog := AcceptDialog.new()
	dialog.title = operation + " failed"
	dialog.dialog_text = detail
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free, CONNECT_ONE_SHOT)
	dialog.canceled.connect(dialog.queue_free, CONNECT_ONE_SHOT)
	dialog.popup_centered()
```

## 2. Make The HTTP Helper Deliver Start Failures

Replace `_send_api_request()` and `_on_api_request_completed()` with the following. Every callback receives `result`, `response_code`, and `body`, including a request that fails to start. This gives each operation one error/rollback path. Set `timeout` to avoid retained request nodes.

```gdscript
func _send_api_request(
	url: String,
	headers: Array,
	method: HTTPClient.Method,
	body: String = "",
	callback: Callable = Callable()
) -> void:
	var request := HTTPRequest.new()
	request.timeout = 15.0
	add_child(request)
	request.request_completed.connect(
		_on_api_request_completed.bind(request, callback),
		CONNECT_ONE_SHOT
	)

	var error := request.request(url, headers, method, body)
	if error != OK:
		if callback.is_valid():
			callback.call(error, 0, PackedStringArray(), PackedByteArray())
		request.queue_free()


func _on_api_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray,
	request: HTTPRequest,
	callback: Callable
) -> void:
	if callback.is_valid():
		callback.call(result, response_code, headers, body)
	request.queue_free()
```

## 3. Version Workspace Fetches And Suppress Teardown Writes

Replace `fetch_workspace()`. Update `_on_workspace_response()` to accept the bound revision and reject failed, stale, and malformed responses before calling `_clear_graph()`.

```gdscript
func fetch_workspace() -> void:
	_workspace_revision += 1
	var revision := _workspace_revision
	_send_api_request(
		BACKEND_URL + "/workspace",
		[],
		HTTPClient.METHOD_GET,
		"",
		_on_workspace_response.bind(revision)
	)


func _on_workspace_response(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray,
	revision: int
) -> void:
	if _request_failed(result, response_code):
		if revision == _workspace_revision:
			_show_request_error("Workspace refresh", result, response_code, body)
		return
	if revision != _workspace_revision or revision <= _applied_workspace_revision:
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if not json is Dictionary:
		_show_request_error("Workspace refresh", result, response_code, body)
		return

	_applied_workspace_revision = revision
	_suppress_editor_signals = true
	_clear_graph()
	# Keep the existing node and edge reconstruction loops here.
	_suppress_editor_signals = false
```

At the start of `_clear_graph()`, clear unsent drag data. Before freeing a node, disconnect per-node signals if they are connected. This prevents focus loss caused by teardown from issuing a PATCH.

```gdscript
func _clear_graph() -> void:
	_pending_position_saves.clear()
	_suppress_editor_signals = true
	for child in get_children():
		if child is GraphNode:
			_disconnect_node_signals(child)
			remove_child(child)
			child.queue_free()
	_node_data.clear()
	_textedits.clear()
	_lineedits.clear()
	_graphnodes.clear()
	_edge_data.clear()
	_suppress_editor_signals = false
```

## 4. Centralize Signal Connections And Teardown

Add these helpers. Replace direct `connect()` calls in `_spawn_graph_node()` with the matching helper. `is_connected()` makes refresh or future reuse safe. Disconnect callbacks before freeing dynamic controls.

```gdscript
func _connect_once(signal_object: Signal, callback: Callable) -> void:
	if not signal_object.is_connected(callback):
		signal_object.connect(callback)


func _disconnect_if_connected(signal_object: Signal, callback: Callable) -> void:
	if signal_object.is_connected(callback):
		signal_object.disconnect(callback)


func _disconnect_node_signals(gn: GraphNode) -> void:
	var node_id := str(gn.name)
	_disconnect_if_connected(gn.dragged, _on_graph_node_dragged.bind(node_id))
	_disconnect_if_connected(gn.gui_input, _on_graph_node_input.bind(node_id))
	var text_edit: TextEdit = _textedits.get(node_id)
	if text_edit != null:
		_disconnect_if_connected(text_edit.focus_exited, _on_textedit_focus_exited.bind(node_id))
	var line_edit: LineEdit = _lineedits.get(node_id)
	if line_edit != null:
		_disconnect_if_connected(line_edit.focus_exited, _on_file_path_focus_exited.bind(node_id))
```

Use these replacements during construction:

```gdscript
_connect_once(gn.dragged, _on_graph_node_dragged.bind(node_id))
_connect_once(te.focus_exited, _on_textedit_focus_exited.bind(node_id))
_connect_once(path_edit.focus_exited, _on_file_path_focus_exited.bind(node_id))
_connect_once(gn.gui_input, _on_graph_node_input.bind(node_id))
```

At the top of both focus handlers, add:

```gdscript
if _suppress_editor_signals:
	return
```

## 5. Confirm Text Before Updating Cache Or Visual State

Replace `_on_textedit_focus_exited()` and `_on_patch_response()`. The handler ignores unchanged text, binds the last confirmed content for rollback, and binds a per-node revision. The callback accepts only the latest request and only copies backend-returned content into the cache.

```gdscript
func _on_textedit_focus_exited(node_id: String) -> void:
	if _suppress_editor_signals:
		return
	var nd: Dictionary = _node_data.get(node_id, {})
	var text_edit: TextEdit = _textedits.get(node_id)
	if nd.is_empty() or text_edit == null or nd.get("is_locked", false):
		return
	var previous_content := str(nd.get("content", ""))
	var requested_content := text_edit.text
	if requested_content == previous_content:
		return
	var revision := _next_node_revision(node_id)
	var body := JSON.stringify({"type": nd.get("type", "text_source"), "content": requested_content})
	_send_api_request(
		BACKEND_URL + "/nodes/" + node_id,
		["Content-Type: application/json"],
		HTTPClient.METHOD_PATCH,
		body,
		_on_text_patched.bind(node_id, revision, previous_content)
	)


func _on_text_patched(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray,
	node_id: String,
	revision: int,
	previous_content: String
) -> void:
	if not _is_current_node_revision(node_id, revision):
		return
	if _request_failed(result, response_code):
		var text_edit: TextEdit = _textedits.get(node_id)
		if text_edit != null:
			_suppress_editor_signals = true
			text_edit.text = previous_content
			_suppress_editor_signals = false
		_show_request_error("Text update", result, response_code, body)
		return
	var response_node = JSON.parse_string(body.get_string_from_utf8())
	if not response_node is Dictionary or not response_node.has("content"):
		fetch_workspace()
		return
	_node_data[node_id]["content"] = str(response_node["content"])
	var text_edit: TextEdit = _textedits.get(node_id)
	if text_edit != null:
		_suppress_editor_signals = true
		text_edit.text = str(response_node["content"])
		_suppress_editor_signals = false
```

Before `_lock_node()` constructs its request, do not send cached content. Lock only the server-side flag, then use the full returned node to update `_node_data` and styling. Bind a revision and reject a stale lock response.

```gdscript
func _lock_node(node_id: String) -> void:
	if not _node_data.has(node_id) or _node_data[node_id].get("is_locked", false):
		return
	var revision := _next_node_revision(node_id)
	_send_api_request(
		BACKEND_URL + "/nodes/" + node_id,
		["Content-Type: application/json"],
		HTTPClient.METHOD_PATCH,
		JSON.stringify({"is_locked": true}),
		_on_lock_response.bind(node_id, revision)
	)
```

## 6. Roll Back And Version File And Position Updates

Apply the same revision rule to file paths. The failure branch restores `previous_path`; success requires a node response and updates both cache and control from that response.

```gdscript
var previous_path := str(nd.get("content", ""))
var revision := _next_node_revision(node_id)
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id,
	["Content-Type: application/json"],
	HTTPClient.METHOD_PATCH,
	body,
	_on_file_path_patched.bind(node_id, revision, previous_path)
)
```

Use this callback signature and outcome handling:

```gdscript
func _on_file_path_patched(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, node_id: String, revision: int, previous_path: String) -> void:
	if not _is_current_node_revision(node_id, revision):
		return
	var path_edit: LineEdit = _lineedits.get(node_id)
	if _request_failed(result, response_code):
		if path_edit != null:
			path_edit.text = previous_path
		_show_request_error("File path update", result, response_code, body)
		return
	var response_node = JSON.parse_string(body.get_string_from_utf8())
	if not response_node is Dictionary or not response_node.has("content"):
		fetch_workspace()
		return
	var confirmed_path := str(response_node["content"])
	_node_data[node_id]["content"] = confirmed_path
	if path_edit != null:
		path_edit.text = confirmed_path
```

In `_patch_node_position()`, capture the confirmed position before dispatch and bind a revision. Do not write the requested vector to `_node_data` before success.

```gdscript
var previous_position: Dictionary = _node_data.get(node_id, {}).get("position", {}).duplicate(true)
var revision := _next_node_revision(node_id)
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id,
	["Content-Type: application/json"],
	HTTPClient.METHOD_PATCH,
	body,
	_on_node_position_patched.bind(node_id, revision, previous_position)
)
```

Replace the position callback with this version. A GraphEdit drag is already visually applied by the engine; only a failed request needs a visual rollback.

```gdscript
func _on_node_position_patched(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, node_id: String, revision: int, previous_position: Dictionary) -> void:
	if not _is_current_node_revision(node_id, revision):
		return
	if _request_failed(result, response_code):
		var graph_node: GraphNode = _graphnodes.get(node_id)
		if graph_node != null:
			graph_node.position_offset = Vector2(previous_position.get("x", 0.0), previous_position.get("y", 0.0))
		_show_request_error("Position update", result, response_code, body)
		return
	var response_node = JSON.parse_string(body.get_string_from_utf8())
	if not response_node is Dictionary or not response_node.get("position") is Dictionary:
		fetch_workspace()
		return
	var confirmed_position: Dictionary = response_node["position"]
	_node_data[node_id]["position"] = confirmed_position.duplicate(true)
	var graph_node: GraphNode = _graphnodes.get(node_id)
	if graph_node != null:
		graph_node.position_offset = Vector2(confirmed_position.get("x", 0.0), confirmed_position.get("y", 0.0))
```

## 7. Serialize Composite Mutations Per Node

Add a queue so add-input and template edits cannot concurrently overwrite complete `inputs` and `properties` arrays. Each queued action derives its request only after the preceding server-confirmed response has updated `_node_data`.

```gdscript
var _composite_mutation_queues: Dictionary = {}
var _composite_mutation_active: Dictionary = {}


func _enqueue_composite_mutation(node_id: String, mutation: Dictionary) -> void:
	var queue: Array = _composite_mutation_queues.get(node_id, [])
	queue.append(mutation)
	_composite_mutation_queues[node_id] = queue
	_start_next_composite_mutation(node_id)


func _start_next_composite_mutation(node_id: String) -> void:
	if _composite_mutation_active.get(node_id, false):
		return
	var queue: Array = _composite_mutation_queues.get(node_id, [])
	if queue.is_empty():
		return
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.is_empty() or nd.get("is_locked", false):
		_composite_mutation_queues[node_id] = []
		return
	var mutation: Dictionary = queue.pop_front()
	_composite_mutation_queues[node_id] = queue
	var inputs: Array = nd.get("inputs", []).duplicate(true)
	var properties: Dictionary = nd.get("properties", {}).duplicate(true)
	if mutation["kind"] == "add_input":
		inputs.append({"name": mutation["port_name"]})
	else:
		properties["template"] = mutation["template"]
	_composite_mutation_active[node_id] = true
	var revision := _next_node_revision(node_id)
	var body := JSON.stringify({"type": "composite_text", "inputs": inputs, "properties": properties})
	_send_api_request(BACKEND_URL + "/nodes/" + node_id, ["Content-Type: application/json"], HTTPClient.METHOD_PATCH, body, _on_composite_mutation_response.bind(node_id, revision))


func _on_composite_mutation_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, node_id: String, revision: int) -> void:
	_composite_mutation_active.erase(node_id)
	if not _is_current_node_revision(node_id, revision):
		_start_next_composite_mutation(node_id)
		return
	if _request_failed(result, response_code):
		_show_request_error("Composite update", result, response_code, body)
		_start_next_composite_mutation(node_id)
		return
	var response_node = JSON.parse_string(body.get_string_from_utf8())
	if not response_node is Dictionary:
		fetch_workspace()
		return
	_node_data[node_id]["inputs"] = response_node.get("inputs", []).duplicate(true)
	_node_data[node_id]["properties"] = response_node.get("properties", {}).duplicate(true)
	_rebuild_composite_input_rows(node_id)
	_start_next_composite_mutation(node_id)
```

Replace both direct composite PATCH dispatches with `_enqueue_composite_mutation(node_id, {"kind": "add_input", "port_name": port_name})` or `_enqueue_composite_mutation(node_id, {"kind": "set_template", "template": _template_edit.text})`.

Before rebuilding rows, disconnect existing GraphEdit connections whose target port names are missing from the confirmed input list. Then rebuild rows and recreate only edges in `_edge_data` whose named ports still resolve. Do not preserve connections by slot index.

## 8. Preserve Edge Identity And Confirm Edge Changes

Store edges by edge ID, not source/target pair. Include both named ports in the stored value.

```gdscript
_edge_data[edge_id] = {
	"id": edge_id,
	"semantic_type": str(ed.get("semantic_type", "text")),
	"source_node_id": source_node_id,
	"source_port_name": str(ed.get("source_port_name", "")),
	"target_node_id": target_node_id,
	"target_port_name": str(ed.get("target_port_name", "")),
}
```

When the backend supports a semantic-only PATCH model, send only that property. Otherwise pass the confirmed stored endpoint values, never blank fields. Bind an edge revision and replace the local entry only with the returned edge object.

```gdscript
func _toggle_edge_type(edge_id: String, new_semantic_type: String) -> void:
	if not _edge_data.has(edge_id):
		return
	var revision := _next_edge_revision(edge_id)
	_send_api_request(
		BACKEND_URL + "/edges/" + edge_id,
		["Content-Type: application/json"],
		HTTPClient.METHOD_PATCH,
		JSON.stringify({"semantic_type": new_semantic_type}),
		_on_edge_toggle_response.bind(edge_id, revision)
	)


func _on_edge_toggle_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, edge_id: String, revision: int) -> void:
	if not _is_current_edge_revision(edge_id, revision):
		return
	if _request_failed(result, response_code):
		_show_request_error("Edge semantic update", result, response_code, body)
		return
	var response_edge = JSON.parse_string(body.get_string_from_utf8())
	if not response_edge is Dictionary:
		fetch_workspace()
		return
	_edge_data[edge_id] = response_edge.duplicate(true)
```

## 9. Bind Cook And Monitor Operations To Their Source Node

Remove `_cooking_node_id`. Bind `node_id` into every cook and monitor callback. A monitor must use the same bound source ID for placement and edge creation.

```gdscript
func _cook_node(node_id: String) -> void:
	_send_api_request(BACKEND_URL + "/nodes/" + node_id + "/cook", [], HTTPClient.METHOD_POST, "", _on_cook_response.bind(node_id))


func _on_cook_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, source_node_id: String) -> void:
	if _request_failed(result, response_code):
		_show_request_error("Cook", result, response_code, body)
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if not json is Dictionary:
		fetch_workspace()
		return
	_apply_provenance_highlights(json.get("traversed_node_ids", []))
	var compiled := str(json.get("compiled_text", ""))
	_show_cook_dialog(compiled)
	_spawn_monitor_node(source_node_id, compiled)


func _spawn_monitor_node(source_node_id: String, compiled_text: String) -> void:
	var source_graph_node: GraphNode = _graphnodes.get(source_node_id)
	var position := source_graph_node.position_offset if source_graph_node != null else Vector2.ZERO
	var body := JSON.stringify({"type": "monitor", "content": compiled_text, "position": {"x": position.x + 300.0, "y": position.y, "z": 0.0}, "inputs": [{"name": "text_in"}], "outputs": []})
	_send_api_request(BACKEND_URL + "/nodes", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body, _on_monitor_created.bind(source_node_id))
```

The monitor-created callback must use its `source_node_id` parameter, validate the source output name with `_port_name_at()`, and request `fetch_workspace()` after the edge POST succeeds. Do not call `connect_node()` directly for the monitor or fork flows.

## 10. Render Forks From The Authoritative Workspace

Replace `_on_fork_response()` behavior. On a 201 response, do not mutate the returned node position, call `_spawn_graph_node()`, or draw a noodle. Request one workspace refresh and let the backend-created `supersedes` edge render through the normal named-port reconciliation path.

```gdscript
func _on_fork_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, original_id: String) -> void:
	if _request_failed(result, response_code):
		_show_request_error("Fork", result, response_code, body)
		return
	fetch_workspace()
```

## 11. Make Lock Styling Idempotent And Free Dialogs On All Close Paths

Prevent repeated title suffixes in `_apply_locked_style()`:

```gdscript
var base_title := _title_for_type(str(_node_data.get(node_id, {}).get("type", "")))
gn.title = base_title + " [BAKED]"
```

Replace the cook dialog connection with both terminal dialog signals:

```gdscript
dialog.confirmed.connect(dialog.queue_free, CONNECT_ONE_SHOT)
dialog.canceled.connect(dialog.queue_free, CONNECT_ONE_SHOT)
```

## Implementation Verification

1. Force a text PATCH failure; verify the `TextEdit` returns to the confirmed cache value and an error dialog appears.
2. Send two text, file-path, position, and edge-toggle operations in rapid succession; delay the first response and verify it cannot overwrite the later confirmed result.
3. Start two workspace fetches; complete the older one last and verify it is ignored.
4. Cook two nodes before either monitor request completes; verify each monitor is positioned and connected to its own source.
5. Trigger a workspace refresh while a `TextEdit` is focused; verify teardown sends no PATCH.
6. Add an input and edit the template rapidly; verify both confirmed updates survive in the backend workspace response.
7. Confirm no duplicate signal connections by rebuilding the workspace repeatedly and observing one handler invocation per user action.
8. Fork text, file, and composite nodes; verify the UI displays only backend-provided state and no invalid dataflow noodle is created.
