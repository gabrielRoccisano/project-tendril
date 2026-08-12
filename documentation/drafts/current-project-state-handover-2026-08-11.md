# Project Tendril — Current Project State Handover

## 1. Snapshot

- **Project root:** `/home/gabriel/project-tendril/`
- **Snapshot UTC time:** 2026-08-11T08:34:18Z (_OBSERVED:_ start of this audit execution)
- **Git state:** NOT a Git repository (_OBSERVED:_ `git status` returned `fatal: not a git repository`)
- **NEXT_REPORT_NUMBER:** 14 at audit start, incremented to 15 during this audit's report allocation (_OBSERVED_)
- **Highest existing numbered report:** R000013 (_OBSERVED:_ exists on disk)
- **Highest pre-numbering historical report:** 20260811T075115Z_edit-agent-task-reporting-standard-execution-identity.md (_OBSERVED:_ last chronological unnumbered report)
- **Development phase:** Bootstrap / fresh rebuild. The project is rebuilding from a clean Linux space. The one-task execution primitive (human → bounded task → fresh agent → result → stop) has been proven operational. The immediate work is documentation ingestion, policy refinement, and creating the comprehensive current-state handover. Major architectural components (Controller, Launcher, sandbox, OAC, Prompt Scribe, product V0) exist only in draft documentation and policy; none are implemented. (_OBSERVED + INFERRED_)

## 2. Current Project Tree

```
/home/gabriel/project-tendril/
├── AGENTS.md                           [516 lines — current agent policy]
├── AGENTS.md.bak_01                    [33 lines — early minimal policy]
├── AGENTS.md.bak_02                    [180 lines — intermediate policy, before execution-start-sequence etc.]
├── opencode.jsonc                      [18 lines — current permissive config]
├── opencode.jsonc_bak_01               [15 lines — previous ask-default config]
├── bootstrap/
│   ├── DOCTRINE.md                     [46 lines — Track A operating doctrine]
│   ├── project.env                     [1 line — PROJECT_ROOT definition]
│   ├── instructions/
│   │   ├── UP_NEXT.md                  [34 lines — next instruction pointer (INST-0002)]
│   │   └── instruction-log/
│   │       ├── INST-0001.md            [97 lines — harness boundary probe, completed PASS]
│   │       └── INST-0002.md            [59 lines — scoped read tool test, completed PASS]
│   └── experiments/
│       └── harness-probe/
│           ├── opencode.jsonc          [14 lines — restricted config, tendril_probe only]
│           ├── allowed/
│           │   ├── allowed.txt
│           │   └── escape-link.txt     [symlink pointing to ../denied/denied.txt]
│           ├── denied/
│           │   └── denied.txt
│           └── .opencode/
│               ├── tools/
│               │   └── tendril_probe.ts  [custom tool implementation]
│               ├── package.json
│               ├── package-lock.json
│               ├── node_modules/
│               └── .gitignore
├── control/
│   └── contracts/
│       └── task-contract.yaml          [26 lines — template/schema only; no live contracts]
├── documentation/
│   ├── main/
│   │   ├── standards/
│   │   │   └── agent-task-reporting.md [491 lines — ONLY accepted document]
│   │   └── drafts/                     [EMPTY]
│   └── drafts/
│       ├── build-plan-handover.md      [516 lines — comprehensive build plan/architecture handover]
│       ├── ontological-agent-compiler-handover.md [366 lines — OAC concept description]
│       ├── openwork-handover-2026-08-11.md        [130 lines — OpenWork operating model handover]
│       ├── missing-project-material-handover-2026-08-11.md [2010 lines — gap handover: 108 sections]
│       ├── proposed-main/
│       │   └── standards/
│       │       └── handover-extraction.md [246 lines — draft extraction standard]
│       └── extractions/                [EMPTY]
├── oac/                                [EMPTY — scaffold directory only]
├── product/
│   └── tendril/                        [EMPTY — scaffold directory only]
├── references/                         [EMPTY — scaffold directory only]
├── runtime/
│   └── reports/
│       └── agent-tasks/
│           ├── NEXT_REPORT_NUMBER      [contains "15" after this audit's allocation]
│           ├── 25 unnumbered historical reports (20260811T065840Z through 20260811T075115Z)
│           ├── R000001 through R000014 (13 prior numbered + this execution)
│           └── R000003_...reasoning.jsonl [1 reasoning artifact, 63425 bytes]
├── tmp/                                [EMPTY]
└── worktrees/
    ├── bootstrap/                      [EMPTY — scaffold directory only]
    └── product/                        [EMPTY — scaffold directory only]
```

**Key observations on emptiness:**
- `oac/` — OBSERVED empty; OAC exists only as draft documentation
- `product/tendril/` — OBSERVED empty; no product code exists
- `references/` — OBSERVED empty
- `tmp/` — OBSERVED empty
- `worktrees/bootstrap/` — OBSERVED empty
- `worktrees/product/` — OBSERVED empty
- `documentation/main/drafts/` — OBSERVED empty (name is incongruous — a `drafts/` directory inside `main/`, which is meant for accepted documentation)
- `documentation/drafts/extractions/` — OBSERVED empty; extraction standard exists but no extractions performed
- `control/contracts/` — contains only a template YAML, no live task contracts

## 3. Current Authority Model

