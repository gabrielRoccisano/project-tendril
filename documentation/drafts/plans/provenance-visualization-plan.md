# Provenance Visualization Implementation Plan

## Purpose

Update `product/tendril/gui/main.gd` so a successful cook response visually proves the backend DAG traversal. The backend `CookResponse` JSON contains exactly these fields:

```json
{
  "compiled_text": "...",
  "traversed_node_ids": ["node-a", "node-b"],
  "traversed_edges": ["edge-a"]
}
```

`traversed_node_ids` is the visualization input. Do not derive traversal locally from `_edge_data`; the GUI remains a projection of the backend response.

## 1. Reserve the Canvas Menu Action

Add this constant directly after the existing `MENU_SPAWN_FILE_SOURCE` constant and before `MENU_EDGE_FIRST`:

```gdscript
const MENU_CLEAR_HIGHLIGHTS := 7
```

The value `7` does not overlap with the existing fixed menu IDs `0` through `6`, and stays below `MENU_EDGE_FIRST` (`100`).

## 2. Add Provenance Helpers

Add these methods as top-level methods in `main.gd`, preferably immediately before `_on_canvas_popup`. They operate on the existing `_graphnodes: Dictionary`, whose keys are backend node IDs and whose values are spawned `GraphNode` instances.

```gdscript
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
```

`node_id in traversed_node_ids` compares the string key from `_graphnodes` to the string IDs supplied by `CookResponse`. The highlight state uses full opacity. All non-traversed nodes are dimmed. The reset changes only `modulate`, so locked-node styles and existing port/theme overrides remain intact.

## 3. Parse and Apply Cook Provenance

In `_on_cook_response`, replace the successful-response body from the existing `var json = ...` line through `_spawn_monitor_node(compiled)` with this code:

```gdscript
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json is Dictionary:
			var compiled: String = str(json.get("compiled_text", ""))
			var traversed_node_ids: Array = json.get("traversed_node_ids", [])
			_apply_provenance_highlights(traversed_node_ids)
			print("[Tendril] Cook result:\n", compiled)
			_show_cook_dialog(compiled)
			_spawn_monitor_node(compiled)
		else:
			print("[Tendril] Invalid cook response JSON")
```

The resulting full response handler should be:

```gdscript
func _on_cook_response(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json is Dictionary:
			var compiled: String = str(json.get("compiled_text", ""))
			var traversed_node_ids: Array = json.get("traversed_node_ids", [])
			_apply_provenance_highlights(traversed_node_ids)
			print("[Tendril] Cook result:\n", compiled)
			_show_cook_dialog(compiled)
			_spawn_monitor_node(compiled)
		else:
			print("[Tendril] Invalid cook response JSON")
	else:
		print("[Tendril] Cook failed: ", response_code, " - ", body.get_string_from_utf8())
```

This deliberately applies provenance before spawning the monitor node. The monitor is a frontend artifact created after the backend cook response and is not among the response's traversed source IDs.

## 4. Add Clear Highlights to the Canvas Menu

In `_on_canvas_popup`, add the following menu item after the three spawn entries and before assigning `_popup_menu.position`:

```gdscript
	_popup_menu.add_separator()
	_popup_menu.add_item("Clear Highlights", MENU_CLEAR_HIGHLIGHTS)
```

The completed menu-construction block is:

```gdscript
	_popup_menu.clear()
	_popup_menu.add_item("Spawn Text Node", MENU_SPAWN_TEXT)
	_popup_menu.add_item("Spawn File Source Node", MENU_SPAWN_FILE_SOURCE)
	_popup_menu.add_item("Spawn Composite Node", MENU_SPAWN_COMPOSITE)
	_popup_menu.add_separator()
	_popup_menu.add_item("Clear Highlights", MENU_CLEAR_HIGHLIGHTS)
	_popup_menu.position = get_screen_position() + at_position
	_popup_menu.popup()
```

This action belongs only in the canvas context menu. Do not add it to the node-specific context menu in `_on_graph_node_input`.

## 5. Dispatch the Reset Action

In `_on_popup_action`, add this match branch before `MENU_COOK`:

```gdscript
		MENU_CLEAR_HIGHLIGHTS:
			_clear_provenance_highlights()
```

The relevant portion becomes:

```gdscript
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
```

## 6. Implementation Verification

After making the planned `main.gd` changes, verify:

1. `CookResponse` parsing reads `compiled_text` and `traversed_node_ids` from the JSON dictionary.
2. `_apply_provenance_highlights` visits every `_graphnodes` entry, fully displays traversed nodes, and dims every other spawned node.
3. Right-clicking blank canvas space displays `Clear Highlights`.
4. Selecting `Clear Highlights` sets every spawned `GraphNode.modulate` to `Color(1, 1, 1, 1)`.
5. A failed or invalid cook response does not alter current highlight state.
6. Existing monitor creation, cook dialog display, node context menu actions, and locked-node styling remain unchanged.
