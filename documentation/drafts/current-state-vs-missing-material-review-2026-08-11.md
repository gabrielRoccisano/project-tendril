# Project Tendril — Current State vs Missing Material Review

## Draft Reconciliation Status

Status:
PASS

Human Decision:
APPROVED AS A DRAFT RECONCILIATION ARTIFACT

Meaning:

This artifact is considered structurally complete, internally consistent, and sufficiently evidence-grounded for human reconciliation and subsequent bounded adjudication work.

This PASS does not mean every individual classification is canonically correct.

The classifications remain draft reconciliation judgments and may be changed through later human adjudication.

This artifact remains non-authoritative draft material until specific decisions are separately adjudicated and explicitly promoted by the human.

## 1. Review Scope

- **Project root:** `/home/gabriel/project-tendril/`
- **Current-state handover:** `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` (audit artifact, not authority)
- **Missing-material handover:** `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` (draft integration input, not authority; contains 108 numbered topics)
- **Review timestamp:** 2026-08-11T09:06:20Z (Started UTC of this execution)
- **Evidence hierarchy used:**
  1. Actual current files under `/home/gabriel/project-tendril/` (primary)
  2. Current-state handover (audit artifact, used for orientation only)
  3. Missing-material handover (topic list and claims being reviewed)
- Where either handover disagrees with actual files, the actual files govern and the discrepancy is recorded.
- Prior-session memory and prior execution outputs were not used as evidence. The target review file previously contained the output of an earlier execution (R000015, same task slug); that content was not used as evidence and this execution writes its own review to the exact authorized path.

## 2. Classification Model

### State classifications

- **PRESENT** — The topic is materially represented in current Project Tendril at the layer claimed by the topic. Mention somewhere in a draft is not sufficient.
- **PARTIAL** — Meaningful representation exists at some layer (working mechanism, accepted policy rule, scaffold artifact, or substantive draft deliverable), but important parts remain absent, incomplete, draft-only, policy-only, scaffold-only, unimplemented, or unresolved.
- **ABSENT** — No meaningful current representation was found; the topic's substance exists at most as draft text describing something not built, not decided, or not documented.
- **CONFLICT** — Current project material materially contradicts the missing-material topic.
- **UNKNOWN** — Available evidence is insufficient to classify safely.

### Layer classifications

- **IMPLEMENTED** — Directly evidenced working implementation exists (product/runtime level).
- **OPERATIONAL_BOOTSTRAP** — Directly evidenced working behavior exists, but only as bootstrap/control machinery rather than Tendril product architecture.
- **POLICY_ONLY** — Current policy (AGENTS.md / DOCTRINE.md) establishes the behavior, but no implementation enforces it structurally.
- **ACCEPTED_DOCUMENTATION** — Represented in `documentation/main/` but not implemented.
- **DRAFT_ONLY** — Represented only in `documentation/drafts/` or `documentation/drafts/proposed-main/`.
- **SCAFFOLD_ONLY** — Directory/template/placeholder exists without substantive implementation.
- **MIXED** — Representation spans more than one meaningful layer.
- **NOT_APPLICABLE** — Layer classification not meaningful for this topic.
- **UNKNOWN** — Layer cannot be determined.

### Operational rule applied

Draft text that merely describes a future component, mechanism, ruling, or decision counts only as DRAFT_ONLY material; it does not make the component PRESENT. This follows the task's own examples (Controller, Launcher, OS sandbox classified ABSENT / DRAFT_ONLY).

## 3. Executive Summary

### State counts (108 topics)

- **PRESENT:** 4
- **PARTIAL:** 35
- **ABSENT:** 68
- **CONFLICT:** 1
- **UNKNOWN:** 0

### Layer counts

- **IMPLEMENTED:** 0
- **OPERATIONAL_BOOTSTRAP:** 9
- **POLICY_ONLY:** 9
- **ACCEPTED_DOCUMENTATION:** 9
- **DRAFT_ONLY:** 76
- **SCAFFOLD_ONLY:** 3
- **MIXED:** 2
- **NOT_APPLICABLE:** 0
- **UNKNOWN:** 0

### Summary

- **Strongest currently represented areas:** Report-numbering and execution-identity machinery (topic 5); accepted reporting-standard policy covering timing integrity, reasoning diagnostics fields, supersession, and telemetry-failure mention (topics 6, 9, 63, 95–100); documentation authority and human-sequencing policy in AGENTS.md (topics 20, 29, 38, 58, 59); the "no shadow Tendril" boundary (101); the extraction-standard draft (49–55).
- **Strongest operational bootstrap areas:** Counter-file report allocation (5, 10); the fresh-session one-task execution loop (41); OpenCode application-level permission enforcement (31, 32); custom tool loading and scoped-read proof (26); the UP_NEXT/instruction-log scheduler (40); the one-off reasoning JSONL extraction (2, 3).
- **Largest architecture gaps:** The entire execution architecture — Controller, Launcher, Task Contract beyond template, Control Policy, Execution Envelope, Runtime Ledger, Independent Verifier, lifecycle, rollback, baseline, staleness, write leases, secrets (11–27); OpenWork control plane (37–43); OAC (44–48); headless architecture (69–77); security (30–32); Git/worktree integration (33–36).
- **Largest product implementation gaps:** Everything in `product/tendril/` scope — V0 product, Prompt node, node/run schema, message packets, run pinning, operation tag, context preview, save/reopen, provider abstraction, persistence (78–87). The product directory is empty.
- **Largest runtime/harness gaps:** Harness-owned observation (1), capture-before-control (4), harness-owned diagnostics (6, 95–97), semantic-progress measurement (7), finalization telemetry (8), phase timestamp ownership (9), Runtime Ledger (17), atomic allocation (10), telemetry-failure classification (99).
- **Major draft-only areas:** 76 of 108 topics are DRAFT_ONLY. The execution architecture, security, OAC, headless architecture, product scope, corpus strategy, and historical material exist only as draft handovers.
- **Important conflicts:** 1 (topic 3 — reasoning artifact naming: handover prefers `.reasoning.jsonl` with R-number prefix; accepted standard prescribes `.reasoning.md` and shows a non-R-prefixed example).
- **Important unknowns:** No topics were classified UNKNOWN; all 108 were determinable from in-scope files. External material referenced by the handover (old Baton repository, OpenCode SQLite database, older corpus, File Library) could not be inspected and limits verification of historical claims, not classification.

## 4. Topic-by-Topic Review

### 1. Harness-Owned Agent Observation

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §1
- Describes the required harness/controller-owned observation model ("Agent reports the work. Harness reports the agent.")

Additional evidence:
- `/home/gabriel/project-tendril/AGENTS.md:160` — raw reasoning "must eventually be captured by the harness" (future acknowledgment, not implementation)
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:162` — atomic allocation "a future harness/controller responsibility"

Missing or unresolved:
- No harness exists; no independent observation of execution beyond agent-authored reports

Assessment:
No harness-owned observation capability exists. The concept is acknowledged as future work in accepted policy and described in drafts only.

### 2. Raw Reasoning Capture

State:
PARTIAL

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/R000003_20260811T075943Z_deepseek-v4-flash-max_locate-thought-stream.reasoning.jsonl` (63425 bytes)
- One-off demonstration that the runtime reasoning stream is directly observable and extractable

Additional evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:491` — "preferred long-term source of the reasoning trace is the execution harness/runtime, not self-reconstruction by the agent"
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §2

Missing or unresolved:
- No capture mechanism; no ongoing per-execution capture; the single artifact was agent-extracted from the OpenCode SQLite database during a bootstrap execution

Assessment:
The raw reasoning stream was observed once and preserved in one artifact. The capability is demonstrated but is bootstrap practice, not harness machinery.

### 3. Reasoning JSONL Artifact

State:
CONFLICT

Layer:
MIXED

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:482-489` — prescribes storing reasoning traces beside task reports "using the same basename with .reasoning.md", with an example path lacking the R-number prefix
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/R000003_20260811T075943Z_deepseek-v4-flash-max_locate-thought-stream.reasoning.jsonl` — the only existing artifact, `.reasoning.jsonl`, R-number-prefixed, matching the handover's preferred form

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §3 — "Preferred raw form: `R000123_<timestamp>_<task-slug>.reasoning.jsonl`"; `.reasoning.md` only "may later be derived"

Missing or unresolved:
- Per-execution artifacts do not exist (only R000003 has one); standard and handover disagree on suffix and filename form

Assessment:
Missing-material position: the preferred raw artifact is `.reasoning.jsonl` with an R-number-prefixed basename; `.reasoning.md` is at most a derived view. Current-project position: the accepted reporting standard prescribes `.reasoning.md` beside the report and its example uses a timestamp-only name with no R-number; the one on-disk artifact uses `.reasoning.jsonl` with an R-number prefix. The two positions materially contradict each other on artifact naming. The R000003 demonstration itself is real (see section 8).

### 4. Capture Must Begin Before the Model Gets Control

State:
PARTIAL

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §Pre-Task Initialization Gate (lines 55-160)
- Prompt-level gate requiring report-first behavior and prohibiting substantive reasoning before report creation

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §4 — the handover itself states prompt-level rules are "temporary bootstrap controls, not the final enforcement mechanism"

Missing or unresolved:
- Structural capture before model control does not exist; no harness to allocate identity, timestamp start, and initialize telemetry before agent launch

Assessment:
The prompt gate is a genuine policy control, but it is behavior policy, not capture. The structural requirement is unimplemented and the handover itself acknowledges the current mechanism is temporary.

### 5. Report Number as Execution Join Key

State:
PRESENT

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:39,100-107` — Report Number is the canonical execution identifier and stable join key; identity excluded from filenames
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/NEXT_REPORT_NUMBER` (counter mechanism)
- `R000001`-style numbered reports and the R000003 `.reasoning.jsonl` artifact joining by R-number prefix

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §5

Missing or unresolved:
- Concurrency-safe allocation (see topic 10); the only telemetry artifact joined so far is R000003

Assessment:
The join-key concept is materially implemented in the current reporting system: monotonic numbering, R-prefixed filenames without provider/model identity, and one telemetry artifact joined by Report Number. This is bootstrap machinery, not product architecture.

### 6. Harness-Owned Reasoning Diagnostics

State:
PARTIAL

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` §Reasoning Diagnostics (lines 428-491)
- Diagnostics fields exist (Reasoning Capture, Trace, Duration, Tokens, Loop Indicators, Decision Revisions, Repeated Checks) and are populated by the reporting agent

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §6 — flags agent self-population as unreliable

Missing or unresolved:
- Harness ownership; automatic extraction of reasoning event count, duration, tokens, stalls, reversals

