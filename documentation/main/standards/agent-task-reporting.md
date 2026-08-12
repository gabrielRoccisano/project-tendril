# Agent Task Reporting Standard

Status: CURRENT

## Purpose

Every Project Tendril agent task must leave a concise, inspectable record of what actually happened.

The report records observable execution facts.
It is not a substitute for independent verification and does not grant authority to the agent's conclusions.

Every agent execution produces a task report.

A terminal task report must never be reused for a later human instruction.

New instruction = new report.

The durable report and the human-facing answer are separate concerns.

## Report Location

All agent task reports are written beneath:

/home/gabriel/project-tendril/runtime/reports/agent-tasks/

## Filename

Use:

R<sequence>_<YYYYMMDDTHHMMSSZ>_<task-slug>.md

The filename timestamp must be the observed Started UTC timestamp.

The timestamp must be UTC.

Examples:

R000021_20260811T074605Z_inspect-agent-task-reporting-standard.md

Rules:

- Report Number is the canonical execution identifier.
- The filename must not contain Runner, Provider, Model, Model Variant, Effort, or Session ID.
- Execution Identity remains recorded inside the report.
- Identity fields must not affect report creation or filename construction.
- Do not rename the report when later identity telemetry becomes available.
- Report Number is the stable join key between the task report and all associated telemetry artifacts.

## Execution Identity

Every task execution must have an explicit report identity.

Require these fields:

Report Number:
<R000001-style project-local sequence>

Started UTC:
<YYYY-MM-DDTHH:MM:SSZ | UNKNOWN>

Runner:
<runtime/runner name | UNKNOWN>

Provider:
<provider name | UNKNOWN>

Model:
<exact model name | UNKNOWN>

Model Variant:
<variant if separately exposed | NONE | UNKNOWN>

Effort:
<exact configured effort level | DEFAULT | UNKNOWN>

Session ID:
<runtime session identifier | UNKNOWN>

Rules:

- Execution identity is observed telemetry.
- Never infer model identity from the task contents.
- Never infer model identity from previous sessions.
- Never infer effort level from expected model behavior.
- Record the exact provider, model, variant, and effort exposed by the active runtime/session.
- If any identity field is not observable, record UNKNOWN.
- Do not substitute a plausible value.
- A report must make it possible to distinguish two executions of the same task performed by different models or effort levels.
- Missing identity telemetry must never delay report initialization.
- If an identity value is not immediately exposed, initialize it as UNKNOWN.
- Identity values may be appended or corrected later when directly observed.
- Execution identity may become more complete after initialization, but the report filename never changes.
- Do not inspect previous reports to determine identity naming conventions.
- Do not inspect runtime storage to resolve optional identity fields before report initialization.

## Report Numbering

Establish a project-local monotonically increasing report number using:

R000001
R000002
R000003
...

Rules:

- Each execution receives one report number.
- A report number identifies an execution, not a task definition.
- Re-running the same task receives a new report number.
- Different models running the same task receive different report numbers.
- Never reuse an existing report number.
- Determine and reserve the report number during report initialization.
- Do not renumber historical reports.
- Existing unnumbered historical reports remain valid historical records.
- If a new number cannot be allocated reliably, do not guess or reuse a number; report the allocation problem explicitly.

### Report Number Allocation

Define one authoritative counter file:

/home/gabriel/project-tendril/runtime/reports/agent-tasks/NEXT_REPORT_NUMBER

The file contains exactly one decimal integer followed by a newline.

Example:

23

means the next report number to allocate is:

R000023

Allocation procedure:

1. During report initialization, before substantive task work:
   - read NEXT_REPORT_NUMBER
   - validate that it contains exactly one positive decimal integer
   - allocate that value as the execution's Report Number
   - increment the integer by one
   - write the incremented value back to NEXT_REPORT_NUMBER
   - then create the task report using the allocated number

2. Format allocated numbers as:

R000001
R000002
R000003

with at least six decimal digits after R.

3. The counter value represents the next unallocated report number, not the most recently allocated number.

4. Never determine the next number by scanning filenames when NEXT_REPORT_NUMBER is available.

5. Never guess a missing or malformed counter value.

6. If NEXT_REPORT_NUMBER is missing, malformed, unreadable, or cannot be updated safely:
   - do not allocate a report number
   - do not reuse an existing number
   - report the allocation failure as BLOCKED where safely possible

7. Allocation must occur before the report file is created.

8. Once allocated, a report number belongs permanently to that execution even if the execution later becomes BLOCKED, PARTIAL, or FAIL.

9. Do not recycle report numbers.

10. Historical reports created before numbered reporting remain unnumbered and are not included retroactively.

