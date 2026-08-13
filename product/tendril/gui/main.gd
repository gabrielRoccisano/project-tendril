extends GraphEdit

const BACKEND_URL = "http://localhost:8000"

const MENU_SPAWN_TEXT := 0
const MENU_COOK := 1
const MENU_LOCK := 2
const MENU_SPAWN_COMPOSITE := 3
const MENU_ADD_COMPOSITE_INPUT := 4
const MENU_EDIT_COMPOSITE_TEMPLATE := 5
const MENU_SPAWN_FILE_SOURCE := 6
const MENU_CLEAR_HIGHLIGHTS := 7
const MENU_EDGE_FIRST := 100
const MENU_EDGE_DELETE_FIRST := 200
const TEXT_EDGE_COLOR := Color(0.8, 0.2, 0.2)
const MEMORY_EDGE_COLOR := Color(0.2, 0.8, 0.2)
const TEXT_EDGE_WIDTH := 2.0
const MEMORY_EDGE_WIDTH := 5.0
const TEXT_EDGE_DASH_LENGTH := 8.0

var _popup_menu: PopupMenu
var _context_node_id: String = ""
var _pending_spawn_position: Vector2 = Vector2.ZERO

var _port_name_dialog: AcceptDialog
var _port_name_edit: LineEdit
var _port_dialog_node_id: String = ""

var _template_dialog: AcceptDialog
var _template_edit: TextEdit
var _template_dialog_node_id: String = ""

var _node_data: Dictionary = {}
var _textedits: Dictionary = {}
var _lineedits: Dictionary = {}
var _graphnodes: Dictionary = {}
var _edge_data: Dictionary = {}
var _edge_menu_ids: Dictionary = {}
var _edge_delete_menu_ids: Dictionary = {}
var _pending_position_saves: Dictionary = {}

var _workspace_revision := 0
var _applied_workspace_revision := 0
var _node_revisions: Dictionary = {}
var _edge_revisions: Dictionary = {}
var _suppress_editor_signals := false
var _composite_mutation_queues: Dictionary = {}
var _composite_mutation_active: Dictionary = {}


func _ready():
	add_theme_color_override("connection_color", Color(0, 0, 0, 0))
	right_disconnects = true
	_popup_menu = PopupMenu.new()
	_popup_menu.name = "ContextMenu"
	_popup_menu.id_pressed.connect(_on_popup_action)
	add_child(_popup_menu)

	_setup_composite_dialogs()

	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	popup_request.connect(_on_canvas_popup)
	end_node_move.connect(_on_end_node_move)

	fetch_workspace()


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

	var nodes_data: Array = json.get("nodes", [])
	var edges_data: Array = json.get("edges", [])
	print("[Tendril] Workspace loaded: ", nodes_data.size(), " nodes, ", edges_data.size(), " edges")

	for nd in nodes_data:
		_spawn_graph_node(nd)

	for ed in edges_data:
		var source_node_id: String = str(ed.get("source_node_id", ""))
		var target_node_id: String = str(ed.get("target_node_id", ""))
		var source_port_name: String = str(ed.get("source_port_name", ""))
		var target_port_name: String = str(ed.get("target_port_name", ""))
		var edge_id: String = str(ed.get("id", ""))

		_edge_data[edge_id] = {
			"id": edge_id,
			"semantic_type": str(ed.get("semantic_type", "text")),
			"source_node_id": source_node_id,
			"source_port_name": source_port_name,
			"target_node_id": target_node_id,
			"target_port_name": target_port_name,
		}

		var source_port_index := _port_index_named(
			source_node_id,
			"outputs",
			source_port_name
		)
		var target_port_index := _port_index_named(
			target_node_id,
			"inputs",
			target_port_name
		)
		if source_port_index >= 0 and target_port_index >= 0:
			connect_node(source_node_id, source_port_index, target_node_id, target_port_index)

	queue_redraw()

	_suppress_editor_signals = false


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
	gn.draggable = not is_locked
	_connect_once(gn.dragged, _on_graph_node_dragged.bind(node_id))

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
	elif ntype == "file_source":
		var path_edit = LineEdit.new()
		path_edit.text = content
		path_edit.placeholder_text = "File path"
		path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		path_edit.custom_minimum_size = Vector2(200, 36)
		gn.add_child(path_edit)
		_lineedits[node_id] = path_edit
		_connect_once(path_edit.focus_exited, _on_file_path_focus_exited.bind(node_id))
		gn.set_slot(0, false, 0, Color.WHITE, true, 0, port_color, null, null)
	else:
		var te = TextEdit.new()
		te.text = content
		te.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		te.size_flags_vertical = Control.SIZE_EXPAND_FILL
		te.custom_minimum_size = Vector2(200, 80)
		gn.add_child(te)
		_textedits[node_id] = te
		_connect_once(te.focus_exited, _on_textedit_focus_exited.bind(node_id))
		gn.set_slot(0, false, 0, Color.WHITE, true, 0, port_color, null, null)

	_connect_once(gn.gui_input, _on_graph_node_input.bind(node_id))

	add_child(gn)
	_graphnodes[node_id] = gn

	_node_data[node_id] = {
		"inputs": inputs,
		"outputs": outputs,
		"properties": properties,
		"type": ntype,
		"is_locked": is_locked,
		"content": content,
		"position": {"x": gn.position_offset.x, "y": gn.position_offset.y, "z": 0.0},
	}

	if is_locked:
		_apply_locked_style(node_id)


