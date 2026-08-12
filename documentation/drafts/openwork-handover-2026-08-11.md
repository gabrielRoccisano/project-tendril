 
# Project Tendril — OpenWork Handover

You are working on Project Tendril.

Canonical project root:

/home/gabriel/project-tendril

Current project structure includes:

- AGENTS.md
- opencode.jsonc
- bootstrap/
- control/
- oac/
- product/
- references/
- runtime/
- worktrees/
- tmp/
- documentation/main/
- documentation/drafts/

## Current Operating Model

OpenWork is being established as the live project-management and execution interface for Tendril.

The immediate execution primitive is intentionally simple:

Human defines one bounded task.
A fresh OpenWork session receives that task.
The current AGENTS.md governs the execution.
The agent performs only that task.
The agent reports the result and stops.

Do not self-sequence into another task.

Prompt Scribe, automatic decomposition, autonomous scheduling, DAG execution, and more advanced Tendril orchestration are intentionally deferred until this basic one-task workflow is reliable.

## Agent Policy

The governing policy is:

/home/gabriel/project-tendril/AGENTS.md

The OpenCode project configuration is:

/home/gabriel/project-tendril/opencode.jsonc

These are canonical Project Tendril control paths.

Previous conversations or remembered state are not authority.

## Current OpenWork State

OpenWork is running against:

/home/gabriel/project-tendril

The Windows OpenWork client connects to the Linux OpenWork worker.

The previous harness-probe workspace has been retired as the active OpenWork workspace. Its contents remain historical bootstrap material.

A fresh agent has already confirmed that AGENTS.md is injected into its context.

The current OpenCode configuration allows useful project work inside the Tendril workspace while the stronger task-specific and OS-level isolation system is still to be built.

The final intended security model remains layered:

1. AGENTS.md — behavioural policy
2. OpenCode configuration and Tendril-owned tools — application capability control
3. Tendril launcher / Linux sandbox — hard filesystem and execution isolation

The hard sandbox is not yet implemented.

## Documentation Workflow

Project Tendril now has:

/home/gabriel/project-tendril/documentation/main/
/home/gabriel/project-tendril/documentation/drafts/

documentation/main/ is intended for accepted/current Tendril documentation.

documentation/drafts/ is intended for material that is still being integrated, reviewed, reconciled, or made coherent.

One immediate use of OpenWork will be documentation ingestion:

Human supplies a body of Tendril source material.
A bounded documentation task integrates it into the appropriate documentation.
Uncertain or unresolved material remains in drafts.
Accepted coherent material can later move into main.

## Longer-Term Direction

The simple one-task execution model is the primitive Tendril will preserve.

Later, Prompt Scribe will accept compound human intent and generate multiple discrete bounded candidate tasks.

Those tasks will then be reviewed/authorised and executed individually through the same one-task harness.

Prompt Scribe will generate candidate work; it will not independently authorise or execute it.

OpenWork is intended to become the live interface for:

- build plan
- task queue
- task state
- blockers
- completed work
- human sequencing

The human remains the authority for task selection, ordering, scope changes, architectural decisions, and acceptance.

# Current Task

Preserve this handover exactly as a Project Tendril draft.

Create:

/home/gabriel/project-tendril/documentation/drafts/openwork-handover-2026-08-11.md

Write the complete handover above into that file.

Do not rewrite, summarize, expand, or reinterpret it.

Do not modify any other file.

When complete, report the exact file created and stop.
