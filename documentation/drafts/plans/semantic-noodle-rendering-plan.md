# Semantic Noodle Rendering Implementation Plan

## Objective

Replace the two active edge semantic values with `text` and `memory_consolidation`, render their GraphEdit connections as RED and GREEN noodles, and let the user switch an outgoing edge between those values. Keep `supersedes` unchanged as a separate history-edge semantic.

## Scope And Constraints

- Modify `product/tendril/api/models.py`, `product/tendril/api/graph.py`, and `product/tendril/gui/main.gd` in the implementation task.
- Do not change the SQLite schema: `semantic_type` remains a text column.
- This plan intentionally does not implement the changes.
- Existing persisted databases containing `narrative_context` or `stable_reference` require a separate migration decision. The snippets below intentionally validate and emit only the authoritative new values.

## 1. Backend Semantic Contract

In `product/tendril/api/models.py`, replace the active `SemanticType` literals exactly with:

```python
SemanticType = Literal[
    "text",
    "memory_consolidation",
    "supersedes",
]
```

This makes FastAPI/Pydantic reject obsolete values at the API boundary while retaining `supersedes` for fork history.

In `product/tendril/api/graph.py`, replace the composite-node formatting branch in `GraphStore.cook()` exactly with:

```python
                            raw = _cook_node(edge.source_node_id)
                            if edge.semantic_type == "memory_consolidation":
                                text = "> " + raw + "\n"
                            else:
                                text = raw
```

The enclosing condition that excludes `supersedes` remains unchanged. Therefore `text` is included inline, and `memory_consolidation` is emitted as a durable-memory blockquote.

## 2. Frontend Edge Data And Creation Defaults

In `product/tendril/gui/main.gd`, the workspace loader must retain the authoritative semantic value for every connection. Replace the `_edge_data` assignment in `_on_workspace_response()` with this exact block:

```gdscript
		var edge_id: String = str(ed.get("id", ""))
		var key: String = source_node_id + "|" + target_node_id
		_edge_data[key] = {
			"id": edge_id,
			"semantic_type": str(ed.get("semantic_type", "text")),
			"source_node_id": source_node_id,
			"source_port_index": source_port_index,
			"target_node_id": target_node_id,
			"target_port_index": target_port_index,
		}
```

The port indexes are required by the drawing lookup. For a new user-created connection, replace the request value in `_on_connection_request()` with:

```gdscript
		"semantic_type": "text",
```

Also replace the monitor connection's request value in `_on_monitor_created()` with the same line:

```gdscript
			"semantic_type": "text"
```

Do not infer a port's color from the node lock state when applying this change. Semantics belong to connections, and a single port can participate in multiple edges with different semantics. The custom noodles are therefore the authoritative port-to-port semantic indicator until the port data contract gains an unambiguous port-level semantic field.

## 3. Custom GraphEdit Noodle Drawing

Add the following helpers and GraphEdit virtual method at file scope in `main.gd`. Godot 4 calls `_draw_connection()` for each built-in connection; returning `true` tells GraphEdit that this method drew the connection and suppresses the default line.

```gdscript
func _edge_semantic_for_draw(from_position: Vector2, to_position: Vector2) -> String:
	var nearest_semantic := "text"
	var nearest_distance := INF
	for edge in _edge_data.values():
		var source: GraphNode = _graphnodes.get(str(edge.get("source_node_id", "")))
		var target: GraphNode = _graphnodes.get(str(edge.get("target_node_id", "")))
		if source == null or target == null:
			continue

		var source_graph_position := source.position_offset + source.get_output_port_position(int(edge.get("source_port_index", -1)))
		var target_graph_position := target.position_offset + target.get_input_port_position(int(edge.get("target_port_index", -1)))
		var expected_from := (source_graph_position - scroll_offset) * zoom
		var expected_to := (target_graph_position - scroll_offset) * zoom
		var distance := expected_from.distance_squared_to(from_position) + expected_to.distance_squared_to(to_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_semantic = str(edge.get("semantic_type", "text"))
	return nearest_semantic


func _bezier_points(from_position: Vector2, to_position: Vector2) -> PackedVector2Array:
	var horizontal_distance := maxf(absf(to_position.x - from_position.x) * 0.5, 80.0)
	var control_a := from_position + Vector2(horizontal_distance, 0.0)
	var control_b := to_position - Vector2(horizontal_distance, 0.0)
	var points := PackedVector2Array()
	const STEPS := 32
	for index in range(STEPS + 1):
		var t := float(index) / float(STEPS)
		points.append(from_position.bezier_interpolate(control_a, control_b, to_position, t))
	return points


func _draw_connection(
	from_position: Vector2,
	to_position: Vector2,
	color: Color,
	width: float,
	curve: bool
) -> bool:
	var semantic_type := _edge_semantic_for_draw(from_position, to_position)
	var noodle_color := Color(0.8, 0.2, 0.2)
	var noodle_width := 3.0
	if semantic_type == "memory_consolidation":
		noodle_color = Color(0.2, 0.8, 0.2)
		noodle_width = 6.0
	elif semantic_type == "supersedes":
		noodle_color = Color(0.55, 0.7, 0.9)
		noodle_width = 3.0

	draw_polyline(_bezier_points(from_position, to_position), noodle_color, noodle_width, true)
	return true
```