func _add_composite_input_row_to_graph_node(gn: GraphNode, port_name: String, port_color: Color):
	var slot_index: int = gn.get_child_count()
	var input_row = Label.new()
	input_row.text = port_name
	input_row.custom_minimum_size = Vector2(200, 28)
	input_row.set_meta("composite_input_row", true)
	gn.add_child(input_row)
	gn.set_slot(slot_index, true, 0, port_color, false, 0, Color.WHITE, null, null)


func _rebuild_composite_input_rows(node_id: String) -> void:
	var gn: GraphNode = _graphnodes.get(node_id)
	if gn == null:
		return

	var nd: Dictionary = _node_data.get(node_id, {})
	var confirmed_inputs: Array = nd.get("inputs", [])
	var confirmed_names: Dictionary = {}
	for port in confirmed_inputs:
		confirmed_names[str(port.get("name", ""))] = true

	var to_disconnect: Array = []
	for edge_id in _edge_data:
		var ed: Dictionary = _edge_data[edge_id]
		if str(ed.get("target_node_id", "")) != node_id:
			continue
		var target_port_name := str(ed.get("target_port_name", ""))
		if target_port_name.is_empty() or not confirmed_names.has(target_port_name):
			var source_node_id := str(ed.get("source_node_id", ""))
			var source_port_index := _port_index_named(source_node_id, "outputs", str(ed.get("source_port_name", "")))
			var target_port_index := _port_index_named(node_id, "inputs", target_port_name)
			if source_port_index >= 0 and target_port_index >= 0:
				to_disconnect.append([source_node_id, source_port_index, node_id, target_port_index])
	for conn in to_disconnect:
		if is_node_connected(conn[0], conn[1], conn[2], conn[3]):
			disconnect_node(conn[0], conn[1], conn[2], conn[3])

	for child in gn.get_children():
		if child.has_meta("composite_input_row"):
			gn.remove_child(child)
			child.queue_free()

	var port_color: Color = Color(0.2, 0.8, 0.2) if nd.get("is_locked", false) else Color(0.8, 0.2, 0.2)
	for port in confirmed_inputs:
		_add_composite_input_row_to_graph_node(gn, str(port.get("name", "")), port_color)

	gn.size.y = maxf(150.0, 90.0 + float(confirmed_inputs.size()) * 28.0)

	for edge_id in _edge_data:
		var ed: Dictionary = _edge_data[edge_id]
		if str(ed.get("target_node_id", "")) != node_id:
			continue
		var source_node_id := str(ed.get("source_node_id", ""))
		var source_port_index := _port_index_named(source_node_id, "outputs", str(ed.get("source_port_name", "")))
		var target_port_index := _port_index_named(node_id, "inputs", str(ed.get("target_port_name", "")))
		if source_port_index >= 0 and target_port_index >= 0:
			if not is_node_connected(source_node_id, source_port_index, node_id, target_port_index):
				connect_node(source_node_id, source_port_index, node_id, target_port_index)


