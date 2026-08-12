import uuid
from pathlib import Path

from models import CookResponse, Edge, Node


class GraphStore:
    def __init__(self) -> None:
        self._nodes: dict[str, Node] = {}
        self._edges: dict[str, Edge] = {}

    def add_node(self, node: Node) -> Node:
        if not node.id:
            node.id = str(uuid.uuid4())
        self._nodes[node.id] = node
        return node

    def get_node(self, node_id: str) -> Node:
        if node_id not in self._nodes:
            raise KeyError(f"Node {node_id} not found")
        return self._nodes[node_id]

    def update_node(self, node_id: str, node: Node) -> Node:
        existing = self._nodes.get(node_id)
        if existing is None:
            raise KeyError(f"Node {node_id} not found")
        if existing.is_locked:
            raise ValueError(f"Node {node_id} is locked")
        node.id = node_id
        self._nodes[node_id] = node
        return node

    def add_edge(self, edge: Edge) -> Edge:
        if not edge.id:
            edge.id = str(uuid.uuid4())
        if edge.source_node_id not in self._nodes:
            raise KeyError(f"Source node {edge.source_node_id} not found")
        if edge.target_node_id not in self._nodes:
            raise KeyError(f"Target node {edge.target_node_id} not found")
        self._edges[edge.id] = edge
        return edge

    def get_workspace(self) -> dict:
        return {
            "nodes": list(self._nodes.values()),
            "edges": list(self._edges.values()),
        }

    def cook(self, node_id: str) -> CookResponse:
        traversed_nodes: list[str] = []
        traversed_edges: list[str] = []
        visiting: set[str] = set()

        def _resolve_supersedes(nid: str) -> str:
            current = nid
            while True:
                superseded = None
                for edge in self._edges.values():
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

            node = self._nodes[nid]

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
                    for edge in self._edges.values():
                        if (
                            edge.target_node_id == nid
                            and edge.target_port_name == port.name
                            and edge.semantic_type != "supersedes"
                        ):
                            if edge.id not in traversed_edges:
                                traversed_edges.append(edge.id)
                            text = _cook_node(edge.source_node_id)
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

        compiled_text = _cook_node(node_id)
        return CookResponse(
            compiled_text=compiled_text,
            traversed_node_ids=traversed_nodes,
            traversed_edges=traversed_edges,
        )

    def fork_node(self, node_id: str) -> Node:
        original = self._nodes[node_id]
        new_node = original.model_copy(deep=True)
        new_node.id = str(uuid.uuid4())
        new_node.is_locked = False
        self._nodes[new_node.id] = new_node

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
        self._edges[supersedes_edge.id] = supersedes_edge

        return new_node
