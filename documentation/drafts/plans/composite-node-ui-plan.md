# Composite Text Node UI Implementation Plan

## Goal And Constraints

Implement Composite Text Nodes in `product/tendril/gui/main.gd` without moving domain logic into Godot. The frontend must render and edit backend state, send every mutation through the HTTP API, and update local state only after the backend returns HTTP 200 or 201.

The implementation phase should modify only `main.gd`. Keep the current single-script structure and existing UI conventions.

## API Contract To Implement

`Port` is exactly:

```json
{"name": "header"}
```

`NodeProperties` is exactly:

```json
{"template": "{{header}}\n---\n{{body}}"}
```

A newly created Composite Text Node must be posted as:

```json
{
  "type": "composite_text",
  "content": "",
  "position": {"x": 150.0, "y": -200.0, "z": 0.0},
  "inputs": [],
  "outputs": [{"name": "combined_text"}],
  "properties": {"template": ""}
}
```

The backend response remains authoritative. Do not generate a node ID in Godot. Spawn the visual `GraphNode` from the returned Node object.

## 1. Menu IDs, Dialog State, And Requests

Add these constants immediately below `BACKEND_URL`. Named constants avoid collisions in the one shared `_popup_menu` used for both canvas and node context menus.

```gdscript
const MENU_SPAWN_TEXT := 0
const MENU_COOK := 1
const MENU_LOCK := 2
const MENU_SPAWN_COMPOSITE := 3
const MENU_ADD_COMPOSITE_INPUT := 4
const MENU_EDIT_COMPOSITE_TEMPLATE := 5
const MENU_EDGE_FIRST := 100
```

Add two dedicated HTTP requests. An `HTTPRequest` is single-flight; separate request nodes prevent a port update and a template update from consuming each other's one-shot response handlers.

```gdscript
var _http_composite_inputs: HTTPRequest
var _http_composite_template: HTTPRequest
```

Add persistent dialog and target-node state:

```gdscript
var _port_name_dialog: AcceptDialog
var _port_name_edit: LineEdit
var _port_dialog_node_id: String = ""

var _template_dialog: AcceptDialog
var _template_edit: TextEdit
var _template_dialog_node_id: String = ""
```

In `_ready()`, create the new requests with the existing requests and include them in the existing `add_child` loop:

```gdscript
	_http_composite_inputs = HTTPRequest.new()
	_http_composite_template = HTTPRequest.new()
	for r in [
		_http_workspace,
		_http_node,
		_http_edge,
		_http_cook,
		_http_patch,
		_http_fork,
		_http_composite_inputs,
		_http_composite_template,
	]:
		add_child(r)
```

Replace the current one-line `for r in [...]` loop rather than adding a second loop. After creating `_popup_menu`, call the dialog setup function once:

```gdscript
	_setup_composite_dialogs()
```

Add this function. The dialogs are reused rather than created on every right click.

```gdscript
func _setup_composite_dialogs():
	_port_name_dialog = AcceptDialog.new()
	_port_name_dialog.title = "Add Composite Input"
	_port_name_dialog.get_ok_button().text = "Add"
	_port_name_edit = LineEdit.new()
	_port_name_edit.placeholder_text = "Port name"
	_port_name_edit.custom_minimum_size = Vector2(320, 36)
	_port_name_dialog.add_child(_port_name_edit)
	add_child(_port_name_dialog)
	_port_name_dialog.confirmed.connect(_on_port_name_confirmed)

	_template_dialog = AcceptDialog.new()
	_template_dialog.title = "Edit Composite Template"
	_template_dialog.get_ok_button().text = "Save"
	_template_edit = TextEdit.new()
	_template_edit.custom_minimum_size = Vector2(520, 320)
	_template_dialog.add_child(_template_edit)
	add_child(_template_dialog)
	_template_dialog.confirmed.connect(_on_template_confirmed)
```