func _apply_locked_style(node_id: String):
	var gn: GraphNode = _graphnodes.get(node_id)
	if gn == null:
		return
	var te: TextEdit = _textedits.get(node_id)
	if te:
		te.editable = false
	var path_edit: LineEdit = _lineedits.get(node_id)
	if path_edit:
		path_edit.editable = false
	gn.draggable = false
	var panel = StyleBoxFlat.new()
	panel.bg_color = Color(0.15, 0.35, 0.15, 1.0)
	panel.border_width_left = 2
	panel.border_width_right = 2
	panel.border_width_top = 2
	panel.border_width_bottom = 2
	panel.border_color = Color(0.3, 0.6, 0.3, 1.0)
	gn.add_theme_stylebox_override("panel", panel)
	gn.add_theme_stylebox_override("panel_selected", panel)
	gn.add_theme_stylebox_override("titlebar", panel)
	gn.set_slot_color_right(0, Color(0.2, 0.8, 0.2))
	var base_title := _title_for_type(str(_node_data.get(node_id, {}).get("type", "")))
	gn.title = base_title + " [BAKED]"

	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") == "composite_text":
		var inputs: Array = nd.get("inputs", [])
		for input_index in range(inputs.size()):
			gn.set_slot_color_left(input_index + 1, Color(0.2, 0.8, 0.2))


func _title_for_type(ntype: String) -> String:
	match ntype:
		"text_source": return "Text Node"
		"file_source": return "File Node"
		"composite_text": return "Composite"
		"extraction": return "Extraction"
		"compression": return "Compression"
		"monitor": return "Monitor"
		_: return ntype


func _apply_provenance_highlights(traversed_node_ids: Array):
	for node_id in _graphnodes:
		var gn: GraphNode = _graphnodes[node_id]
		if node_id in traversed_node_ids:
			gn.modulate = Color(1, 1, 1, 1)
		else:
			gn.modulate = Color(0.3, 0.3, 0.3, 0.3)


func _clear_provenance_highlights():
	for node_id in _graphnodes:
		var gn: GraphNode = _graphnodes[node_id]
		gn.modulate = Color(1, 1, 1, 1)


func _on_canvas_popup(at_position: Vector2):
	_pending_spawn_position = at_position
	_context_node_id = ""
	_popup_menu.clear()
	_edge_menu_ids.clear()
	_edge_delete_menu_ids.clear()
	_popup_menu.add_item("Spawn Text Node", MENU_SPAWN_TEXT)
	_popup_menu.add_item("Spawn File Source Node", MENU_SPAWN_FILE_SOURCE)
	_popup_menu.add_item("Spawn Composite Node", MENU_SPAWN_COMPOSITE)
	_popup_menu.add_separator()
	_popup_menu.add_item("Clear Highlights", MENU_CLEAR_HIGHLIGHTS)
	_popup_menu.position = get_screen_position() + at_position
	_popup_menu.popup()


