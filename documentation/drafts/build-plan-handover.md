



# Project Tendril — Latest Build Handover

## 1. Current objective

Project Tendril is being rebuilt from a clean Linux project space with one immediate goal:

> **Reach reliable, useful one-task agent execution in OpenWork before adding orchestration complexity.**

For now, a human gives OpenWork **one bounded task**, a fresh agent performs exactly that task, reports what it did, and stops.

Prompt Scribe, automatic task decomposition, DAG execution, autonomous scheduling, Controller/Launcher automation, and the full Ontological Agent Compiler are deliberately deferred until this primitive works routinely.

This is a pragmatic simplification of the larger V0 architecture rather than a rejection of it. The underlying architecture still separates interpretation, authority, execution, and verification.  filecite turn0file0 

---

## 2. Canonical project location

The current canonical root is:

```text
/home/gabriel/project-tendril/
```

This **supersedes** older documents that use:

```text
/home/gabriel/tendril-project/
```

The old Tendril/Baton/CBook system is preserved as historical reference and should not be mutated as part of the rebuild.

Historical material does not automatically become current authority.

---

## 3. Current physical structure

The rebuild is intentionally minimal.

Current important areas include:

```text
/home/gabriel/project-tendril/
├── AGENTS.md
├── opencode.jsonc
├── bootstrap/
├── control/
├── documentation/
│   ├── main/
│   └── drafts/
├── oac/
├── product/
│   └── tendril/
├── references/
├── runtime/
├── tmp/
└── worktrees/
```

Do not create speculative directory trees merely because they may eventually be useful.

The project structure should grow in response to actual work.

---

## 4. OpenWork is now the active working interface

The Windows OpenWork client is connected to a Linux OpenWork worker rooted at:

```text
/home/gabriel/project-tendril
```

The old harness-probe workspace is no longer the active workspace.

The intended division is now:

```text
OpenWork
    = task execution + eventually queue/state

AGENTS.md
    = universal agent policy

opencode.jsonc
    = OpenCode capability configuration

project filesystem
    = durable artifacts and evidence

human
    = task sequencing, architectural authority, acceptance
```

This chat should not remain the live project manager.

The longer-term plan is for OpenWork to carry the build queue and task state directly.

---

## 5. Current execution primitive

The core workflow is deliberately simple:

```text
HUMAN
  ↓
one bounded task
  ↓
fresh OpenWork session
  ↓
current AGENTS.md
  ↓
agent performs only that task
  ↓
agent reports observable result
  ↓
STOP
  ↓
human reviews / chooses next task
```

A task should normally state only what is necessary:

```text
Objective
Scope
Constraints
Done When
```

Do not burden trivial work with the future full execution schema yet.

The earlier architectural work established a richer `TaskContract → ControlPolicy → ExecutionEnvelope → ExecutionResult` model, but that is the later deterministic execution kernel rather than a prerequisite for today's basic workflow.  filecite turn0file0 

---

## 6. Agent policy

The canonical policy is:

```text
/home/gabriel/project-tendril/AGENTS.md
```

Every fresh agent execution must operate under the current policy.

Core rules include:

- one task;
- one objective;
- bounded scope;
- minimal necessary context;
- no scope expansion;
- no opportunistic work;
- no self-sequencing;
- missing authority or information → `BLOCKED`;
- discovered adjacent work → `FOLLOW-UP CANDIDATE`;
- previous sessions are not authority;
- current policy + current task govern execution;
- completion claims require observable evidence;
- human controls sequencing and acceptance.

The agent should also be explicitly told canonical control paths when those files matter:

```text
Project root:
/home/gabriel/project-tendril

Agent policy:
/home/gabriel/project-tendril/AGENTS.md

OpenCode configuration:
/home/gabriel/project-tendril/opencode.jsonc

Project temporary directory:
/home/gabriel/project-tendril/tmp
```

---

## 7. OpenCode configuration

Canonical configuration:

```text
/home/gabriel/project-tendril/opencode.jsonc
```

This is separate from `AGENTS.md`.

Conceptually:

```text
AGENTS.md
    tells the model what it must do

opencode.jsonc
    controls what OpenCode exposes/allows
```

The build is currently using a relatively permissive **inside-project** configuration so useful work can proceed.

The important current boundary is:

> Work should remain inside `/home/gabriel/project-tendril/`.

External paths, web access, subagents and broader effects should progressively become explicitly controlled.

The final architecture still requires stronger OS-level isolation. OpenCode permissions are not intended to be the ultimate security perimeter.

---

## 8. What has already been established experimentally

The bootstrap work proved several useful mechanisms.

### Harness/tool boundary

A project-local custom OpenCode tool successfully loaded and executed through OpenWork.

Built-in capabilities such as `bash`, `edit`, and `webfetch` could be removed from the model-visible tool surface.

### Scoped filesystem tool

A Tendril-owned read tool successfully:

- read an allowed file;
- rejected `../` traversal;
- rejected a symlink that resolved outside its allowed scope.

This established the useful principle:

> A Tendril-owned semantic tool can expose a smaller capability than the underlying Linux process possesses.

### Fresh execution requirement

Changing the tool implementation did not reliably alter an already-running execution environment.

Therefore:

> **Changes to policy, tools, permissions or execution configuration require a fresh session/execution context.**

These experiments are complete. Do not continue creating artificial probes unless a real implementation problem requires one.

---

## 9. Immediate productive use: documentation ingestion

Current documentation structure:

```text
documentation/
├── main/
└── drafts/
```

Meaning:

### `documentation/main/`

Current, coherent, human-accepted Tendril documentation.

### `documentation/drafts/`

Material still being:

- integrated;
- rewritten;
- reconciled;
- reviewed;
- classified;
- checked for authority.

The first real productive OpenWork workflow is documentation processing.

Example:

```text
human supplies source material
        ↓
fresh documentation task
        ↓
agent creates/reworks one draft
        ↓
stop
        ↓
fresh review task
        ↓
human decides whether/how it becomes main documentation
```

A handover has already successfully been written and independently verified at:

```text
documentation/drafts/openwork-handover-2026-08-11.md
```

This confirmed the basic one-task → artifact → stop → verification workflow.

---

## 10. OpenWork project-management direction

Once ordinary task execution is stable, OpenWork should become the live queue.

Intended states:

```text
PLAN
READY
IN PROGRESS
REQUIRES ATTENTION
DONE
```

Each bounded unit of work should ultimately correspond to its own task/session.

Important authority rule:

```text
discovered work
    → PLAN / follow-up candidate

human-approved work
    → READY

selected work
    → IN PROGRESS

completed + accepted
    → DONE
```

Agents do not promote their own discoveries into executable work.

The old filesystem-based `UP_NEXT.md` / `instruction-log/` mechanism was useful bootstrap scaffolding, but it is **not intended to remain the live build scheduler once OpenWork carries that state**.

---

## 11. Prompt Scribe — later, not now

Prompt Scribe will eventually sit upstream of the simple execution primitive.

Its purpose is:

```text
compound human intent
        ↓
Prompt Scribe
        ↓
multiple discrete TaskContractCandidates
        ↓
human review / approval
        ↓
OpenWork queue
        ↓
one task at a time
```

For example, a compound instruction such as:

> Build the launcher.

might later become:

```text
T-101 Define launcher contract
T-102 Define workspace materialization
T-103 Implement worktree creation
T-104 Implement path visibility
T-105 Implement process launch
T-106 Implement result capture
T-107 Implement trusted verification
T-108 Integrate pipeline
```

The sophistication belongs **upstream in decomposition**, not inside each execution worker.

Prompt Scribe:

- interprets;
- decomposes;
- proposes scope;
- identifies dependencies;
- identifies ambiguity.

It does **not** authorize or execute.

This retains the critical architecture rule that interpretation does not confer authority.  filecite turn0file0 

---

## 12. Longer-term execution architecture

The larger V0 architecture remains relevant once the primitive workflow is established.

The eventual deterministic pipeline is:

```text
Human Intent
      ↓
Prompt Scribe / OAC
      ↓
TaskContractCandidate
      ↓
Human acceptance
      ↓
ControlPolicy
      ↓
Controller
      ↓
ExecutionEnvelope
      ↓
Launcher / sandbox
      ↓
Agent
      ↓
ExecutionResult
      ↓
Independent verification
      ↓
Human accept / reject / rework
```

The finalized architectural contracts already distinguish:

- logical untrusted task requirements;
- authoritative control policy;
- frozen materialized execution envelope;
- clarification state;
- trusted execution result.  filecite turn0file0 

The earlier rebuild architecture also correctly identified that runtime truth, control authority and project knowledge must remain distinct planes.  filecite turn0file1 

---

## 13. Security direction

The intended security stack is layered:

```text
AGENTS.md
    behavioral policy
        ↓
OpenCode permissions
    application capability control
        ↓
Tendril-owned tools
    task/path-specific capability control
        ↓
Controller + Launcher
    execution authorization
        ↓
Linux namespace/sandbox
    hard physical boundary
```

The end state should satisfy:

> An ordinary agent cannot access paths or capabilities that are outside its execution envelope, even if it deliberately tries.

The earlier GLM review correctly highlighted that control authority must not simply become part of an unrestricted agent filesystem and that physical and semantic authority boundaries must remain distinct.  filecite turn0file2 

For today's build, however, do not block useful work while trying to implement the final sandbox all at once.

---

## 14. What is deliberately deferred

Do **not** build yet unless a real need forces it:

- automatic Prompt Scribe;
- full OAC;
- task DAG execution;
- autonomous queue scheduling;
- multi-agent concurrency;
- automatic task approval;
- automatic permission expansion;
- sophisticated knowledge retrieval;
- background process supervision;
- Tendril GUI;
- complete Controller;
- complete Launcher;
- complete OS sandbox;
- automatic Git integration.

---

# Immediate plan

The next development phase is:

1. **Use OpenWork for real bounded documentation tasks.**
2. Build confidence that fresh agents reliably obey `AGENTS.md`.
3. Have each task produce one useful artifact or one clearly defined result.
4. Move the actual Tendril build plan and queue into OpenWork.
5. Establish manual `PLAN → READY → IN PROGRESS → DONE/ATTENTION`.
6. Only then automate queue management.
7. Only after the one-task execution primitive is stable, begin Prompt Scribe/task-contract generation.
8. Build the Controller/Launcher/security substrate incrementally from the needs exposed by real work.

## Current milestone

The immediate milestone is no longer theoretical:

> **A human can give OpenWork one bounded Project Tendril task, a fresh agent can perform that task under the current project policy, produce an inspectable result, report what happened, and stop.**

That primitive is now functioning.

The next priority is to **use it to ingest and organize the accumulated Tendril documentation**, while progressively moving project planning and task state out of conversational memory and into OpenWork.  memcite