## 2. Render Composite Nodes And Track Complete State

Replace `_spawn_graph_node` with the following version. The composite output occupies slot row 0. Every dynamic input gets a later row and therefore an input port whose GraphEdit port index follows the `inputs` array order. Non-composite rendering remains unchanged.

```gdscript
func _spawn_graph_node(node_dict: Dictionary):
	var node_id: String = str(node_dict.get("id", ""))
	var pos: Dictionary = node_dict.get("position", {})
	var content: String = str(node_dict.get("content", ""))
	var is_locked: bool = node_dict.get("is_locked", false)
	var ntype: String = str(node_dict.get("type", "text_source"))
	var inputs: Array = node_dict.get("inputs", []).duplicate(true)
	var outputs: Array = node_dict.get("outputs", []).duplicate(true)
	var properties: Dictionary = node_dict.get("properties", {}).duplicate(true)

	var gn = GraphNode.new()
	gn.name = node_id
	gn.title = _title_for_type(ntype)
	gn.position_offset = Vector2(pos.get("x", 0.0), pos.get("y", 0.0))
	gn.size = Vector2(240, 150)

	var port_color: Color = Color(0.2, 0.8, 0.2) if is_locked else Color(0.8, 0.2, 0.2)
	if ntype == "composite_text":
		var output_row = Label.new()
		output_row.text = "combined_text"
		output_row.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		output_row.custom_minimum_size = Vector2(200, 28)
		gn.add_child(output_row)
		gn.set_slot(0, false, 0, Color.WHITE, true, 0, port_color, null, null)

		for port in inputs:
			_add_composite_input_row_to_graph_node(gn, str(port.get("name", "")), port_color)
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

	gn.gui_input.connect(_on_graph_node_input.bind(node_id))

	add_child(gn)
	_graphnodes[node_id] = gn

	_node_data[node_id] = {
		"inputs": inputs,
		"outputs": outputs,
		"properties": properties,
		"type": ntype,
		"is_locked": is_locked,
		"content": content,
	}

	if is_locked:
		_apply_locked_style(node_id)
```

Add the row helper used above. Metadata lets the implementation rebuild only dynamic input rows after the backend accepts a port mutation.

```gdscript
func _add_composite_input_row_to_graph_node(gn: GraphNode, port_name: String, port_color: Color):
	var slot_index: int = gn.get_child_count()
	var input_row = Label.new()
	input_row.text = port_name
	input_row.custom_minimum_size = Vector2(200, 28)
	input_row.set_meta("composite_input_row", true)
	gn.add_child(input_row)
	gn.set_slot(slot_index, true, 0, port_color, false, 0, Color.WHITE, null, null)
```

Add this rebuild helper. It is called only after a successful PATCH and ensures the visual port order exactly matches `_node_data[node_id]["inputs"]`.

```gdscript
func _rebuild_composite_input_rows(node_id: String):
	var gn: GraphNode = _graphnodes.get(node_id)
	if gn == null:
		return

	for child in gn.get_children():
		if child.has_meta("composite_input_row"):
			gn.remove_child(child)
			child.queue_free()

	var nd: Dictionary = _node_data.get(node_id, {})
	var port_color: Color = Color(0.2, 0.8, 0.2) if nd.get("is_locked", false) else Color(0.8, 0.2, 0.2)
	for port in nd.get("inputs", []):
		_add_composite_input_row_to_graph_node(gn, str(port.get("name", "")), port_color)

	gn.size.y = maxf(150.0, 90.0 + float(nd.get("inputs", []).size()) * 28.0)
```

Extend `_apply_locked_style` after `gn.set_slot_color_right(0, ...)` so loaded or newly locked composite input ports also become green:

```gdscript
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") == "composite_text":
		var inputs: Array = nd.get("inputs", [])
		for input_index in range(inputs.size()):
			gn.set_slot_color_left(input_index + 1, Color(0.2, 0.8, 0.2))
```

