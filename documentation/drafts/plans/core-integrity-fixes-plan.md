# Core Integrity Fixes Implementation Plan

## Scope And Constraints

Implement the two V0 integrity fixes in `product/tendril/gui/main.gd` and `product/tendril/api/graph.py`. Do not alter the API contract in `product/tendril/api/main.py`: `NodePatch.position: Position3D | None` and the existing `PATCH /nodes/{node_id}` route already expose the required field.

The GUI must remain a backend projection. A successful position PATCH is authoritative; a failed PATCH must be logged rather than silently treated as persisted.

## 1. HTTP Request Ownership

### Problem

`main.gd` owns eight long-lived `HTTPRequest` nodes (`_http_workspace`, `_http_node`, `_http_edge`, `_http_cook`, `_http_patch`, `_http_fork`, `_http_composite_inputs`, and `_http_composite_template`). Multiple unrelated actions reuse the same node while an earlier request may still be in flight. `HTTPRequest` only supports one active request, so the later call can fail to start or callbacks can be attached to the wrong logical request.

### Required Refactor

1. Delete the eight `var _http_*: HTTPRequest` declarations at lines 15-22.
2. Delete all `HTTPRequest.new()`, `add_child(r)`, and fixed-response signal setup from `_ready()` at lines 45-67.
3. Add this request-scoped helper immediately after `_ready()`:

```gdscript
func _send_api_request(
	url: String,
	headers: Array,
	method: HTTPClient.Method,
	body: String = "",
	callback: Callable = Callable()
) -> void:
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(
		_on_api_request_completed.bind(request, callback),
		CONNECT_ONE_SHOT
	)

	var error := request.request(url, headers, method, body)
	if error != OK:
		print("[Tendril] API request failed to start: ", error, " - ", url)
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

The connection is installed before `request()` starts the network operation. The dedicated completion handler calls the response-specific callback and then frees only that request node. Do not call `queue_free()` in individual callbacks because the shared handler owns that lifecycle.

### Exact Call-Site Replacements

Use `_send_api_request()` for every current API operation. Remove every direct `.request()` call and every direct `.request_completed.connect()` or `.disconnect()` call on the deleted `_http_*` members.

```gdscript
# fetch_workspace()
_send_api_request(BACKEND_URL + "/workspace", [], HTTPClient.METHOD_GET, "", _on_workspace_response)

# _spawn_new_node(), _spawn_new_file_source_node(), _spawn_new_composite_node(), and _spawn_monitor_node()
_send_api_request(BACKEND_URL + "/nodes", headers, HTTPClient.METHOD_POST, body, _on_node_created)

# _on_port_name_confirmed()
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id,
	headers,
	HTTPClient.METHOD_PATCH,
	body,
	_on_composite_inputs_patched.bind(node_id, updated_inputs, updated_properties)
)

# _on_template_confirmed()
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id,
	headers,
	HTTPClient.METHOD_PATCH,
	body,
	_on_composite_template_patched.bind(node_id, updated_inputs, updated_properties)
)

# _on_file_path_focus_exited()
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id,
	headers,
	HTTPClient.METHOD_PATCH,
	body,
	_on_file_path_patched.bind(node_id, file_path)
)

# _on_textedit_focus_exited()
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id,
	headers,
	HTTPClient.METHOD_PATCH,
	body,
	_on_patch_response
)

# _on_connection_request()
_send_api_request(BACKEND_URL + "/edges", headers, HTTPClient.METHOD_POST, body, _on_edge_created)

# _lock_node()
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id,
	headers,
	HTTPClient.METHOD_PATCH,
	body,
	_on_lock_response.bind(node_id)
)

# _toggle_edge_type()
_send_api_request(
	BACKEND_URL + "/edges/" + edge_id,
	headers,
	HTTPClient.METHOD_PATCH,
	body,
	_on_edge_toggle_response.bind(edge_id, new_semantic_type)
)

# _fork_node()
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id + "/fork",
	[],
	HTTPClient.METHOD_POST,
	"",
	_on_fork_response.bind(node_id)
)

# _cook_node()
_send_api_request(
	BACKEND_URL + "/nodes/" + node_id + "/cook",
	[],
	HTTPClient.METHOD_POST,
	"",
	_on_cook_response
)

# The edge creation at the end of _on_monitor_created().
_send_api_request(BACKEND_URL + "/edges", req_headers, HTTPClient.METHOD_POST, edge_body, _on_edge_created)
```

For the three node-creation functions, retain their distinct payload construction and replace only the final request/signal lines with the shared node-creation call shown above. Remove the old per-call `error` handling; the helper now logs failures and frees the request. The monitor edge must use `_on_edge_created` so it refreshes the workspace after the backend confirms creation.

## 2. Frontend Position Persistence

### Signal Strategy

Use each `GraphNode`'s `dragged` signal to record its current canvas offset, and `GraphEdit.end_node_move` to send one PATCH after the drag finishes. This avoids one PATCH per mouse-motion frame while still persisting every completed move.

### Exact Changes

1. Add this field alongside the other dictionaries near the top of `main.gd`:

```gdscript
var _pending_position_saves: Dictionary = {}
```

2. Add this signal connection in `_ready()` after the existing `connection_request` and `popup_request` connections:

```gdscript
end_node_move.connect(_on_end_node_move)
```

3. In `_spawn_graph_node()`, immediately after `gn.position_offset` and `gn.size` are assigned, make locked nodes immovable and subscribe every graph node to movement:

```gdscript
	gn.draggable = not is_locked
	gn.dragged.connect(_on_graph_node_dragged.bind(node_id))
