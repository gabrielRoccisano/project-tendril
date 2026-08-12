# Project Tendril Architecture Vocabulary and Vision Audit

## Search Result

No file named `tendril-network-vision.md`, nor any file containing the exact phrases "Tendril Network Vision" or "Network Vision", was found in the authorized search scope.

The documents below comprise the architecture-named sources, the OAC architecture handover, and the current manifest language that adopts the queried vocabulary. Downstream review and plan documents that materially repeat or assess the vocabulary are identified by exact path and section in Vocabulary Analysis, but are not reproduced as architecture/vision source documents.

## Extracted Documents

### Document 1

**Exact File Path:** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`

**Full Document Contents:**

````markdown
# TENDRIL PROJECT HANDOVER: V0 ARCHITECTURE & IMPLEMENTATION PLAN

## 1. Executive Summary
This document outlines the finalized architecture for Tendril V0. Tendril is a provenance-first, spatial context-management system. It replaces degrading, linear chat context windows with a functional, port-based Directed Acyclic Graph (DAG). 

V0 is restricted to a 2D node graph interface to ensure rapid development and high-performance text editing. However, the underlying data model and backend infrastructure are explicitly designed to support a 3D mycelial spatial topology in V1. 

The core value proposition of V0 is proving the metabolic workflow: taking messy, bloated chat narratives (RED), manually extracting stable decisions (GREEN), compressing the narrative, and feeding a lean, highly focused context packet into a new branch of work.

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

**3. Immutability & Forking (Mycelial Rules):**
History is immutable. The backend enforces this.
*   If a node is `is_locked = true`, `PATCH` requests to modify its text are **rejected**.
*   To edit a locked node, the GUI calls `POST /nodes/{id}/fork`. The backend duplicates the node, copies properties, sets the new node to `is_locked = false`, and automatically generates a `supersedes` edge.
*   **Traversal Rule:** If the cook engine encounters a node that has been superseded (an outgoing `supersedes` edge), it must dynamically reroute to the superseding node to ensure compiled context reflects the *current* state of decisions.

## 5. Spatial Semantics & Visual Language (2D for V0)
Even in the 2D Godot GUI, the canvas has semantic gravity. It is not an arbitrary sandbox.

*   **X-Axis (Progression):** Left to right. Past to future.
*   **Y-Axis (Abstraction):** 
    *   **Bottom of screen (Y > 0): The "Ground".** Stable, locked decisions (GREEN) snap here.
    *   **Top/Middle (Y < 0): The "Canopy".** Uncommitted, exploratory narrative (RED) floats here.
*   **V0 Data Contract Guarantee:** The GUI maps 2D screen coordinates to a 3D vector before sending to the API: `position: {"x": 150.0, "y": -200.0, "z": 0.0}`. Z is hardcoded to `0.0` for V0.
*   **Node States (Live vs. Baked):** 
    *   *Live (Unlocked):* Emissive, subtly pulsing, editable. These are the active exploration edges.
    *   *Baked (Locked):* Matte, solid, read-only. These are frozen history.
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
````

### Document 2

**Exact File Path:** `documentation/drafts/proposed-main/architecture/v0-api-schemas.md`

**Full Document Contents:**

````markdown
# Tendril V0 Backend API Schemas

Status: PROPOSED
Plan Phase: P9 — Tendril Version Zero Headless Runtime
Source Task: close-p3-define-v0-api-schemas

## Purpose

Define the minimal JSON schemas and REST endpoints for the V0 Tendril headless runtime backend. These schemas cover the three core entities — Nodes, Edges, and ContextPackets — plus the endpoints needed to create/read them and trigger context compilation.

Semantics come first. The backend must be functionally usable without a GUI.

---

## Core Entities

### Node

A Node is the fundamental unit of content in the Tendril graph.

```json
{
  "id": "<uuid>",
  "type": "text | file",
  "content": "<string>",
  "metadata": {
    "label": "<string>",
    "created_at": "<ISO-8601 UTC>",
    "updated_at": "<ISO-8601 UTC>",
    "tags": ["<string>"]
  }
}
```

Fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string (UUID) | yes | Unique node identifier |
| `type` | enum: `text`, `file` | yes | Node kind — inline text or file reference |
| `content` | string | yes | Raw content (text body or file path) |
| `metadata` | object | yes | Node metadata |
| `metadata.label` | string | yes | Human-readable label |
| `metadata.created_at` | string (ISO-8601 UTC) | yes | Creation timestamp |
| `metadata.updated_at` | string (ISO-8601 UTC) | yes | Last modification timestamp |
| `metadata.tags` | array of string | no | Arbitrary tags |

`type` semantics:

- `text`: `content` is inline text.
- `file`: `content` is a filesystem path relative to the project root.

---

### Edge

An Edge is a directed relationship between two Nodes.

```json
{
  "id": "<uuid>",
  "source_id": "<uuid>",
  "target_id": "<uuid>",
  "semantic_type": "<string>",
  "metadata": {
    "created_at": "<ISO-8601 UTC>"
  }
}
```

Fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string (UUID) | yes | Unique edge identifier |
| `source_id` | string (UUID) | yes | Source node ID |
| `target_id` | string (UUID) | yes | Target node ID |
| `semantic_type` | string | yes | Label for the relationship semantics |
| `metadata` | object | yes | Edge metadata |
| `metadata.created_at` | string (ISO-8601 UTC) | yes | Creation timestamp |

`semantic_type` direction convention:

An edge from A to B with type X means "A X B". For example:

- `context_for`: source provides context for target.
- `critiques`: source critiques target.
- `extends`: source extends or builds upon target.
- `refines`: source refines target.
- `references`: source references target.

The semantic_type vocabulary is open. The backend stores the label; the human and/or future compilers assign meaning.

---

### ContextPacket

A ContextPacket is the compiled contextual envelope produced by the Context Compiler endpoint. It bundles a target node with the concatenated upstream content needed for its semantic context.

```json
{
  "target_node_id": "<uuid>",
  "compiled_content": "<string>",
  "upstream_node_ids": ["<uuid>"]
}
```

Fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `target_node_id` | string (UUID) | yes | The node for which context was compiled |
| `compiled_content` | string | yes | Upstream content concatenated as a single string |
| `upstream_node_ids` | array of string (UUID) | yes | IDs of all upstream nodes included (ordered by traversal) |

Compilation is recursive and deterministic:

1. Start from `target_node_id`.
2. Walk inbound edges (where `target_id` matches the current node).
3. For each source node, prepend its content (with a header separator identifying the node label).
4. Recurse into each source node's own inbound edges.
5. Detect cycles: each node appears at most once. On re-encounter, include a reference line instead of recursing.
6. Order: breadth-first, then by node creation timestamp within each level.

---

## REST Endpoints

Base path: `/api/v0`

All request and response bodies are JSON. Timestamps are ISO-8601 UTC.

### Nodes

#### POST /api/v0/nodes

Create a new node.

Request body:
```json
{
  "type": "text",
  "content": "Hello, Tendril.",
  "label": "greeting",
  "tags": ["example"]
}
```

Response (201 Created):
```json
{
  "id": "<uuid>",
  "type": "text",
  "content": "Hello, Tendril.",
  "metadata": {
    "label": "greeting",
    "created_at": "2026-08-12T07:00:00Z",
    "updated_at": "2026-08-12T07:00:00Z",
    "tags": ["example"]
  }
}
```

#### GET /api/v0/nodes

List all nodes.

Response (200 OK):
```json
{
  "nodes": [ "<node>", "<node>" ]
}
```

#### GET /api/v0/nodes/:id

Get a single node by ID.

Response (200 OK): `<node>`
Response (404): `{ "error": "node not found" }`

#### PATCH /api/v0/nodes/:id

Update node content and/or label.

Request body (all fields optional):
```json
{
  "content": "Updated content.",
  "label": "new-label",
  "tags": ["tag1", "tag2"]
}
```

Response (200 OK): `<updated node>`

#### DELETE /api/v0/nodes/:id

Delete a node and all edges referencing it.

Response (204 No Content)

---

### Edges

#### POST /api/v0/edges

Create a new edge.

Request body:
```json
{
  "source_id": "<uuid>",
  "target_id": "<uuid>",
  "semantic_type": "context_for"
}
```

Response (201 Created): `<edge>`

Validation:
- Both `source_id` and `target_id` must reference existing nodes.
- Returns 400 if a referenced node does not exist.
- Returns 409 if an edge with the same `source_id`, `target_id`, and `semantic_type` already exists.

#### GET /api/v0/edges

List all edges.

Response (200 OK):
```json
{
  "edges": [ "<edge>", "<edge>" ]
}
```

#### GET /api/v0/edges/:id

Get a single edge by ID.

Response (200 OK): `<edge>`
Response (404): `{ "error": "edge not found" }`

#### DELETE /api/v0/edges/:id

Delete an edge.

Response (204 No Content)

#### GET /api/v0/nodes/:id/edges

Get all edges connected to a node (both inbound and outbound).

Response (200 OK):
```json
{
  "node_id": "<uuid>",
  "inbound": [ "<edge>" ],
  "outbound": [ "<edge>" ]
}
```

---

### Context Compilation

#### POST /api/v0/compile

Trigger deterministic context compilation for a target node.

Request body:
```json
{
  "target_node_id": "<uuid>"
}
```

Response (200 OK): `<ContextPacket>`
Response (404): `{ "error": "node not found" }`

The compiled_content format uses node labels as section headers:

```
=== context_node_label ===
content of context node