## 3. Canvas Menu And Composite Node Creation

Replace `_on_canvas_popup` with:

```gdscript
func _on_canvas_popup(at_position: Vector2):
	_pending_spawn_position = at_position
	_context_node_id = ""
	_popup_menu.clear()
	_popup_menu.add_item("Spawn Text Node", MENU_SPAWN_TEXT)
	_popup_menu.add_item("Spawn Composite Node", MENU_SPAWN_COMPOSITE)
	_popup_menu.position = get_screen_position() + at_position
	_popup_menu.popup()
```

Replace the numeric IDs in `_on_popup_action` and add the composite actions:

```gdscript
func _on_popup_action(id: int):
	match id:
		MENU_SPAWN_TEXT:
			_spawn_new_node(_pending_spawn_position)
		MENU_SPAWN_COMPOSITE:
			_spawn_new_composite_node(_pending_spawn_position)
		MENU_COOK:
			if _context_node_id != "":
				_cook_node(_context_node_id)
		MENU_LOCK:
			if _context_node_id != "":
				_lock_node(_context_node_id)
		MENU_ADD_COMPOSITE_INPUT:
			if _context_node_id != "":
				_show_add_composite_port_dialog(_context_node_id)
		MENU_EDIT_COMPOSITE_TEMPLATE:
			if _context_node_id != "":
				_show_template_dialog(_context_node_id)
		_:
			if id >= MENU_EDGE_FIRST:
				_toggle_edge_by_menu_index(_context_node_id, id - MENU_EDGE_FIRST)
```

Add the exact create request. This is 0 inputs, one `combined_text` output, and an empty template.

```gdscript
func _spawn_new_composite_node(at_position: Vector2):
	var body = JSON.stringify({
		"type": "composite_text",
		"content": "",
		"position": {"x": at_position.x, "y": at_position.y, "z": 0.0},
		"inputs": [],
		"outputs": [{"name": "combined_text"}],
		"properties": {"template": ""},
	})
	var headers = ["Content-Type: application/json"]
	var error := _http_node.request(
		BACKEND_URL + "/nodes",
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	if error != OK:
		print("[Tendril] Composite node request failed to start: ", error)
		return
	_http_node.request_completed.connect(_on_node_created, CONNECT_ONE_SHOT)
```

The existing `_on_node_created` handles the HTTP 201 response and calls `_spawn_graph_node(json)`, so no second create-response function is needed.

## 4. Composite Node Right-Click Menu

In `_on_graph_node_input`, replace the menu-building portion with this code. Composite editing actions are omitted when the node is locked because the backend rejects locked-node PATCH mutations.

```gdscript
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_context_node_id = node_id
		var nd: Dictionary = _node_data.get(node_id, {})
		_popup_menu.clear()
		_popup_menu.add_item("Cook Context", MENU_COOK)
		if not nd.get("is_locked", false):
			_popup_menu.add_item("Lock / Bake", MENU_LOCK)
			if nd.get("type", "") == "composite_text":
				_popup_menu.add_separator()
				_popup_menu.add_item("Add Input Port", MENU_ADD_COMPOSITE_INPUT)
				_popup_menu.add_item("Edit Template", MENU_EDIT_COMPOSITE_TEMPLATE)

		var edge_index: int = MENU_EDGE_FIRST
		for key in _edge_data:
			var ed: Dictionary = _edge_data[key]
			if ed.get("source_node_id", "") == node_id:
				var target_id: String = ed.get("target_node_id", "")
				var etype: String = ed.get("semantic_type", "narrative_context")
				var label: String = "Edge → " + target_id.get_slice("-", 1) + ": " + ("RED" if etype == "narrative_context" else "GREEN")
				_popup_menu.add_item(label, edge_index)
				edge_index += 1

		_popup_menu.position = get_screen_position() + get_local_mouse_position()
		_popup_menu.popup()
```

