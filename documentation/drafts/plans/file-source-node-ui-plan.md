# File Source Node UI Implementation Plan

## Scope And Backend Contract

Implement this only in `product/tendril/gui/main.gd`. The backend's `GraphStore.cook()` handles `type == "file_source"` by reading the path from `node.content`, with `node.properties.template` only as a fallback. The frontend must therefore create and PATCH the path as `content`; do not introduce `properties.path`.

The File Source Node has no inputs and one `text_out` output. It uses `LineEdit`, not `TextEdit`, because its value is a filesystem path rather than raw text content.

## 1. Add Menu Identifier And State Storage

Add the following constant immediately after `MENU_EDIT_COMPOSITE_TEMPLATE := 5`:

```gdscript
const MENU_SPAWN_FILE_SOURCE := 6
```

Add this dictionary immediately after `_textedits` so File Source path controls are independently tracked by node ID:

```gdscript
var _lineedits: Dictionary = {}
```

In `_clear_graph()`, clear this dictionary between the existing `_textedits.clear()` and `_graphnodes.clear()` calls:

```gdscript
	_textedits.clear()
	_lineedits.clear()
	_graphnodes.clear()
```

## 2. Add File Source To The Canvas Context Menu

In `_on_canvas_popup(at_position: Vector2)`, add the File Source item after the existing Text Node item. The canvas menu block must be:

```gdscript
	_popup_menu.clear()
	_popup_menu.add_item("Spawn Text Node", MENU_SPAWN_TEXT)
	_popup_menu.add_item("Spawn File Source Node", MENU_SPAWN_FILE_SOURCE)
	_popup_menu.add_item("Spawn Composite Node", MENU_SPAWN_COMPOSITE)
	_popup_menu.position = get_screen_position() + at_position
	_popup_menu.popup()
```

In `_on_popup_action(id: int)`, add this branch directly after `MENU_SPAWN_TEXT`:

```gdscript
		MENU_SPAWN_FILE_SOURCE:
			_spawn_new_file_source_node(_pending_spawn_position)
```

The beginning of the match will then be:

```gdscript
	match id:
		MENU_SPAWN_TEXT:
			_spawn_new_node(_pending_spawn_position)
		MENU_SPAWN_FILE_SOURCE:
			_spawn_new_file_source_node(_pending_spawn_position)
		MENU_SPAWN_COMPOSITE:
			_spawn_new_composite_node(_pending_spawn_position)
```

## 3. Create The File Source Node Through `POST /nodes`

Add this function immediately after `_spawn_new_node()`. It mirrors the established Text Source creation request, changing only the node type and leaving the file path empty for the user to enter:

```gdscript
func _spawn_new_file_source_node(at_position: Vector2):
	var body = JSON.stringify({
		"type": "file_source",
		"content": "",
		"position": {"x": at_position.x, "y": at_position.y, "z": 0.0},
		"inputs": [],
		"outputs": [{"name": "text_out"}]
	})
	var headers = ["Content-Type: application/json"]
	var error := _http_node.request(
		BACKEND_URL + "/nodes",
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	if error != OK:
		print("[Tendril] File source node request failed to start: ", error)
		return
	_http_node.request_completed.connect(_on_node_created, CONNECT_ONE_SHOT)
```

Keep `_on_node_created()` unchanged. Its existing `_spawn_graph_node(json)` call renders the authoritative node returned by the backend.

## 4. Render A `LineEdit` For File Source Nodes

In `_spawn_graph_node(node_dict: Dictionary)`, retain the `composite_text` branch unchanged. Replace the current single `else:` branch that always creates `TextEdit` with the following `elif` and `else` branches:

```gdscript
	elif ntype == "file_source":
		var path_edit = LineEdit.new()
		path_edit.text = content
		path_edit.placeholder_text = "File path"
		path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		path_edit.custom_minimum_size = Vector2(200, 36)
		gn.add_child(path_edit)
		_lineedits[node_id] = path_edit
		path_edit.focus_exited.connect(_on_file_path_focus_exited.bind(node_id))
		gn.set_slot(0, false, 0, Color.WHITE, true, 0, port_color, null, null)
	else:
		var te = TextEdit.new()
		te.text = content
		te.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		te.size_flags_vertical = Control.SIZE_EXPAND_FILL
		te.custom_minimum_size = Vector2(200, 80)
		gn.add_child(te)
		_textedits[node_id] = te
		te.focus_exited.connect(_on_textedit_focus_exited.bind(node_id))
		gn.set_slot(0, false, 0, Color.WHITE, true, 0, port_color, null, null)
```