=== another_context_label ===
content of another node

=== cycle: cycle_node_label ===
(already included upstream)

=== <target_node_label> ===
target node content
```

The target node's own content appears last. Upstream nodes appear in breadth-first order (closest first), with nodes at equal depth ordered by creation timestamp.

---

## Implementation Notes

1. **Storage**: In-memory is acceptable for V0. Persistence layer can be added later.
2. **Transport**: HTTP/1.1, localhost only for V0. No TLS required.
3. **Authentication**: None for V0. Single-user local development.
4. **Concurrency**: Single-threaded request handling is acceptable for V0.
5. **Content size**: No arbitrary limits for V0, but the compiler should not recurse beyond a default maximum depth (e.g., 50) to prevent runaway compilation.
````

### Document 3

**Exact File Path:** `documentation/drafts/ontological-agent-compiler-handover.md`

**Full Document Contents:**

````markdown
 
# Project Tendril — Ontological Agent Compiler Handover

## Status

The **Ontological Agent Compiler (OAC)** is an adjacent research and architecture stream associated with Project Tendril.

It is **not the Tendril execution engine**, and it is not currently the part being implemented first.

Its purpose is to solve the problem immediately upstream of execution:

> How do we take human intent, ground it against the actual project, and turn it into small, explicit, bounded agent tasks with the right context?

The current Tendril build is deliberately establishing the simple one-task execution primitive first. OAC will later generate inputs for that primitive.

---

## Core Idea

OAC means **Ontological Agent Compiler**.

It compiles the **task world**, not agent software.

Conceptually:

```text
Human intent
    +
