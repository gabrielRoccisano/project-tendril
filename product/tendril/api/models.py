from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field


class Position3D(BaseModel):
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0


class Port(BaseModel):
    name: str


NodeType = Literal[
    "text_source",
    "file_source",
    "composite_text",
    "extraction",
    "compression",
    "monitor",
]


class NodeProperties(BaseModel):
    template: str = ""


class Node(BaseModel):
    id: str = ""
    type: NodeType
    is_locked: bool = False
    content: str = ""
    position: Position3D = Field(default_factory=Position3D)
    inputs: list[Port] = Field(default_factory=list)
    outputs: list[Port] = Field(default_factory=list)
    properties: NodeProperties = Field(default_factory=NodeProperties)


SemanticType = Literal[
    "narrative_context",
    "stable_reference",
    "supersedes",
]


class Edge(BaseModel):
    id: str = ""
    source_node_id: str
    source_port_name: str
    target_node_id: str
    target_port_name: str
    semantic_type: SemanticType


class CookResponse(BaseModel):
    compiled_text: str
    traversed_node_ids: list[str]
    traversed_edges: list[str]
