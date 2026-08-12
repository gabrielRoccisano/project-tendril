# Telemetry and Reporting Decisions

Status:
HUMAN-RATIFIED
PROPOSED-MAIN
NOT YET ACCEPTED OWNING DOCUMENTATION

## Purpose

This document durably records the human-ratified Decisions A and C from the completed P2 telemetry/reporting adjudication (R000018). It is the first durable P2 decision artifact and is intended to serve as the authoritative basis for subsequent proposed policy and documentation changes. The decisions recorded here are already settled by human ratification; only the document itself remains proposed-main pending later review and promotion.

## Authority Status

- R000018 was adjudication evidence recorded in a task report, not accepted project authority.
- The human has now explicitly ratified Decisions A and C.
- This document records those settled decisions.
- This file remains proposed-main until separately reviewed and promoted.
- Proposed-main status does not make the decisions themselves provisional.

## Decision A — Execution-Observation Ownership

Decision A settles which side of the telemetry/reporting boundary owns each observation. Agent-authored task reports are operational claims, not authoritative runtime telemetry. Runtime / Harness owns the observation layer.

| Fact domain | Owner |
|---|---|
| Agent-authored claims about its own work | AGENT (as claim author) |
| Agent-authored task reports | AGENT (operational claims, not authoritative runtime telemetry) |
| Raw reasoning capture | RUNTIME / HARNESS |
| Tool-event capture | RUNTIME / HARNESS |
| Runtime-event capture | RUNTIME / HARNESS |
| Lifecycle timestamps | RUNTIME / HARNESS (ultimately) |
| Reasoning diagnostics | RUNTIME / HARNESS |
| Semantic-progress measurement | RUNTIME / HARNESS |
| Report Number allocation and its role as the stable execution join key | RUNTIME / HARNESS (ultimately) |
| Telemetry-failure facts | RUNTIME / HARNESS |

Bootstrap mechanisms may remain temporarily until structural runtime ownership exists.

Trusted verification and human acceptance remain downstream concerns and are not redefined by this decision.

## Decision C — Canonical Raw Reasoning Artifact

Canonical raw form:

`.reasoning.jsonl`

Canonical naming direction:

`R<number>_<timestamp>_<task-slug>.reasoning.jsonl`

Requirements:

- Report Number is the stable join key.
- Raw events remain in original order.
- Raw reasoning telemetry is never cleaned, summarized, rewritten, or reconstructed.
- Provider/model/variant/effort are excluded from the canonical filename.
- Markdown may exist only as an optional derived human-readable view.
- `.reasoning.md` is not the canonical raw representation.

## Existing Evidence

- R000018 adjudication: `runtime/reports/agent-tasks/R000018_20260811T092630Z_adjudicate-telemetry-reporting-contract.md` (Adjudication Record section).
- Existing raw reasoning artifact: `runtime/reports/agent-tasks/R000003_20260811T075943Z_deepseek-v4-flash-max_locate-thought-stream.reasoning.jsonl` — an existing `.reasoning.jsonl` artifact.
- Current accepted reporting standard: `documentation/main/standards/agent-task-reporting.md`.

Evidence is referenced as it exists. The historical R000003 artifact filename predates Decision C and includes model identity; it is evidence of existing `.reasoning.jsonl` practice, not itself a conforming example of the canonical naming direction.

## Known Accepted-Standard Conflict

The current accepted reporting standard still contains the older `.reasoning.md` representation: raw reasoning traces stored beside the corresponding task report using the same basename with `.reasoning.md`, and an example path without the R-number prefix. That representation conflicts with ratified Decision C (`.reasoning.jsonl` is canonical). This task does not modify that standard.

## Required Follow-On Materialization

The next required P2 work:

1. propose exact changes to `agent-task-reporting.md`
2. determine any minimal AGENTS.md changes required by Decision A
3. review proposed changes against this ratified decision record
4. promote only with explicit human authorization

Those changes are not performed by this task.

## Scope Boundary

This decision record does not settle:

- full Harness implementation
- Controller architecture
- Launcher architecture
- verifier implementation
- acceptance workflow
- runtime database
- sandbox technology
- broader execution lifecycle
