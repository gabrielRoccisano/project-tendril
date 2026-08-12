import json
import sqlite3
import threading
import uuid
from contextlib import contextmanager
from pathlib import Path

from models import CookResponse, Edge, Node, NodeProperties, Port, Position3D


class GraphStore:
    def __init__(self, db_path: str | Path = "tendril.db") -> None:
        self._db_path = str(db_path)
        self._lock = threading.Lock()
        self._apply_migrations()

    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self._db_path)
        conn.row_factory = sqlite3.Row
        return conn

    @contextmanager
    def _connection(self):
        with self._lock:
            conn = self._connect()
            try:
                yield conn
            finally:
                conn.close()

    def _apply_migrations(self) -> None:
        migrations_path = Path(__file__).with_name("migrations.sql")
        with self._connection() as conn:
            conn.executescript(migrations_path.read_text())

    def _row_to_node(self, row: sqlite3.Row) -> Node:
        return Node(
            id=row["id"],
            type=row["type"],
            is_locked=bool(row["is_locked"]),
            position=Position3D(
                x=row["position_x"],
                y=row["position_y"],
                z=row["position_z"],
            ),
            inputs=[Port(**port) for port in json.loads(row["inputs"])],
            outputs=[Port(**port) for port in json.loads(row["outputs"])],
            properties=NodeProperties(**json.loads(row["properties"])),
            content=row["content"],
        )

    def _node_to_row(self, node: Node) -> tuple:
        return (
            node.id,
            node.type,
            int(node.is_locked),
            node.position.x,
            node.position.y,
            node.position.z,
            json.dumps([port.model_dump() for port in node.inputs]),
            json.dumps([port.model_dump() for port in node.outputs]),
            json.dumps(node.properties.model_dump()),
            node.content,
        )

    def _row_to_edge(self, row: sqlite3.Row) -> Edge:
        return Edge(
            id=row["id"],
            source_node_id=row["source_node_id"],
            source_port_name=row["source_port_name"],
            target_node_id=row["target_node_id"],
            target_port_name=row["target_port_name"],
            semantic_type=row["semantic_type"],
        )

    def add_node(self, node: Node) -> Node:
        if not node.id:
            node.id = str(uuid.uuid4())
        with self._connection() as conn:
            with conn:
                conn.execute(
                    "INSERT INTO nodes (id, type, is_locked, position_x, position_y,"
                    " position_z, inputs, outputs, properties, content)"
                    " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    self._node_to_row(node),
                )
        return node

    def get_node(self, node_id: str) -> Node:
        with self._connection() as conn:
            row = conn.execute(
                "SELECT * FROM nodes WHERE id = ?", (node_id,)
            ).fetchone()
        if row is None:
            raise KeyError(f"Node {node_id} not found")
        return self._row_to_node(row)

    def update_node(self, node_id: str, patch: dict) -> Node:
        existing = self.get_node(node_id)
        if existing.is_locked:
            raise ValueError(f"Node {node_id} is locked")
        merged = existing.model_copy(deep=True)
        for field, value in patch.items():
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

    def add_edge(self, edge: Edge) -> Edge:
        if not edge.id:
            edge.id = str(uuid.uuid4())
        with self._connection() as conn:
            if not conn.execute(
                "SELECT 1 FROM nodes WHERE id = ?", (edge.source_node_id,)
            ).fetchone():
                raise KeyError(f"Source node {edge.source_node_id} not found")
            if not conn.execute(
                "SELECT 1 FROM nodes WHERE id = ?", (edge.target_node_id,)
            ).fetchone():
                raise KeyError(f"Target node {edge.target_node_id} not found")
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

    def update_edge(self, edge_id: str, edge: Edge) -> Edge:
        with self._connection() as conn:
            existing = conn.execute(
                "SELECT * FROM edges WHERE id = ?", (edge_id,)
            ).fetchone()
            if existing is None:
                raise KeyError(f"Edge {edge_id} not found")
            with conn:
                conn.execute(
                    "UPDATE edges SET semantic_type = ? WHERE id = ?",
                    (edge.semantic_type, edge_id),
                )
            updated = conn.execute(
                "SELECT * FROM edges WHERE id = ?", (edge_id,)
            ).fetchone()
        return self._row_to_edge(updated)

    def get_workspace(self) -> dict:
        with self._connection() as conn:
            node_rows = conn.execute("SELECT * FROM nodes").fetchall()
            edge_rows = conn.execute("SELECT * FROM edges").fetchall()
        return {
            "nodes": [self._row_to_node(row) for row in node_rows],
            "edges": [self._row_to_edge(row) for row in edge_rows],
        }

    def _fetch_node(self, node_id: str) -> Node:
        return self.get_node(node_id)

    def _fetch_edges(self) -> list[Edge]:
        with self._connection() as conn:
            rows = conn.execute("SELECT * FROM edges").fetchall()
        return [self._row_to_edge(row) for row in rows]

    def cook(self, node_id: str) -> CookResponse:
        traversed_nodes: list[str] = []
        traversed_edges: list[str] = []
        visiting: set[str] = set()

        def _resolve_supersedes(nid: str) -> str:
            current = nid
            visited_nodes: set[str] = set()
            while True:
                if current in visited_nodes:
                    raise ValueError(f"Cycle detected at node {current}")
                visited_nodes.add(current)
                superseded = None
                for edge in edges:
                    if (
                        edge.source_node_id == current
                        and edge.semantic_type == "supersedes"
                    ):
                        superseded = edge.target_node_id
                        break
                if superseded is None:
                    return current
                current = superseded

        def _cook_node(nid: str) -> str:
            nid = _resolve_supersedes(nid)

            if nid in visiting:
                raise ValueError(f"Cycle detected at node {nid}")

            node = self._fetch_node(nid)

            if node.type == "file_source":
                if nid not in traversed_nodes:
                    traversed_nodes.append(nid)
                file_path = node.content or node.properties.template
                if not file_path:
                    return ""
                try:
                    return Path(file_path).read_text()
                except FileNotFoundError:
                    return "[Error: File Not Found]"

            if node.type in ("text_source", "extraction", "compression", "monitor"):
                if nid not in traversed_nodes:
                    traversed_nodes.append(nid)
                return node.content

            if node.type == "composite_text":
                visiting.add(nid)

                upstream_texts: dict[str, str] = {}
                for port in node.inputs:
                    text = ""
                    for edge in edges:
                        if (
                            edge.target_node_id == nid
                            and edge.target_port_name == port.name
                            and edge.semantic_type != "supersedes"
                        ):
                            if edge.id not in traversed_edges:
                                traversed_edges.append(edge.id)
                            raw = _cook_node(edge.source_node_id)
                            if edge.semantic_type == "stable_reference":
                                text = "> " + raw + "\n"
                            else:
                                text = raw
                            break
                    upstream_texts[port.name] = text

                visiting.discard(nid)

                if nid not in traversed_nodes:
                    traversed_nodes.append(nid)

                result = node.properties.template
                for port_name, text in upstream_texts.items():
                    result = result.replace("{{" + port_name + "}}", text)
                return result

            if nid not in traversed_nodes:
                traversed_nodes.append(nid)
            return node.content

        edges = self._fetch_edges()
        compiled_text = _cook_node(node_id)
        return CookResponse(
            compiled_text=compiled_text,
            traversed_node_ids=traversed_nodes,
            traversed_edges=traversed_edges,
        )

    def fork_node(self, node_id: str) -> Node:
        original = self.get_node(node_id)
        new_node = original.model_copy(deep=True)
        new_node.id = str(uuid.uuid4())
        new_node.is_locked = False
        self.add_node(new_node)

        source_port = original.outputs[0].name if original.outputs else "text_out"
        target_port = new_node.inputs[0].name if new_node.inputs else "text_in"

        supersedes_edge = Edge(
            id=str(uuid.uuid4()),
            source_node_id=original.id,
            source_port_name=source_port,
            target_node_id=new_node.id,
            target_port_name=target_port,
            semantic_type="supersedes",
        )
        self.add_edge(supersedes_edge)

        return new_node
