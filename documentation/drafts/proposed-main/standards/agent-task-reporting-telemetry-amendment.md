# Agent Task Reporting — Telemetry Amendment Proposal

Status: PROPOSED-MAIN
Based on: Human-ratified Decisions A and C (telemetry-reporting-decisions.md)

## Purpose

This proposal provides the exact changes to current accepted standards required to materialize human-ratified Decisions A and C into accepted documentation. The decisions themselves are settled. This artifact is the proposed amendment; promotion to accepted documentation requires separate human authorization.

---

## Part 1: Decision C Materialization — Exact Proposed Changes to agent-task-reporting.md

Decision C establishes `.reasoning.jsonl` as the canonical raw reasoning telemetry format, joined to the task report by Report Number.

### Target Document

`documentation/main/standards/agent-task-reporting.md`

### Affected Section

`## Reasoning Diagnostics` — final storage/location paragraph and example.

### Current Text (lines 516-530 of the current accepted standard)

```
Raw reasoning traces should be stored beside the corresponding task report beneath:

/home/gabriel/project-tendril/runtime/reports/agent-tasks/

using the same basename with:

.reasoning.md

Example:

20260811T072709Z_verify-handover-extraction-standard-draft.md

20260811T072709Z_verify-handover-extraction-standard-draft.reasoning.md

The preferred long-term source of the reasoning trace is the execution harness/runtime, not self-reconstruction by the agent.
```

### Proposed Replacement Text

```
Raw reasoning traces should be stored beside the corresponding task report beneath:

/home/gabriel/project-tendril/runtime/reports/agent-tasks/

Canonical raw format:

.reasoning.jsonl

using the naming convention:

R<number>_<timestamp>_<task-slug>.reasoning.jsonl

Rules:

- Report Number is the stable join key between the task report and the raw reasoning artifact.
- Raw events remain in original order.
- Raw reasoning telemetry is never cleaned, summarized, rewritten, or reconstructed.
- A human-readable .reasoning.md may be derived from the raw .reasoning.jsonl artifact as an optional view.
- .reasoning.md is not the canonical raw representation.

Example:

R000003_20260811T075943Z_locate-thought-stream.reasoning.jsonl

The preferred long-term source of the reasoning trace is the execution harness/runtime, not self-reconstruction by the agent.
```

### Rationale

| Aspect | Current standard | Proposed | Decision C basis |
|---|---|---|---|
| Canonical format | .reasoning.md | .reasoning.jsonl | "Canonical raw form: .reasoning.jsonl" |
| Naming convention | Timestamp-only; no R-prefix | R<number>_<timestamp>_<task-slug> | "R<number>_<timestamp>_<task-slug>.reasoning.jsonl" |
| Join key | Inconsistent (example omits R-prefix) | Report Number as stable join key | "Report Number is the stable join key" |
| Event preservation | Not stated | Never cleaned/rewritten/reconstructed | "Raw reasoning telemetry is never cleaned, summarized, rewritten, or reconstructed" |
| .reasoning.md role | Canonical raw format | Optional derived human-readable view | "Markdown may exist only as an optional derived human-readable view" |
| Example path | No R-prefix, .reasoning.md | R-prefix, .reasoning.jsonl | "Provider/model/variant/effort are excluded from the canonical filename" |
| Long-term source | Harness/runtime (line 524 preserved) | Harness/runtime (preserved) | Consistent with Decision A ownership boundary |

### Changes Not Made

- The `## Reasoning Diagnostics` required fields (Reasoning Capture, Reasoning Trace, Reasoning Duration Seconds, Reasoning Tokens) are **not** modified by this proposal. Those agent-populated diagnostic fields remain bootstrap-reporting fields. Decision A assigns ultimate ownership of reasoning diagnostics to Runtime/Harness but explicitly allows bootstrap fallback.
- The existing rules at lines 488-514 of the standard (raw reasoning must not be reconstructed, runtime as preferred source, etc.) are **not** modified. They remain compatible with Decision C.
- No other sections of the standard are affected.

---

## Part 2: Decision A Impact Assessment

Decision A settles the execution-observation ownership boundary: Runtime/Harness owns the observation layer (raw reasoning, tool events, runtime events, lifecycle timestamps, reasoning diagnostics, semantic-progress measurement, report number allocation, telemetry-failure classification). The Agent owns its authored claims and task reports, which are projections, not authoritative telemetry.

### Document 1: agent-task-reporting.md

**Assessment: NO CHANGE REQUIRED.**

The current accepted standard is compatible with Decision A. Key supporting evidence:

1. **Line 10:** "It is not a substitute for independent verification and does not grant authority to the agent's conclusions." — Establishes that the report is a claim, not authority. This is the foundation of the agent-claim/runtime-observation distinction.