This intentionally uses `draw_polyline()` rather than dash logic: the requested RED curve is red, and the GREEN curve is solid and twice as heavy. The `color`, `width`, and `curve` virtual parameters remain present to match Godot 4's override signature, even though custom semantic styles replace the supplied theme color, width, and curve setting.

The implementation task must run the GUI and confirm the calculated port coordinates align at the project's target Godot 4 minor version. If a target version reports `_draw_connection` with a different virtual signature, update only the function signature to the engine's generated override while preserving the method body.

## 4. Right-Click Semantic Toggle

Replace the single edge-menu constant and add a context edge array near the existing menu and context variables:

```gdscript
const MENU_EDGE_TOGGLE_FIRST := 100

var _context_edge_ids: Array[String] = []
```

In `_on_graph_node_input()`, immediately before `var edge_index`, clear the context list and replace the edge-menu loop with:

```gdscript
		_context_edge_ids.clear()
		var edge_index: int = MENU_EDGE_TOGGLE_FIRST
		for edge in _edge_data.values():
			if str(edge.get("source_node_id", "")) != node_id:
				continue
			var edge_id := str(edge.get("id", ""))
			var semantic_type := str(edge.get("semantic_type", "text"))
			var target_id := str(edge.get("target_node_id", ""))
			var target_label := target_id.get_slice("-", 1)
			var action_label := "Set Edge → " + target_label + " to Memory Consolidation (GREEN)"
			if semantic_type == "memory_consolidation":
				action_label = "Set Edge → " + target_label + " to Basic Text (RED)"
			_popup_menu.add_item(action_label, edge_index)
			_context_edge_ids.append(edge_id)
			edge_index += 1
```

Replace the edge branch in `_on_popup_action()` with:

```gdscript
		_:
			if id >= MENU_EDGE_TOGGLE_FIRST:
				_toggle_context_edge(id - MENU_EDGE_TOGGLE_FIRST)
```

Replace `_toggle_edge_by_menu_index()` with:

```gdscript
func _toggle_context_edge(menu_index: int):
	if menu_index < 0 or menu_index >= _context_edge_ids.size():
		return
	var edge_id := _context_edge_ids[menu_index]
	for edge in _edge_data.values():
		if str(edge.get("id", "")) != edge_id:
			continue
		var semantic_type := str(edge.get("semantic_type", "text"))
		var new_type := "memory_consolidation" if semantic_type == "text" else "text"
		_toggle_edge_type(edge_id, new_type)
		return
```

The existing `_toggle_edge_type()` PATCH request already updates an edge's `semantic_type`. Retain it, but after the successful local update in `_on_edge_toggle_response()`, request a repaint so the custom noodle changes immediately:

```gdscript
				ed["semantic_type"] = new_type
				queue_redraw()
				break
```

## 5. Implementation Verification

1. Start the API with a fresh database and verify OpenAPI accepts `text`, `memory_consolidation`, and `supersedes`, while rejecting the two retired values.
2. Create one `text` and one `memory_consolidation` edge, then cook a composite node. Confirm text is inline and the memory consolidation is prefixed by `> ` and followed by a newline.
3. Load the Godot GUI and confirm `_edge_data` includes each edge ID, semantic type, and source/target port indexes.
4. Confirm a `text` connection draws as the red Bezier curve and a `memory_consolidation` connection draws as the solid green curve with a visibly larger width.
5. Right-click a source node, select its edge action, and confirm the label changes between `Basic Text (RED)` and `Memory Consolidation (GREEN)`, the PATCH succeeds, and the noodle repaints immediately.
6. Confirm a `supersedes` edge continues to draw with its separate blue/silver style and does not participate in the RED/GREEN toggle.