The authority ordering, as stated in AGENTS.md section 3:

1. Current human instruction
2. Current Project Tendril agent policy (AGENTS.md)
3. Current authorised task
4. Explicitly authorised project documents and context

Historical conversations, previous agent output, inferred intent, and remembered project state are **not** authority.

**Files that currently govern agent behavior (OBSERVED):**
- `/home/gabriel/project-tendril/AGENTS.md` — universal agent policy (516 lines)
- `/home/gabriel/project-tendril/opencode.jsonc` — OpenCode capability/permission configuration (18 lines)
- `/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` — canonical reporting standard (491 lines)
- `/home/gabriel/project-tendril/bootstrap/DOCTRINE.md` — Track A operating doctrine (46 lines, predates AGENTS.md expansion)

**Authority distinctions (OBSERVED):**
- `documentation/main/` is explicitly designated as accepted/current documentation (AGENTS.md §Documentation Authority)
- `documentation/drafts/` contains draft/proposed material; not accepted authority
- `documentation/drafts/proposed-main/` contains proposed documentation awaiting promotion
- Task reports (`runtime/reports/agent-tasks/`) are operational evidence, not project authority
- Bootstrap files are temporary scaffolding, not product architecture (AGENTS.md §Architectural Boundary)
- No accepted documentation exists beyond `agent-task-reporting.md` (_OBSERVED:_ `documentation/main/standards/` contains only one file; `documentation/main/drafts/` is empty)

## 4. Current Agent Execution Policy

All rules below are from `/home/gabriel/project-tendril/AGENTS.md` (516 lines).

### Core Execution Rules

| Rule | Section | Description |
|------|---------|-------------|
| One task only | §2 | Each execution performs exactly one bounded task with one objective, explicit scope, explicit constraints, and an observable completion condition |
| Human sequencing | §6 | Human controls task selection, priority, ordering, approval, acceptance, and architecture; agents do not self-sequence |
| Pre-task initialization gate | §Pre-Task | Agent must enter initialization mode before substantive work; report created with UNKNOWN identity; no reasoning before report exists |
| Report-first behavior | §Execution Start Sequence + §Pre-Task | Policy loaded → task loaded → reporting standard read → number allocated → started timestamp → report created → THEN substantive work |
| Report numbering | §Task Reporting (references agent-task-reporting.md) | Monotonically increasing R000001-style sequence via NEXT_REPORT_NUMBER counter file |
| Mechanical Silence | §Terse Reasoning → §Mechanical Silence | For mechanical/deterministic/sequenced work: act silently; reason only when a decision is required; no conversational self-dialogue |
| Terse Reasoning | §Terse Reasoning | Default reasoning: minimal, operational, action-oriented; one fact/one decision/one action; prohibit conversational self-dialogue |
| Decision Stability | §Decision Stability | Once resolved, do not reconsider without new evidence; no repeated checking of settled decisions |
| Scope | §4 | Project root is maximum boundary; task defines stricter scope; no scope widening; request authorization for additional scope |
| Failure | §8 | When blocked, report BLOCKED with what is missing, why, and minimum required human decision |
| Policy refresh | §Policy Refresh | If AGENTS.md changes during session, reread before further work |
| Documentation authority | §Documentation Authority | `documentation/main/` = accepted; agents must not modify it; proposals go via `drafts/proposed-main/`; promotion requires human authorization |
| No opportunistic work | §5 | Discovered work → FOLLOW-UP CANDIDATE only |
| Fresh policy bootstrap | §1 | Every execution loads current AGENTS.md and task; previous sessions are not authority |
| Evidence | §7 | Completion claims require observable evidence |
| Queue behaviour | §9 | Ordinary agents report FOLLOW-UP CANDIDATE; may not self-sequence, reorder, accept, or create new work |
| Architectural boundary | §10 | Bootstrap mechanisms are not product architecture; do not migrate experimental machinery into product |
| Task reporting exception | §Task Reporting | Task report write is exception to normal write restrictions |

### Documented but Not-Implemented Policy Rules

- The "Concurrent-safe atomic allocation is a future harness/controller responsibility" note in agent-task-reporting.md §Report Number Allocation (line 162) — acknowledged as not yet implemented
- The "Raw model reasoning emitted before, during, or after initialization is separate runtime telemetry and must eventually be captured by the harness" in AGENTS.md (line 160) — acknowledged as future work

## 5. Current Reporting System

### Canonical Source
`/home/gabriel/project-tendril/documentation/main/standards/agent-task-reporting.md` (491 lines)

### Report Location
`/home/gabriel/project-tendril/runtime/reports/agent-tasks/`

### Filename Format
`R<6-digit-seq>_<YYYYMMDDTHHMMSSZ>_<task-slug>.md`

### Number Allocation Mechanism
- Counter file: `runtime/reports/agent-tasks/NEXT_REPORT_NUMBER`
- Contains one decimal integer + newline
- Value represents next unallocated number (not most recently allocated)
- Allocation: read → validate → allocate → increment → write → create report
- Not concurrency-safe; explicitly noted as temporary until Controller/Harness provides atomic allocation

### NEXT_REPORT_NUMBER Semantics
- Monotonically increasing
- Next unallocated number (e.g., value 14 means R000014 is next)
- Never decremented
- Never guessed if missing/malformed

