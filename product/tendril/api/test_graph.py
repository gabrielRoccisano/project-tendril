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
