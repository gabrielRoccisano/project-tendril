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