2. **Line 524:** "The preferred long-term source of the reasoning trace is the execution harness/runtime, not self-reconstruction by the agent." — Already identifies the harness/runtime as the preferred observation source. This aligns with Decision A's assignment of raw reasoning capture to Runtime/Harness.

3. **Lines 488-497:** The rules governing raw reasoning telemetry (do not reconstruct, do not approximate, do not rewrite, do not clean up) are prohibitions on agent behavior, not assertions of agent ownership. They align with Decision A's requirement that raw telemetry "is never cleaned, summarized, rewritten, or reconstructed."

4. **Required diagnostic fields** (Reasoning Capture, Reasoning Trace, Reasoning Duration Seconds, Reasoning Tokens at lines 466-485): These are agent-populated bootstrap fields recording what the agent can observe. Decision A explicitly acknowledges this bootstrap mechanism: "Reasoning diagnostics: HARNESS (structural); agent self-report is interim and non-authoritative." The standard's requirement for agents to populate these fields does not assert permanent agent ownership — it is a bootstrap mechanism operating until structural harness ownership exists. The language at line 524 ("preferred long-term source... the execution harness/runtime") reinforces the temporary nature.

5. **Timing fields** (Started UTC, Finished UTC, Duration Seconds at lines 197-235): Same pattern. Agents sample the system clock and record timing under bootstrap rules. Decision A: "Lifecycle timestamps: RUNTIME / HARNESS (ultimately)." The standard's rules about timing integrity (never reconstruct, UNKNOWN if missed, exact observed telemetry preferred) are compatible with the ultimate ownership assignment.

6. **Report number allocation** (lines 96-170): The bootstrap counter-file procedure is explicitly temporary: "Concurrent-safe atomic allocation is a future harness/controller responsibility" (line 170). This aligns with Decision A: "Report Number allocation and its role as the stable execution join key: RUNTIME / HARNESS (ultimately)."

No section of the standard asserts permanent agent ownership over a fact domain that Decision A assigns to Runtime/Harness.

### Document 2: AGENTS.md

**Assessment: NO CHANGE REQUIRED.**

The current execution policy is compatible with Decision A. Key supporting evidence:

1. **Line 472:** "Agent claims are not runtime observations." — Direct statement of the core Decision A distinction.

2. **Line 322:** "Agent-authored descriptions remain claims about what occurred." — Classifies agent output as claims, not observed facts.

3. **Line 447:** "Agent task report: claim/projection of the execution." — Explicitly labels the task report as a projection, not the observation layer.

4. **Line 414:** "The agent must not create its own authoritative execution identity." — Prevents agent from asserting ownership over identity facts.

5. **Line 470:** "Missing telemetry is never reconstructed." — Aligns with Decision A's telemetry-failure boundary (missing data is a runtime fact; agent does not fabricate it).

6. **Line 474:** "Logging responsibility ultimately belongs to trusted code, not model compliance." — Assigns ultimate logging responsibility to the runtime (trusted code), not the agent (model compliance).

7. **Line 615:** "Raw model reasoning emitted before, during, or after initialization is separate runtime telemetry and must eventually be captured by the harness rather than reconstructed by the agent." — Directly assigns raw reasoning capture to the harness, aligning with Decision A.

8. **Mandatory Execution Logging** (lines 129-474): The execution logging gate, core invariant, and associated rules are about creating durable execution records — they do not claim agent ownership of telemetry. They require the agent to INITIALIZE a report (an authored claim), not to OWN the observation layer.

9. **Task Reporting** (lines 596-627): The requirement for agents to produce task reports is compatible: the report is the agent's claim/projection (Decision A: "Agent-authored task reports: AGENT (as claim author)"). Recording observations in a report is not the same as claiming to own those observations.

No section of AGENTS.md asserts permanent agent ownership over a fact domain assigned to Runtime/Harness by Decision A.

### Summary

| Document | Conflict Found? | Action |
|---|---|---|
| agent-task-reporting.md | No conflict | NO CHANGE REQUIRED for Decision A |
| AGENTS.md | No conflict | NO CHANGE REQUIRED for Decision A |

Both documents already contain language consistent with Decision A's ownership boundary. The bootstrap mechanisms (agent-sampled timestamps, agent-populated diagnostic fields, counter-file allocation) are explicitly or implicitly temporary pending structural runtime ownership, which Decision A acknowledges.

---

## Verification Notes

- Decision C: The proposed replacement at lines 516-530 of agent-task-reporting.md is the only change required to materialize Decision C. The affected text block is self-contained; no other sections reference `.reasoning.md` as canonical.
- Decision A: No edits required. Both documents already distinguish agent claims from runtime observations.
- The `telemetry-reporting-decisions.md` artifact remains the authoritative record of the ratified decisions. This amendment proposal is a proposed implementation of those decisions, not a restatement of them.
- All proposed changes maintain the current standard's existing structure, section numbering, and compatible rules.