Leave the locked-node double-click/fork block following this code unchanged.

## 5. Add Input Port Dialog And PATCH

Add the dialog opener:

```gdscript
func _show_add_composite_port_dialog(node_id: String):
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") != "composite_text" or nd.get("is_locked", false):
		return
	_port_dialog_node_id = node_id
	_port_name_edit.text = ""
	_port_name_edit.placeholder_text = "Port name"
	_port_name_dialog.popup_centered(Vector2i(360, 120))
	_port_name_edit.call_deferred("grab_focus")
```

Add the confirmation handler. It trims whitespace, rejects empty and duplicate names locally, and includes both the updated `inputs` array and current `properties` object in the PATCH.

```gdscript
func _on_port_name_confirmed():
	var node_id: String = _port_dialog_node_id
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") != "composite_text" or nd.get("is_locked", false):
		return

	var port_name: String = _port_name_edit.text.strip_edges()
	if port_name.is_empty():
		_port_name_edit.placeholder_text = "Port name is required"
		_port_name_dialog.call_deferred("popup_centered", Vector2i(360, 120))
		return

	var updated_inputs: Array = nd.get("inputs", []).duplicate(true)
	for port in updated_inputs:
		if str(port.get("name", "")) == port_name:
			_port_name_edit.text = ""
			_port_name_edit.placeholder_text = "Port name already exists"
			_port_name_dialog.call_deferred("popup_centered", Vector2i(360, 120))
			return

	updated_inputs.append({"name": port_name})
	var updated_properties: Dictionary = nd.get("properties", {}).duplicate(true)
	var body = JSON.stringify({
		"type": "composite_text",
		"inputs": updated_inputs,
		"properties": updated_properties,
	})
	var headers = ["Content-Type: application/json"]
	var callback := _on_composite_inputs_patched.bind(node_id, updated_inputs, updated_properties)
	_http_composite_inputs.request_completed.connect(callback, CONNECT_ONE_SHOT)
	var error := _http_composite_inputs.request(
		BACKEND_URL + "/nodes/" + node_id,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	if error != OK:
		_http_composite_inputs.request_completed.disconnect(callback)
		print("[Tendril] Composite input PATCH failed to start: ", error)
```

Add the response handler. Do not add the visual slot or mutate `_node_data` before HTTP 200. Prefer returned backend values and use the submitted values only if a valid response object omits them.

```gdscript
func _on_composite_inputs_patched(
	result,
	response_code,
	headers,
	body,
	node_id: String,
	requested_inputs: Array,
	requested_properties: Dictionary
):
	if response_code != 200:
		print("[Tendril] Composite input PATCH failed: ", response_code, " - ", body.get_string_from_utf8())
		return

	var response_node = JSON.parse_string(body.get_string_from_utf8())
	var synced_inputs: Array = requested_inputs.duplicate(true)
	var synced_properties: Dictionary = requested_properties.duplicate(true)
	if response_node is Dictionary:
		synced_inputs = response_node.get("inputs", requested_inputs).duplicate(true)
		synced_properties = response_node.get("properties", requested_properties).duplicate(true)

	if not _node_data.has(node_id):
		return
	_node_data[node_id]["inputs"] = synced_inputs
	_node_data[node_id]["properties"] = synced_properties
	_rebuild_composite_input_rows(node_id)
```

## 6. Template Editing Dialog And PATCH

Add the template dialog opener. It loads the current local projection of `properties.template` every time the dialog opens.

```gdscript
func _show_template_dialog(node_id: String):
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") != "composite_text" or nd.get("is_locked", false):
		return
	_template_dialog_node_id = node_id
	var properties: Dictionary = nd.get("properties", {})
	_template_edit.text = str(properties.get("template", ""))
	_template_dialog.popup_centered(Vector2i(560, 380))
	_template_edit.call_deferred("grab_focus")
```