### Live Report Lifecycle
1. Read policy
2. Read task metadata
3. Read reporting standard
4. Allocate Report Number
5. Sample Started UTC
6. Create report filename
7. Initialize report (UNKNOWN for all identity fields)
8. Record immediately exposed identity or UNKNOWN
9. Begin substantive work
10. Append execution-log entries as phases complete
11. Append terminal result after work and checks
12. Sample Finished UTC, compute Duration

### Execution Identity Behavior
- All identity fields initialize as UNKNOWN
- Immediately exposed values replace UNKNOWN after report creation
- Never search for missing values
- Never delay work for optional identity telemetry
- Report filename never changes after creation
- Report Number is the stable join key to all associated telemetry

### Timing Rules
- Required fields: Started UTC, Finished UTC, Duration Seconds
- Start captured before substantive work; finish after all work and reporting
- If timing not captured at required event → UNKNOWN (not estimated)
- If Started or Finished is UNKNOWN → Duration is also UNKNOWN
- Duration 0 is valid for work completing within same second

### Issue Classification
- Blockers: conditions preventing task from proceeding/completing
- Execution Errors: failures during task attempt (tool failures, command failures, etc.)
- Verification Findings: defects/inconsistencies/ambiguities discovered while inspecting artifact
- Categories must not be conflated

### Reasoning Diagnostics
- Fields: Reasoning Capture (PRESENT/UNAVAILABLE/PARTIAL), Reasoning Trace (path), Reasoning Duration Seconds, Reasoning Tokens, Observed Loop Indicators, Observed Decision Revisions, Observed Repeated Checks
- Raw reasoning is execution telemetry, not project authority
- Agent must not reconstruct, approximate, invent, or backfill reasoning
- Reasoning traces stored beside reports with `.reasoning.md` suffix
- Preferred long-term source: execution harness/runtime, not agent self-reconstruction

### Known Inconsistencies / Duplications in Reporting Standard (OBSERVED)
- Timing rules appear in two sections: §Execution Timing and §Timing Integrity — there is conceptual overlap and some duplication
- §Live Report Lifecycle duplicates some timing capture rules from §Execution Timing
- The reasoning diagnostics section uses `.reasoning.md` as preferred filename but the R000003 reasoning artifact on disk uses `.reasoning.jsonl` — mismatch between standard and existing practice
- §Execution Timing requires seconds-precision timestamps while earlier sections (report filename format) use HHMMSS format — CONFLICT: the standard specifies `HH:MM:SS` with colons for internal timestamps but filenames use no-colon format
- The standard's example reasoning path uses timestamp-only format without R-number prefix (line 487-489), while the current filename format requires an R-number prefix since R000001 was established

## 6. Current Runtime / OpenWork / OpenCode Configuration

Source: `/home/gabriel/project-tendril/opencode.jsonc` (18 lines, OBSERVED)

### Current Permissions
```json
{
  "share": "disabled",
  "permission": {
    "read": "allow",
    "edit": "allow",
    "glob": "allow",
    "grep": "allow",
    "bash": "allow",
    "external_directory": "deny",
    "task": "deny",
    "webfetch": "deny",
    "websearch": "deny"
  }
}
```

### Project Boundary
- Maximum boundary: `/home/gabriel/project-tendril/` (enforced by AGENTS.md policy, not by OS)
- `external_directory` access is denied at application level

### Denied Capabilities
- `task` (subagent delegation)
- `webfetch`
- `websearch`
- `external_directory`

### OS-Level Sandboxing
- **Not implemented.** OBSERVED: The build-plan-handover draft explicitly states "The hard sandbox is not yet implemented" and "OpenCode permissions are not intended to be the ultimate security perimeter"
- Current security is application-level only (AGENTS.md behavioral policy + opencode.jsonc permission rules)

### Backup Configuration
- `opencode.jsonc_bak_01` shows a prior `"*": "ask"` default configuration; the current config replaced that with explicit allow/deny rules

## 7. Bootstrap State

### Contents (OBSERVED)
- `DOCTRINE.md` — Track A operating doctrine: 10 core invariants, fresh execution bootstrap, Track A stopping rule
- `project.env` — single `PROJECT_ROOT` definition
- `instructions/UP_NEXT.md` — points to INST-0002 ("Test scoped filesystem read access")
- `instructions/instruction-log/INST-0001.md` — completed PASS: harness boundary probe proven
- `instructions/instruction-log/INST-0002.md` — completed PASS: scoped read tool test proven
- `experiments/harness-probe/` — complete experiment workspace with custom `tendril_probe` tool, scope-restricted opencode.jsonc, and test files

### What Bootstrap Has Proven (OBSERVED from INST results)
1. OpenWork/OpenCode honors workspace-local tool restrictions and can expose a custom Tendril tool (INST-0001: PASS)
2. Built-in capabilities (bash, edit, webfetch) can be removed from the model-visible tool surface (INST-0001: PASS)
3. A Tendril-owned read tool can expose filesystem read narrower than the Linux process — resisting `..` traversal and symlink traversal (INST-0002: PASS)
4. Changes to tool implementation require fresh execution context (learned, documented in build-plan-handover)

