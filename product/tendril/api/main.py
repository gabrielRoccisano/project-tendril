from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from graph import GraphStore
from models import CookResponse, Edge, Node, NodeProperties, NodeType, Port, Position3D


class NodePatch(BaseModel):
    type: NodeType | None = None
    is_locked: bool | None = None
    content: str | None = None
    position: Position3D | None = None
    inputs: list[Port] | None = None
    outputs: list[Port] | None = None
    properties: NodeProperties | None = None


app = FastAPI()
store = GraphStore()


@app.get("/health")
async def health_check():
    return {"status": "ok"}


@app.post("/nodes", status_code=201)
async def create_node(node: Node) -> Node:
    return store.add_node(node)


@app.get("/nodes/{node_id}")
async def get_node(node_id: str) -> Node:
    try:
        return store.get_node(node_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="node not found")


@app.patch("/nodes/{node_id}")
async def update_node(node_id: str, node: NodePatch) -> Node:
    try:
        return store.update_node(
            node_id, node.model_dump(exclude_unset=True, exclude_none=True)
        )
    except KeyError:
        raise HTTPException(status_code=404, detail="node not found")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))


@app.post("/edges", status_code=201)
async def create_edge(edge: Edge) -> Edge:
    try:
        return store.add_edge(edge)
    except (KeyError, ValueError) as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/nodes/{node_id}/cook")
async def cook_node(node_id: str) -> CookResponse:
    try:
        return store.cook(node_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="node not found")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/nodes/{node_id}/fork", status_code=201)
async def fork_node(node_id: str) -> Node:
    try:
        return store.fork_node(node_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="node not found")


@app.get("/workspace")
async def get_workspace():
    return store.get_workspace()


@app.patch("/edges/{edge_id}")
async def update_edge(edge_id: str, edge: Edge) -> Edge:
    try:
        return store.update_edge(edge_id, edge)
    except KeyError:
        raise HTTPException(status_code=404, detail="edge not found")