Concurrent-safe atomic allocation is a future harness/controller responsibility. Until the harness provides atomic allocation, ordinary agent execution must use only the defined counter-file procedure and must not invent an alternative numbering method.

## Required Status

Every report must end in exactly one of:

- PASS
- PARTIAL
- BLOCKED
- FAIL

Definitions:

PASS
The stated task completed and the required result was observed.

PARTIAL
Some authorized work completed, but the task did not completely satisfy its done condition.

BLOCKED
The task could not proceed because required information, authority, capability, dependency, or access was unavailable.

FAIL
The task was attempted but did not produce the required result.

## Execution Timing

Every task report must record execution timing using UTC system/runtime time.

Required fields:

Started UTC:
YYYY-MM-DDTHH:MM:SSZ

Finished UTC:
YYYY-MM-DDTHH:MM:SSZ

Duration Seconds:
<elapsed wall-clock seconds>

Rules:

- Start and finish timestamps must include seconds.
- Timestamps must be obtained from the execution environment or system clock, not estimated by the agent.
- Duration Seconds must be calculated from the recorded execution timing, not described approximately.
- Do not use values such as "~1 minute", "about 30 seconds", or similar estimates.
- A duration of 0 is valid for work completing within the same recorded second.
- The start time must be captured when task execution begins.
- The finish time must be captured after the task work and required reporting activity are complete.
- Timing values recorded in the report must be internally consistent.

## Timing Integrity

- Execution timing is observed telemetry.
- Timing values must never be reconstructed, approximated, backfilled, or fabricated after the relevant event.
- Started UTC must be captured before substantive task execution begins.
- Finished UTC must be captured after substantive task execution and required reporting work are complete.
- If a required timing value was not captured at the required event, record:

  UNKNOWN

- Do not substitute a later timestamp merely to make the report internally consistent.
- If Started UTC or Finished UTC is UNKNOWN, Duration Seconds must also be UNKNOWN.
- A missing timing observation must be reported explicitly as a telemetry failure.
- Exact observed telemetry is preferred over plausible reconstructed telemetry.
- UNKNOWN is preferable to an invented or inferred value.

## Live Report Lifecycle

Establish these rules:

- The task report is a live execution artifact, not an end-of-task reconstruction.
- Optional telemetry must never block report initialization.
- The minimum initialization sequence is:
  1. read current policy
  2. read current task metadata
  3. read reporting standard
  4. allocate Report Number
  5. sample Started UTC
  6. create report filename from Report Number, Started UTC, and task slug
  7. initialize the report immediately
  8. record immediately exposed execution identity values or UNKNOWN
  9. begin substantive task work
- The observed start timestamp determines the report filename timestamp.
- The initial report write must record:
  - Report Number
  - Task
  - Objective
  - Authorized Scope
  - Started UTC
  - Execution Identity values that are immediately exposed or recorded as UNKNOWN

- After initialization, substantive task work may begin.
- As each distinct execution phase completes, append an execution-log entry to the existing report.
- Do not wait until task completion to record evidence already observed.
- Previously recorded observations must not be silently rewritten merely to improve the narrative.
- If a later observation corrects an earlier observation, append the correction and identify what it supersedes.
- The terminal result is appended only after the task's required work and checks are complete.
- Finished UTC must be sampled at terminal finalization.
- Duration Seconds must be computed from the observed Started UTC and Finished UTC values.
- The report remains operational evidence and does not become project authority.

## Required Report Structure

# Task Report

## Task

Task:
<short task name>

Objective:
<the bounded objective supplied to the agent>

## Plan Alignment

Manifest:
`documentation/main/PROJECT_BUILD_MANIFEST.md`

Plan Phase:
`P<number> | UNKNOWN`

Plan Item:
`<specific manifest item> | UNKNOWN`

Plan Alignment:
`ALIGNED | HUMAN_OVERRIDE | MANIFEST_UPDATE | OUT_OF_PLAN | UNKNOWN`

Alignment Basis:
`<one short sentence>`

Plan Checkpoint:
`<manifest section or item>`

Rules:

- this section is required for every execution
- Alignment Basis must be concise
- do not summarize the whole manifest
- do not invent a phase or item
- UNKNOWN is preferable to guessing
- OUT_OF_PLAN without explicit human override causes BLOCKED before substantive work
- MANIFEST_UPDATE is used only when the human explicitly authorizes modifying the manifest itself
- HUMAN_OVERRIDE requires explicit human authorization

## Execution Identity

Report Number:
<R000001>

Runner:
<value | UNKNOWN>

Provider:
<value | UNKNOWN>

Model:
<value | UNKNOWN>

Model Variant:
<value | NONE | UNKNOWN>