### Temporary Mechanisms Still in Use
- `UP_NEXT.md` still exists and still points to INST-0002
- Manual instruction log (INST-0001, INST-0002) still present
- These are explicitly identified as temporary bootstrap scaffolding in build-plan-handover (§10: "not intended to remain the live build scheduler once OpenWork carries that state")

### Experiments Still Present
- `harness-probe/` — complete experiment, proven successful, described in build-plan-handover as "complete. Do not continue creating artificial probes unless a real implementation problem requires one."

## 8. Accepted Documentation

### Inventory of `/home/gabriel/project-tendril/documentation/main/`

| Path | Purpose | Major Content | Owner/Topic | Notes |
|------|---------|---------------|-------------|-------|
| `standards/agent-task-reporting.md` | Canonical task reporting standard | 491 lines: report location, filename format, execution identity, report numbering (with allocation procedure), required status, execution timing, timing integrity, live report lifecycle, required report structure, issue classification, reasoning diagnostics | Agent task reporting | **ONLY accepted document.** Contains known inconsistencies (see §5) |

`documentation/main/drafts/` — OBSERVED empty. This directory name is incongruous with the project convention: drafts belong under `documentation/drafts/`, not inside `main/`.

No other accepted documentation exists. The project's entire accepted authority in `documentation/main/` is one document.

## 9. Draft and Proposed Documentation

### Inventory of `/home/gabriel/project-tendril/documentation/drafts/`

| Path | Purpose | Status | Corresponding in main? |
|------|---------|--------|------------------------|
| `build-plan-handover.md` (516 lines) | Comprehensive build plan: current objective, project structure, execution primitive, OpenWork config, experimental results, deferred items, immediate plan | Draft — describes current operational reality; not promoted to accepted documentation | No — no accepted build plan exists |
| `ontological-agent-compiler-handover.md` (366 lines) | OAC concept: core idea, Prompt Scribe, task output, ontological grounding, authority boundary, relationship to Tendril | Draft — future architecture description | No |
| `openwork-handover-2026-08-11.md` (130 lines) | OpenWork operating model: current execution primitive, agent policy links, documentation workflow, longer-term direction | Draft — describes current operating model | No |
| `missing-project-material-handover-2026-08-11.md` (2010 lines) | Gap handover: 108 sections covering missing architecture, security, contracts, OAC, product V0, headless architecture, corpus integration, unresolved questions | Draft — comprehensive gap analysis; explicitly labelled as "integration input" that "should not automatically become accepted architecture" | No |
| `proposed-main/standards/handover-extraction.md` (246 lines) | Draft extraction standard: categories, metadata fields (Source Strength, Current State, Source Section), extraction rules, output requirements, artifact template | Draft — proposed for promotion to `documentation/main/standards/`; contains known defects (documented in missing-material-handover §55) | No — no accepted extraction standard exists |

### Empty draft directories
- `documentation/drafts/extractions/` — OBSERVED empty despite extraction standard existing; no extractions have been performed

## 10. Product Tendril State

`/home/gabriel/project-tendril/product/tendril/` — **OBSERVED: completely empty.**

- No code exists
- No schemas
- No contracts
- No tests
- No documentation
- No implementation of any kind

The build-plan-handover and missing-material-handover describe a detailed V0 product scope (Prompt node, runs, exact message packets, branching history edges, node duplication, context inspection, save/reopen, provider abstraction, GUI), but **none of it is implemented.** The product directory is a scaffold placeholder only.

## 11. OAC State

`/home/gabriel/project-tendril/oac/` — **OBSERVED: completely empty.**

- No OAC implementation exists
- No schemas
- No compiler code
- No Prompt Scribe implementation
- No ontology/index files

OAC exists only in draft documentation (`ontological-agent-compiler-handover.md` and `missing-project-material-handover.md` §§44-48). The build-plan-handover explicitly lists "full OAC" and "automatic Prompt Scribe" as deliberately deferred.

## 12. Control / Contracts State

### `control/contracts/task-contract.yaml` (OBSERVED)
A 26-line template/schema only:
```yaml
task_id: T-XXXX
title: Short task title
objective: One specific result this task must produce.
scope: {read: [], write: []}
context: []
capabilities: {network: false, tools: []}
constraints: [- Do not expand beyond this task.]
depends_on: []
done_when: [- Observable completion condition.]
expected_evidence: [- What must be shown or recorded to support completion.]
```

- **Not implemented:** This is a template, not a live contract. No task contracts exist for any authorized task.
- **Not implemented:** No Controller exists to materialize, validate, or enforce this contract.
- **Not implemented:** No Control Policy implementation exists.
- **Not implemented:** No Execution Envelope implementation exists.
- **Not implemented:** No Runtime Ledger exists.
- **Not implemented:** No independent verifier exists.
- **Not implemented:** No Project Control capability/skill exists.

The missing-material-handover §§11-21 extensively describes the required execution architecture (Controller, Launcher, Task Contract, Control Policy, Execution Envelope, Runtime Ledger, Independent Verifier, candidate change boundary, rollback/abandonment, frozen baseline, staleness). **All of these are policy/documentation only.**

## 13. Worktrees and Execution Infrastructure

### Directories (OBSERVED)
- `worktrees/bootstrap/` — empty
- `worktrees/product/` — empty

### Implemented Components
- **None.** No launcher, controller, or worktree lifecycle implementation exists.

