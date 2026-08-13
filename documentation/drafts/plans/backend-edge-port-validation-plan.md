# Backend Edge Port Validation Implementation Plan

## Objective

Fix unresolved High audit finding F-06 from `documentation/drafts/audits/audit-api-coherence.md`: `POST /edges` currently persists arbitrary port names after checking only that the endpoint nodes exist. Make the backend reject a data edge unless its source port is a declared output and its target port is a declared input. Keep history creation under the existing atomic `fork_node()` operation by rejecting direct `supersedes` creation through `GraphStore.add_edge()`.

This is the highest-priority unresolved audited defect. The earlier Critical semantic-type, locked-node race, and fork-atomicity findings are already fixed in the live code. Existing plans do not cover backend port validation.

## Scope

Modify exactly:

- `product/tendril/api/graph.py`
- `product/tendril/api/main.py`
- `product/tendril/api/test_graph.py` (new)

Do not modify the GUI, database schema, node/edge Pydantic models, or persisted database. Do not add dependencies.

## Implementation Steps

### 1. Validate Edge Semantics and Port Direction in `GraphStore.add_edge()`

In `product/tendril/api/graph.py`, replace the complete existing `GraphStore.add_edge()` method with this exact implementation:

```python
    def add_edge(self, edge: Edge) -> Edge:
        if edge.semantic_type == "supersedes":
            raise ValueError("Supersedes edges can only be created by fork_node")
        if not edge.id:
            edge.id = str(uuid.uuid4())

        with self._connection() as conn:
            source_row = conn.execute(
                "SELECT * FROM nodes WHERE id = ?", (edge.source_node_id,)
            ).fetchone()
            if source_row is None:
                raise KeyError(f"Source node {edge.source_node_id} not found")

            target_row = conn.execute(
                "SELECT * FROM nodes WHERE id = ?", (edge.target_node_id,)
            ).fetchone()
            if target_row is None:
                raise KeyError(f"Target node {edge.target_node_id} not found")

            source = self._row_to_node(source_row)
            if edge.source_port_name not in {port.name for port in source.outputs}:
                raise ValueError(
                    f"Source port {edge.source_port_name} is not an output of node "
                    f"{edge.source_node_id}"
                )

            target = self._row_to_node(target_row)
            if edge.target_port_name not in {port.name for port in target.inputs}:
                raise ValueError(
                    f"Target port {edge.target_port_name} is not an input of node "
                    f"{edge.target_node_id}"
                )

            with conn:
                conn.execute(
                    "INSERT INTO edges (id, source_node_id, source_port_name,"
                    " target_node_id, target_port_name, semantic_type)"
                    " VALUES (?, ?, ?, ?, ?, ?)",
                    (
                        edge.id,
                        edge.source_node_id,
                        edge.source_port_name,
                        edge.target_node_id,
                        edge.target_port_name,
                        edge.semantic_type,
                    ),
                )
        return edge
```

The validation and insert remain inside one `_connection()` lock scope. Validate against `source.outputs` and `target.inputs`, not against the union of both port collections. This enforces direction as well as name existence.

Do not route `supersedes` through this method. `fork_node()` already creates its node and history edge in one transaction; allowing `POST /edges` to create history relationships would bypass that invariant.

### 2. Return HTTP 400 for Port and History Validation Failures

In `product/tendril/api/main.py`, replace the complete `create_edge()` route with:

```python
@app.post("/edges", status_code=201)
async def create_edge(edge: Edge) -> Edge:
    try:
        return store.add_edge(edge)
    except (KeyError, ValueError) as e:
        raise HTTPException(status_code=400, detail=str(e))
```

Keep missing endpoint nodes as HTTP 400, matching current behavior. Port-direction failures and attempts to directly create `supersedes` edges must also be deliberate client errors rather than unhandled HTTP 500 responses.

### 3. Add Focused Standard-Library Tests

Create `product/tendril/api/test_graph.py` with exactly this content:

