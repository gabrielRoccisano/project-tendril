extends GraphEdit

const BACKEND_URL = "http://localhost:8000"

var _http_workspace: HTTPRequest
var _http_node: HTTPRequest
var _http_edge: HTTPRequest
var _http_cook: HTTPRequest
var _http_patch: HTTPRequest
var _http_fork: HTTPRequest

var _popup_menu: PopupMenu
var _context_node_id: String = ""
var _pending_spawn_position: Vector2 = Vector2.ZERO
var _cooking_node_id: String = ""

var _node_data: Dictionary = {}
var _textedits: Dictionary = {}
var _graphnodes: Dictionary = {}
var _edge_data: Dictionary = {}


func _ready():
	_http_workspace = HTTPRequest.new()
	_http_node = HTTPRequest.new()
	_http_edge = HTTPRequest.new()
	_http_cook = HTTPRequest.new()
	_http_patch = HTTPRequest.new()
	_http_fork = HTTPRequest.new()
	for r in [_http_workspace, _http_node, _http_edge, _http_cook, _http_patch, _http_fork]:
		add_child(r)

	_http_workspace.request_completed.connect(_on_workspace_response)
	_http_patch.request_completed.connect(_on_patch_response)

	_popup_menu = PopupMenu.new()
	_popup_menu.name = "ContextMenu"
	_popup_menu.id_pressed.connect(_on_popup_action)
	add_child(_popup_menu)

	connection_request.connect(_on_connection_request)
	popup_request.connect(_on_canvas_popup)

	fetch_workspace()


func fetch_workspace():
	_http_workspace.request(BACKEND_URL + "/workspace")


func _clear_graph():
	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()
	_node_data.clear()
	_textedits.clear()
	_graphnodes.clear()
	_edge_data.clear()


func _spawn_graph_node(node_dict: Dictionary):
	var node_id: String = str(node_dict.get("id", ""))
	var pos = node_dict.get("position", {})
	var content: String = str(node_dict.get("content", ""))
	var is_locked: bool = node_dict.get("is_locked", false)
	var ntype: String = str(node_dict.get("type", "text_source"))

	var gn = GraphNode.new()
	gn.name = node_id
	gn.title = _title_for_type(ntype)
	gn.position_offset = Vector2(pos.get("x", 0.0), pos.get("y", 0.0))
	gn.size = Vector2(240, 150)

	var te = TextEdit.new()
	te.text = content
	te.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	te.size_flags_vertical = Control.SIZE_EXPAND_FILL
	te.custom_minimum_size = Vector2(200, 80)
	gn.add_child(te)
	_textedits[node_id] = te
	te.focus_exited.connect(_on_textedit_focus_exited.bind(node_id))

	var port_color: Color = Color(0.2, 0.8, 0.2) if is_locked else Color(0.8, 0.2, 0.2)
	gn.set_slot(0, false, 0, Color.WHITE, true, 0, port_color, null, null)

	gn.gui_input.connect(_on_graph_node_input.bind(node_id))

	add_child(gn)
	_graphnodes[node_id] = gn

	_node_data[node_id] = {
		"inputs": node_dict.get("inputs", []),
		"outputs": node_dict.get("outputs", []),
		"type": ntype,
		"is_locked": is_locked,
		"content": content,
	}

	if is_locked:
		_apply_locked_style(node_id)


func _apply_locked_style(node_id: String):
	var gn: GraphNode = _graphnodes.get(node_id)
	if gn == null:
		return
	var te: TextEdit = _textedits.get(node_id)
	if te:
		te.editable = false
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
	gn.title = gn.title + " [BAKED]"


func _title_for_type(ntype: String) -> String:
	match ntype:
		"text_source": return "Text Node"
		"file_source": return "File Node"
		"composite_text": return "Composite"
		"extraction": return "Extraction"
		"compression": return "Compression"
		"monitor": return "Monitor"
		_: return ntype