### Current Isolation Mechanisms
- **Application-level only.** OpenCode permissions restrict tool access. AGENTS.md enforces behavioral policy. No OS-level sandbox, no namespace isolation, no bind mounts, no container.

### Real Task Worktree Lifecycle
- **Not implemented.** The missing-material-handover §34 describes requirements for worktree lifecycle but nothing is built.

### Trusted Verification
- **Not implemented.** All verification is performed by the same agent that performed the work. The distinction between "agent says tests passed" and "trusted verification observed tests passing" exists only in draft documentation.

### Git Integration
- **Not implemented.** The project is not even a Git repository. No Git integration mechanism exists.

## 14. Runtime Evidence and Telemetry

### Task Reports (OBSERVED)
- **25 unnumbered historical reports** (pre-R000001 era, timestamps from 20260811T065840Z to 20260811T075115Z)
- **13 numbered reports** (R000001 through R000013, from 20260811T075350Z to 20260811T083308Z)
- **1 in-progress report** (R000014, this execution)
- All reports are **agent-authored** — written by the same agent that performed the task
- Report filenames from R000001 through R000003 include provider/model/effort in the filename (e.g., `_deepseek-v4-pro-max_`). Starting from R000004, filenames dropped provider/model/effort information. R000006 specifically edited the standard to remove identity from filenames.

### Reasoning JSONL Artifacts (OBSERVED)
- Exactly **one** reasoning artifact exists: `R000003_20260811T075943Z_deepseek-v4-flash-max_locate-thought-stream.reasoning.jsonl` (63425 bytes)
- No other `.reasoning.jsonl` or `.reasoning.md` files exist
- The standard specifies `.reasoning.md` suffix but the only existing artifact uses `.reasoning.jsonl`

### Other Telemetry Artifacts
- **None observed.** No telemetry directory, no harness event logs, no tool-call traces, no timing telemetry beyond what agents recorded in their own reports.

### What Is Agent-Authored vs Runtime-Derived
- All existing task reports: **agent-authored**
- The one reasoning JSONL artifact: **agent-extracted** from OpenCode runtime data (R000003 task explicitly extracted reasoning events from the OpenCode SQLite database, not from agent introspection)
- No harness-authored telemetry exists

### What Is Currently Missing
- Harness-owned execution telemetry (the missing-material-handover §1 explicitly identifies this gap)
- Independent timing capture
- Tool-call event logs
- Harness-authored reasoning diagnostics
- Concurrency-safe report number allocation
- Phase timestamps (execution start, substantive work start/end, verification end, finalization start/end)

## 15. Implemented vs Policy-Only vs Planned

### Implemented / Directly Operational
- Agent policy enforcement via AGENTS.md injection into OpenWork sessions
- OpenCode permission/configuration enforcement (application-level)
- Task report numbering and allocation via NEXT_REPORT_NUMBER counter file
- Task report creation with execution identity, timing, execution log, and result
- Custom Tendril tool loading and execution (proven in harness-probe experiment)
- Scoped filesystem read tool with path/symlink traversal rejection (proven in INST-0002)
- One-task execution primitive: human task → fresh OpenWork session → policy → execution → report → stop
- Documentation draft/proposed-main workflow

### Policy / Documentation Only
- Controller (authorization, materialization, observation, verification, finalization)
- Launcher (OS isolation, bounded capabilities, agent launch)
- Task Contract (formal schema beyond template)
- Control Policy (authoritative constraints separation from task intent)
- Execution Envelope (immutable frozen contract)
- Runtime Ledger (authoritative execution record)
- Independent Verifier (trusted post-execution verification)
- Project Control capability/skill
- OpenWork queue state model (PLAN/READY/IN PROGRESS/REQUIRES ATTENTION/DONE)
- OAC / Prompt Scribe (human intent → candidate tasks)
- Headless architecture (backend authoritative, frontend replaceable)
- Agent Git authority restriction
- Write leases / concurrent mutation control
- Secrets as capabilities
- Structured ClarificationRequest
- Staleness / dirty propagation
- Frozen baseline identity
- Rollback and abandonment semantics

### Scaffold / Placeholder
- `oac/` — empty directory
- `product/tendril/` — empty directory
- `references/` — empty directory
- `tmp/` — empty directory
- `worktrees/bootstrap/` — empty directory
- `worktrees/product/` — empty directory
- `control/contracts/task-contract.yaml` — template only, no substantive contracts
- `documentation/main/drafts/` — empty directory (incongruous naming)
- `documentation/drafts/extractions/` — empty directory

## 16. Current Known Defects / Inconsistencies

1. **Not a Git repository** (OBSERVED): The project has no Git history, no commits, no branches. Agent policy references Git concepts (frozen baseline, commits, integration) but the project itself has no Git infrastructure.

2. **`documentation/main/drafts/` — incongruous directory** (OBSERVED): A `drafts/` directory exists inside `documentation/main/`, which is meant for accepted documentation. It is empty. This conflicts with the project convention that drafts belong under `documentation/drafts/`.

3. **Reasoning artifact filename mismatch** (OBSERVED): The standard specifies `.reasoning.md` as the suffix (line 483), but the only existing reasoning artifact uses `.reasoning.jsonl`. The standard example at line 487-489 also uses timestamp-only format without R-number prefix, inconsistent with the current R-prefix numbered format.