Add the confirmation handler. Empty templates are valid. The payload includes the unchanged `inputs` array and the complete updated `properties` object.

```gdscript
func _on_template_confirmed():
	var node_id: String = _template_dialog_node_id
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") != "composite_text" or nd.get("is_locked", false):
		return

	var updated_inputs: Array = nd.get("inputs", []).duplicate(true)
	var updated_properties: Dictionary = nd.get("properties", {}).duplicate(true)
	updated_properties["template"] = _template_edit.text
	var body = JSON.stringify({
		"type": "composite_text",
		"inputs": updated_inputs,
		"properties": updated_properties,
	})
	var headers = ["Content-Type: application/json"]
	var callback := _on_composite_template_patched.bind(node_id, updated_inputs, updated_properties)
	_http_composite_template.request_completed.connect(callback, CONNECT_ONE_SHOT)
	var error := _http_composite_template.request(
		BACKEND_URL + "/nodes/" + node_id,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	if error != OK:
		_http_composite_template.request_completed.disconnect(callback)
		print("[Tendril] Composite template PATCH failed to start: ", error)
```

Add the response handler:

```gdscript
func _on_composite_template_patched(
	result,
	response_code,
	headers,
	body,
	node_id: String,
	requested_inputs: Array,
	requested_properties: Dictionary
):
	if response_code != 200:
		print("[Tendril] Composite template PATCH failed: ", response_code, " - ", body.get_string_from_utf8())
		return

	var response_node = JSON.parse_string(body.get_string_from_utf8())
	var synced_inputs: Array = requested_inputs.duplicate(true)
	var synced_properties: Dictionary = requested_properties.duplicate(true)
	if response_node is Dictionary:
		synced_inputs = response_node.get("inputs", requested_inputs).duplicate(true)
		synced_properties = response_node.get("properties", requested_properties).duplicate(true)

	if not _node_data.has(node_id):
		return
	_node_data[node_id]["inputs"] = synced_inputs
	_node_data[node_id]["properties"] = synced_properties
```

This supplies the required local state sync for `_node_data`; `_graphnodes` remains the node-ID-to-control index, and `_rebuild_composite_input_rows` updates that control after accepted input changes. Composite nodes intentionally have no entry in `_textedits`, because their editable text is `properties.template` in the reusable dialog.

## 7. Use Named Ports For Connections

The current connection handler hardcodes `text_out` and `text_in`. That would create invalid edges for `combined_text` and dynamic composite input names. Add these helpers:

```gdscript
func _port_name_at(node_id: String, collection: String, port_index: int) -> String:
	var nd: Dictionary = _node_data.get(node_id, {})
	var ports: Array = nd.get(collection, [])
	if port_index < 0 or port_index >= ports.size():
		return ""
	return str(ports[port_index].get("name", ""))


func _port_index_named(node_id: String, collection: String, port_name: String) -> int:
	var nd: Dictionary = _node_data.get(node_id, {})
	var ports: Array = nd.get(collection, [])
	for index in range(ports.size()):
		if str(ports[index].get("name", "")) == port_name:
			return index
	return -1
```

Replace `_on_connection_request` with:

```gdscript
func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	var source_node_id := str(from_node)
	var target_node_id := str(to_node)
	var source_port_name := _port_name_at(source_node_id, "outputs", from_port)
	var target_port_name := _port_name_at(target_node_id, "inputs", to_port)
	if source_port_name.is_empty() or target_port_name.is_empty():
		print("[Tendril] Connection rejected locally: unresolved named port")
		return

	var body = JSON.stringify({
		"source_node_id": source_node_id,
		"source_port_name": source_port_name,
		"target_node_id": target_node_id,
		"target_port_name": target_port_name,
		"semantic_type": "narrative_context",
	})
	var headers = ["Content-Type: application/json"]
	_http_edge.request(BACKEND_URL + "/edges", headers, HTTPClient.METHOD_POST, body)
	_http_edge.request_completed.connect(_on_edge_created, CONNECT_ONE_SHOT)
```