Assessment:
The diagnostics fields are represented in the accepted standard but are agent-populated, which the handover (and the standard's own line 475) identifies as unreliable. Harness-owned analysis does not exist.

### 7. Semantic-Progress Measurement

State:
PARTIAL

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §Decision Stability (lines 311-319) and §Terse Reasoning — "No new evidence, no renewed deliberation" as governing model behavior
- `/home/gabriel/project-tendril/AGENTS.md:319` — "Do not continue reasoning merely to increase confidence in an already-supported decision"

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §7

Missing or unresolved:
- Any measurement signal; no harness distinguishes reasoning activity from semantic progress

Assessment:
The principle is established as policy governing model reasoning, but measurement is entirely absent.

### 8. Finalization-Time Telemetry

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §8

Additional evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` §Execution Timing — only Started/Finished UTC and Duration Seconds are captured

Missing or unresolved:
- Phase distinctions (execution start, substantive work start/end, verification end, finalization start/end); Finalization Duration metric

Assessment:
No phase-level telemetry exists. The accepted standard captures only start/finish/duration; the topic is described only in draft form.

### 9. Phase Timestamp Ownership

State:
PARTIAL

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` §Timing Integrity (lines 213-227) — timestamps must never be reconstructed, approximated, backfilled, or fabricated; UNKNOWN if not captured at the required event
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` §Live Report Lifecycle (lines 229-261)

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §9 — R000005 detected/corrected timestamp reconstruction

Missing or unresolved:
- Harness/controller-owned phase timestamps; the current rule depends on the model sampling correctly

Assessment:
The anti-reconstruction rule is established in the accepted standard and followed in live reports, but ownership remains with the agent, not a harness.

### 10. Atomic Report-Number Allocation

State:
PARTIAL

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/NEXT_REPORT_NUMBER` — working counter-file allocation (read/validate/allocate/increment/write)
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:162` — "Concurrent-safe atomic allocation is a future harness/controller responsibility"

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §10

Missing or unresolved:
- Concurrency safety; atomic reservation for parallel executions

Assessment:
The counter-file protocol works today as bootstrap machinery and satisfies monotonicity/no-reuse. Atomicity is explicitly deferred to a future harness.

### 11. Controller

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §11
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §12 (pipeline description)

Additional evidence:
- `/home/gabriel/project-tendril/control/` — contains only `contracts/task-contract.yaml` template; no controller code

Missing or unresolved:
- Entire component: validation, authorization, envelope materialization, observation, termination, verification, finalization

Assessment:
No controller code, configuration, or state exists anywhere in the project. Described only in drafts.

### 12. Launcher

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §12
- `/home/gabriel/project-tendril/worktrees/bootstrap/` and `/home/gabriel/project-tendril/worktrees/product/` — both empty

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §14 (Launcher deliberately deferred)

Missing or unresolved:
- Entire component: worktree creation, filesystem isolation, namespace/mount boundaries, capability injection, process spawn

Assessment:
No launcher exists. The worktrees directories are empty scaffolds.

### 13. Controller ≠ Launcher

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §13
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §12 — pipeline shows Controller, ExecutionEnvelope, Launcher as separate stages

Additional evidence:
- none necessary

Missing or unresolved:
- Explicit accepted documentation of the distinction; any implementation of either component

Assessment:
The distinction is present only as draft pipeline description. No accepted document states it and no component exists.

### 14. Task Contract

State:
PARTIAL

Layer:
SCAFFOLD_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/control/contracts/task-contract.yaml` — 26-line template with task_id, title, objective, scope (read/write), context, capabilities (network/tools), constraints, depends_on, done_when, expected_evidence

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §14

Missing or unresolved:
- Live contracts; validation; materialization; required evidence/verification semantics beyond template fields; ambiguity/blocking behavior

Assessment:
A real template exists on disk covering a meaningful subset of the required fields, but no live task contract exists for any authorized task and nothing validates or enforces it. Scaffold-only.

### 15. Control Policy

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §15

Additional evidence:
- `/home/gabriel/project-tendril/opencode.jsonc` — application-level permission rules, not a machine-readable Control Policy

Missing or unresolved:
- Authoritative constraint layer (filesystem, network, process, secrets, write restrictions, verifier rules) separate from task intent

Assessment:
No Control Policy representation exists beyond draft description. The current permission configuration is OpenCode application config, not Control Policy.

### 16. Execution Envelope

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §16

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §12

Missing or unresolved:
- Frozen/hashable execution contract; materialization flow

Assessment:
Described only in drafts. Nothing materializes, freezes, or hashes an execution contract.

### 17. Runtime Ledger

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §17

Additional evidence:
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/` — contains only agent-authored task reports and one reasoning JSONL; no ledger

Missing or unresolved:
- Authoritative execution record: envelope hash, process/runtime IDs, worktree, tool events, termination reason, verifier result

Assessment:
No ledger exists. Task reports are agent-authored projections, not a runtime ledger.

### 18. Independent Verifier

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §18

Additional evidence:
- All verification in current reports is performed by the executing agent (self-verification)

Missing or unresolved:
- Trusted post-execution verification infrastructure; irrefutable verification evidence

Assessment:
No independent verification exists anywhere in the project. Verification is agent self-verification only.

### 19. SUCCEEDED ≠ VERIFIED

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §19

Additional evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` §Required Status — the only status model is PASS/PARTIAL/BLOCKED/FAIL, assigned by the agent

Missing or unresolved:
- Formal lifecycle (DRAFT … SUCCEEDED/FAILED/BLOCKED, VERIFIED, ACCEPTED/REJECTED, CLOSED); SUCCEEDED-vs-VERIFIED distinction

Assessment:
The only current status model is the agent-assigned terminal status in the accepted standard. No lifecycle or verified distinction exists.

### 20. Candidate Change / Acceptance Boundary

State:
PARTIAL

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §Documentation Authority (lines 491-515) — drafts/proposed-main placement, promotion to main requires explicit human authorization
- `/home/gabriel/project-tendril/AGENTS.md:515` — extraction/reconciliation agents must not modify authoritative documentation without explicit promotion authority

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §20

Missing or unresolved:
- Structural candidate boundary for code, schemas, and architecture; only documentation promotion has a policy boundary

Assessment:
A candidate/acceptance boundary exists for documentation (policy-enforced), but there is no mechanism applying candidate → verification → acceptance → integration to other artifact types.

### 21. Rollback and Abandonment

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §21

Additional evidence:
- none necessary

Missing or unresolved:
- Semantics for aborted/failed/rejected/timed-out/crashed executions; evidence preservation without polluting authoritative state

Assessment:
No rollback, abandonment, or failure-preservation semantics exist in any current file.

### 22. Frozen Baseline

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §22

Additional evidence:
- `/home/gabriel/project-tendril/` is not a Git repository (verified: `git status` → "fatal: not a git repository"); no commit or baseline identity exists

Missing or unresolved:
- Repository/commit/worktree/policy-version baseline identity for executions

Assessment:
No baseline identity mechanism exists. The project has no version control at all.

### 23. Staleness / Dirty Propagation

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §23

Additional evidence:
- none necessary

Missing or unresolved:
- Staleness semantics for dependent results when upstream authority changes

Assessment:
No staleness or dirty-propagation mechanism or policy exists in current files.

### 24. Stable Identity and Provenance

State:
PARTIAL

Layer:
MIXED

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:34-39,88-108` — Report Number as stable execution identity; allocation rules
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/` — operational evidence of stable report/execution identity

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §24

Missing or unresolved:
- Stable identity for tasks, envelopes, worktrees, artifacts, decisions, evidence, nodes, runs, source material; provenance preservation for derived/copied objects

Assessment:
Only the report/execution identity domain (Report Number) is represented, at accepted-documentation and operational-bootstrap layers. All other identity domains are absent.

### 25. Write Leases / Concurrent Mutation

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §25

Additional evidence:
- none necessary

Missing or unresolved:
- Any mechanism preventing overlapping uncontrolled writes by parallel agents

Assessment:
No write-lease or concurrency-mutation control exists; the invariant is described only in the draft.

### 26. Tool Identity

State:
PARTIAL

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `/home/gabriel/project-tendril/bootstrap/experiments/harness-probe/.opencode/tools/tendril_probe.ts` — custom Tendril-owned tool, loaded and executed through OpenWork
- `/home/gabriel/project-tendril/bootstrap/instructions/instruction-log/INST-0001.md`, `INST-0002.md` — PASS results: tool-surface control, scoped read with path/symlink traversal rejection

Additional evidence:
- `/home/gabriel/project-tendril/opencode.jsonc` — application-level capability allow/deny by capability name

Missing or unresolved:
- A capability-description model tying abstract actions to actual tools/runtimes; observability of tool identity as a general mechanism

Assessment:
The bootstrap experiments prove custom tools with restricted surfaces work today. A general tool-identity/capability model does not exist.

### 27. Secrets as Capabilities

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §27

Additional evidence:
- `/home/gabriel/project-tendril/opencode.jsonc` — no secret-related capability exists; nothing injects or revokes secrets

Missing or unresolved:
- Launcher-side secret injection, minimal exposure, no workspace copying, no report/log disclosure, revocation

Assessment:
No secret handling exists at any layer.

### 28. Structured Clarification

State:
PARTIAL

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §Failure Behaviour — BLOCKED must state what is missing, why it prevents completion, and the minimum human decision or capability required
- `/home/gabriel/project-tendril/bootstrap/DOCTRINE.md` invariant 5 — "missing authority or information causes BLOCKED, not guessing"

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §28

Missing or unresolved:
- A structured ClarificationRequest object; no structured ambiguity representation in any data model

Assessment:
The BLOCKED protocol is established policy and functions operationally, but there is no structured clarification artifact.

### 29. Discovery vs Execution

State:
PARTIAL

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §5 No Opportunistic Work (line 226) and §9 Queue Behaviour (line 286) — FOLLOW-UP CANDIDATE reporting; agents may not self-sequence, reorder, accept, or create work
- `/home/gabriel/project-tendril/AGENTS.md` §6 Human Sequencing Authority

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §29 — the handover itself acknowledges the principle "exists behaviorally in AGENTS.md"

Missing or unresolved:
- Explicit representation in a data/API model (discovery, proposal, authorization, execution as distinct states)

Assessment:
The distinction is behaviorally enforced by policy today. The structural data model the handover wants is absent.

### 30. Real OS-Level Sandbox

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §30
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §13 — "OpenCode permissions are not intended to be the ultimate security perimeter"; sandbox deferred
- `/home/gabriel/project-tendril/documentation/drafts/openwork-handover-2026-08-11.md` — "The hard sandbox is not yet implemented"

Additional evidence:
- No namespace, bind-mount, container, or kernel-enforcement configuration exists anywhere in the project

Missing or unresolved:
- Any OS-enforced isolation mechanism

Assessment:
No OS-level sandbox exists. Security is application-level only (AGENTS.md + opencode.jsonc).

### 31. Project Perimeter

State:
PARTIAL

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `/home/gabriel/project-tendril/opencode.jsonc` — `external_directory: deny` enforced at application level
- `/home/gabriel/project-tendril/AGENTS.md` §4 — project root is the maximum boundary

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §31

Missing or unresolved:
- Launcher-constructed finite visible filesystem; deny-by-default host visibility; structural enforcement

Assessment:
The perimeter today is application-level denial plus behavioral policy, and it works. The structural deny-by-default filesystem is absent.

### 32. Network Capability

State:
PARTIAL

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `/home/gabriel/project-tendril/opencode.jsonc` — `webfetch: deny`, `websearch: deny` enforced at application level

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §32

Missing or unresolved:
- A capability schema for no-network / specific-provider / specific-endpoint / broader authorization

Assessment:
Network is denied at the application layer today (working), but there is no granular network capability model.

### 33. Agent Git Authority

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §33

Additional evidence:
- `/home/gabriel/project-tendril/AGENTS.md` — contains no Git-authority rule (verified by search); project is not a Git repository

Missing or unresolved:
- Any rule or mechanism preventing ordinary agents from owning Git integration

Assessment:
No Git authority policy or mechanism exists. The topic is draft-only.

### 34. Worktree Lifecycle

State:
ABSENT

Layer:
SCAFFOLD_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/worktrees/bootstrap/` and `/home/gabriel/project-tendril/worktrees/product/` — empty directories

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §34 — the handover itself states the directories "are currently structure, not the complete lifecycle"

Missing or unresolved:
- Creation, baseline selection, naming, task association, cleanup, preservation, integration semantics

Assessment:
Only empty scaffold directories exist. No lifecycle behavior.

### 35. Git Integration Evidence

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §35

Additional evidence:
- Project is not a Git repository (verified with `git status`)

Missing or unresolved:
- Baseline commit, candidate diff, verification result, resulting commit, provenance chain

Assessment:
No Git integration exists in any form.

### 36. Private Repository / Authorship / Licensing

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §36

Additional evidence:
- No repository exists; no licensing, privacy, or authorship policy exists in current files

Missing or unresolved:
- Durable Git/GitHub policy (private during development, authorship preservation, licensing headroom, clean history)

Assessment:
The fresh project has no repository and no such policy. The historical direction cannot be inspected within the project boundary, but its absence from the fresh rebuild is directly verifiable.

### 37. OpenWork Queue State Model

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §37
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §10 — intended PLAN/READY/IN PROGRESS/REQUIRES ATTENTION/DONE states as description only

Additional evidence:
- No queue state files, API, or configuration exist in the project

Missing or unresolved:
- Any materialized state model or state transitions

Assessment:
The state model exists only as draft descriptions. No queue machinery exists.

### 38. Human Queue Authority

State:
PARTIAL

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §6 Human Sequencing Authority — human controls task selection, priority, ordering, approval, scope, acceptance, architecture
- `/home/gabriel/project-tendril/AGENTS.md` §9 — agents may not self-sequence

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §38 — the handover itself states this "currently exists as agent policy"

Missing or unresolved:
- Real control-plane state transitions enforcing the authority

Assessment:
Human queue authority is fully established as policy and behaviorally enforced today; the structural control-plane rule is absent.

### 39. Project Control

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §39

Additional evidence:
- No Project Control skill, capability, or tool exists; no `.opencode` skills directory at project root

Missing or unresolved:
- Any capability managing candidate registration, queue state, readiness, attention, acceptance, dependencies

Assessment:
No Project Control exists. The human manages task state manually.

### 40. Retire Manual `UP_NEXT`

State:
PARTIAL

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `/home/gabriel/project-tendril/bootstrap/instructions/UP_NEXT.md` — still points to INST-0002, which is completed (PASS)
- `/home/gabriel/project-tendril/bootstrap/instructions/instruction-log/INST-0002.md` — completed PASS result

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §10 — mechanism "not intended to remain the live build scheduler once OpenWork carries that state"

Missing or unresolved:
- The OpenWork queue that would allow retirement; the pointer is stale (INST-0002 done)

Assessment:
UP_NEXT still operates as the scheduler pointer and is stale relative to the completed instruction log. Its retirement is documented as intended but not performed because no queue exists yet.

### 41. Fresh Session Per Task

State:
PARTIAL

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §1 Fresh Policy Bootstrap — every execution loads current policy and task; previous sessions are not authority
- `/home/gabriel/project-tendril/bootstrap/DOCTRINE.md` §Fresh Execution Bootstrap
- Operational practice: one task per fresh session, one report, stop

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §41

Missing or unresolved:
- Controller-enforced fresh execution per task; today the human manually opens fresh sessions

Assessment:
The fresh-session one-task pattern works today as bootstrap practice with policy support. Making it a controller execution property is absent.

### 42. OpenWork Context Contamination Isolation

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §42

Additional evidence:
- No workspace/run identity validation mechanism exists in the project

Missing or unresolved:
- Explicit materialization and validation of workspace/run identity, execution context, project root, policy, session association

Assessment:
No isolation or identity-validation mechanism exists. Draft-only.

### 43. OpenWork/OpenCode Boundary

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §43

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §4 — describes the working division (draft only)

Missing or unresolved:
- Accepted documentation of the boundary; harness integration tapping the correct telemetry source

Assessment:
The boundary is described in draft handovers only. No accepted documentation or harness work exists.

### 44. OAC Purpose

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/ontological-agent-compiler-handover.md` — full draft description of OAC purpose
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §44

Additional evidence:
- `/home/gabriel/project-tendril/oac/` — empty directory

Missing or unresolved:
- Any OAC component; the directory is an empty scaffold

Assessment:
OAC is described extensively in a draft handover, but no component exists. Draft-only.

### 45. OAC Does Not Authorize Work

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/ontological-agent-compiler-handover.md` §Authority Boundary — documents what OAC may not do
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §45

Additional evidence:
- none necessary

Missing or unresolved:
- Any OAC existence; the constraint applies to a component that does not exist

Assessment:
The constraint is documented in draft form, but since no OAC exists the topic's substance is draft-only.

### 46. OAC Output Contract

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §46
- `/home/gabriel/project-tendril/documentation/drafts/ontological-agent-compiler-handover.md` §Task Output — "The exact task-contract schema is not yet frozen"

Additional evidence:
- none necessary

Missing or unresolved:
- Any compiler output schema; no candidate-task artifact format exists

Assessment:
No output contract exists in any form.

### 47. Compiler Versioning

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §47

Additional evidence:
- none necessary

Missing or unresolved:
- Provenance for task translation; compiler/policy version identification

Assessment:
No compiler exists, so no versioning exists. Draft-only.

### 48. Lazy Ontology Bootstrap

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §48

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §14 — "Do not build yet unless a real need forces it" (adjacent, not identical)

Missing or unresolved:
- Any ontology kernel or expansion policy

Assessment:
The direction is described only in the draft. No ontology exists at all.

### 49. Handover Extraction Standard

State:
PARTIAL

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/proposed-main/standards/handover-extraction.md` — 246-line draft standard (Status: CURRENT within the draft, but not promoted)

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §49

Missing or unresolved:
- Cleanup of known defects; acceptance and promotion to `documentation/main/`

Assessment:
The standard exists as a substantive draft deliverable under proposed-main. It is not accepted; promotion is pending.

### 50. Extraction Categories

State:
PARTIAL

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/proposed-main/standards/handover-extraction.md` §Extraction Categories — 16 canonical categories present in the draft

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §50

Missing or unresolved:
- Review and acceptance of the category set

Assessment:
The categories are fully represented in the draft standard but not accepted.

### 51. Extraction Metadata

State:
PARTIAL

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/proposed-main/standards/handover-extraction.md` §Extracted Item Metadata — Source Strength (EXPLICIT/INFERRED/UNCERTAIN), Current State (UNKNOWN/ALREADY REPRESENTED/PARTIAL/NEW/CONFLICTING), Source Section

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §51

Missing or unresolved:
- Acceptance; single-source UNKNOWN default is a rule in the draft, not in force

Assessment:
The metadata model is represented in the draft standard only.

### 52. One Source → One Extraction

State:
PARTIAL

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/proposed-main/standards/handover-extraction.md` — "One source handover produces one extraction artifact"; "Do not perform cross-document reconciliation during single-source extraction"

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §52

Missing or unresolved:
- Any performed extractions; acceptance of the rule

Assessment:
The rule is represented in the draft standard. No extraction artifacts exist to apply it.

### 53. Extraction Is Not Authority

State:
PARTIAL

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/proposed-main/standards/handover-extraction.md` — "Extraction does not itself: grant authority, modify accepted documentation, authorize or execute discovered work"

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §53

Missing or unresolved:
- Acceptance of the standard; the rule is not yet in force

Assessment:
The non-authority principle is fully written in the draft standard, consistent with AGENTS.md Documentation Authority, but only as a draft.

### 54. Extraction Output Location

State:
PARTIAL

Layer:
SCAFFOLD_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/extractions/` — directory exists and is empty
- `/home/gabriel/project-tendril/documentation/drafts/proposed-main/standards/handover-extraction.md` §Output Requirements — designates this path

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §54 (asked to confirm existence)

Missing or unresolved:
- Any extraction artifacts; formal creation authorization

Assessment:
The directory exists (observed empty). No extractions have been performed.

### 55. Known Extraction-Standard Defects

State:
PRESENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/proposed-main/standards/handover-extraction.md` — verified in the file: repeated "output remains draft" statements (lines 142, 173); duplicated "For the single-source default Current State behavior..." cross-reference (lines 93, 162); Source Section defined twice (lines 97-105 and 117-128); provenance wording at line 105 that can read as optional

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §55
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §9 — records the same defects

Missing or unresolved:
- none — the defects the topic claims are verifiably present in the draft

Assessment:
The topic describes defects that materially exist in the current draft file. The repair is not done (not part of this review).

### 56. Full Documentation Integration Pipeline

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §56

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/extractions/` — empty; no pipeline stages exist

Missing or unresolved:
- Source → verbatim draft → extraction → reconciliation → human adjudication → materialization as a pipeline

Assessment:
The pipeline is described only in the draft. None of its stages exist as machinery (extraction outputs are empty; no reconciliation stage exists).

### 57. Reconciliation Stage

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §57

Additional evidence:
- No reconciliation artifacts or tools exist; this review document is itself a one-off reconciliation execution, not pipeline machinery

Missing or unresolved:
- A reusable reconciliation stage comparing extracted material against accepted docs, other extractions, and evidence

Assessment:
No reconciliation stage exists. Classification is being performed ad hoc by this execution only.

### 58. Human Adjudication

State:
PARTIAL

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §Documentation Authority — promotion requires explicit human authorization; extraction/reconciliation agents must leave authoritative docs unchanged
- `/home/gabriel/project-tendril/AGENTS.md` §3 Authority ordering and §6 Human Sequencing Authority

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §58

Missing or unresolved:
- A defined adjudication step in a pipeline; the policy boundary exists but no process machinery

Assessment:
The human boundary over meaning/authority promotion is established policy. Pipeline-level adjudication does not exist.

### 59. Materialization as Separate Mutation

State:
PARTIAL

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §2 One Task, §5 No Opportunistic Work, §Documentation Authority — each project mutation is a bounded task; promotion requires human authorization

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §59

Missing or unresolved:
- Structured separation of adjudication from mutation in a pipeline; independent verification after each mutation

Assessment:
The behavioral rule (one bounded task per mutation, no wholesale rewriting) is policy. Structured pipeline separation is absent.

### 60. Old Corpus Integration Into Fresh Rebuild

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §60

Additional evidence:
- No corpus files exist under `/home/gabriel/project-tendril/`; `references/` is empty; the old corpus lives outside the project boundary and was not inspected

Missing or unresolved:
- Any serial integration process or imported corpus material

Assessment:
No old corpus material or integration process exists in the fresh rebuild. Draft-only.

### 61. Bible / Manifest Strategy

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §61

Additional evidence:
- No TENDRIL_BIBLE.md, CORPUS_MANIFEST.json, artifact-ID, or hash machinery exists in the fresh rebuild

Missing or unresolved:
- Any decision on whether the historical corpus structure is retained, simplified, or replaced

Assessment:
The historical machinery is absent from the fresh rebuild; no decision has been made. Draft-only.

### 62. Projection Is Not Authority

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §62

Additional evidence:
- Adjacent (not equivalent): `/home/gabriel/project-tendril/AGENTS.md` — task reports are operational evidence, not authority; `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:10` — reports do not grant authority

Missing or unresolved:
- The projection-vs-authority invariant for indexes, databases, UI projections, summaries, derived graphs

Assessment:
The report-non-authority rule is related, but the projection invariant itself exists only in the draft.

### 63. Additive History / Supersession

State:
PARTIAL

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:257-258` — "Previously recorded observations must not be silently rewritten... append the correction and identify what it supersedes"

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §63

Missing or unresolved:
- General supersession semantics for corpus/documents/decisions; the rule currently covers live task reports only

Assessment:
An additive-history rule exists in the accepted reporting standard for reports. The broader design is absent.

### 64. Hash Domains

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §64

Additional evidence:
- No hashing machinery exists (no Git, no envelope, no artifact hashing)

Missing or unresolved:
- Any hash-domain definition

Assessment:
No hash usage exists in the fresh rebuild. Draft-only.

### 65. SilverBullet Is Not Execution Authority

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §65

Additional evidence:
- No SilverBullet reference exists anywhere in current files; the ruling itself is not recorded in any current file

Missing or unresolved:
- The ruling as recorded fresh-rebuild material

Assessment:
The invariant is trivially satisfied (no SilverBullet dependency exists) but the ruling is not documented in the fresh project; it exists only in the draft.

### 66. Markdown + Git Corpus

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §66

Additional evidence:
- Project is not a Git repository; no corpus files exist

Missing or unresolved:
- Any corpus; any Git tracking

Assessment:
No corpus or Git tracking exists. Draft-only.

### 67. Unresolved Corpus-Projection Fork

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §67 — the question is recorded as unresolved
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.1 — records the same open question

Additional evidence:
- none necessary

Missing or unresolved:
- Any decision on corpus Markdown authority (directly maintained vs generated projection)

Assessment:
The question is recorded as open in draft files only. No decision or architecture exists.

### 68. Linux Native Filesystem

State:
PARTIAL

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/` — observed living on a native case-sensitive Linux filesystem under `/home/gabriel/project-tendril/`
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §2 — canonical location documented; supersedes older paths

Additional evidence:
- `/home/gabriel/project-tendril/bootstrap/project.env` — PROJECT_ROOT definition

Missing or unresolved:
- An explicit implementation/environment decision record (draft description only)

Assessment:
The deployment reality is directly observed (native Linux path), and the location decision is documented in a draft. No accepted environment-decision record exists.

### 69. Tendril Must Be Functionally Headless

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §69

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §14 — Tendril GUI deliberately deferred (adjacent)

Missing or unresolved:
- The headless ruling as fresh-rebuild material; any runtime

Assessment:
The ruling exists only in the draft. No product or runtime exists.

### 70. Node Contracts Define Semantics

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §70

Additional evidence:
- `/home/gabriel/project-tendril/product/tendril/` — empty

Missing or unresolved:
- Any node contract or runtime

Assessment:
No node-contract representation exists. Draft-only.

### 71. Backend Is Authoritative

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §71

Additional evidence:
- none necessary

Missing or unresolved:
- Any backend/frontend split

Assessment:
Described only in drafts. No backend or frontend exists.

### 72. Finite Frontend Surface

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §72

Additional evidence:
- none necessary

Missing or unresolved:
- Any frontend

Assessment:
Draft-only.

### 73. GUI Action = Backend Command

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §73

Additional evidence:
- none necessary

Missing or unresolved:
- Any GUI or backend command surface

Assessment:
Draft-only.

### 74. Replaceable Clients

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §74

Additional evidence:
- none necessary

Missing or unresolved:
- Any runtime or client

Assessment:
Draft-only.

### 75. Platform Split Is Not Ontology

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §75

Additional evidence:
- none necessary

Missing or unresolved:
- The ruling as fresh-rebuild material; any platform architecture

Assessment:
The ruling exists only in the draft.

### 76. Transport Is Still Open

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §76 — transport recorded as open

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.5 — records the same open question

Missing or unresolved:
- Any transport decision or transport itself

Assessment:
Transport is recorded as an open question in draft files; no transport exists. Draft-only.

### 77. Runtime Database Is Still Open

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §77 — runtime persistence schema recorded as open

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.4 — records the same open question

Missing or unresolved:
- Any runtime database or persistence schema

Assessment:
The question is recorded as open in draft files only.

### 78. Version Zero Product Scope

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §78
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §1 — V0 described as larger architecture, product deferred

Additional evidence:
- `/home/gabriel/project-tendril/product/tendril/` — empty directory

Missing or unresolved:
- Any V0 specification in accepted files; any product code

Assessment:
V0 scope is described in drafts only. The product directory is empty.

### 79. Upstream Run Selection

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §79

Additional evidence:
- none necessary

Missing or unresolved:
- Any run-selection or pinning schema

Assessment:
Draft-only.

### 80. Operation Tag

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §80

Additional evidence:
- none necessary

Missing or unresolved:
- Any run schema with operation classification

Assessment:
Draft-only.

### 81. Exact Message Packet

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §81

Additional evidence:
- none necessary

Missing or unresolved:
- Any message packet schema or model execution record

Assessment:
Draft-only.

### 82. Context Preview

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §82

Additional evidence:
- none necessary

Missing or unresolved:
- Any context-inspection capability

Assessment:
Draft-only.

### 83. Context Composer / Horse Blinkers

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §83

Additional evidence:
- none necessary

Missing or unresolved:
- Any context-selection mechanism

Assessment:
Draft-only.

### 84. Typed Channels

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §84

Additional evidence:
- none necessary

Missing or unresolved:
- Any channel/edge schema

Assessment:
Draft-only.

### 85. Pull-Based Execution

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §85

Additional evidence:
- none necessary

Missing or unresolved:
- Any execution engine

Assessment:
Draft-only.

### 86. Topology as Logic

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §86

Additional evidence:
- none necessary

Missing or unresolved:
- The direction as fresh-rebuild material; any graph topology

Assessment:
Draft-only.

### 87. Graph-Native Foyer

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §87 — self-described as "post-foundational architecture"

Additional evidence:
- none necessary

Missing or unresolved:
- Any foyer or projection surface

Assessment:
Draft-only, and the topic itself marks it as post-foundational.

### 88. Chat Compression Contract

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §88

Additional evidence:
- none necessary

Missing or unresolved:
- Any compression contract or chat-memory machinery

Assessment:
Draft-only.

### 89. Human Semantic Promotion Boundary

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §89

Additional evidence:
- Adjacent (not equivalent): AGENTS.md §Documentation Authority governs documentation promotion only

Missing or unresolved:
- A compression-specific promotion boundary

Assessment:
The general human-authority principle exists in policy, but the compression-specific boundary is draft-only.

### 90. Provider Flexibility

State:
PARTIAL

Layer:
OPERATIONAL_BOOTSTRAP

Primary owner/evidence:
- `runtime/reports/agent-tasks/` — report filenames R000001–R000005 evidence multiple models used in the bootstrap loop (deepseek-v4-pro-max, deepseek-v4-flash-max, deepseek-deepseek-v4-pro, deepseek-deepseek-v4-flash)
- `/home/gabriel/project-tendril/opencode.jsonc` — provider-agnostic tool configuration

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §90

Missing or unresolved:
- Product-level provider abstraction (no product exists)

Assessment:
Operationally, the bootstrap loop runs multiple providers/models without coupling. No product abstraction exists.

### 91. Current Operational Model Routing

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §91 — presented conditionally ("if an operational policy is wanted")

Additional evidence:
- No routing policy exists in any current file; historical filenames show models used, not a routing rule

Missing or unresolved:
- Any routing policy

Assessment:
No routing policy is recorded. The topic is informational and draft-only.

### 92. Baton Is Evidence, Not Fresh Authority

State:
PARTIAL

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §2 — "Historical material does not automatically become current authority"; old Baton/Tendril/CBook system preserved as historical reference

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §92

Missing or unresolved:
- Accepted documentation of the principle; no Baton material exists inside the fresh rebuild

Assessment:
The principle is documented in a draft handover. No Baton material exists in the project.

### 93. Historical Launcher Boundary

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §93

Additional evidence:
- No launcher material exists in the fresh rebuild; the historical finding cannot be verified within the project boundary

Missing or unresolved:
- The recorded historical decision as fresh-rebuild material

Assessment:
The historical launcher findings exist only in the draft. Draft-only.

### 94. Repository Archaeology Workflow

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §94

Additional evidence:
- none necessary

Missing or unresolved:
- The protocol as retained material; any repository to scan

Assessment:
Draft-only.

### 95. Agent Self-Diagnostics Are Not Trustworthy

State:
PARTIAL

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:475` — "Diagnostic observations about loops or repeated reasoning must be grounded in the captured trace rather than invented by the reporting agent"
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` §Reasoning Diagnostics — agent-populated fields remain in the standard

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §95 — R000012 reported UNAVAILABLE while the thought stream showed activity

Missing or unresolved:
- Removal of agent-asserted telemetry facts; harness ownership

Assessment:
The accepted standard acknowledges the limitation but still requires agent-populated diagnostics fields. Harness ownership is absent.

### 96. `Reasoning Capture` Semantics

State:
PARTIAL

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:434-472` — PRESENT/PARTIAL/UNAVAILABLE defined from the agent's perspective

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §96

Missing or unresolved:
- Runtime/harness-perspective semantics; separation of Agent Reasoning Visibility from Harness Reasoning Capture

Assessment:
The vocabulary exists in the accepted standard with agent-side semantics only. Harness-side definitions are absent.

### 97. Reasoning Diagnostics Placement

State:
PARTIAL

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` §Reasoning Diagnostics — diagnostics currently live inside the agent task report

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §97; `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.7

Missing or unresolved:
- The placement decision (in-report vs companion telemetry file vs harness-appended section)

Assessment:
The current placement (in the agent report) is established in the accepted standard. The future placement decision is recorded as open.

### 98. Timing Rule Consolidation

State:
PRESENT

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` — verified duplication: §Execution Timing (lines 187-211), §Timing Integrity (lines 213-227), §Live Report Lifecycle (lines 229-261) overlap on capture rules, UNKNOWN handling, and finalization timing

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §16.4 — records the same duplication

Missing or unresolved:
- none — the duplication the topic claims verifiably exists in the accepted standard

Assessment:
The timing-rule duplication materially exists in the accepted standard. Cleanup is not done (out of scope for this review).

### 99. Telemetry Failure Classification

State:
PARTIAL

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:225` — "A missing timing observation must be reported explicitly as a telemetry failure"

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §99; `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.8

Missing or unresolved:
- A canonical mapping of telemetry failure to a single issue/status representation

Assessment:
The concept is mentioned once in the accepted standard; no canonical classification exists.

### 100. Fresh Timestamp Per Execution-Log Entry

State:
PARTIAL

Layer:
ACCEPTED_DOCUMENTATION

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` §Execution Timing / §Timing Integrity — fresh sampling required for Started/Finished; §Live Report Lifecycle — "Previously recorded observations must not be silently rewritten"
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:253-254` — execution-log entries carry `<UTC timestamp> — <phase>`

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §100

Missing or unresolved:
- An unambiguous rule that each logged phase timestamp is freshly observed (or harness-supplied), not copied

Assessment:
Fresh-timestamp rules exist for start/finish and the log format requires per-entry timestamps, but the standard does not explicitly prohibit copying one timestamp across phases.

### 101. Bootstrap Must Not Become Shadow Tendril

State:
PRESENT

Layer:
POLICY_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/AGENTS.md` §Architectural Boundary (line 300) — "Bootstrap and control mechanisms used to build Tendril are not automatically Tendril product architecture"; no shadow implementation; no migration without authorization
- `/home/gabriel/project-tendril/bootstrap/DOCTRINE.md` §Track A Stopping Rule — "Do not build a shadow Tendril inside Bootstrap"

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §101

Missing or unresolved:
- Structural enforcement; the rule is policy only

Assessment:
The anti-shadow rule is established verbatim in current policy (AGENTS.md) and doctrine. It is policy, not structure.

### 102. No More Experiments as the Primary Mode

State:
PARTIAL

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/build-plan-handover.md` §8 — "These experiments are complete. Do not continue creating artificial probes unless a real implementation problem requires one."
- Observed practice: only two experiments (INST-0001, INST-0002) exist and both are closed

Additional evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §102

Missing or unresolved:
- Accepted policy; the direction exists only in a draft handover

Assessment:
The direction is documented in the build-plan draft and current practice complies (no new probes). No accepted policy codifies it.

### 103. Exact Controller Implementation

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §103 — implementation details recorded as unfrozen
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.2 — records the same open question

Additional evidence:
- none necessary

Missing or unresolved:
- Language, process topology, daemon-vs-invoked, persistence interface, Controller API

Assessment:
The question is recorded as open in draft files; no controller exists.

### 104. Exact Sandbox Technology

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §104 — sandbox technology recorded as unfrozen
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.3 — records the same open question

Additional evidence:
- none necessary

Missing or unresolved:
- Selection of isolation mechanism

Assessment:
The question is recorded as open; no sandbox exists.

### 105. Exact Runtime Persistence Schema

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §105 — schema recorded as unfrozen
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.4 — records the same open question

Additional evidence:
- none necessary

Missing or unresolved:
- Any persistence schema independent of SilverBullet

Assessment:
Recorded as open in drafts only.

### 106. Corpus Markdown Authority Model

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §106 — still unresolved (duplicates §67's question)
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.1

Additional evidence:
- none necessary

Missing or unresolved:
- Directly-maintained vs generated Markdown authority decision

Assessment:
Recorded as unresolved in drafts only.

### 107. Permanent Transport

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §107 — transport still open (duplicates §76)
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.5

Additional evidence:
- none necessary

Missing or unresolved:
- Transport selection

Assessment:
Recorded as open in drafts only.

### 108. Durable Entity Set

State:
ABSENT

Layer:
DRAFT_ONLY

Primary owner/evidence:
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §108 — entity set recorded as unresolved; "Do not let old vocabulary create new obligations"
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §18.6

Additional evidence:
- none necessary

Missing or unresolved:
- Verification and freezing of any durable entity set

Assessment:
Recorded as unresolved in drafts only.

## 5. Present Topics

- **5. Report Number as Execution Join Key** — layer OPERATIONAL_BOOTSTRAP — owner: report-numbering machinery in `documentation/main/standards/agent-task-reporting.md` + `runtime/reports/agent-tasks/NEXT_REPORT_NUMBER` and numbered reports.
- **55. Known Extraction-Standard Defects** — layer DRAFT_ONLY — owner: `documentation/drafts/proposed-main/standards/handover-extraction.md` (defects verifiably present in the draft).
- **98. Timing Rule Consolidation** — layer ACCEPTED_DOCUMENTATION — owner: `documentation/main/standards/agent-task-reporting.md` (duplication verifiably present).
- **101. Bootstrap Must Not Become Shadow Tendril** — layer POLICY_ONLY — owner: `AGENTS.md` §Architectural Boundary + `bootstrap/DOCTRINE.md` §Track A Stopping Rule.

## 6. Partial Topics

- **2. Raw Reasoning Capture** — OPERATIONAL_BOOTSTRAP — exists: one extracted JSONL artifact (R000003); missing: capture machinery.
- **4. Capture Must Begin Before the Model Gets Control** — POLICY_ONLY — exists: Pre-Task Initialization Gate; missing: structural pre-model capture.
- **6. Harness-Owned Reasoning Diagnostics** — ACCEPTED_DOCUMENTATION — exists: diagnostics fields in accepted standard (agent-populated); missing: harness ownership.
- **7. Semantic-Progress Measurement** — POLICY_ONLY — exists: "No new evidence, no renewed deliberation" policy; missing: measurement.
- **9. Phase Timestamp Ownership** — ACCEPTED_DOCUMENTATION — exists: anti-reconstruction timing-integrity policy; missing: harness-owned phase timestamps.
- **10. Atomic Report-Number Allocation** — OPERATIONAL_BOOTSTRAP — exists: working counter-file allocation; missing: concurrency safety.
- **14. Task Contract** — SCAFFOLD_ONLY — exists: `task-contract.yaml` template; missing: live contracts, validation, materialization.
- **20. Candidate Change / Acceptance Boundary** — POLICY_ONLY — exists: documentation promotion boundary; missing: boundary for code/schemas/architecture.
- **24. Stable Identity and Provenance** — MIXED — exists: Report Number identity (accepted doc + bootstrap); missing: other identity domains.
- **26. Tool Identity** — OPERATIONAL_BOOTSTRAP — exists: custom tool loading/scoped read proof; missing: capability-description model.
- **28. Structured Clarification** — POLICY_ONLY — exists: BLOCKED protocol; missing: structured ClarificationRequest.
- **29. Discovery vs Execution** — POLICY_ONLY — exists: FOLLOW-UP CANDIDATE behavior; missing: data/API representation.
- **31. Project Perimeter** — OPERATIONAL_BOOTSTRAP — exists: application-level external_directory deny; missing: structural finite filesystem.
- **32. Network Capability** — OPERATIONAL_BOOTSTRAP — exists: app-level webfetch/websearch deny; missing: capability schema.
- **38. Human Queue Authority** — POLICY_ONLY — exists: AGENTS.md human sequencing; missing: control-plane transitions.
- **40. Retire Manual UP_NEXT** — OPERATIONAL_BOOTSTRAP — exists: UP_NEXT pointer still operating (stale); missing: OpenWork queue to enable retirement.
- **41. Fresh Session Per Task** — OPERATIONAL_BOOTSTRAP — exists: manual fresh-session pattern + policy; missing: controller-enforced freshness.
- **49. Handover Extraction Standard** — DRAFT_ONLY — exists: 246-line draft in proposed-main; missing: cleanup, acceptance, promotion.
- **50. Extraction Categories** — DRAFT_ONLY — exists: 16 categories in draft; missing: acceptance.
- **51. Extraction Metadata** — DRAFT_ONLY — exists: Source Strength/Current State/Source Section in draft; missing: acceptance.
- **52. One Source → One Extraction** — DRAFT_ONLY — exists: rule in draft; missing: acceptance and performed extractions.
- **53. Extraction Is Not Authority** — DRAFT_ONLY — exists: rule in draft; missing: acceptance.
- **54. Extraction Output Location** — SCAFFOLD_ONLY — exists: empty `documentation/drafts/extractions/`; missing: extraction artifacts.
- **58. Human Adjudication** — POLICY_ONLY — exists: promotion requires human authorization; missing: pipeline adjudication step.
- **59. Materialization as Separate Mutation** — POLICY_ONLY — exists: one-task/no-opportunistic-work policy; missing: structured pipeline separation.
- **63. Additive History / Supersession** — ACCEPTED_DOCUMENTATION — exists: supersession rule for reports; missing: general semantics.
- **68. Linux Native Filesystem** — DRAFT_ONLY — exists: deployment on native Linux + draft location decision; missing: accepted environment-decision record.
- **90. Provider Flexibility** — OPERATIONAL_BOOTSTRAP — exists: multi-model bootstrap usage; missing: product abstraction.
- **92. Baton Is Evidence, Not Fresh Authority** — DRAFT_ONLY — exists: build-plan handover records the principle; missing: accepted documentation.
- **95. Agent Self-Diagnostics Are Not Trustworthy** — ACCEPTED_DOCUMENTATION — exists: standard's grounding rule; missing: removal of agent telemetry assertions, harness ownership.
- **96. `Reasoning Capture` Semantics** — ACCEPTED_DOCUMENTATION — exists: agent-side semantics in standard; missing: runtime/harness semantics.
- **97. Reasoning Diagnostics Placement** — ACCEPTED_DOCUMENTATION — exists: current in-report placement; missing: placement decision.
- **99. Telemetry Failure Classification** — ACCEPTED_DOCUMENTATION — exists: one mention in standard; missing: canonical classification.
- **100. Fresh Timestamp Per Execution-Log Entry** — ACCEPTED_DOCUMENTATION — exists: fresh sampling rules for start/finish; missing: explicit per-entry freshness rule.
- **102. No More Experiments as the Primary Mode** — DRAFT_ONLY — exists: direction in build-plan draft + compliant practice; missing: accepted policy.

## 7. Absent Topics

The following 68 topics have no meaningful current representation beyond draft description or empty scaffold:

1, 8, 11, 12, 13, 15, 16, 17, 18, 19, 21, 22, 23, 25, 27, 30, 33, 34, 35, 36, 37, 39, 42, 43, 44, 45, 46, 47, 48, 56, 57, 60, 61, 62, 64, 65, 66, 67, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 91, 93, 94, 103, 104, 105, 106, 107, 108.

Implementation is not proposed here.

## 8. Conflicts

### Topic 3 — Reasoning JSONL Artifact

**Missing-material position:**
The preferred raw reasoning artifact form is `R000123_<timestamp>_<task-slug>.reasoning.jsonl`; `.reasoning.md` is at most a later derived human-readable view; the raw JSONL remains the evidence source.

**Current-project position:**
The accepted reporting standard prescribes that raw reasoning traces be stored beside the task report using the same basename with `.reasoning.md`, and its example path uses a timestamp-only name with no R-number prefix.

**Evidence:**
- `/home/gabriel/project-tendril/documentation/drafts/missing-project-material-handover-2026-08-11.md` §3
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md:482-489`
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/R000003_20260811T075943Z_deepseek-v4-flash-max_locate-thought-stream.reasoning.jsonl` (existing practice matches the handover, not the standard)
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` §16.3 (records the same mismatch)

No adjudication is performed here.

## 9. Unknown Topics

None. All 108 topics were determinable from in-scope current files. Where the handover references material outside the project boundary (old Baton repository, OpenCode SQLite database, older corpus, File Library), the historical content could not be verified, but this affected verification of historical claims, not the classification of fresh-project representation. See Review Limitations (§28).

## 10. Operational Bootstrap

Capabilities that genuinely work today but are bootstrap/control mechanisms, not Tendril product architecture:

- **Fresh-session one-task workflow** — human writes one bounded task, fresh session, policy loaded, one report, stop. Works today; human-managed.
- **AGENTS.md policy loading** — current policy injected into every fresh execution.
- **Report numbering** — NEXT_REPORT_NUMBER counter-file allocation, monotonic R-numbers.
- **Live task reports** — initialization-first lifecycle, execution log, terminal status, timing.
- **Mechanical Silence / Terse Reasoning / Decision Stability** — behavioral policy shaping model execution behavior.
- **OpenCode permissions** — application-level allow/deny (external_directory, task, webfetch, websearch denied) enforced at runtime.
- **Custom harness probe** — `tendril_probe.ts` custom tool loading through OpenWork (INST-0001 PASS).
- **Scoped read experiment** — Tendril-owned read tool rejecting `..` and symlink traversal (INST-0002 PASS).
- **Reasoning extraction** — one-off extraction of the OpenCode thought stream into R000003 `.reasoning.jsonl`.
- **UP_NEXT / instruction-log scheduler** — filesystem-based instruction pointer (now stale).
- **Task-contract template** — `control/contracts/task-contract.yaml` as a schema placeholder.

None of these is product implementation; the product directories are empty.

## 11. Policy-Only Material

Rules that exist in AGENTS.md (or accepted standards) but have no structural implementation:

- One-task rule (§2); scope rules (§4); no opportunistic work (§5); human sequencing (§6); queue behaviour (§9)
- Pre-Task Initialization Gate (§Pre-Task)
- Execution Start Sequence and report-first identity initialization
- Terse Reasoning, Mechanical Silence, Decision Stability
- Failure behaviour (BLOCKED protocol)
- Documentation Authority (promotion requires human authorization)
- Architectural Boundary (no shadow Tendril)
- Task reporting exception
- Policy Refresh / Fresh Policy Bootstrap
- Reporting standard rules on timing integrity, supersession, reasoning diagnostics grounding, telemetry-failure reporting — policy rules followed by agents, not enforced by any mechanism

## 12. Accepted-Documentation-Only Material

Architecture represented in `documentation/main/` but not in code/runtime:

- `standards/agent-task-reporting.md` (the only accepted document): report location, filename format, execution identity, report numbering/allocation, required status, execution timing, timing integrity, live report lifecycle, report structure, issue classification, reasoning diagnostics — all agent-populated; no runtime enforces them.

## 13. Draft-Only Material

Architecture represented only under `documentation/drafts/` or `documentation/drafts/proposed-main/`:

- `build-plan-handover.md` — execution pipeline, Controller/Envelope/Launcher, security stack, deferred items, queue direction
- `ontological-agent-compiler-handover.md` — OAC, Prompt Scribe, authority boundary
- `openwork-handover-2026-08-11.md` — OpenWork operating model
- `missing-project-material-handover-2026-08-11.md` — 108-topic gap architecture
- `current-project-state-handover-2026-08-11.md` — the audit artifact
- `proposed-main/standards/handover-extraction.md` — extraction standard draft
- This review document
- The execution architecture (topics 11-27), security (30-32), Git (33-36), control plane (37-43), OAC (44-48), pipeline (56-57), corpus (60-67), headless (69-77), product (78-87), compression (88-89), routing (91), historical (92-94), open questions (103-108)

## 14. Scaffold-Only Material

Empty/template-only components (verified on disk):

- `product/tendril/` — empty
- `oac/` — empty
- `references/` — empty
- `worktrees/bootstrap/` — empty
- `worktrees/product/` — empty
- `tmp/` — empty
- `documentation/main/drafts/` — empty (incongruous name; drafts belong under `documentation/drafts/`)
- `documentation/drafts/extractions/` — empty
- `control/contracts/task-contract.yaml` — 26-line template only
- `bootstrap/instructions/` (UP_NEXT.md + instruction-log) — operational scaffolding, not product

## 15. Implemented Material

Directly evidenced implementation only (no policy, plans, or empty directories):

- None at the Tendril product level (`product/tendril/` is empty).
- Operational (bootstrap layer): the one-task fresh-session execution loop; AGENTS.md policy injection; OpenCode permission enforcement; counter-file report allocation; live task-report lifecycle; custom `tendril_probe` tool; scoped-read tool behavior; the R000003 reasoning JSONL extraction.

## 16. Harness / Runtime Gap Review

| Item | State | Layer |
|---|---|---|
| harness-owned observation | ABSENT | DRAFT_ONLY |
| raw reasoning capture | PARTIAL | OPERATIONAL_BOOTSTRAP |
| automatic reasoning JSONL capture | ABSENT | DRAFT_ONLY (one manual artifact only) |
| pre-model telemetry capture | ABSENT | DRAFT_ONLY |
| harness-owned diagnostics | ABSENT | DRAFT_ONLY (agent-populated fields in accepted standard) |
| semantic-progress measurement | ABSENT | DRAFT_ONLY (policy principle only) |
| finalization telemetry | ABSENT | DRAFT_ONLY |
| phase timestamp ownership | PARTIAL | ACCEPTED_DOCUMENTATION |
| atomic report allocation | PARTIAL | OPERATIONAL_BOOTSTRAP |
| Controller | ABSENT | DRAFT_ONLY |
| Launcher | ABSENT | DRAFT_ONLY |
| Task Contract | PARTIAL | SCAFFOLD_ONLY |
| Control Policy | ABSENT | DRAFT_ONLY |
| Execution Envelope | ABSENT | DRAFT_ONLY |
| Runtime Ledger | ABSENT | DRAFT_ONLY |
| Independent Verifier | ABSENT | DRAFT_ONLY |
| SUCCEEDED vs VERIFIED lifecycle | ABSENT | DRAFT_ONLY |
| candidate acceptance boundary | PARTIAL | POLICY_ONLY |
| rollback/abandonment | ABSENT | DRAFT_ONLY |
| frozen baseline | ABSENT | DRAFT_ONLY |
| staleness | ABSENT | DRAFT_ONLY |
| write leases | ABSENT | DRAFT_ONLY |
| secrets/capabilities | ABSENT | DRAFT_ONLY |
| structured clarification | PARTIAL | POLICY_ONLY |

## 17. Product Gap Review

All items are ABSENT / DRAFT_ONLY; `product/tendril/` is empty and none of these exist in any form:

- Tendril V0 implementation — ABSENT / DRAFT_ONLY
- Prompt node — ABSENT / DRAFT_ONLY
- node/run schema — ABSENT / DRAFT_ONLY
- exact message packet — ABSENT / DRAFT_ONLY
- upstream run pinning — ABSENT / DRAFT_ONLY
- operation tag — ABSENT / DRAFT_ONLY
- context preview — ABSENT / DRAFT_ONLY
- context composer — ABSENT / DRAFT_ONLY
- typed channels — ABSENT / DRAFT_ONLY
- pull-based execution — ABSENT / DRAFT_ONLY
- save/reopen — ABSENT / DRAFT_ONLY
- provider abstraction — ABSENT / DRAFT_ONLY
- headless runtime — ABSENT / DRAFT_ONLY
- backend authority — ABSENT / DRAFT_ONLY
- replaceable frontend — ABSENT / DRAFT_ONLY
- GUI command boundary — ABSENT / DRAFT_ONLY
- transport — ABSENT / DRAFT_ONLY
- runtime persistence — ABSENT / DRAFT_ONLY

## 18. OAC Gap Review

- OAC purpose/documentation — PARTIAL / DRAFT_ONLY (`ontological-agent-compiler-handover.md` is a substantive draft)
- actual OAC implementation — ABSENT / DRAFT_ONLY (`oac/` empty)
- Prompt Scribe — ABSENT / DRAFT_ONLY (described in drafts; explicitly deferred in build-plan-handover §11, §14)
- OAC output contract — ABSENT / DRAFT_ONLY
- OAC authority boundary — ABSENT / DRAFT_ONLY (documented in draft only; no OAC exists)
- compiler versioning — ABSENT / DRAFT_ONLY
- lazy ontology bootstrap — ABSENT / DRAFT_ONLY

## 19. Documentation Pipeline Gap Review

- handover extraction standard — PARTIAL / DRAFT_ONLY (draft in proposed-main)
- accepted extraction standard — ABSENT (nothing in `documentation/main/`)
- extraction outputs — ABSENT (`documentation/drafts/extractions/` empty)
- extraction metadata — PARTIAL / DRAFT_ONLY (fields in draft)
- one-source-one-extraction — PARTIAL / DRAFT_ONLY (rule in draft)
- reconciliation — ABSENT / DRAFT_ONLY (only ad hoc in this execution)
- human adjudication — PARTIAL / POLICY_ONLY (authorization boundary in policy)
- materialization — PARTIAL / POLICY_ONLY (one-task mutation rule in policy)
- corpus integration — ABSENT / DRAFT_ONLY

## 20. OpenWork Control-Plane Gap Review

- PLAN/READY/IN PROGRESS/REQUIRES ATTENTION/DONE model — ABSENT / DRAFT_ONLY
- human queue authority — PARTIAL / POLICY_ONLY
- Project Control — ABSENT / DRAFT_ONLY
- retirement of UP_NEXT — PARTIAL / OPERATIONAL_BOOTSTRAP
- fresh-session automation — PARTIAL / OPERATIONAL_BOOTSTRAP
- context contamination isolation — ABSENT / DRAFT_ONLY
- OpenWork/OpenCode runtime boundary — ABSENT / DRAFT_ONLY

## 21. Security Gap Review

- application-level permissions — PRESENT / OPERATIONAL_BOOTSTRAP (`opencode.jsonc` enforced at runtime)
- project perimeter — PARTIAL / OPERATIONAL_BOOTSTRAP (app-level deny; no structural perimeter)
- OS-level sandbox — ABSENT / DRAFT_ONLY
- network capability — PARTIAL / OPERATIONAL_BOOTSTRAP (app-level deny; no capability model)
- secret injection — ABSENT / DRAFT_ONLY
- Git authority — ABSENT / DRAFT_ONLY
- trusted integration — ABSENT / DRAFT_ONLY
- trusted verification — ABSENT / DRAFT_ONLY

## 22. Git / Repository Gap Review

**Git repository state — directly verified:** `git status` in `/home/gabriel/project-tendril/` returns `fatal: not a git repository`. The fresh project is not a Git repository, confirming the current-state audit.

- Git repository state — ABSENT / NOT_APPLICABLE (verified not a repository)
- private repository policy — ABSENT / DRAFT_ONLY
- baseline identity — ABSENT / DRAFT_ONLY
- worktree lifecycle — ABSENT / SCAFFOLD_ONLY
- trusted integration — ABSENT / DRAFT_ONLY
- commit provenance — ABSENT / DRAFT_ONLY
- historical Baton relationship — PARTIAL / DRAFT_ONLY (build-plan-handover §2 records "historical material does not automatically become current authority")

## 23. Historical Material Requiring Reconciliation

Topics whose only support comes from old Tendril/Baton material, draft handovers, or remembered architecture embodied only in drafts (not promoted here):

- 60 Old Corpus Integration, 61 Bible/Manifest Strategy, 62 Projection Is Not Authority, 64 Hash Domains, 65 SilverBullet Not Execution Authority, 66 Markdown+Git Corpus, 67/106 Corpus Authority Model, 69 Headless Ruling, 75 Platform Split, 86 Topology as Logic, 87 Graph-Native Foyer, 88 Chat Compression, 89 Semantic Promotion Boundary, 92 Baton as Evidence, 93 Historical Launcher Boundary, 94 Repository Archaeology Workflow, 108 Durable Entity Set
- The whole execution architecture (11-27), security (30-32), Git (33-36), OAC (44-48), headless (70-77), product (78-85), and control-plane (37-43) sets are draft-embodied architecture.

## 24. Policy / Reporting Defects Confirmed by Current Files

- **Agent self-diagnostics unreliable** — `agent-task-reporting.md` §Reasoning Diagnostics asks the agent to populate loop/revision/check fields; standard line 475 itself requires grounding in the captured trace; missing-material §6 cites R000012's UNAVAILABLE report vs captured thought activity.
- **Reasoning capture semantics** — PRESENT/PARTIAL/UNAVAILABLE defined from the agent's perspective only (lines 434-472); no runtime-side definitions.
- **Reasoning diagnostics placement** — currently inside the agent report; placement decision open (missing-material §97).
- **Timing rule duplication** — verified overlap between §Execution Timing, §Timing Integrity, and §Live Report Lifecycle.
- **Telemetry failure classification** — single mention at line 225; no canonical representation.
- **Execution-log timestamp rules** — per-entry fresh-timestamp requirement not explicit.
- **Stale reasoning filename examples** — standard lines 482-489 prescribe `.reasoning.md` with a timestamp-only, non-R-prefixed example; the only artifact is R-prefixed `.reasoning.jsonl` (topic 3 conflict).
- **Meta-edit instructions embedded in AGENTS.md** — verified literal "Add this operational rule exactly:" / "Also clarify:" / "Add these operational rules exactly:" artifacts at lines 144, 148, 152, 156, 372, 431.
- **DOCTRINE.md vs AGENTS.md overlap** — both files exist with overlapping but non-identical rules; no document states whether DOCTRINE.md remains binding.
- **Stale UP_NEXT.md** — points to INST-0002, which is completed PASS.
- **Backup files without formal role** — `AGENTS.md.bak_01`, `AGENTS.md.bak_02`, `opencode.jsonc_bak_01` exist with no documented role.
- **Incongruous `documentation/main/drafts/`** — empty drafts directory inside accepted documentation.
- **R000003 reasoning filename includes provider/model** — `_deepseek-v4-flash-max_` in the artifact name, contrary to the current identity-free filename convention (historical artifact, pre-R000006).

## 25. Current Bootstrap vs Actual Tendril

| CURRENT BOOTSTRAP / CONTROL | ACTUAL TENDRIL PRODUCT / RUNTIME |
|---|---|
| AGENTS.md behavioral policy (loaded per session) | Product code (none) |
| opencode.jsonc application permissions | Controller (none) |
| NEXT_REPORT_NUMBER counter allocation | Launcher (none) |
| Agent-authored live task reports | Runtime Ledger (none) |
| One reasoning JSONL artifact (manual extraction) | Harness telemetry capture (none) |
| UP_NEXT / instruction-log scheduler | OpenWork control plane / queue (none) |
| Custom tendril_probe tool experiments | OAC / Prompt Scribe (none) |
| Scoped-read experiment (INST-0002) | OS-level sandbox (none) |
| task-contract.yaml template | Task Contract / Execution Envelope (none) |
| Documentation drafts / proposed-main workflow | Documentation pipeline stages (none) |
| Human-managed fresh sessions | Fresh-session automation (none) |
| REPORTING STANDARD (accepted doc) | Product V0, headless runtime, persistence (none) |

Every currently evidenced capability belongs to the left column. Nothing on the right exists on disk.

## 26. Highest-Value Reconciliation Candidates

Ranked. This is NOT task authorization and creates no implementation tasks.

1. **Topic 3 — Reasoning JSONL Artifact** — CONFLICT — the artifact-naming contradiction blocks consistent telemetry joining before any harness work.
2. **Topics 49/55 — Extraction standard draft and its defects** — PARTIAL — the documentation pipeline cannot start until the draft is cleaned and accepted.
3. **Topic 2 — Raw reasoning capture** — PARTIAL — only one artifact exists; capture is foundational to every harness topic.
4. **Topic 10 — Atomic report allocation** — PARTIAL — concurrency safety is a prerequisite for parallel executions.
5. **Topic 14 — Task Contract** — PARTIAL — the template exists but no live contract or validation does.
6. **Topics 95-97 — Reasoning diagnostics semantics** — PARTIAL — agent self-reporting is acknowledged unreliable; ownership and placement need a decision.
7. **Topic 41 — Fresh session per task** — PARTIAL — the proven pattern should become a controller property.
8. **Topic 40 — UP_NEXT retirement** — PARTIAL — stale pointer; needs a queue replacement decision.
9. **Topic 30 — Real OS-level sandbox** — ABSENT — the security boundary is entirely missing.
10. **Topic 37 — OpenWork queue state** — ABSENT — the control plane is entirely missing.

## 27. Material That Should NOT Be Integrated Yet

- **76/107 Transport** and **77/105 Runtime database/persistence** — implementation technology deliberately unresolved.
- **103 Exact Controller implementation** — language/topology/API unfrozen; semantics before details.
- **104 Exact sandbox technology** — requirement clear, mechanism open.
- **67/106 Corpus Markdown authority model** — competing architectures (directly-maintained vs generated projection) remain open.
- **61 Bible/Manifest strategy** — retention vs simplification vs replacement undecided.
- **91 Model routing** — mutable operational policy; must not be embedded as architecture.
- **87 Graph-native foyer** — explicitly post-foundational.
- **92-94 Historical launcher/archaeology material** — evidence only; reuse decisions separate.
- **108 Durable entity set** — old vocabulary must not create obligations; verify each entity first.
- **19 Lifecycle state names** — "exact names remain to be finalized".
- **44-48 OAC** — deliberately deferred until the execution primitive is stable.
- **60 Old corpus material** — pending integration classification, not automatic authority.

## 28. Review Limitations

- Both source handovers are non-authoritative; actual files governed wherever they disagreed.
- References outside the project boundary (old Baton repository, OpenCode SQLite database, older corpus, File Library) could not be inspected; historical claims could not be independently verified.
- The project has no Git history, so no baseline or provenance could be consulted.
- The R000003 reasoning JSONL was verified by existence and metadata only, not parsed line-by-line.
- The target review file previously contained an earlier execution's output (R000015, same task slug); that content was replaced by this execution's review and was not used as evidence.
- Classification and layer assignment are this execution's judgment under the task's defined model; the distinction between ABSENT/DRAFT_ONLY and PARTIAL/DRAFT_ONLY is interpretive.
- Absence judgments (e.g., product, OAC, controller) rely on the observed directory walk and file inventory of the fresh rebuild.

## 29. Evidence Index

- `AGENTS.md` (516 lines) — current policy: one-task, initialization gate, terse reasoning, mechanical silence, decision stability, scope, queue behaviour, documentation authority, architectural boundary, no-shadow-Tendril rule; meta-edit artifacts at 144/148/152/156/372/431; no Git rules.
- `opencode.jsonc` — application permissions: read/edit/glob/grep/bash allow; external_directory/task/webfetch/websearch deny; share disabled.
- `bootstrap/DOCTRINE.md` — Track A doctrine: 10 invariants, fresh bootstrap, stopping rule, no shadow Tendril.
- `bootstrap/project.env` — PROJECT_ROOT.
- `bootstrap/instructions/UP_NEXT.md` — stale pointer to INST-0002.
- `bootstrap/instructions/instruction-log/INST-0001.md`, `INST-0002.md` — PASS results for tool-surface control and scoped read.
- `bootstrap/experiments/harness-probe/` — custom `tendril_probe.ts`, restricted config, allowed/denied fixtures, symlink test artifact.
- `control/contracts/task-contract.yaml` — 26-line template only.
- `documentation/main/standards/agent-task-reporting.md` (491 lines) — only accepted document; join key, allocation, timing, timing integrity, live lifecycle, issue classification, reasoning diagnostics (`.reasoning.md` prescription), supersession rule, telemetry-failure mention.
- `documentation/main/drafts/` — empty.
- `documentation/drafts/build-plan-handover.md` — pipeline, security stack, deferred items, queue direction, historical-material rule, experiments-complete statement.
- `documentation/drafts/ontological-agent-compiler-handover.md` — OAC purpose, Prompt Scribe, authority boundary.
- `documentation/drafts/openwork-handover-2026-08-11.md` — OpenWork operating model; hard sandbox not implemented.
- `documentation/drafts/missing-project-material-handover-2026-08-11.md` — the 108-topic source under review.
- `documentation/drafts/current-project-state-handover-2026-08-11.md` — audit artifact; unresolved-question records; defect records.
- `documentation/drafts/proposed-main/standards/handover-extraction.md` — draft extraction standard with verified defects (repetition, duplicated Source Section, duplicated cross-reference).
- `documentation/drafts/extractions/` — empty.
- `oac/`, `product/tendril/`, `references/`, `tmp/`, `worktrees/bootstrap/`, `worktrees/product/` — empty scaffolds.
- `runtime/reports/agent-tasks/` — 25 unnumbered + numbered reports R000001-R000016; NEXT_REPORT_NUMBER=17 after this allocation; R000003 `.reasoning.jsonl` (63425 bytes); model names in R000001-R000005 filenames.
- `git status` — "fatal: not a git repository".
- `AGENTS.md.bak_01`, `AGENTS.md.bak_02`, `opencode.jsonc_bak_01` — backup files without documented role.

## 30. Classification Index

1 | Harness-Owned Agent Observation | ABSENT | DRAFT_ONLY
2 | Raw Reasoning Capture | PARTIAL | OPERATIONAL_BOOTSTRAP
3 | Reasoning JSONL Artifact | CONFLICT | MIXED
4 | Capture Must Begin Before the Model Gets Control | PARTIAL | POLICY_ONLY
5 | Report Number as Execution Join Key | PRESENT | OPERATIONAL_BOOTSTRAP
6 | Harness-Owned Reasoning Diagnostics | PARTIAL | ACCEPTED_DOCUMENTATION
7 | Semantic-Progress Measurement | PARTIAL | POLICY_ONLY
8 | Finalization-Time Telemetry | ABSENT | DRAFT_ONLY
9 | Phase Timestamp Ownership | PARTIAL | ACCEPTED_DOCUMENTATION
10 | Atomic Report-Number Allocation | PARTIAL | OPERATIONAL_BOOTSTRAP
11 | Controller | ABSENT | DRAFT_ONLY
12 | Launcher | ABSENT | DRAFT_ONLY
13 | Controller ≠ Launcher | ABSENT | DRAFT_ONLY
14 | Task Contract | PARTIAL | SCAFFOLD_ONLY
15 | Control Policy | ABSENT | DRAFT_ONLY
16 | Execution Envelope | ABSENT | DRAFT_ONLY
17 | Runtime Ledger | ABSENT | DRAFT_ONLY
18 | Independent Verifier | ABSENT | DRAFT_ONLY
19 | SUCCEEDED ≠ VERIFIED | ABSENT | DRAFT_ONLY
20 | Candidate Change / Acceptance Boundary | PARTIAL | POLICY_ONLY
21 | Rollback and Abandonment | ABSENT | DRAFT_ONLY
22 | Frozen Baseline | ABSENT | DRAFT_ONLY
23 | Staleness / Dirty Propagation | ABSENT | DRAFT_ONLY
24 | Stable Identity and Provenance | PARTIAL | MIXED
25 | Write Leases / Concurrent Mutation | ABSENT | DRAFT_ONLY
26 | Tool Identity | PARTIAL | OPERATIONAL_BOOTSTRAP
27 | Secrets as Capabilities | ABSENT | DRAFT_ONLY
28 | Structured Clarification | PARTIAL | POLICY_ONLY
29 | Discovery vs Execution | PARTIAL | POLICY_ONLY
30 | Real OS-Level Sandbox | ABSENT | DRAFT_ONLY
31 | Project Perimeter | PARTIAL | OPERATIONAL_BOOTSTRAP
32 | Network Capability | PARTIAL | OPERATIONAL_BOOTSTRAP
33 | Agent Git Authority | ABSENT | DRAFT_ONLY
34 | Worktree Lifecycle | ABSENT | SCAFFOLD_ONLY
35 | Git Integration Evidence | ABSENT | DRAFT_ONLY
36 | Private Repository / Authorship / Licensing | ABSENT | DRAFT_ONLY
37 | OpenWork Queue State Model | ABSENT | DRAFT_ONLY
38 | Human Queue Authority | PARTIAL | POLICY_ONLY
39 | Project Control | ABSENT | DRAFT_ONLY
40 | Retire Manual UP_NEXT | PARTIAL | OPERATIONAL_BOOTSTRAP
41 | Fresh Session Per Task | PARTIAL | OPERATIONAL_BOOTSTRAP
42 | OpenWork Context Contamination Isolation | ABSENT | DRAFT_ONLY
43 | OpenWork/OpenCode Boundary | ABSENT | DRAFT_ONLY
44 | OAC Purpose | ABSENT | DRAFT_ONLY
45 | OAC Does Not Authorize Work | ABSENT | DRAFT_ONLY
46 | OAC Output Contract | ABSENT | DRAFT_ONLY
47 | Compiler Versioning | ABSENT | DRAFT_ONLY
48 | Lazy Ontology Bootstrap | ABSENT | DRAFT_ONLY
49 | Handover Extraction Standard | PARTIAL | DRAFT_ONLY
50 | Extraction Categories | PARTIAL | DRAFT_ONLY
51 | Extraction Metadata | PARTIAL | DRAFT_ONLY
52 | One Source → One Extraction | PARTIAL | DRAFT_ONLY
53 | Extraction Is Not Authority | PARTIAL | DRAFT_ONLY
54 | Extraction Output Location | PARTIAL | SCAFFOLD_ONLY
55 | Known Extraction-Standard Defects | PRESENT | DRAFT_ONLY
56 | Full Documentation Integration Pipeline | ABSENT | DRAFT_ONLY
57 | Reconciliation Stage | ABSENT | DRAFT_ONLY
58 | Human Adjudication | PARTIAL | POLICY_ONLY
59 | Materialization as Separate Mutation | PARTIAL | POLICY_ONLY
60 | Old Corpus Integration Into Fresh Rebuild | ABSENT | DRAFT_ONLY
61 | Bible / Manifest Strategy | ABSENT | DRAFT_ONLY
62 | Projection Is Not Authority | ABSENT | DRAFT_ONLY
63 | Additive History / Supersession | PARTIAL | ACCEPTED_DOCUMENTATION
64 | Hash Domains | ABSENT | DRAFT_ONLY
65 | SilverBullet Is Not Execution Authority | ABSENT | DRAFT_ONLY
66 | Markdown + Git Corpus | ABSENT | DRAFT_ONLY
67 | Unresolved Corpus-Projection Fork | ABSENT | DRAFT_ONLY
68 | Linux Native Filesystem | PARTIAL | DRAFT_ONLY
69 | Tendril Must Be Functionally Headless | ABSENT | DRAFT_ONLY
70 | Node Contracts Define Semantics | ABSENT | DRAFT_ONLY
71 | Backend Is Authoritative | ABSENT | DRAFT_ONLY
72 | Finite Frontend Surface | ABSENT | DRAFT_ONLY
73 | GUI Action = Backend Command | ABSENT | DRAFT_ONLY
74 | Replaceable Clients | ABSENT | DRAFT_ONLY
75 | Platform Split Is Not Ontology | ABSENT | DRAFT_ONLY
76 | Transport Is Still Open | ABSENT | DRAFT_ONLY
77 | Runtime Database Is Still Open | ABSENT | DRAFT_ONLY
78 | Version Zero Product Scope | ABSENT | DRAFT_ONLY
79 | Upstream Run Selection | ABSENT | DRAFT_ONLY
80 | Operation Tag | ABSENT | DRAFT_ONLY
81 | Exact Message Packet | ABSENT | DRAFT_ONLY
82 | Context Preview | ABSENT | DRAFT_ONLY
83 | Context Composer / Horse Blinkers | ABSENT | DRAFT_ONLY
84 | Typed Channels | ABSENT | DRAFT_ONLY
85 | Pull-Based Execution | ABSENT | DRAFT_ONLY
86 | Topology as Logic | ABSENT | DRAFT_ONLY
87 | Graph-Native Foyer | ABSENT | DRAFT_ONLY
88 | Chat Compression Contract | ABSENT | DRAFT_ONLY
89 | Human Semantic Promotion Boundary | ABSENT | DRAFT_ONLY
90 | Provider Flexibility | PARTIAL | OPERATIONAL_BOOTSTRAP
91 | Current Operational Model Routing | ABSENT | DRAFT_ONLY
92 | Baton Is Evidence, Not Fresh Authority | PARTIAL | DRAFT_ONLY
93 | Historical Launcher Boundary | ABSENT | DRAFT_ONLY
94 | Repository Archaeology Workflow | ABSENT | DRAFT_ONLY
95 | Agent Self-Diagnostics Are Not Trustworthy | PARTIAL | ACCEPTED_DOCUMENTATION
96 | `Reasoning Capture` Semantics | PARTIAL | ACCEPTED_DOCUMENTATION
97 | Reasoning Diagnostics Placement | PARTIAL | ACCEPTED_DOCUMENTATION
98 | Timing Rule Consolidation | PRESENT | ACCEPTED_DOCUMENTATION
99 | Telemetry Failure Classification | PARTIAL | ACCEPTED_DOCUMENTATION
100 | Fresh Timestamp Per Execution-Log Entry | PARTIAL | ACCEPTED_DOCUMENTATION
101 | Bootstrap Must Not Become Shadow Tendril | PRESENT | POLICY_ONLY
102 | No More Experiments as the Primary Mode | PARTIAL | DRAFT_ONLY
103 | Exact Controller Implementation | ABSENT | DRAFT_ONLY
104 | Exact Sandbox Technology | ABSENT | DRAFT_ONLY
105 | Exact Runtime Persistence Schema | ABSENT | DRAFT_ONLY
106 | Corpus Markdown Authority Model | ABSENT | DRAFT_ONLY
107 | Permanent Transport | ABSENT | DRAFT_ONLY
108 | Durable Entity Set | ABSENT | DRAFT_ONLY
