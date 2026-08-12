extends GraphEdit

const BACKEND_URL = "http://localhost:8000"

var http_request: HTTPRequest

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_workspace_response)
	fetch_workspace()

func fetch_workspace() -> void:
	var error = http_request.request(BACKEND_URL + "/workspace")
	if error != OK:
		print("[Tendril] HTTP request failed: ", error)

func _on_workspace_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		print("[Tendril] Workspace fetch failed: ", response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		print("[Tendril] Invalid JSON response")
		return

	var nodes_data: Array = json.get("nodes", [])
	var edges_data: Array = json.get("edges", [])
	print("[Tendril] Workspace loaded: ", nodes_data.size(), " nodes, ", edges_data.size(), " edges")

	for node_dict in nodes_data:
		var gn = GraphNode.new()
		gn.name = str(node_dict.get("id", ""))
		gn.title = str(node_dict.get("type", "unknown"))
		gn.position_offset = Vector2(
			node_dict.get("position", {}).get("x", 0.0),
			node_dict.get("position", {}).get("y", 0.0)
		)
		var label = Label.new()
		label.text = str(node_dict.get("content", ""))
		gn.add_child(label)
		add_child(gn)