Effort:
<value | DEFAULT | UNKNOWN>

Session ID:
<value | UNKNOWN>

## Timing

Started UTC:
<YYYY-MM-DDTHH:MM:SSZ | UNKNOWN>

Finished UTC:
<YYYY-MM-DDTHH:MM:SSZ | UNKNOWN>

Duration Seconds:
<number | UNKNOWN>

## Execution Log

Each log entry must use:

### <UTC timestamp> — <phase>

Action:
<observable action performed>

Observed:
<observable result>

State:
<CONTINUE | FINDING | BLOCKED | COMPLETE>

Rules:

- Append one entry when a distinct task phase or requested check completes.
- Do not create an entry for every internal thought.
- Do not record private chain-of-thought.
- Do not repeatedly log an already-settled result unless new evidence changes it.
- Verification tasks should record completed checks as they are resolved rather than reconstructing all checks at the end.
- A finding should be recorded when first observed.
- The final report summary may synthesize the accumulated log, but must not replace it.

## Result

Status:
<PASS | PARTIAL | BLOCKED | FAIL>

Summary:
<short factual description of the result>

## Changes

Created:
- <paths or none>

Modified:
- <paths or none>

Deleted:
- <paths or none>

## Evidence

- <observable evidence supporting the reported result>

## Scope

Authorized scope:
<paths or scope supplied by the task>

Scope compliance:
<confirm whether execution remained within that scope>

## Issues

Blockers:
- <items or none>

Execution Errors:
- <items or none>

Verification Findings:
- <items or none>

## Follow-up Candidates

- <newly discovered work or none>

Follow-up candidates are informational only.
The agent must not execute them unless separately authorized.

## Terminal Statement

<one concise statement describing why the final status was assigned>

## Issue Classification

### Blockers

Conditions that prevented the authorized task from proceeding or completing.

Examples:
- missing authority
- missing required input
- unavailable dependency
- denied required capability
- unresolved required human decision

### Execution Errors

Failures that occurred while attempting the authorized task.

Examples:
- command failure
- tool failure
- filesystem error
- parse error
- runtime exception

A defect discovered in the artifact being inspected is not automatically an Execution Error.

### Verification Findings

Defects, inconsistencies, ambiguities, missing requirements, failed acceptance conditions, or other findings discovered while inspecting or verifying an artifact or task result.

Verification Findings may exist even when execution itself completed without error.

Rules:

- Do not report Verification Findings as Execution Errors.
- Do not report an Execution Error merely as a Verification Finding.
- Use `none` when a category has no entries.
- Terminal status must reflect the actual task result and applicable verification findings, not merely whether execution errors occurred.
- A verification task may complete execution successfully while still returning PARTIAL or FAIL because of Verification Findings.

## Reasoning Diagnostics

Model reasoning, when exposed by the execution runtime, is execution telemetry used for harness analysis.

Required fields:

Reasoning Capture:
<PRESENT | UNAVAILABLE | PARTIAL>

Reasoning Trace:
<path | UNKNOWN>

Reasoning Duration Seconds:
<number | UNKNOWN>

Reasoning Tokens:
<number | UNKNOWN>

Observed Loop Indicators:
- <items or none>

Observed Decision Revisions:
- <items or none>

Observed Repeated Checks:
- <items or none>

Rules:

- Raw reasoning telemetry must not be reconstructed, approximated, invented, or backfilled.
- Preserve emitted reasoning without rewriting it when the runtime exposes it.
- Do not ask the model to recreate reasoning that was not captured.
- Raw reasoning is execution evidence, not authoritative Project Tendril knowledge.
- Raw reasoning is not proof that the final result is correct.
- Preserve reasoning traces so later harness analysis can identify:
  - repeated deliberation
  - repeated checks
  - decision reversals
  - stalled progress
  - unnecessary reconsideration
  - reasoning without new evidence
- Do not clean up or rewrite the raw reasoning trace to make it appear more coherent.
- If reasoning is unavailable from the runtime, record:

  Reasoning Capture: UNAVAILABLE
  Reasoning Trace: UNKNOWN

- Diagnostic observations about loops or repeated reasoning must be grounded in the captured trace rather than invented by the reporting agent.

Raw reasoning traces should be stored beside the corresponding task report beneath:

/home/gabriel/project-tendril/runtime/reports/agent-tasks/

using the same basename with:

.reasoning.md

Example:

20260811T072709Z_verify-handover-extraction-standard-draft.md

20260811T072709Z_verify-handover-extraction-standard-draft.reasoning.md

The preferred long-term source of the reasoning trace is the execution harness/runtime, not self-reconstruction by the agent.