```

4. Extend the `_node_data[node_id]` dictionary with the loaded position so local state reflects the backend projection:

```gdscript
		"position": {"x": gn.position_offset.x, "y": gn.position_offset.y, "z": 0.0},
```

5. In `_apply_locked_style()`, set the same interaction constraint in case the node is locked after its initial render:

```gdscript
	gn.draggable = false
```

6. Add these methods after `_on_patch_response()`:

```gdscript
func _on_graph_node_dragged(_from: Vector2, to: Vector2, node_id: String) -> void:
	var node_data: Dictionary = _node_data.get(node_id, {})
	if node_data.get("is_locked", false):
		return
	_pending_position_saves[node_id] = to


func _on_end_node_move() -> void:
	for pending_node_id in _pending_position_saves:
		var node_id := str(pending_node_id)
		var position: Vector2 = _pending_position_saves[pending_node_id]
		_patch_node_position(node_id, position)
	_pending_position_saves.clear()


func _patch_node_position(node_id: String, position: Vector2) -> void:
	var body := JSON.stringify({
		"position": {"x": position.x, "y": position.y, "z": 0.0},
	})
	var headers = ["Content-Type: application/json"]
	_send_api_request(
		BACKEND_URL + "/nodes/" + node_id,
		headers,
		HTTPClient.METHOD_PATCH,
		body,
		_on_node_position_patched.bind(node_id, position)
	)


func _on_node_position_patched(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray,
	node_id: String,
	requested_position: Vector2
) -> void:
	if response_code != 200:
		print("[Tendril] Position PATCH failed: ", response_code, " - ", body.get_string_from_utf8())
		return
	if _node_data.has(node_id):
		_node_data[node_id]["position"] = {
			"x": requested_position.x,
			"y": requested_position.y,
			"z": 0.0,
		}
```

The `dragged` signal can fire repeatedly while a user moves a node. `_pending_position_saves` overwrites the earlier position for that node, and `end_node_move` flushes only the final coordinate. This is a lightweight drag-end debounce without timers or domain state in the GUI.

## 3. Backend Position Serialization

### Problem

`main.py` correctly parses `position` as `Position3D`, but `node.model_dump()` passed to `GraphStore.update_node()` produces nested dictionary data. The existing generic `setattr(merged, "position", value)` can therefore replace `merged.position` with a `dict`. `_node_to_row()` then accesses `node.position.x`, `node.position.y`, and `node.position.z`, which requires a `Position3D` object.

### Exact `graph.py` Replacement

Replace the complete `GraphStore.update_node()` method with this version. It explicitly validates `patch["position"]` into `Position3D` before `_node_to_row()` serializes its x/y/z attributes into `position_x`, `position_y`, and `position_z`.

```python
    def update_node(self, node_id: str, patch: dict) -> Node:
        existing = self.get_node(node_id)
        if existing.is_locked:
            raise ValueError(f"Node {node_id} is locked")

        merged = existing.model_copy(deep=True)
        patch_data = patch.copy()
        if "position" in patch_data:
            merged.position = Position3D.model_validate(patch_data.pop("position"))

        for field, value in patch_data.items():
            setattr(merged, field, value)
        merged.id = node_id

        with self._connection() as conn:
            with conn:
                conn.execute(
                    "UPDATE nodes SET type = ?, is_locked = ?, position_x = ?,"
                    " position_y = ?, position_z = ?, inputs = ?, outputs = ?,"
                    " properties = ?, content = ? WHERE id = ?",
                    (*self._node_to_row(merged)[1:], node_id),
                )
        return merged
```

No schema or route change is needed in `main.py`. Its existing code must remain:

```python
return store.update_node(
    node_id, node.model_dump(exclude_unset=True, exclude_none=True)
)
```

After normalization, the existing `_node_to_row()` implementation writes:

```python
node.position.x,
node.position.y,
node.position.z,
```

to the three SQLite columns, and `_row_to_node()` already reconstructs the same values as `Position3D` for GET `/nodes/{id}` and GET `/workspace`.

## 4. Implementation Verification

1. Run the backend test suite, then add or run a focused PATCH test that creates a node, PATCHes `{"position": {"x": 12.5, "y": -4.0, "z": 0.0}}`, creates a fresh `GraphStore` instance, and verifies the reloaded `position` matches all three values. A fresh store proves the values reached SQLite rather than only the response object.
2. Run the FastAPI service and issue the same PATCH through HTTP. Confirm it returns 200 and `GET /nodes/{id}` returns the requested coordinates.
3. In Godot, trigger two node creates and a content PATCH without waiting for earlier responses. Confirm every request receives its intended callback and no `HTTPRequest` remains in the scene tree after completion.
4. Drag one unlocked node, release it, restart or reload the workspace, and confirm its final GUI coordinate is restored. Inspect the backend log/network trace to confirm exactly one PATCH was sent for that drag.
5. Attempt to drag a locked node. Confirm it cannot move because `gn.draggable` is false and no position PATCH is issued.