```python
import tempfile
import unittest
from pathlib import Path

from graph import GraphStore
from models import Edge, Node, Port


class EdgePortValidationTests(unittest.TestCase):
    def setUp(self) -> None:
        self._temporary_directory = tempfile.TemporaryDirectory(
            dir=Path(__file__).parent
        )
        database_path = Path(self._temporary_directory.name) / "test.db"
        self.store = GraphStore(database_path)
        self.source = self.store.add_node(
            Node(
                id="source",
                type="composite_text",
                inputs=[Port(name="source_input")],
                outputs=[Port(name="combined_text")],
            )
        )
        self.target = self.store.add_node(
            Node(
                id="target",
                type="composite_text",
                inputs=[Port(name="context")],
                outputs=[Port(name="target_output")],
            )
        )

    def tearDown(self) -> None:
        self._temporary_directory.cleanup()

    def _edge(
        self,
        source_port_name: str = "combined_text",
        target_port_name: str = "context",
        semantic_type: str = "text",
    ) -> Edge:
        return Edge(
            source_node_id=self.source.id,
            source_port_name=source_port_name,
            target_node_id=self.target.id,
            target_port_name=target_port_name,
            semantic_type=semantic_type,
        )

    def test_accepts_declared_output_to_declared_input(self) -> None:
        edge = self.store.add_edge(self._edge())

        self.assertTrue(edge.id)
        workspace_edges = self.store.get_workspace()["edges"]
        self.assertEqual([edge.id], [stored.id for stored in workspace_edges])

    def test_rejects_unknown_source_output(self) -> None:
        with self.assertRaisesRegex(ValueError, "Source port missing"):
            self.store.add_edge(self._edge(source_port_name="missing"))

    def test_rejects_source_input_used_as_output(self) -> None:
        with self.assertRaisesRegex(ValueError, "Source port source_input"):
            self.store.add_edge(self._edge(source_port_name="source_input"))

    def test_rejects_unknown_target_input(self) -> None:
        with self.assertRaisesRegex(ValueError, "Target port missing"):
            self.store.add_edge(self._edge(target_port_name="missing"))

    def test_rejects_target_output_used_as_input(self) -> None:
        with self.assertRaisesRegex(ValueError, "Target port target_output"):
            self.store.add_edge(self._edge(target_port_name="target_output"))

    def test_rejects_direct_supersedes_creation(self) -> None:
        with self.assertRaisesRegex(
            ValueError, "Supersedes edges can only be created by fork_node"
        ):
            self.store.add_edge(self._edge(semantic_type="supersedes"))


if __name__ == "__main__":
    unittest.main()
```

The temporary SQLite directory is explicitly created beneath `product/tendril/api/` and removed by `tearDown()`, so test execution stays inside the project perimeter and leaves no database artifact behind.

### 4. Preserve Atomic Fork Behavior

Do not change `GraphStore.fork_node()`. Its direct history-edge insert is intentional: the new node and `supersedes` edge must remain in the same connection and transaction. The new `add_edge()` guard applies only to direct edge creation, including `POST /edges`.

## Verification

Run all commands from `product/tendril/api/`.

1. Run the focused tests:

```bash
python -m unittest -v test_graph.py
```

Expected result: all six tests report `ok`, followed by `Ran 6 tests` and `OK`.

2. Parse every backend Python module without writing bytecode:

```bash
python -c 'import ast; from pathlib import Path; paths = ("graph.py", "main.py", "models.py", "test_graph.py"); [ast.parse(Path(path).read_text(), filename=path) for path in paths]'
```

Expected result: exit status 0 and no syntax errors.

3. Confirm the test did not leave temporary databases:

```bash
git status --short product/tendril/api/
```

Expected result: only the intended modifications to `graph.py`, `main.py`, and new `test_graph.py` appear. No generated temporary directory or `.db` file appears.

4. Start the API using the existing project environment:

```bash
./venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000
```

Using the running API, verify these outcomes through `POST /edges`:

- A `text` edge from a declared source output to a declared target input returns HTTP 201.
- An edge with an unknown source port returns HTTP 400 with a `Source port ... is not an output` detail.
- An edge that names a source input as `source_port_name` returns HTTP 400.
- An edge with an unknown target port returns HTTP 400 with a `Target port ... is not an input` detail.
- An edge that names a target output as `target_port_name` returns HTTP 400.
- A direct `supersedes` edge returns HTTP 400 with `Supersedes edges can only be created by fork_node`.

5. Regression-check the existing fork path: lock a node, call `POST /nodes/{node_id}/fork`, and confirm HTTP 201. Then call `GET /workspace` and confirm the new unlocked node and its original-to-new `supersedes` edge both exist. This proves the atomic internal history path was not blocked by direct-edge validation.

Success requires all automated checks to pass, the HTTP behavior above to be observed, and no file outside the three-file implementation scope to be modified.