In `_on_workspace_response`, replace the existing unconditional `connect_node(...)` call inside the edge loop with named-port lookup. This preserves dynamic target-port order after reload:

```gdscript
	for ed in edges_data:
		var source_node_id: String = str(ed.get("source_node_id", ""))
		var target_node_id: String = str(ed.get("target_node_id", ""))
		var source_port_index := _port_index_named(
			source_node_id,
			"outputs",
			str(ed.get("source_port_name", ""))
		)
		var target_port_index := _port_index_named(
			target_node_id,
			"inputs",
			str(ed.get("target_port_name", ""))
		)
		if source_port_index >= 0 and target_port_index >= 0:
			connect_node(source_node_id, source_port_index, target_node_id, target_port_index)

		var edge_id: String = str(ed.get("id", ""))
		var key: String = source_node_id + "|" + target_node_id
		_edge_data[key] = {
			"id": edge_id,
			"semantic_type": str(ed.get("semantic_type", "narrative_context")),
			"source_node_id": source_node_id,
			"target_node_id": target_node_id,
		}
```

Finally, in `_on_monitor_created`, stop hardcoding the cooked node's output as `text_out`. Before building `edge_body`, resolve it from state:

```gdscript
		var source_port_name := _port_name_at(_cooking_node_id, "outputs", 0)
		var edge_body = JSON.stringify({
			"source_node_id": _cooking_node_id,
			"source_port_name": source_port_name,
			"target_node_id": str(json.get("id", "")),
			"target_port_name": "text_in",
			"semantic_type": "narrative_context",
		})
```

This makes a cooked composite use `combined_text` and preserves existing `text_out` behavior for source-like nodes.

## 8. Implementation Order

1. Add menu constants, request variables, dialog variables, and `_ready()` initialization.
2. Replace `_spawn_graph_node`; add composite row render/rebuild helpers; extend locked styling.
3. Add canvas menu integration and `_spawn_new_composite_node`.
4. Extend the node context menu and popup dispatch.
5. Add the input-port dialog, PATCH request, successful-response state sync, and visual rebuild.
6. Add the template dialog, PATCH request, and successful-response state sync.
7. Replace hardcoded connection port names with the named-port helpers.
8. Run the verification below before considering the implementation complete.

## 9. Verification For The Implementation Phase

Perform these checks against a running API and Godot client:

1. Right-clicking blank canvas shows both `Spawn Text Node` and `Spawn Composite Node`.
2. Spawning a composite emits `POST /nodes` with type `composite_text`, no inputs, output `combined_text`, `properties.template == ""`, and `position.z == 0.0`.
3. The visual composite initially has no left ports and exactly one right port labelled `combined_text`.
4. Right-clicking an unlocked composite shows `Add Input Port` and `Edit Template`.
5. Adding `header`, then `body`, emits PATCH bodies whose inputs are `[{'name':'header'}]` and then `[{'name':'header'}, {'name':'body'}]`; each successful response adds the matching left port.
6. Empty and duplicate input names do not dispatch PATCH requests.
7. Editing the template to `{{header}}\n---\n{{body}}` emits a PATCH with that exact `properties.template` value and preserves the complete inputs array.
8. A failed PATCH leaves `_node_data` and visual ports unchanged.
9. Reloading `/workspace` recreates the same input order, template state, and `combined_text` output.
10. Connecting a Text Source output to the composite's second input emits `source_port_name: text_out` and `target_port_name: body`.
11. Connecting the composite output onward emits `source_port_name: combined_text`.
12. Locked composites do not show input/template editing actions, and their input/output ports use the locked green color.
13. Existing Text Source spawning, text PATCH, cook, lock, fork, edge-type toggle, and monitor behavior still work.
14. Parse `main.gd` with Godot and confirm there are no GDScript errors before runtime testing.