Project ontology
    +
Ontological index
    +
Accepted project knowledge
        ↓
       OAC
        ↓
Bounded task-contract candidates
    +
required context
    +
dependencies
    +
explicit ambiguities
```

The compiler's job is to translate a human request into a representation that an execution agent can act on without needing to reconstruct the whole project or infer its own authority.

---

## Primary Function

A human may provide something compound and underspecified, such as:

> Build the isolated Tendril launcher and trusted verification pipeline.

That instruction is too broad for the execution harness.

OAC should be capable of deriving smaller candidate tasks such as:

```text
Define launcher execution contract
Define filesystem visibility contract
Implement worktree creation
Implement execution environment preparation
Implement bounded agent launch
Capture execution result
Implement trusted verification
Integrate the launcher pipeline
```

Each resulting task should be independently bounded and carry only the context required for that task.

The execution agent should not be responsible for performing this decomposition itself.

---

## Prompt Scribe

**Prompt Scribe** is the human-intent ingestion/decomposition concept associated with this process.

Its eventual role is to accept compound human intent and produce simpler discrete task candidates.

For example:

```text
Human compound request
        ↓
Prompt Scribe / OAC
        ↓
candidate task decomposition
        ↓
human review / authorization
        ↓
individual Tendril tasks
```

Prompt Scribe should therefore generate the kind of simple task that the current one-task OpenWork harness can execute.

The sophistication belongs upstream in interpretation and decomposition.

The worker remains simple.

---

## Task Output

A compiled task should eventually contain enough information to define one execution unambiguously.

Likely fields include:

```text
task identity
title
objective
required context
read scope
write scope
allowed capabilities
constraints
dependencies
done conditions
expected evidence
```

The exact task-contract schema is not yet frozen.

The important invariant is that the compiler should emit the **smallest sufficient task and context specification** needed for execution.

---

## Ontological Grounding

OAC is not simply a prompt splitter.

Its distinguishing purpose is to ground decomposition in a representation of the project.

For example, the project ontology may describe:

```text
entities
components
documents
interfaces
dependencies
ownership
authority
relationships
accepted decisions
execution boundaries
```

This allows the compiler to understand that apparently simple human language may refer to specific existing project concepts.

Instead of merely converting:

```text
"update the launcher"
```

into prose, OAC should be able to resolve what **launcher** means in the current project and identify the relevant context and boundaries.

---

## Authority Boundary

OAC is **not an authority source**.

The intended boundary is approximately:

```text
HumanInstruction
+
ProjectOntology
+
OntologicalIndex
+
AcceptedKnowledge

        ↓ OAC

TaskContractCandidate
+
StructuredAmbiguities
```

OAC may:

* interpret human intent;
* identify relevant project entities;
* identify dependencies;
* select candidate context;
* decompose compound work;
* propose task boundaries;
* produce task-contract candidates;
* surface unresolved ambiguity.

OAC may **not independently**:

* authorize execution;
* enlarge human intent;
* make unresolved architectural decisions;
* decide that candidate tasks are approved;
* mount execution environments;
* inject secrets;
* choose trusted verification authority;
* perform Git integration;
* alter Tendril control policy.

Those responsibilities belong elsewhere.

---

## Ambiguity Handling

Where human intent cannot be safely compiled without making an important decision, OAC should surface the ambiguity rather than silently resolve it.

For example:

```text
DECISION REQUIRED

The requested feature could be implemented in either the
controller or the execution worker.

The current accepted architecture does not determine ownership.
```

This should prevent apparently helpful model inference from becoming accidental architecture.

---

## Relationship to Tendril

Tendril ultimately orchestrates work.

OAC helps determine **what the work actually is**.

A simplified future flow is:

```text
                  HUMAN
                    │
             compound intent
                    │
                    ▼
          ONTOLOGICAL AGENT COMPILER
             / Prompt Scribe
                    │
          candidate bounded tasks
                    │
                    ▼
               HUMAN REVIEW
                    │
              authorization
                    │
                    ▼
             PROJECT CONTROL
                    │
               task queue
                    │
                    ▼
          ONE-TASK AGENT HARNESS
                    │
                execution
                    │
                    ▼
          TRUSTED VERIFICATION
```

This preserves the distinction between:

* **interpretation**
* **authorization**
* **execution**
* **verification**

---

## Relationship to Current OpenWork Build

The current Project Tendril OpenWork workflow intentionally abstracts OAC away.

Today the human manually performs the operation OAC will eventually automate:

```text
compound thought
        ↓
human writes one bounded task
        ↓
OpenWork agent executes it
```

Later:

```text
compound thought
        ↓
OAC / Prompt Scribe
        ↓
multiple bounded task candidates
        ↓
human approves
        ↓
