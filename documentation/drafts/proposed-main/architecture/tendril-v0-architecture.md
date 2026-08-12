# TENDRIL PROJECT HANDOVER: V0 ARCHITECTURE & IMPLEMENTATION PLAN

## 1. Executive Summary
This document outlines the finalized architecture for Tendril V0. Tendril is a provenance-first, spatial context-management system. It replaces degrading, linear chat context windows with a functional, port-based Directed Acyclic Graph (DAG). 

V0 is restricted to a 2D node graph interface to ensure rapid development and high-performance text editing. However, the underlying data model and backend infrastructure are explicitly designed to support a 3D spatial topology in V1.

The core value proposition of V0 is proving the core workflow: taking messy, bloated chat narratives (RED), manually extracting stable decisions (GREEN), compressing the narrative, and feeding a lean, highly focused context packet into a new branch of work.

## 2. Tech Stack: Godot 4 (Native Client) + Python (Backend)
Tendril must feel like Houdini, Nuke, or TouchDesigner—a butter-smooth native spatial UI. Web-based frameworks (WebGL/DOM) fail at high-density text rendering in spatial canvases.

*   **Godot 4 (V0 2D):** We will use Godot's native 2D `Control` and `GraphEdit` systems. This provides infinite canvas panning/zooming, crisp OS-level text rendering, and native `TextEdit` inputs.
*   **Godot 4 (V1 3D Upgrade Path):** Godot's unified rendering pipeline allows us to swap the 2D canvas for a 3D viewport (`Node3D`) without rewriting application logic or the backend API. 
*   **Thin Client Mandate:** Godot is strictly a projection of backend API state. It holds no domain logic. All state changes are dispatched via `HTTPRequest`.
*   **Performance (LOD Strategy):** To prevent lag with large text blocks, the Godot frontend must implement a Level of Detail (LOD) strategy. Zoomed-out nodes render a cached thumbnail or truncated text (`Label`). Only zoomed-in or actively focused nodes spawn the heavy `TextEdit` elements.

## 3. The Functional Node Model (TouchDesigner Paradigm)
Tendril V0 is a functional dataflow pipeline inspired by TouchDesigner's Data Operators (DATs). 

*   **Named Text Channels:** Nodes possess arrays of named input and output ports. All data passing through is treated as text strings.
*   **Dynamic Ports:** Users can dynamically add/remove named input ports on operator nodes.
*   **V0 Node Types:**
    1.  **Text Source Node:** 0 inputs, 1 output (`text_out`). Holds raw, user-typed/pasted text.
    2.  **File Source Node:** 0 inputs, 1 output (`text_out`). Backend `cook` method reads a file path from disk and returns text. (Spawns as read-only/stable).
    3.  **Composite Text Node:** Dynamic user-defined inputs, 1 output (`combined_text`). Uses a template property to concatenate upstream text.
    4.  **Extraction Node (Manual):** Represents the "Extract Decisions" box. User manually reads upstream context and types stable facts. Outputs `stable_text`.
    5.  **Compression Node (Manual):** Represents the "Compress Narrative" box. User manually writes a thin narrative summary. Outputs `compressed_narrative`.
    6.  **Monitor Node (Context Output):** Generated when a user "Cooks" a node. Displays the compiled context text directly in the 2D canvas, keeping the user in the spatial workspace.

## 4. Backend `tendril-api`: A DAG Execution Engine
The Python backend is a graph traversal and execution engine.

**1. Graph Traversal & "Cooking":**
`POST /nodes/{id}/cook` triggers recursive upstream traversal. The engine fetches text from connected output ports, passes the text dictionary to the target node's Operator class, executes the logic, and returns the final compiled string. The engine must implement cycle detection and handle missing/unconnected inputs gracefully (passing empty strings).

**2. Semantic-Aware Template Engine:**
Edges are strictly typed (`text` / RED, `memory_consolidation` / GREEN). RED denotes basic text: raw prompt text, chat text, model responses, and other unconsolidated textual content. GREEN denotes extracted memory consolidations: decisions, invariants, derived constraints, definitions, and stable facts promoted to durable memory. The `cook` engine passes the `semantic_type` to the template renderer alongside the text. The template syntax must support conditional formatting based on this (e.g., rendering GREEN inputs as markdown blockquotes or footnotes, and RED inputs as inline text).

**3. Immutability & Forking Rules:**
History is immutable. The backend enforces this.
*   If a node is `is_locked = true`, `PATCH` requests to modify its text are **rejected**.
*   To edit a locked node, the GUI calls `POST /nodes/{id}/fork`. The backend duplicates the node, copies properties, sets the new node to `is_locked = false`, and automatically generates a `supersedes` edge.
*   **Traversal Rule:** If the cook engine encounters a node that has been superseded (an outgoing `supersedes` edge), it must dynamically reroute to the superseding node to ensure compiled context reflects the *current* state of decisions.

## 5. Spatial Semantics & Visual Language (2D for V0)
V0 uses a standard flat 2D graph layout. Nodes can be placed freely anywhere on the X/Y plane. There is no enforced vertical or horizontal semantic gravity in V0.

*   **V0 Data Contract Guarantee:** The GUI maps 2D screen coordinates to a 3D vector before sending to the API: `position: {"x": 150.0, "y": -200.0, "z": 0.0}`. Z is hardcoded to `0.0` for V0.
*   **Node States (Unlocked vs Locked):**
    *   *Unlocked:* Editable.
    *   *Locked:* Read-only.
*   **Edge (Noodle) Styles:**
    *   `text` (RED): Ports and noodles represent basic text: raw prompt text, chat text, model responses, and other unconsolidated textual content. Noodles are emissive and slightly dashed.
    *   `memory_consolidation` (GREEN): Ports and noodles represent extracted memory consolidations: decisions, invariants, derived constraints, definitions, and stable facts promoted to durable memory. Noodles remain solid and visually heavier than RED noodles.
    *   `supersedes` (Fork): Distinct metallic silver or blue dashed line to trace non-destructive edit history without confusing it with active context flow.

## 6. V0 API State Contract

**Node Object:**
```json
{
  "id": "node_01",
  "type": "composite_text",
  "is_locked": false,
  "position": {"x": 150.0, "y": -200.0, "z": 0.0},
  "inputs": [
    {"name": "header"},
    {"name": "body"}
  ],
  "outputs": [
    {"name": "combined_text"}
  ],
  "properties": {
    "template": "{{header}}\n---\n{{body}}"
  }
}
```