func _on_graph_node_input(event: InputEvent, node_id: String):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_context_node_id = node_id
		var nd: Dictionary = _node_data.get(node_id, {})
		_popup_menu.clear()
		_edge_menu_ids.clear()
		_edge_delete_menu_ids.clear()
		_popup_menu.add_item("Cook Context", MENU_COOK)
		if not nd.get("is_locked", false):
			_popup_menu.add_item("Lock / Bake", MENU_LOCK)
			if nd.get("type", "") == "composite_text":
				_popup_menu.add_separator()
				_popup_menu.add_item("Add Input Port", MENU_ADD_COMPOSITE_INPUT)
				_popup_menu.add_item("Edit Template", MENU_EDIT_COMPOSITE_TEMPLATE)

		_edge_menu_ids.clear()
		_edge_delete_menu_ids.clear()
		var edge_menu_id := MENU_EDGE_FIRST
		var delete_menu_id := MENU_EDGE_DELETE_FIRST
		for edge_id in _edge_data:
			var edge: Dictionary = _edge_data[edge_id]
			var source_id := str(edge.get("source_node_id", ""))
			var target_id := str(edge.get("target_node_id", ""))
			if source_id != node_id and target_id != node_id:
				continue

			var semantic_type := str(edge.get("semantic_type", "text"))
			if semantic_type == "supersedes":
				continue

			var other_id := target_id if source_id == node_id else source_id
			var other_label := other_id.get_slice("-", 1)
			if other_label.is_empty():
				other_label = other_id

			if source_id == node_id:
				if semantic_type == "text":
					_popup_menu.add_item(
						"Set Edge to Memory Consolidation (GREEN) -> " + other_label,
						edge_menu_id
					)
				elif semantic_type == "memory_consolidation":
					_popup_menu.add_item(
						"Set Edge to Basic Text (RED) -> " + other_label,
						edge_menu_id
					)
				_edge_menu_ids[edge_menu_id] = str(edge_id)
				edge_menu_id += 1

			var direction := " -> " if source_id == node_id else " <- "
			_popup_menu.add_item("Disconnect Edge" + direction + other_label, delete_menu_id)
			_edge_delete_menu_ids[delete_menu_id] = str(edge_id)
			delete_menu_id += 1

		_popup_menu.position = get_screen_position() + get_local_mouse_position()
		_popup_menu.popup()

	if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
		var nd: Dictionary = _node_data.get(node_id, {})
		if nd.get("is_locked", false):
			_fork_node(node_id)


func _on_popup_action(id: int):
	match id:
		MENU_SPAWN_TEXT:
			_spawn_new_node(_pending_spawn_position)
		MENU_SPAWN_FILE_SOURCE:
			_spawn_new_file_source_node(_pending_spawn_position)
		MENU_SPAWN_COMPOSITE:
			_spawn_new_composite_node(_pending_spawn_position)
		MENU_CLEAR_HIGHLIGHTS:
			_clear_provenance_highlights()
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
			if _edge_menu_ids.has(id):
				_toggle_edge_from_menu(id)
			elif _edge_delete_menu_ids.has(id):
				_request_edge_deletion(str(_edge_delete_menu_ids[id]))


func _spawn_new_node(at_position: Vector2):
	var body = JSON.stringify({
		"type": "text_source",
		"content": "",
		"position": {"x": at_position.x, "y": at_position.y, "z": 0.0},
		"inputs": [],
		"outputs": [{"name": "text_out"}]
	})
	var headers = ["Content-Type: application/json"]
	_send_api_request(BACKEND_URL + "/nodes", headers, HTTPClient.METHOD_POST, body, _on_node_created)


func _spawn_new_file_source_node(at_position: Vector2):
	var body = JSON.stringify({
		"type": "file_source",
		"content": "",
		"position": {"x": at_position.x, "y": at_position.y, "z": 0.0},
		"inputs": [],
		"outputs": [{"name": "text_out"}]
	})
	var headers = ["Content-Type: application/json"]
	_send_api_request(BACKEND_URL + "/nodes", headers, HTTPClient.METHOD_POST, body, _on_node_created)


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
	_send_api_request(BACKEND_URL + "/nodes", headers, HTTPClient.METHOD_POST, body, _on_node_created)


func _on_node_created(result, response_code, headers, body):
	if response_code != 201:
		print("[Tendril] Node creation failed: ", response_code)
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
	_spawn_graph_node(json)


func _show_add_composite_port_dialog(node_id: String):
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") != "composite_text" or nd.get("is_locked", false):
		return
	_port_dialog_node_id = node_id
	_port_name_edit.text = ""
	_port_name_edit.placeholder_text = "Port name"
	_port_name_dialog.popup_centered(Vector2i(360, 120))
	_port_name_edit.call_deferred("grab_focus")


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

	_enqueue_composite_mutation(node_id, {"kind": "add_input", "port_name": port_name})