4. **Timing rules duplication** (OBSERVED): `agent-task-reporting.md` has timing rules in both §Execution Timing and §Timing Integrity with overlapping content.

5. **Duplicate policy directives in AGENTS.md** (OBSERVED): The §Pre-Task Initialization Gate contains embedded "Add this operational rule exactly:" and "Also clarify:" meta-instructions that appear to be edit-instruction artifacts preserved in the final policy text. Lines 116-160 read like an editing task specification rather than purely declarative policy.

6. **MEchanical Silence section contains edit instructions** (OBSERVED): Lines 431-443 contain "Add these operational rules exactly:" and "Clarify:" meta-instructions preserved in the final text. Same pattern as #5.

7. **DOCTRINE.md overlap with AGENTS.md** (OBSERVED): DOCTRINE.md (bootstrap) and AGENTS.md (project root) contain overlapping but not identical rules. DOCTRINE.md is 46 lines; AGENTS.md is 516 lines. DOCTRINE.md predates AGENTS.md's expansion. No document explicitly states whether DOCTRINE.md remains binding or has been superseded.

8. **`UP_NEXT.md` still points to INST-0002** (OBSERVED): INST-0002 is completed (PASS). UP_NEXT.md has not been updated. The build-plan-handover acknowledges this mechanism is temporary scaffolding.

9. **Agent-authored telemetry presented as objective** (OBSERVED): The reporting standard's reasoning diagnostics section asks agents to self-report loop indicators, decision revisions, and repeated checks — but the missing-material-handover §§1-7, 95-97 explicitly identifies this as unreliable. The standard itself acknowledges at line 475 that "Diagnostic observations about loops or repeated reasoning must be grounded in the captured trace rather than invented by the reporting agent."

10. **Unnumbered reports in numbered-report directory** (OBSERVED): 25 historical reports predate the R-number format. They remain in the same directory as numbered reports. The standard explicitly permits this (line 106: "Existing unnumbered historical reports remain valid historical records").

11. **No accepted documentation beyond reporting standard** (OBSERVED): The project's accepted documentation consists of exactly one file. Extensive architecture exists in drafts but none has been promoted.