func _on_workspace_response(result, response_code, headers, body):
	if response_code != 200:
		print("[Tendril] Workspace fetch failed: ", response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		print("[Tendril] Invalid JSON response")
		return

	_clear_graph()

	var nodes_data: Array = json.get("nodes", [])
	var edges_data: Array = json.get("edges", [])
	print("[Tendril] Workspace loaded: ", nodes_data.size(), " nodes, ", edges_data.size(), " edges")

	for nd in nodes_data:
		_spawn_graph_node(nd)

	for ed in edges_data:
		connect_node(
			str(ed.get("source_node_id", "")), 0,
			str(ed.get("target_node_id", "")), 0
		)
		var edge_id: String = str(ed.get("id", ""))
		var key: String = str(ed.get("source_node_id", "")) + "|" + str(ed.get("target_node_id", ""))
		_edge_data[key] = {
			"id": edge_id,
			"semantic_type": str(ed.get("semantic_type", "narrative_context")),
			"source_node_id": str(ed.get("source_node_id", "")),
			"target_node_id": str(ed.get("target_node_id", "")),
		}


func _on_canvas_popup(at_position: Vector2):
	_pending_spawn_position = at_position
	_popup_menu.clear()
	_popup_menu.add_item("Spawn Text Node", 0)
	_popup_menu.position = get_screen_position() + at_position
	_popup_menu.popup()


func _on_graph_node_input(event: InputEvent, node_id: String):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_context_node_id = node_id
		var nd: Dictionary = _node_data.get(node_id, {})
		_popup_menu.clear()
		_popup_menu.add_item("Cook Context", 1)
		if not nd.get("is_locked", false):
			_popup_menu.add_item("Lock / Bake", 2)

		var edge_index: int = 100
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

	if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
		var nd: Dictionary = _node_data.get(node_id, {})
		if nd.get("is_locked", false):
			_fork_node(node_id)


func _on_popup_action(id: int):
	match id:
		0:
			_spawn_new_node(_pending_spawn_position)
		1:
			if _context_node_id != "":
				_cook_node(_context_node_id)
		2:
			if _context_node_id != "":
				_lock_node(_context_node_id)
		_:
			if id >= 100:
				_toggle_edge_by_menu_index(_context_node_id, id - 100)


func _spawn_new_node(at_position: Vector2):
	var body = JSON.stringify({
		"type": "text_source",
		"content": "",
		"position": {"x": at_position.x, "y": at_position.y, "z": 0.0},
		"inputs": [],
		"outputs": [{"name": "text_out"}]
	})
	var headers = ["Content-Type: application/json"]
	_http_node.request(BACKEND_URL + "/nodes", headers, HTTPClient.METHOD_POST, body)
	_http_node.request_completed.connect(_on_node_created, CONNECT_ONE_SHOT)


func _on_node_created(result, response_code, headers, body):
	if response_code != 201:
		print("[Tendril] Node creation failed: ", response_code)
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
	_spawn_graph_node(json)


func _on_textedit_focus_exited(node_id: String):
	var nd: Dictionary = _node_data.get(node_id, {})
	if nd.get("is_locked", false):
		return
	var te: TextEdit = _textedits.get(node_id)
	if te == null:
		return
	var body = JSON.stringify({"type": nd.get("type", "text_source"), "content": te.text})
	var headers = ["Content-Type: application/json"]
	_http_patch.request(
		BACKEND_URL + "/nodes/" + node_id,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)


func _on_patch_response(result, response_code, headers, body):
	if response_code != 200:
		print("[Tendril] PATCH failed: ", response_code, " - ", body.get_string_from_utf8())


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	var body = JSON.stringify({
		"source_node_id": str(from_node),
		"source_port_name": "text_out",
		"target_node_id": str(to_node),
		"target_port_name": "text_in",
		"semantic_type": "narrative_context"
	})
	var headers = ["Content-Type: application/json"]
	_http_edge.request(BACKEND_URL + "/edges", headers, HTTPClient.METHOD_POST, body)
	_http_edge.request_completed.connect(_on_edge_created, CONNECT_ONE_SHOT)


func _on_edge_created(result, response_code, headers, body):
	if response_code != 201:
		print("[Tendril] Edge creation failed: ", response_code, " - ", body.get_string_from_utf8())
		return
	fetch_workspace()


func _lock_node(node_id: String):
	var nd: Dictionary = _node_data.get(node_id, {})
	var body = JSON.stringify({
		"type": nd.get("type", "text_source"),
		"content": nd.get("content", ""),
		"is_locked": true
	})
	var headers = ["Content-Type: application/json"]
	_http_patch.request(
		BACKEND_URL + "/nodes/" + node_id,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	_http_patch.request_completed.connect(_on_lock_response.bind(node_id), CONNECT_ONE_SHOT)


func _on_lock_response(result, response_code, headers, body, node_id: String):
	if response_code != 200:
		print("[Tendril] Lock failed: ", response_code, " - ", body.get_string_from_utf8())
		return
	_node_data[node_id]["is_locked"] = true
	_apply_locked_style(node_id)


func _toggle_edge_by_menu_index(source_node_id: String, menu_index: int):
	var idx: int = 0
	for key in _edge_data:
		var ed: Dictionary = _edge_data[key]
		if ed.get("source_node_id", "") == source_node_id:
			if idx == menu_index:
				var etype: String = ed.get("semantic_type", "narrative_context")
				var new_type: String = "stable_reference" if etype == "narrative_context" else "narrative_context"
				_toggle_edge_type(ed.get("id", ""), new_type)
				return
			idx += 1


func _toggle_edge_type(edge_id: String, new_semantic_type: String):
	var body = JSON.stringify({
		"source_node_id": "",
		"source_port_name": "",
		"target_node_id": "",
		"target_port_name": "",
		"semantic_type": new_semantic_type
	})
	var headers = ["Content-Type: application/json"]
	_http_patch.request(
		BACKEND_URL + "/edges/" + edge_id,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	_http_patch.request_completed.connect(_on_edge_toggle_response.bind(edge_id, new_semantic_type), CONNECT_ONE_SHOT)


func _on_edge_toggle_response(result, response_code, headers, body, edge_id: String, new_type: String):
	if response_code == 200:
		for key in _edge_data:
			var ed: Dictionary = _edge_data[key]
			if ed.get("id", "") == edge_id:
				ed["semantic_type"] = new_type
				break
		print("[Tendril] Edge ", edge_id, " toggled to ", new_type)
	else:
		print("[Tendril] Edge toggle failed: ", response_code, " - ", body.get_string_from_utf8())


func _fork_node(node_id: String):
	_http_fork.request(BACKEND_URL + "/nodes/" + node_id + "/fork", [], HTTPClient.METHOD_POST)
	_http_fork.request_completed.connect(_on_fork_response.bind(node_id), CONNECT_ONE_SHOT)


func _on_fork_response(result, response_code, headers, body, original_id: String):
	if response_code != 201:
		print("[Tendril] Fork failed: ", response_code, " - ", body.get_string_from_utf8())
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
	var original_gn: GraphNode = _graphnodes.get(original_id)
	if original_gn:
		json["position"] = {
			"x": original_gn.position_offset.x + 300.0,
			"y": original_gn.position_offset.y,
			"z": 0.0
		}
	_spawn_graph_node(json)
	connect_node(original_id, 0, str(json.get("id", "")), 0)


func _cook_node(node_id: String):
	_cooking_node_id = node_id
	_http_cook.request(BACKEND_URL + "/nodes/" + node_id + "/cook", [], HTTPClient.METHOD_POST)
	_http_cook.request_completed.connect(_on_cook_response, CONNECT_ONE_SHOT)


func _on_cook_response(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json:
			var compiled = str(json.get("compiled_text", ""))
			print("[Tendril] Cook result:\n", compiled)
			_show_cook_dialog(compiled)
			_spawn_monitor_node(compiled)
	else:
		print("[Tendril] Cook failed: ", response_code, " - ", body.get_string_from_utf8())


func _spawn_monitor_node(compiled_text: String):
	var original_gn: GraphNode = _graphnodes.get(_cooking_node_id)
	var pos_x: float = 0.0
	var pos_y: float = 0.0
	if original_gn:
		pos_x = original_gn.position_offset.x + 300.0
		pos_y = original_gn.position_offset.y

	var body = JSON.stringify({
		"type": "monitor",
		"content": compiled_text,
		"position": {"x": pos_x, "y": pos_y, "z": 0.0},
		"inputs": [{"name": "text_in"}],
		"outputs": []
	})
	var headers = ["Content-Type: application/json"]
	_http_node.request(BACKEND_URL + "/nodes", headers, HTTPClient.METHOD_POST, body)
	_http_node.request_completed.connect(_on_monitor_created, CONNECT_ONE_SHOT)


func _on_monitor_created(result, response_code, headers, body):
	if response_code != 201:
		print("[Tendril] Monitor creation failed: ", response_code)
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
	_spawn_graph_node(json)
	if _cooking_node_id != "":
		connect_node(_cooking_node_id, 0, str(json.get("id", "")), 0)
		var edge_body = JSON.stringify({
			"source_node_id": _cooking_node_id,
			"source_port_name": "text_out",
			"target_node_id": str(json.get("id", "")),
			"target_port_name": "text_in",
			"semantic_type": "narrative_context"
		})
		var req_headers = ["Content-Type: application/json"]
		_http_edge.request(BACKEND_URL + "/edges", req_headers, HTTPClient.METHOD_POST, edge_body)


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
	dialog.confirmed.connect(dialog.queue_free)