func _show_template_dialog(node_id: String):
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") != "composite_text" or nd.get("is_locked", false):
		return
	_template_dialog_node_id = node_id
	var properties: Dictionary = nd.get("properties", {})
	_template_edit.text = str(properties.get("template", ""))
	_template_dialog.popup_centered(Vector2i(560, 380))
	_template_edit.call_deferred("grab_focus")


func _on_template_confirmed():
	var node_id: String = _template_dialog_node_id
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("type", "") != "composite_text" or nd.get("is_locked", false):
		return

	_enqueue_composite_mutation(node_id, {"kind": "set_template", "template": _template_edit.text})


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


func _on_file_path_focus_exited(node_id: String) -> void:
	if _suppress_editor_signals:
		return
	var nd: Dictionary = _node_data.get(node_id, {})
	var path_edit: LineEdit = _lineedits.get(node_id)
	if nd.is_empty() or path_edit == null or nd.get("is_locked", false):
		return

	var previous_path := str(nd.get("content", ""))
	var file_path := path_edit.text.strip_edges()
	if file_path == previous_path:
		return

	var revision := _next_node_revision(node_id)
	var body = JSON.stringify({
		"type": "file_source",
		"content": file_path,
	})
	_send_api_request(
		BACKEND_URL + "/nodes/" + node_id,
		["Content-Type: application/json"],
		HTTPClient.METHOD_PATCH,
		body,
		_on_file_path_patched.bind(node_id, revision, previous_path)
	)


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
	var previous_position: Dictionary = _node_data.get(node_id, {}).get("position", {}).duplicate(true)
	var revision := _next_node_revision(node_id)
	var body := JSON.stringify({
		"position": {"x": position.x, "y": position.y, "z": 0.0},
	})
	_send_api_request(
		BACKEND_URL + "/nodes/" + node_id,
		["Content-Type: application/json"],
		HTTPClient.METHOD_PATCH,
		body,
		_on_node_position_patched.bind(node_id, revision, previous_position)
	)


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


func _edge_for_connection(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
) -> Dictionary:
	var source_node_id := str(from_node)
	var target_node_id := str(to_node)
	var source_port_name := _port_name_at(source_node_id, "outputs", from_port)
	var target_port_name := _port_name_at(target_node_id, "inputs", to_port)
	var supersedes_edge: Dictionary = {}

	for edge_id in _edge_data:
		var edge: Dictionary = _edge_data[edge_id]
		if str(edge.get("source_node_id", "")) != source_node_id:
			continue
		if str(edge.get("source_port_name", "")) != source_port_name:
			continue
		if str(edge.get("target_node_id", "")) != target_node_id:
			continue
		if str(edge.get("target_port_name", "")) != target_port_name:
			continue
		if str(edge.get("semantic_type", "text")) != "supersedes":
			return edge
		supersedes_edge = edge

	return supersedes_edge


func _draw() -> void:
	for connection in get_connection_list():
		var from_node := StringName(connection.get("from_node", ""))
		var from_port := int(connection.get("from_port", -1))
		var to_node := StringName(connection.get("to_node", ""))
		var to_port := int(connection.get("to_port", -1))
		if from_port < 0 or to_port < 0:
			continue

		var edge := _edge_for_connection(from_node, from_port, to_node, to_port)
		if edge.is_empty():
			continue

		var from_graph_node: GraphNode = get_node_or_null(NodePath(str(from_node)))
		var to_graph_node: GraphNode = get_node_or_null(NodePath(str(to_node)))
		if from_graph_node == null or to_graph_node == null:
			continue

		var from_position: Vector2 = (
			from_graph_node.position
			+ from_graph_node.get_output_port_position(from_port)
		)
		var to_position: Vector2 = (
			to_graph_node.position
			+ to_graph_node.get_input_port_position(to_port)
		)
		_draw_semantic_connection(
			from_position,
			to_position,
			str(edge.get("semantic_type", "text"))
		)