This preserves the existing generic `TextEdit` behavior for Text Source, Extraction, Compression, and Monitor nodes while rendering File Source nodes as a single-line path field. It also creates the same output slot at index `0`, which corresponds to the requested `text_out` output supplied by the backend.

## 5. Preserve File Source Read-Only Behavior When Locked

In `_apply_locked_style(node_id: String)`, add the following immediately after the existing `_textedits` editable check. This prevents a locked File Source node's path from remaining editable:

```gdscript
	var path_edit: LineEdit = _lineedits.get(node_id)
	if path_edit:
		path_edit.editable = false
```

The top of the function will be:

```gdscript
	var te: TextEdit = _textedits.get(node_id)
	if te:
		te.editable = false
	var path_edit: LineEdit = _lineedits.get(node_id)
	if path_edit:
		path_edit.editable = false
	var panel = StyleBoxFlat.new()
```

## 6. Synchronize The File Path On `focus_exited`

Add these two functions immediately before the existing `_on_textedit_focus_exited()` function. The first sends the exact backend contract (`content`) when the `LineEdit` loses focus. The second uses the backend response as the local authoritative state and prevents the UI control and `_node_data` cache from drifting.

```gdscript
func _on_file_path_focus_exited(node_id: String):
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("is_locked", false):
		return
	var path_edit: LineEdit = _lineedits.get(node_id)
	if path_edit == null:
		return

	var file_path := path_edit.text.strip_edges()
	if file_path == str(nd.get("content", "")):
		return

	var body = JSON.stringify({
		"type": "file_source",
		"content": file_path,
	})
	var headers = ["Content-Type: application/json"]
	var callback := _on_file_path_patched.bind(node_id, file_path)
	_http_patch.request_completed.connect(callback, CONNECT_ONE_SHOT)
	var error := _http_patch.request(
		BACKEND_URL + "/nodes/" + node_id,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	if error != OK:
		_http_patch.request_completed.disconnect(callback)
		print("[Tendril] File path PATCH failed to start: ", error)


func _on_file_path_patched(
	result,
	response_code,
	headers,
	body,
	node_id: String,
	requested_path: String
):
	if response_code != 200:
		print("[Tendril] File path PATCH failed: ", response_code, " - ", body.get_string_from_utf8())
		return

	var response_node = JSON.parse_string(body.get_string_from_utf8())
	var synced_path := requested_path
	if response_node is Dictionary:
		synced_path = str(response_node.get("content", requested_path))

	if _node_data.has(node_id):
		_node_data[node_id]["content"] = synced_path
	var path_edit: LineEdit = _lineedits.get(node_id)
	if path_edit:
		path_edit.text = synced_path
```

Use `focus_exited` only, not both `focus_exited` and `text_submitted`, so Enter does not cause an immediate PATCH followed by a duplicate PATCH when the field loses focus.

## 7. Implementation Checks

1. Start the backend and Godot frontend, then right-click empty canvas space. Confirm the menu includes `Spawn File Source Node`.
2. Select it and confirm `POST /nodes` creates a node with `type: "file_source"`, `inputs: []`, and `outputs: [{"name": "text_out"}]`.
3. Confirm the rendered File Node contains a `LineEdit` with the `File path` placeholder, not a `TextEdit`.
4. Enter a valid path, move focus away, and confirm the frontend sends `PATCH /nodes/{id}` with `{"type":"file_source","content":"<path>"}`.
5. Confirm the successful PATCH response updates `_node_data[node_id]["content"]` and its tracked `_lineedits[node_id]` control.
6. Cook the File Node or a connected composite node. Confirm the backend reads the path from `content` and returns the file text.
7. Lock the File Node and confirm its `LineEdit` is no longer editable.