OpenWork / Tendril executes each independently
```

Therefore the current one-task execution harness is not temporary throwaway behavior.

It is the **execution primitive that OAC will eventually target**.

---

## Architectural Separation

OAC must remain distinguishable from:

* Tendril's execution harness;
* Project Control;
* OpenWork;
* the launcher;
* the sandbox;
* trusted verification;
* the Tendril GUI.

It may ultimately interact closely with all of them, but it should not absorb their authority.

OAC answers:

> **What bounded work does this human intent mean in the context of this project?**

It does not answer:

> **May this work execute?**

or:

> **How is the execution physically secured?**

---

## Current Development Position

OAC is intentionally deferred while the basic Tendril execution workflow is made functional.

Current priority is:

```text
human creates one bounded task
→ fresh agent
→ current policy
→ bounded execution
→ result
→ stop
```

Once that primitive is reliable, OAC can begin producing the same kind of task automatically.

This prevents the compiler from being designed against an execution system that does not yet exist.

---

## Core Principle

The central OAC idea is:

> **Convert rich human intent into the smallest sufficient, ontologically grounded, bounded task and context specification — without converting interpretation into authority.**
````

### Document 4

**Exact File Path:** `documentation/main/PROJECT_BUILD_MANIFEST.md`

**Full Document Contents:**

````markdown
# Project Tendril — Primary Build Manifest

Status: CURRENT
Authority: HUMAN-APPROVED BUILD PLAN
Project Root: /home/gabriel/project-tendril/

## 1. Purpose

This document is the primary manifest for Project Tendril build direction, sequencing, and current development state.

Every reported execution must eventually determine which part of this manifest it advances before substantive work begins.

The purpose is to prevent design drift across:

- human/agent conversations
- OpenWork sessions
- model changes
- draft handovers
- implementation tasks
- architectural adjudications

The manifest is the default reference for:

- what phase Project Tendril is currently in
- what work is expected next
- why that work has priority
- what has already been completed
- what is deliberately deferred
- whether a proposed task advances the agreed build plan

This document does not replace:

- AGENTS.md as execution policy
- accepted topic-specific architectural documentation
- explicit current human authority

Where a current human instruction intentionally changes this plan, the instruction may override the manifest.

The deviation must be recorded.

The manifest itself is not silently rewritten by an agent.

A changed build direction becomes current only through explicit human authorization and a bounded manifest-update task.

---

## 1a. V0 Product Pivot

The immediate focus is building the minimal Tendril backend API and GUI. The Ontological Agent Compiler (OAC) and automated orchestration are deferred. The system only needs to support a limited range of tasks to allow human-governed graph construction and context compilation.

Tech stack locked: Godot 4 (native client, V0 2D, V1 3D upgrade path) + Python FastAPI (headless DAG execution engine). See `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md` for the full V0 architecture and implementation plan.

---

# 2. Authority and Drift Rule

For build sequencing and current development direction:

1. Explicit current human instruction
2. This Primary Build Manifest
3. Accepted topic-specific documentation
4. Approved adjudication results not yet materialized
5. Draft reconciliation / handover material
6. Historical Tendril / Baton evidence
7. Conversation-derived suggestions

For execution behavior and permissions:

AGENTS.md and current accepted execution standards govern.

For topic-specific architecture:

the accepted owning architecture document governs once one exists.

A conversation, model recommendation, historical handover, or draft does not silently change this manifest.

Operational rule:

Current plan beats conversational drift.

Human authority may change the plan.

Agents may detect drift but may not resolve it themselves.

---

## 3. Current Project State

The broad inventory phase is complete enough to build from.

Completed foundation work includes:

- fresh Project Tendril root established
- bootstrap doctrine established
- one-task execution pattern established
- current-state audit completed
- 108-topic missing-material reconciliation completed
- reconciliation explicitly human-approved as a draft reconciliation artifact
- first bounded telemetry/reporting adjudication completed
- custom OpenWork/OpenCode tool-surface experiments completed
- scoped-read boundary experiment completed
- report-number and task-report bootstrap operating
- bootstrap versus Tendril-product distinction established

Current project reality:

- bootstrap/control mechanisms work
- actual Tendril product/runtime implementation remains essentially absent
- Controller is absent
- Launcher is absent
- OS-level sandbox is absent
- Runtime Ledger is absent
- independent verification is absent
- OAC is absent
- product/tendril remains unimplemented
- durable Tendril runtime persistence is unresolved
- Git baseline for the fresh rebuild has not yet been established

The project must now transition from broad inventory into:

adjudication
→ accepted contract
→ bounded implementation
→ verification

---

## 4. Governing Build Pattern

Project Tendril should evolve through:

manual convention
→ observed repeated pattern
→ explicit adjudication
→ accepted contract
→ bounded implementation
→ verification
→ structural Tendril capability

Do not automate a behavior merely because it can be automated.

First prove the behavior manually.

Then define its meaning.

Then implement the smallest structural replacement.

---

# BUILD PHASES

## P0 — Fresh-Rebuild Inventory and Reconciliation

State: COMPLETE

Purpose:

Establish what actually exists in the fresh rebuild and preserve missing historical/design material without treating it as current authority.

Completed work includes:

- current-state handover
- missing-material handover
- 108-topic reconciliation
- human PASS of reconciliation as draft adjudication input

Do not return to broad inventory as the normal mode.

Historical archaeology is now just-in-time and question-driven.

---

## P1 — Interaction Routing

State: COMPLETE

Purpose:

Remove unnecessary reporting bureaucracy from ordinary project information retrieval while preserving durable reporting for consequential execution.

Supersession note:

P1 successfully proved QUERY / task interaction routing in AGENTS.md.
Its original report-free QUERY behavior was later superseded by P2 execution-integrity correction.
Current policy requires every agent invocation to create a new logged execution.
QUERY remains a read-only interaction class, not an unlogged lane.

### P1.1 — QUERY / REPORTED EXECUTION policy

State: COMPLETE

Implement the accepted routing model in AGENTS.md.

QUERY:

ephemeral information retrieval
→ search/read
→ concise answer
→ stop

No Report Number.
No task report.
No reporting-standard initialization.
No PASS/FAIL boilerplate.

REPORTED EXECUTION:

durable inspection or mutation
→ normal report lifecycle

Subclasses:

INSPECTION
MUTATION

The existing Pre-Task Initialization Gate remains intact but applies only to REPORTED EXECUTION.

### P1.2 — QUERY routing validation

State: COMPLETE

After the policy mutation:

start a fresh OpenWork session

send exactly:

where is the current plan stored? and what is in it?

Validate:

- report counter unchanged during query
- no task report created
- reporting standard not read
- no PASS/PARTIAL/BLOCKED/FAIL boilerplate
- no classification deliberation
- concise correct answer

P1 is complete only when this validation passes.

---

## P2 — Telemetry and Reporting Contract Materialization

State: COMPLETE

Purpose:

Turn the completed reasoning-telemetry adjudication into coherent proposed and then accepted project policy.

The bootstrap reporting standard is sufficient; future telemetry work will be handled by the runtime.

Execution-integrity correction (current P2 item):

A discovered session-boundary/logging failure established the invariant:

Every human instruction that causes agent work must create a distinct durable execution before substantive work.

This must ultimately be enforced structurally by Tendril runtime code.

The report-free QUERY lane has been removed. QUERY, INSPECTION, and MUTATION are all logged executions.

Adjudicated direction includes:

Agent:
- authors claims about its work

Runtime / Harness:
- owns raw reasoning capture
- owns tool-event capture
- owns runtime-event capture
- ultimately owns lifecycle timestamps
- owns reasoning diagnostics
- owns semantic-progress measurement
- ultimately owns Report Number allocation
- owns telemetry-failure facts

Current bootstrap mechanisms remain temporary until structural replacements exist.

Canonical raw reasoning direction:

R<number>_<timestamp>_<task-slug>.reasoning.jsonl

Properties:

- Report Number is stable join key
- raw event order preserved
- raw telemetry never cleaned or rewritten
- provider/model/variant/effort excluded from canonical filename
- Markdown may exist only as a derived human-readable view

Next work:

1. record explicit human decisions from adjudication
2. create proposed reporting/policy changes
3. review
4. promote only with human authorization

Do not implement the full Harness during this phase.

---

## P3 — Git Baseline

State: COMPLETE

Purpose:

Give the fresh rebuild durable history, baseline identity, diffability, rollback, and provenance before substantial implementation spreads.

Required result:

fresh project
→ Git initialization
→ reviewed ignore rules
→ inspect exact baseline
→ human-reviewed baseline commit

A private remote may follow separately.

Git existence does not grant ordinary agents autonomous commit, merge, or integration authority.

Why this phase is early:

- later mutations become diffable
- rollback becomes possible
- accepted documentation receives provenance
- frozen execution baselines become possible
- worktrees become possible
- trusted integration can later reference actual commits

---

## P4 — OpenWork Live Project State

State: ACTIVE MANUAL PRACTICE / STRUCTURAL IMPLEMENTATION DEFERRED

Purpose:

Use OpenWork immediately as the human-facing live project-control surface.

Conceptual states:

PLAN
READY
IN PROGRESS
REQUIRES ATTENTION
DONE

Human controls:

- task selection
- priority
- sequencing
- PLAN → READY
- scope changes
- acceptance
- rejection
- rework
- architectural decisions
- DONE

Ordinary agents do not self-sequence.

Minimum useful task state should increasingly include:

- Task ID
- Title
- Plan Phase
- Plan Item
- Objective
- Source topics
- Dependencies
- Authorized scope
- Done condition
- Report/evidence reference
- Current state
- Human acceptance state

Do not delay useful work waiting for automated Project Control.

The existing UP_NEXT mechanism should stop acting as the live scheduler once OpenWork reliably carries this state.

---

## P5 — Execution Contract and Lifecycle

State: PLANNED — DEFERRED FOR V0

The OpenWork prompt-policy bootstrap is sufficient for now.

Purpose:

Define what a Tendril execution actually is before building the machinery that executes it.

Primary subjects:

- Task Contract
- Control Policy
- Execution Envelope
- Runtime Ledger
- execution lifecycle
- universal execution logging (no agent invocation for project work without a pre-existing durable execution identity/record)
- agent-invocation gate (Controller/runtime, not model, must enforce the execution-identity prerequisite before invoking the agent)
- SUCCEEDED versus VERIFIED
- candidate versus accepted result
- rollback and abandonment
- frozen baseline
- stable identity and provenance
- structured clarification
- discovery versus authorization
- concurrency / write semantics

Process:

reconciliation evidence
→ bounded adjudication
→ human decisions
→ proposed owning documentation
→ review
→ promotion

Do not design the detailed Controller implementation before this contract is sufficiently stable.

---

## P6 — Minimal Controller

State: PLANNED — DEFERRED FOR V0

The OpenWork prompt-policy bootstrap is sufficient for now.

Purpose:

Implement the first substantial piece of real Tendril execution architecture.

Minimal responsibility:

authorized task
→ execution identity
→ resolved/frozen execution description
→ agent-invocation gate (deny agent invocation if no valid execution identity/record exists)
→ lifecycle state
→ timestamps
→ evidence references
→ terminal execution state

The first Controller should be minimal.

Do not turn it into the complete future orchestration system.

Why:

The Controller begins replacing model-owned and bootstrap-owned execution facts with structural state.

---

## P7 — Launcher and Hard Security

State: PLANNED — DEFERRED FOR V0

The OpenWork prompt-policy bootstrap is sufficient for now.

Purpose:

Materialize an already-defined execution contract into an isolated runtime environment.

Responsibilities include:

- task environment/worktree preparation
- filesystem isolation
- OS-level sandboxing
- capability exposure
- network policy
- secret injection
- process launch
- runtime identity
- cleanup

Conceptual boundary:

Controller
→ frozen Execution Envelope
→ Launcher
→ isolated execution

The Launcher implements authorized execution semantics.

It does not invent them.

---

## P8 — Trusted Verification and Git Integration

State: PLANNED

Purpose:

Separate agent completion claims from trusted evidence and authoritative integration.

Target flow:

agent execution
→ candidate result
→ trusted verifier
→ VERIFIED or rejected
→ human acceptance
→ trusted Git integration

Core invariant:

SUCCEEDED ≠ VERIFIED

VERIFIED ≠ ACCEPTED

Ordinary implementation agents must not become the authority that simultaneously:

- performs work
- verifies the work
- accepts the work
- integrates the work

---

## P9 — Tendril Version Zero Headless Runtime

State: COMPLETE

Tech Stack: Python FastAPI (headless DAG execution engine)

Purpose:

Build the minimal viable graph backend for the V0 Tendril product.

The backend is a functional DAG execution engine implementing:

- Operator-based node model (Text Source, File Source, Composite Text, Extraction, Compression, Monitor)
- Named input/output ports with dynamic port registration
- Recursive "cook" traversal with cycle detection
- Semantic-aware template engine (narrative_context / RED, stable_reference / GREEN)
- Immutable history with fork-based non-destructive editing (supersedes edges)
- Position support (2D coordinates with z=0.0 for V0, 3D-ready data model)

Completed:

- FastAPI CRUD endpoints (nodes, edges)
- Graph traversal and recursive cook engine with cycle detection
- File source disk reading with error handling
- GET /workspace endpoint returning full graph state
- Fork-based non-destructive editing (supersedes edges)
- Absolute import paths for uvicorn execution

---

## P10 — Tendril Frontend

State: CURRENT

Tech Stack: Godot 4 (native client)

Purpose:

Build the minimal GUI for V0 (2D for V0, 3D upgrade path for V1).

The Godot 4 GUI uses native `Control` and `GraphEdit` systems and must support:

- infinite canvas panning/zooming
- node spawning with inline `TextEdit` inputs
- noodle/edge drawing with semantic visual styles (RED dashed, GREEN solid, supersedes metallic)
- LOD strategy (cached thumbnails for zoomed-out nodes, heavy widgets only for focused nodes)
- 2D canvas with semantic gravity (X: progression, Y: abstraction — canopy vs. ground)

Target relationship:

GUI action
→ HTTPRequest
→ backend command
→ authoritative backend state
→ frontend render

The GUI is strictly a projection of backend state. It holds no domain logic.

The Godot 4 unified rendering pipeline allows swapping the 2D canvas for a 3D viewport (`Node3D`) in V1 without rewriting application logic or the backend API.

---

## P11 — OAC / Prompt Scribe

State: DEFERRED

Purpose:

Compile broad human intent into bounded candidate work.

The OAC is removed from the V0 critical path. The human will act as the manual compiler for V0.

Target flow:

compound human request
→ candidate tasks
→ dependencies
→ ambiguities
→ human review
→ authorization

OAC must not:

- authorize its own work
- execute discovered tasks
- self-sequence
- silently resolve architecture
- promote its own output

Do not implement substantive OAC until the Task Contract and execution authorization model are stable.

---

## P12 — Deeper Automation and Tendril Self-Hosting

State: FUTURE

Purpose:

Gradually replace proven bootstrap/manual conventions with Tendril-native structural capabilities.

Only automate behavior after its contract has survived real use.

---

# 5. Deliberately Deferred Decisions

Do not freeze these merely to create apparent completeness:

- exact Controller implementation language
- exact Controller process topology
- exact sandbox technology
- permanent transport
- final runtime database technology
- corpus Markdown authority/projection model
- Bible/Manifest historical machinery
- final durable entity set
- Graph-Native Foyer
- permanent model-routing policy
- broad automatic corpus ingestion

These are resolved only when a current dependency requires them.

---

# 6. Historical Material Policy

Historical Baton/Tendril material is evidence, not fresh authority.

Use historical material only when a current architectural question requires it.

Process:

current question
→ retrieve minimal relevant history
→ extract evidence
→ compare with current state
→ human adjudication
→ integrate accepted result

Do not ingest the complete historical corpus as a prerequisite to continuing implementation.

---

# 7. OpenWork State Ownership

During the bootstrap period:

OpenWork owns:
- live task visibility
- human sequencing
- priority
- current work state
- attention state

Project files own:
- accepted architecture
- policy
- drafts
- implementation
- evidence
- plans

Git will own:
- baseline
- history
- diffs
- provenance
- rollback

Agent task reports own:
- agent-authored execution claims and evidence references

Future Runtime Ledger will own:
- machine-observed execution state

---

# 8. Plan Alignment Requirement

Every REPORTED EXECUTION must eventually identify the relevant plan phase before substantive work proceeds.

The task report must state:

Manifest:
`documentation/main/PROJECT_BUILD_MANIFEST.md`

Plan Phase:
`P<number>`

Plan Item:
specific item where one exists

Plan Alignment:
one of:

ALIGNED
HUMAN_OVERRIDE
MANIFEST_UPDATE
OUT_OF_PLAN
UNKNOWN

Meaning:

ALIGNED:
The task directly advances the current manifest.

HUMAN_OVERRIDE:
The human explicitly authorized work that departs from the current manifest.

MANIFEST_UPDATE:
The task is explicitly authorized to modify the manifest itself.

OUT_OF_PLAN:
The task conflicts with, bypasses, or advances beyond the manifest without explicit human override.

UNKNOWN:
Available information is insufficient to map the task safely.

OUT_OF_PLAN and UNKNOWN must not be silently converted into ALIGNED.

If the task is OUT_OF_PLAN and no explicit human override exists:

report BLOCKED and request the minimum human decision required.

---

# 9. Context Refresh Rule

For a REPORTED EXECUTION, once the supporting policy wiring is implemented:

1. Load current Project Tendril policy.
2. Load the authorized task.
3. Initialize the required task report according to current reporting policy.
4. Before substantive work, read the current Primary Build Manifest.
5. Determine Plan Phase, Plan Item, and Plan Alignment.
6. Record them in the report.
7. Perform substantive work only after this plan check.

Do not repeatedly reread the manifest mechanically.

Re-check the manifest only when:

- task scope appears to change
- an architectural decision is encountered
- sequencing becomes ambiguous
- new evidence suggests the task no longer matches the plan
- the human changes the task
- the manifest itself changes

Operational rule:

Read the manifest to orient the task.

Re-read it only when alignment may have changed.

Do not turn plan checking into repetitive deliberation.

---

# 10. QUERY Relationship

QUERY is a logged execution and follows the standard Plan Alignment procedure.

When a QUERY asks about:

- the current plan
- project priority
- current phase
- what should happen next
- whether work is deferred
- current build direction

the Primary Build Manifest is the primary project source.

Answer from it rather than reconstructing the plan from old chats or arbitrary drafts.

---

# 11. Manifest Change Control

Agents must not silently update this manifest because implementation or conversation has drifted.

A manifest change requires:

- explicit human authorization
- a bounded REPORTED EXECUTION
- stated reason for the change
- identification of affected phases/items
- verification that unrelated plan content was preserved

When the human changes build direction:

update the manifest.

Do not maintain a second competing plan.

---

# 12. Definition of Progress

Progress is not primarily:

- number of reports
- number of drafts
- number of prompts
- amount of reasoning
- amount of historical material ingested

Progress increasingly means:

- current tasks visibly map to the plan
- fewer unresolved authority questions
- more accepted owning documentation
- more structural state
- more machine-observed evidence
- fewer agent-owned runtime facts
- fewer temporary manual mechanisms
- more independently verifiable execution
- more real Tendril product capability
- less design drift across sessions and models

---

# 13. Current Focus

Current phase:

P10 — V0 functional loop (spawn, edit, connect, cook, monitor, lock, fork) implemented. Next: persistence, semantic edge typing, composite nodes.

Completed:

P3 — Git Baseline (COMPLETE)
P9 — Tendril Version Zero Headless Runtime (COMPLETE)

Current immediate objective:

P10 — Tendril Frontend (Godot 4 GraphEdit GUI with full V0 functional loop)

Then:

P4 — OpenWork Live Project State continues in parallel as manual operating practice.

P8 — Trusted Verification and Git Integration will follow when needed.

No later phase becomes the default focus until the human advances the manifest.

---

# 14. Core Rule

Every consequential task should answer:

What part of the agreed build plan does this advance?

If that cannot be answered, stop treating the task as obviously current work.

Operational rule:

Task
→ Plan
→ Alignment
→ Execution
→ Evidence
→ Human state update

---
````

## Vocabulary Analysis

The following terms and constraints warrant human verification. This audit identifies where they occur; it does not adjudicate or fix them.

- **"Tendril Network Vision": not found.** No file named `tendril-network-vision.md`, and no occurrence of "Tendril Network Vision" or "Network Vision", was found in `documentation/`, `control/`, `bootstrap/`, `AGENTS.md`, or root-level project files.
- **Proposed document described as finalized:** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 1. Executive Summary`, says "This document outlines the finalized architecture for Tendril V0." Its location under `documentation/drafts/proposed-main/` identifies it as proposed rather than accepted under `AGENTS.md`'s Documentation Authority rules. Human verification is needed before treating all of its constraints as accepted topic-specific architecture.
- **"3D mycelial spatial topology":** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 1. Executive Summary`. This metaphor and V1 topology commitment are not independently supported by another accepted topic-specific architecture document found in this audit.
- **"Mycelial Rules":** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 4. Backend tendril-api: A DAG Execution Engine`, item `3. Immutability & Forking (Mycelial Rules)`. The underlying immutable-history and fork behavior may be intentional, but the mycelial label is unverified vocabulary.
- **"metabolic workflow":** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 1. Executive Summary`. It frames RED narrative becoming GREEN stable decisions as metabolism; no separate accepted vision document was found to authorize this metaphor.
- **RED/GREEN semantic categories:** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 1. Executive Summary`, `## 4. Backend tendril-api: A DAG Execution Engine` item `2. Semantic-Aware Template Engine`, and `## 5. Spatial Semantics & Visual Language (2D for V0)` item `Edge (Noodle) Styles`. These impose color-coded meanings and rendering behavior: RED is `text`, GREEN is `memory_consolidation`, RED is dashed/emissive, and GREEN is solid/heavier.
- **"semantic gravity":** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 5. Spatial Semantics & Visual Language (2D for V0)`. It turns free canvas placement into a semantic constraint.
- **X-axis progression constraint:** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 5. Spatial Semantics & Visual Language (2D for V0)`, item `X-Axis (Progression)`. It assigns left-to-right placement the meaning "Past to future."
- **Y-axis abstraction constraint, "Ground", "Canopy", and snapping:** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 5. Spatial Semantics & Visual Language (2D for V0)`, item `Y-Axis (Abstraction)`. It requires stable locked GREEN decisions to snap to the bottom/"Ground" at `Y > 0`, while exploratory RED narrative floats at the top/middle/"Canopy" at `Y < 0`. This is the clearest occurrence of the specifically suspected Y-axis snapping constraint.
- **Hardcoded V0 Z coordinate and V1 3D upgrade path:** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 2. Tech Stack: Godot 4 (Native Client) + Python (Backend)` and `## 5. Spatial Semantics & Visual Language (2D for V0)`. These require a 3D-ready position vector and `z = 0.0` in V0.
- **"Live" versus "Baked" node metaphors:** `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 5. Spatial Semantics & Visual Language (2D for V0)`, item `Node States (Live vs. Baked)`. These add pulsing/emissive versus matte visual constraints beyond lock semantics.
- **Manifest propagation of canopy/ground:** `documentation/main/PROJECT_BUILD_MANIFEST.md`, `## P10 — Tendril Frontend`, requires "2D canvas with semantic gravity (X: progression, Y: abstraction — canopy vs. ground)." This places the disputed vocabulary in the human-approved current build manifest even though the linked topic document remains proposed. Human review should determine whether this line itself constitutes authorization or copied drift.
- **Manifest propagation of RED/GREEN styles:** `documentation/main/PROJECT_BUILD_MANIFEST.md`, `## P9 — Tendril Version Zero Headless Runtime` and `## P10 — Tendril Frontend`, specifies `narrative_context / RED`, `stable_reference / GREEN`, and RED dashed/GREEN solid noodles.
- **Semantic-name drift within current project documents:** `documentation/main/PROJECT_BUILD_MANIFEST.md`, `## P9 — Tendril Version Zero Headless Runtime`, uses `narrative_context` and `stable_reference`; `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 4. Backend tendril-api: A DAG Execution Engine`, instead uses `text` and `memory_consolidation`; `documentation/drafts/proposed-main/architecture/v0-api-schemas.md`, `### Edge`, declares an open `semantic_type` vocabulary and examples such as `context_for`, `critiques`, `extends`, `refines`, and `references`. These are materially different semantic contracts.
- **API-contract drift:** `documentation/drafts/proposed-main/architecture/v0-api-schemas.md`, `## Core Entities` and `## REST Endpoints`, defines `Node`/`Edge`/`ContextPacket`, `/api/v0`, open edge vocabulary, and in-memory V0 storage. `documentation/drafts/proposed-main/architecture/tendril-v0-architecture.md`, `## 3. The Functional Node Model`, `## 4. Backend tendril-api`, and `## 6. V0 API State Contract`, defines operator nodes, named ports, strict edge types, cooking, lock/fork behavior, and a different node shape. Human adjudication is needed to identify the owning contract.
- **Downstream implementation plan repeats old RED/GREEN names:** `documentation/drafts/plans/composite-node-ui-plan.md`, `## 4. Composite Node Right-Click Menu`, uses `narrative_context`/RED and all other types/GREEN in its edge label logic.
- **Downstream implementation plan changes RED/GREEN names:** `documentation/drafts/plans/semantic-noodle-rendering-plan.md`, `## Objective`, `## 1. Backend Semantic Contract`, `## 2. Frontend Edge Data And Creation Defaults`, `## 3. Custom GraphEdit Noodle Drawing`, and `## 4. Right-Click Semantic Toggle`, adopts `text`/RED and `memory_consolidation`/GREEN and prescribes exact colors and line widths. It propagates the proposed architecture's new terms rather than the manifest's P9 names.
- **Downstream review treats ground snapping as an architecture requirement:** `documentation/drafts/code-review-v0-implementation.md`, `### GraphEdit Integration`, says stable locked nodes do not snap toward the ground semantic region.
- **Downstream drift audit treats canopy/ground behavior as required:** `documentation/drafts/state-vs-reality-drift-report.md`, `### 3.3 Additional V0 Architecture Gaps`, `### F4. Node Locking/Baking and Visual Port Colors`, and `## 8. Recommended Correction Order`, marks semantic gravity and stable-node ground snapping as missing and recommends completing semantic gravity. This demonstrates propagation of the suspected constraint into implementation evaluation.
- **Ordinary "ground" wording is not the suspected metaphor:** `documentation/drafts/ontological-agent-compiler-handover.md`, `## Status` and `## Ontological Grounding`, uses "ground" as a verb meaning to tie task interpretation to project evidence. It does not describe a spatial Ground, canopy, or Y-axis behavior.
- **No queried architecture vocabulary in control or bootstrap first-party documents:** no first-party file in `control/` or `bootstrap/`, and no occurrence in `AGENTS.md`, used "Network Vision", "canopy", "mycelial", RED/GREEN architectural categories, or "Spatial Semantics". Broad bootstrap search hits for words such as "background" were third-party dependency noise, not Tendril architecture.