func _draw_semantic_connection(
	from_position: Vector2,
	to_position: Vector2,
	semantic_type: String
) -> void:
	var control_distance := maxf(absf(to_position.x - from_position.x) * 0.5, 80.0)
	var curve := Curve2D.new()
	curve.add_point(
		from_position,
		Vector2.ZERO,
		Vector2(control_distance, 0.0)
	)
	curve.add_point(
		to_position,
		Vector2(-control_distance, 0.0),
		Vector2.ZERO
	)
	var points := curve.tessellate(5, 4.0)

	match semantic_type:
		"text":
			_draw_dashed_curve(points, Color(0.8, 0.2, 0.2), TEXT_EDGE_WIDTH)
		"memory_consolidation":
			for point_index in range(points.size() - 1):
				draw_line(
					points[point_index],
					points[point_index + 1],
					Color(0.2, 0.8, 0.2),
					MEMORY_EDGE_WIDTH,
					true
				)


func _draw_dashed_curve(
	points: PackedVector2Array,
	color: Color,
	width: float
) -> void:
	var draw_dash := true
	for point_index in range(points.size() - 1):
		var segment_start := points[point_index]
		var segment_end := points[point_index + 1]
		var segment_length := segment_start.distance_to(segment_end)
		if is_zero_approx(segment_length):
			continue

		var segment_offset := 0.0
		while segment_offset < segment_length:
			var next_offset := minf(
				segment_offset + TEXT_EDGE_DASH_LENGTH,
				segment_length
			)
			if draw_dash:
				draw_line(
					segment_start.lerp(segment_end, segment_offset / segment_length),
					segment_start.lerp(segment_end, next_offset / segment_length),
					color,
					width,
					true
				)
			draw_dash = not draw_dash
			segment_offset = next_offset


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
		"semantic_type": "text",
	})
	var headers = ["Content-Type: application/json"]
	_send_api_request(BACKEND_URL + "/edges", headers, HTTPClient.METHOD_POST, body, _on_edge_created)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	var edge := _edge_for_connection(from_node, from_port, to_node, to_port)
	if edge.is_empty():
		return
	var semantic_type := str(edge.get("semantic_type", ""))
	if semantic_type == "supersedes":
		return
	if semantic_type != "text" and semantic_type != "memory_consolidation":
		return

	var edge_id := str(edge.get("id", ""))
	if edge_id.is_empty():
		return
	_request_edge_deletion(edge_id, from_node, from_port, to_node, to_port)


func _request_edge_deletion(
	edge_id: String,
	from_node: StringName = &"",
	from_port: int = -1,
	to_node: StringName = &"",
	to_port: int = -1
) -> void:
	if not _edge_data.has(edge_id):
		return
	var edge: Dictionary = _edge_data[edge_id]
	if str(edge.get("semantic_type", "text")) == "supersedes":
		print("[Tendril] Supersedes edge ", edge_id, " is immutable; deletion rejected")
		return

	if from_port < 0 or to_port < 0:
		from_node = StringName(str(edge.get("source_node_id", "")))
		from_port = _port_index_named(
			str(from_node),
			"outputs",
			str(edge.get("source_port_name", ""))
		)
		to_node = StringName(str(edge.get("target_node_id", "")))
		to_port = _port_index_named(
			str(to_node),
			"inputs",
			str(edge.get("target_port_name", ""))
		)

	var revision := _next_edge_revision(edge_id)
	_send_api_request(
		BACKEND_URL + "/edges/" + edge_id,
		[],
		HTTPClient.METHOD_DELETE,
		"",
		_on_edge_deleted.bind(edge_id, revision, from_node, from_port, to_node, to_port)
	)