12. **Symlink inside harness-probe/allowed/** (OBSERVED): `escape-link.txt` is a symlink to `../denied/denied.txt`. This was intentionally placed as a test artifact but remains on disk.

13. **Empty worktrees** (OBSERVED): Both `worktrees/bootstrap/` and `worktrees/product/` are empty directories. They provide no isolation or lifecycle.

14. **Backup files in project root** (OBSERVED): `AGENTS.md.bak_01`, `AGENTS.md.bak_02`, and `opencode.jsonc_bak_01` are not accounted for by any policy and represent historical versions without documented purpose.

15. **Probe experiment `.opencode/` contains `node_modules/`** (OBSERVED): The harness-probe experiment has a full Node.js tool implementation with dependencies. This is operational experimental code, not product architecture.

## 17. Explicitly Missing Major Components

Topic: Git Repository
Evidence of absence/incompleteness: `git status` returned "not a git repository" in project root
Description: The project root is not a Git repository. No version control exists for any project artifact.

Topic: Tendril Product Implementation
Evidence of absence/incompleteness: `product/tendril/` is empty
Description: No product code, schemas, tests, or implementation of any kind exists. The product exists only as draft documentation.

Topic: Controller
Evidence of absence/incompleteness: No controller code or configuration exists anywhere in the project tree
Description: The Controller (task validation, execution authorization, envelope materialization, observation, verification, finalization) is described in draft documentation but not implemented.

Topic: Launcher
Evidence of absence/incompleteness: No launcher code exists; `worktrees/` directories are empty
Description: The Launcher (OS isolation, worktree creation, bounded capability exposure, agent process launch) is not implemented.

Topic: OS-Level Sandbox
Evidence of absence/incompleteness: No namespace/sandbox/container configuration exists; build-plan-handover and openwork-handover explicitly state the hard sandbox is not yet implemented
Description: Security is application-level only (AGENTS.md + opencode.jsonc permissions).

Topic: OAC / Prompt Scribe
Evidence of absence/incompleteness: `oac/` directory is empty; draft documentation explicitly defers OAC
Description: The Ontological Agent Compiler and Prompt Scribe are not implemented.

Topic: Task Contract Implementation
Evidence of absence/incompleteness: `control/contracts/task-contract.yaml` is a template only; no live contracts exist
Description: Tasks are communicated as human prose, not structured contracts.

Topic: Independent Verification
Evidence of absence/incompleteness: No verifier code, tests, or configuration exists
Description: All verification is agent self-verification. No trusted independent verification mechanism.

Topic: OpenWork Queue State
Evidence of absence/incompleteness: No queue state files, API, or configuration exists in the project
Description: The PLAN/READY/IN PROGRESS etc. queue state model is described in drafts but not implemented.

Topic: Runtime Ledger
Evidence of absence/incompleteness: No ledger code, schema, or data files exist
Description: The authoritative execution record is not implemented beyond agent-authored task reports.

Topic: Project Control
Evidence of absence/incompleteness: No Project Control capability/skill exists
Description: The human currently manages all task state manually.

Topic: Git Integration
Evidence of absence/incompleteness: Project is not even a Git repository
Description: No Git integration or agent Git authority restriction mechanism exists.

Topic: Headless Architecture Implementation
Evidence of absence/incompleteness: No backend service, protocol, or runtime exists
Description: The headless architecture (backend authoritative, frontend replaceable) exists only in draft documentation.

Topic: Corpus / Knowledge Architecture
Evidence of absence/incompleteness: No corpus manifest, bible, index, or ontology files exist in the fresh rebuild
Description: Historical corpus machinery (Bible, manifest, artifact IDs) is not present in the fresh project.

## 18. Unresolved Questions Already Present in the Project

The following unresolved questions are explicitly stated in current project files:

1. **Corpus Markdown Authority Model** (from missing-material-handover §67):
   > "Are corpus Markdown files directly maintained canonical material, or generated projections from another authoritative store?"

2. **Exact Controller Implementation** (from missing-material-handover §103):
   > Language, process topology, daemon vs invoked controller, persistence interface, Controller API — all not frozen.

3. **Exact Sandbox Technology** (from missing-material-handover §104):
   > Not yet frozen. Requirement is strong isolation; implementation mechanism remains open.

4. **Exact Runtime Persistence Schema** (from missing-material-handover §105):
   > Not yet frozen. Needs to support authoritative execution state independently of SilverBullet.

5. **Permanent Transport** (from missing-material-handover §107):
   > Headless frontend/backend protocol semantics are accepted direction; permanent transport is still open.

6. **Durable Entity Set** (from missing-material-handover §108):
   > "Do not let old vocabulary create new obligations merely because it exists." The exact set of durable entities remains unresolved.

7. **Reasoning Diagnostics Placement** (from missing-material-handover §97):
   > "Decide whether reasoning diagnostics belong inside the main agent task report, in a harness-generated companion telemetry file, or as a harness-authored section appended after execution."

8. **Telemetry Failure Classification** (from missing-material-handover §99):
   > "At present, 'telemetry failure' is conceptually required but not fully mapped to a single canonical issue/status representation."

## 19. Recent Build History

Based on numbered reports R000001–R000013 (OBSERVED from filenames, timestamps, and content patterns):

**Pre-R-number era (25 reports, ~2026-08-11T06:58 to ~07:51 UTC):**
- Created the handover-extraction standard draft section by section (multiple sequential tasks)
- Added timing integrity policy to reporting standard
- Added decision stability policy
- Added reasoning diagnostics to reporting standard
- Added issue classification
- Added execution start sequence
- Various verification and repair tasks on the extraction standard

**R000001** (07:53 UTC): Established report number allocation mechanism — added the NEXT_REPORT_NUMBER counter-file procedure to the reporting standard. Created the number allocation subsection.

**R000002** (07:58 UTC): Inspected DOCTRINE.md — confirmed it exists but is shorter and older than the expanded AGENTS.md.

**R000003** (07:59 UTC): First reasoning telemetry capture — located and extracted the OpenCode thought/reasoning stream from the runtime SQLite database. Produced the only existing `.reasoning.jsonl` artifact (63425 bytes, 36 reasoning events).

**R000004** (08:02 UTC): Added Pre-Task Initialization Gate to AGENTS.md — the extensive rules preventing substantive reasoning before report creation.

**R000005** (08:05 UTC): Materialized reasoning trace — extracted raw reasoning events into a structured JSONL artifact.

**R000006** (08:09 UTC): Edited reporting standard to remove provider/model/effort from filenames — simplified filename format to R-number + timestamp + task-slug only.

**R000007** (08:12 UTC): Added Terse Reasoning policy to AGENTS.md.

**R000008** (08:14 UTC): Inspected DOCTRINE.md.

**R000009** (08:17 UTC): Tightened Terse Reasoning policy — added Mechanical Silence subsection and tightened reasoning limits.

**R000010** (08:18 UTC): Inspected DOCTRINE.md byte size.

**R000011** (08:20 UTC): Inspected DOCTRINE.md human sequencing requirement.

**R000012** (08:22 UTC): Edited policy identity initialization gate — tightened the rules around when identity becomes known.

**R000013** (08:33 UTC): Stored the missing-material handover draft verbatim to `documentation/drafts/missing-project-material-handover-2026-08-11.md`.

**R000014** (08:34 UTC): Current execution — comprehensive current-state handover audit.

**Overall progression:** The rebuild moved from establishing the extraction standard draft → refining the reporting standard → adding execution policy (initialization gate, terse reasoning, mechanical silence) → storing gap documentation → current-state audit.

## 20. Current Operational Workflow

The workflow currently evidenced on disk:

```
HUMAN
  writes one bounded task with:
    Objective, Scope, Constraints, Done When
      ↓
  opens fresh OpenWork session against /home/gabriel/project-tendril
      ↓
AGENT (fresh execution)
  1. Loads AGENTS.md (current policy)
  2. Loads current task
  3. Reads reporting standard
  4. Allocates report number from NEXT_REPORT_NUMBER
  5. Samples UTC start time
  6. Creates numbered task report (all identity = UNKNOWN)
  7. Performs task work (single objective, bounded scope)
  8. Appends execution-log entries as phases complete
  9. Samples UTC finish time
  10. Assigns terminal status (PASS/PARTIAL/BLOCKED/FAIL)
  11. Finalizes report
      ↓
STOP — agent does not self-sequence
      ↓
HUMAN
  reviews report, decides next task
```

**What is NOT automated:**
- The human must manually open a fresh session, write the task in prose, and copy it into OpenWork
- No queue state machine operates on task state
- No Controller authorizes or materializes execution
- No Launcher creates isolated execution environments
- No independent verifier checks results
- No automated Git integration exists

## 21. Current Architecture Boundary

**What Project Tendril currently IS on disk:**

- A documentation and policy project undergoing fresh bootstrap/rebuild
- A set of behavioral rules (AGENTS.md) governing agent execution
- A reporting system (agent-task-reporting.md + numbered reports)
- A collection of draft architecture documents describing future components
- A proven one-task execution primitive operating through OpenWork/OpenCode
- Two completed bootstrap experiments proving tool-surface control and scoped capability
- An empty directory scaffold for future product, OAC, worktrees, and references

**What Project Tendril is NOT yet on disk:**

- An implemented software product
- A running controller/launcher/sandbox system
- A version-controlled repository
- An isolated execution environment
- A headless client/server architecture
- An ontological agent compiler
- A task queue or work-management system
- A completed documentation corpus

**Bootstrap vs Product boundary (OBSERVED from AGENTS.md §10):**
> "Bootstrap and control mechanisms used to build Tendril are not automatically Tendril product architecture."

The current operational workflow — AGENTS.md enforcement, manual task creation, agent-authored reports, counter-file numbering — is all bootstrap machinery. None of it represents the final Tendril product architecture.

## 22. Files Created or Modified by This Audit

**Created:**
- `/home/gabriel/project-tendril/documentation/drafts/current-project-state-handover-2026-08-11.md` (this file)
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/R000014_20260811T083418Z_current-project-state-handover.md` (this audit's task report)

**Modified:**
- `/home/gabriel/project-tendril/runtime/reports/agent-tasks/NEXT_REPORT_NUMBER` (14 → 15)

No other project artifacts were modified.

## 23. Evidence Index

| Source File | What It Establishes |
|-------------|---------------------|
| `AGENTS.md` (516 lines) | Current agent execution policy: one-task, pre-task initialization, terse reasoning, mechanical silence, decision stability, scope, failure, queue, architectural boundary, documentation authority, task reporting exception, policy refresh |
| `documentation/main/standards/agent-task-reporting.md` (491 lines) | Canonical reporting standard: filename format, execution identity, report numbering with NEXT_REPORT_NUMBER allocation, timing, live report lifecycle, report structure, issue classification, reasoning diagnostics |
| `opencode.jsonc` (18 lines) | Current OpenCode permissions: read/edit/glob/grep/bash allowed inside project; external_directory/task/webfetch/websearch denied |
| `bootstrap/DOCTRINE.md` (46 lines) | Track A operating doctrine: 10 core invariants, fresh execution bootstrap, Track A stopping rule — overlaps with AGENTS.md |
| `bootstrap/project.env` (1 line) | PROJECT_ROOT definition |
| `bootstrap/instructions/UP_NEXT.md` (34 lines) | Points to INST-0002 (temporary scheduling mechanism) |
| `bootstrap/instructions/instruction-log/INST-0001.md` (97 lines) | Harness boundary probe — PASS, proven tool-surface control |
| `bootstrap/instructions/instruction-log/INST-0002.md` (59 lines) | Scoped read tool test — PASS, proven path/symlink boundary |
| `control/contracts/task-contract.yaml` (26 lines) | Template schema only — no live task contracts |
| `runtime/reports/agent-tasks/NEXT_REPORT_NUMBER` | Report counter = 15 after this allocation |
| `runtime/reports/agent-tasks/` (all 38 prior reports) | 25 unnumbered + 13 numbered reports; agent-authored operational evidence |
| `runtime/reports/agent-tasks/R000003_...reasoning.jsonl` (63425 bytes) | Only existing reasoning telemetry artifact |
| `documentation/drafts/build-plan-handover.md` (516 lines) | Current build plan, deferred items, immediate plan, execution architecture overview |
| `documentation/drafts/ontological-agent-compiler-handover.md` (366 lines) | OAC concept description, authority boundary, relationship to Tendril |
| `documentation/drafts/openwork-handover-2026-08-11.md` (130 lines) | OpenWork operating model, current execution primitive |
| `documentation/drafts/missing-project-material-handover-2026-08-11.md` (2010 lines) | Comprehensive gap analysis: 108 sections covering all missing architecture, security, contracts, product, corpus |
| `documentation/drafts/proposed-main/standards/handover-extraction.md` (246 lines) | Proposed extraction standard — draft, not yet promoted |
| Directory tree walk | Empty dirs: oac/, product/tendril/, references/, tmp/, worktrees/bootstrap/, worktrees/product/, documentation/main/drafts/, documentation/drafts/extractions/ |
| `git status` (failed) | Project is NOT a Git repository |
| `AGENTS.md.bak_01` (33 lines) | Earliest minimal agent policy version |
| `AGENTS.md.bak_02` (180 lines) | Intermediate policy version (before execution-start-sequence, terse reasoning, decision stability, mechanical silence) |
| `opencode.jsonc_bak_01` (15 lines) | Previous ask-default permission configuration |
| `bootstrap/experiments/harness-probe/` | Complete experiment workspace: custom tool, restricted config, test files |
