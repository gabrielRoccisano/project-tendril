-- Tendril workspace schema
-- Executed on GraphStore startup; CREATE TABLE IF NOT EXISTS keeps it idempotent.

CREATE TABLE IF NOT EXISTS nodes (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    is_locked INTEGER NOT NULL DEFAULT 0,
    position_x REAL NOT NULL DEFAULT 0.0,
    position_y REAL NOT NULL DEFAULT 0.0,
    position_z REAL NOT NULL DEFAULT 0.0,
    inputs TEXT NOT NULL DEFAULT '[]',
    outputs TEXT NOT NULL DEFAULT '[]',
    properties TEXT NOT NULL DEFAULT '{}',
    content TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS edges (
    id TEXT PRIMARY KEY,
    source_node_id TEXT NOT NULL,
    source_port_name TEXT NOT NULL,
    target_node_id TEXT NOT NULL,
    target_port_name TEXT NOT NULL,
    semantic_type TEXT NOT NULL
);