func _on_edge_deleted(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray,
	edge_id: String,
	revision: int,
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
) -> void:
	if not _is_current_edge_revision(edge_id, revision):
		return
	if _request_failed(result, response_code):
		_show_request_error("Edge deletion", result, response_code, body)
		return

	if from_port >= 0 and to_port >= 0 and is_node_connected(from_node, from_port, to_node, to_port):
		disconnect_node(from_node, from_port, to_node, to_port)
	_edge_data.erase(edge_id)
	queue_redraw()


func _on_edge_created(result, response_code, headers, body):
	if response_code != 201:
		print("[Tendril] Edge creation failed: ", response_code, " - ", body.get_string_from_utf8())
		return
	fetch_workspace()


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


func _on_lock_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, node_id: String, revision: int) -> void:
	if not _is_current_node_revision(node_id, revision):
		return
	if _request_failed(result, response_code):
		_show_request_error("Lock", result, response_code, body)
		return
	var response_node = JSON.parse_string(body.get_string_from_utf8())
	if not response_node is Dictionary:
		fetch_workspace()
		return
	for key in response_node:
		_node_data[node_id][key] = response_node[key]
	_apply_locked_style(node_id)


func _toggle_edge_from_menu(menu_id: int) -> void:
	var edge_id := str(_edge_menu_ids.get(menu_id, ""))
	var edge: Dictionary = _edge_data.get(edge_id, {})
	if edge.is_empty():
		return

	var semantic_type := str(edge.get("semantic_type", "text"))
	var new_semantic_type := (
		"memory_consolidation"
		if semantic_type == "text"
		else "text"
	)
	_toggle_edge_type(edge_id, new_semantic_type)


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


func _on_edge_toggle_response(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray,
	edge_id: String,
	revision: int
) -> void:
	if not _is_current_edge_revision(edge_id, revision):
		return
	if _request_failed(result, response_code):
		_show_request_error("Edge semantic update", result, response_code, body)
		return

	var response_edge = JSON.parse_string(body.get_string_from_utf8())
	if not response_edge is Dictionary or str(response_edge.get("id", "")) != edge_id:
		fetch_workspace()
		return

	_edge_data[edge_id] = {
		"id": edge_id,
		"semantic_type": str(response_edge.get("semantic_type", "text")),
		"source_node_id": str(response_edge.get("source_node_id", "")),
		"source_port_name": str(response_edge.get("source_port_name", "")),
		"target_node_id": str(response_edge.get("target_node_id", "")),
		"target_port_name": str(response_edge.get("target_port_name", "")),
	}
	queue_redraw()


func _fork_node(node_id: String):
	_send_api_request(
		BACKEND_URL + "/nodes/" + node_id + "/fork",
		[],
		HTTPClient.METHOD_POST,
		"",
		_on_fork_response.bind(node_id)
	)


func _on_fork_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, original_id: String) -> void:
	if _request_failed(result, response_code):
		_show_request_error("Fork", result, response_code, body)
		return
	fetch_workspace()


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


func _on_monitor_created(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, source_node_id: String) -> void:
	if _request_failed(result, response_code):
		_show_request_error("Monitor creation", result, response_code, body)
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if not json is Dictionary:
		fetch_workspace()
		return
	var target_node_id := str(json.get("id", ""))
	if target_node_id.is_empty():
		fetch_workspace()
		return
	var source_port_name := _port_name_at(source_node_id, "outputs", 0)
	if source_port_name.is_empty():
		fetch_workspace()
		return
	var edge_body = JSON.stringify({
		"source_node_id": source_node_id,
		"source_port_name": source_port_name,
		"target_node_id": target_node_id,
		"target_port_name": "text_in",
		"semantic_type": "text"
	})
	var req_headers = ["Content-Type: application/json"]
	_send_api_request(BACKEND_URL + "/edges", req_headers, HTTPClient.METHOD_POST, edge_body, _on_edge_created)


func _show_cook_dialog(text: String):
	var dialog = AcceptDialog.new()
	dialog.title = "Cooked Context"
	dialog.size = Vector2(500, 400)
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog.add_child(label)
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free, CONNECT_ONE_SHOT)
	dialog.canceled.connect(dialog.queue_free, CONNECT_ONE_SHOT)
