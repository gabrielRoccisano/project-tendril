Below is a **gap handover**, not a restatement of what is already in the fresh rebuild. I am treating "missing" as **not yet confirmed as accepted/current documentation or implemented structure under `/home/gabriel/project-tendril/`**. Some older Tendril material exists in the File Library as `PENDING_INTEGRATION`, especially the headless-runtime/UI boundary and older corpus workflow material; those should be reconciled into the fresh rebuild rather than blindly copied.  

The recent bootstrap work already established numbered reports, simplified report filenames, pre-task initialization, mechanical silence, and report-first identity initialization, so those are **not** repeated below as missing features.   

# Project Tendril — Missing Topics / Integration Handover

**Date:** 2026-08-11
**Fresh rebuild root:** `/home/gabriel/project-tendril/`
**Purpose:** Capture Project Tendril concepts, decisions, architectural requirements, operational requirements, unresolved questions, and implementation obligations that have emerged during planning but are not yet confirmed as properly represented in the current fresh Tendril project files.

This document is an **integration input**. It should not automatically become accepted architecture merely because it is copied into the repository. Existing accepted documentation must be checked first, overlap reconciled, conflicts surfaced, and human authority preserved.

---

## 1. Harness-Owned Agent Observation

The current reporting system is agent-authored. This is useful for recording what the agent claims it did, but it is not sufficient for observing how the agent actually behaved.

The harness/controller must independently observe execution.

Core distinction:

> **Agent reports the work. Harness reports the agent.**

The harness should own objective execution telemetry such as reasoning events, tool events, timing, repeated checks, stalls, loops, decision revisions, and execution lifecycle boundaries.

Agent self-assessment must not be treated as authoritative telemetry.

---

## 2. Raw Reasoning Capture

OpenCode has been directly observed storing the model's visible `Thought` stream as structured reasoning parts and reasoning-carrying events.

The runtime source discovered during R000003 includes:

* OpenCode SQLite database:
  `/home/gabriel/.local/share/opencode/opencode.db`
* reasoning `part` records
* persisted event records
* monotonically ordered event `seq`
* reasoning text
* part start/end timestamps where available
* session IDs
* live OpenCode SSE events
* model/session metadata

This runtime stream is the correct source for reasoning telemetry.

Do not ask an agent to recreate, summarize, or introspect its own missing reasoning.

R000003 established that the runtime reasoning stream is directly observable. 

---

## 3. Reasoning JSONL Artifact

Each execution should eventually have a machine-readable reasoning/event artifact associated with its Report Number.

Preferred raw form:

`R000123_<timestamp>_<task-slug>.reasoning.jsonl`

The raw artifact should preserve runtime events in original order and should not clean up, summarize, deduplicate, rewrite, or improve the reasoning.

The first extraction successfully demonstrated this for R000003 with 36 persisted reasoning events and byte-for-byte text fidelity. 

The JSONL is operational telemetry, not project authority.

A human-readable `.reasoning.md` may later be derived from the raw telemetry, but the raw JSONL remains the evidence source.

---

## 4. Capture Must Begin Before the Model Gets Control

Prompt policy cannot guarantee zero reasoning before the first agent tool call.

The screenshots and raw thought captures showed that a model can perform substantial reasoning before it creates its task report.

The eventual structural solution is:

```text
Controller / Harness
→ allocate execution identity
→ timestamp start
→ initialize telemetry capture
→ initialize execution record
→ launch/invoke agent
→ observe agent
```

This means even reasoning emitted before the agent's first filesystem/tool action is captured.

Prompt-level initialization rules are temporary bootstrap controls, not the final enforcement mechanism.

---

## 5. Report Number as Execution Join Key

Report Number should remain the durable project-local execution identifier.

Associated artifacts should join through that identifier rather than requiring provider/model details in filenames.

Example conceptual family:

```text
R000123_...md
R000123_...reasoning.jsonl
R000123_...telemetry.json
R000123_...evidence/
```

Execution identity such as provider, model, session, effort, runner, and runtime IDs belongs in structured metadata rather than filename semantics.

---

## 6. Harness-Owned Reasoning Diagnostics

The current report format still contains reasoning-diagnostic concepts that agents can populate themselves.

This is unreliable.

R000012 reported:

* `Reasoning Capture: UNAVAILABLE`
* no loop indicators
* no decision revisions
* no repeated checks

while the separately captured OpenWork Thought stream showed substantial reasoning activity. The report therefore described the work cleanly but did not accurately characterize model behavior. 

Fields such as these should ultimately become harness/controller-owned:

* reasoning event count
* reasoning duration
* reasoning token count
* repeated checks
* repeated topics
* decision reversals
* loop indicators
* time without semantic progress
* pre-first-action reasoning
* post-result reasoning
* tool-call gaps
* finalization overhead

Agents should not grade their own cognitive efficiency.

---

## 7. Semantic-Progress Measurement

A future harness should distinguish **reasoning activity** from **semantic progress**.

Examples of progress:

* new evidence observed
* new tool result
* requirement resolved
* finding established
* decision made from new evidence
* authorized mutation performed
* verification completed

Examples of non-progress:

* rephrasing the same question
* reconsidering an already settled decision without new evidence
* repeatedly comparing equivalent alternatives
* narrating report construction
* planning an action already mechanically specified
* increasing confidence after sufficient evidence already exists

Candidate rule:

> **No new evidence, no renewed deliberation.**

Possible harness signal:

```text
repeated topic
+ no new evidence
+ no new decision
+ elapsed reasoning
= possible reasoning stall
```

---

## 8. Finalization-Time Telemetry

Observed executions have sometimes completed substantive work quickly but spent significant additional time producing/finalizing reports.

The harness should distinguish at least:

* execution start
* substantive work start
* substantive work end
* verification end
* finalization start
* finalization end

A useful derived metric is:

`Finalization Duration`

This makes reporting overhead observable rather than mixing it into task execution time.

---

## 9. Phase Timestamp Ownership

Agents have previously reconstructed or approximated phase timestamps from file modification times.

R000005 detected and corrected exactly this problem. 

The final system should not depend on models remembering to sample phase times correctly.

The harness/controller should timestamp observable lifecycle events directly.

Until then, every logged phase timestamp should be freshly observed rather than reconstructed.

---

## 10. Atomic Report-Number Allocation

The current counter file:

`runtime/reports/agent-tasks/NEXT_REPORT_NUMBER`

is an acceptable bootstrap mechanism.

It is **not yet concurrency-safe**.

Future Controller/Harness allocation must be atomic so parallel executions cannot allocate the same Report Number.

Requirements:

* monotonic project-local sequence
* no reuse
* allocation survives failed executions
* allocation happens before execution starts
* concurrent-safe reservation
* no filename scanning as allocator
* historical unnumbered reports remain unnumbered

The current counter-file protocol is temporary until the controller owns this operation.

---

# EXECUTION ARCHITECTURE

## 11. Controller

The Controller is still a major missing real component.

Its job is broader than launching a process.

The Controller should:

* receive a candidate task
* validate it
* resolve current policy
* authorize execution
* materialize the execution contract
* allocate execution identity
* prepare execution state
* invoke the Launcher
* observe runtime events
* terminate execution when necessary
* independently verify the result
* finalize evidence
* hand the result back for human acceptance

The Controller is trusted infrastructure.

The agent is not.

---

## 12. Launcher

The Launcher is distinct from the Controller.

Its job is to transform an already authorized execution specification into an actual isolated operating-system process.

Responsibilities include:

* create/select the task worktree
* establish filesystem isolation
* establish namespace/mount boundaries
* expose only approved paths
* configure environment
* inject authorized capabilities/secrets
* spawn the selected agent/runtime
* return process/runtime identity to the Controller
* terminate/clean up execution resources

The Launcher should not decide project architecture or task meaning.

---

## 13. Controller ≠ Launcher

This distinction should become explicit documentation.

```text
Controller
decides what execution is authorized

Launcher
constructs the authorized execution environment

Agent
performs the bounded task
```

Combining Controller policy decisions with low-level process launching would blur trusted authority boundaries.

---

## 14. Task Contract

A formal Task Contract is required.

It represents the authorized human task before runtime materialization.

It should carry things such as:

* task identity
* objective
* authorized read scope
* authorized write scope
* allowed tools/capabilities
* required evidence
* verification requirements
* success criteria
* ambiguity/blocking behavior
* execution constraints

The Task Contract is logical input, not proof of what actually happened.

---

## 15. Control Policy

Task intent and machine policy must remain separate.

Control Policy should represent authoritative constraints such as:

* filesystem access
* external-directory access
* network capability
* process/tool capability
* secret access
* write restrictions
* maximum execution boundaries
* trusted verifier rules
* runtime/environment requirements

The Task Contract says what is requested.

Control Policy says what is permitted.

---

## 16. Execution Envelope

Before an execution begins, Controller policy and the authorized task should be materialized into an immutable/frozen Execution Envelope.

Conceptual flow:

```text
Task Contract
+
Control Policy
+
resolved runtime configuration
+
frozen baseline
↓
Execution Envelope
```

The envelope should be the exact contract under which one execution occurred.

It should be hashable and immutable after launch.

This avoids a task changing meaning while the agent is running.

---

## 17. Runtime Ledger

Tendril needs an authoritative runtime ledger separate from agent-authored reports.

It should record observed execution truth such as:

* execution ID / Report Number
* envelope identity/hash
* start/end
* process/runtime IDs
* worktree
* model/provider/runtime
* tool events
* termination reason
* verifier result
* produced artifacts
* telemetry references

Agent reports can be projections into this broader execution record.

---

## 18. Independent Verifier

Verification performed by the implementation agent is advisory.

Final verification should be performed independently by trusted Controller/Verifier infrastructure after the agent process has finished.

Core distinction:

```text
agent says tests passed
≠
trusted verification observed tests passing
```

The verifier should operate against the produced candidate/worktree and generate irrefutable evidence.

---

## 19. SUCCEEDED ≠ VERIFIED

A formal task/execution lifecycle is missing.

At minimum the architecture needs to preserve distinctions such as:

```text
DRAFT
TRANSLATED
REVIEWED
AUTHORIZED
MATERIALIZED
RUNNING
SUCCEEDED / FAILED / BLOCKED
VERIFIED
ACCEPTED / REJECTED
CLOSED
```

Exact names remain to be finalized.

Critical invariant:

> `SUCCEEDED` is not the same thing as `VERIFIED`.

And:

> `VERIFIED` is not the same thing as human acceptance or project authority.

---

## 20. Candidate Change / Acceptance Boundary

An agent should produce a **candidate result**, not silently convert its work into accepted project state.

There must be a boundary between:

```text
candidate mutation
→ independent verification
→ human/controller acceptance
→ authoritative integration
```

This applies to code, documentation, schemas, architecture, and knowledge promotion.

---

## 21. Rollback and Abandonment

Execution architecture still needs explicit semantics for:

* aborted task
* failed task
* partially modified worktree
* rejected candidate
* timed-out agent
* crashed process
* verification failure
* human abandonment
* cleanup failure

A failed execution should preserve evidence without polluting authoritative state.

---

## 22. Frozen Baseline

Every execution should identify the exact baseline it worked from.

Relevant baseline identity may include:

* repository
* commit
* worktree
* authoritative documentation version
* policy version/hash
* Execution Envelope hash

This becomes especially important when multiple agents execute concurrently.

---

## 23. Staleness / Dirty Propagation

If a task or candidate depends on state that changes upstream, Tendril eventually needs explicit staleness semantics.

This is the same systems idea as Houdini dirty propagation:

```text
upstream authority changes
→ dependent result becomes stale
→ stale result cannot silently remain accepted as current
```

This should be designed rather than inferred ad hoc.

---

## 24. Stable Identity and Provenance

Stable identifiers are needed across:

* tasks
* executions
* reports
* envelopes
* worktrees
* artifacts
* decisions
* evidence
* nodes
* runs
* source material

Derived/copied objects must preserve provenance rather than becoming indistinguishable new objects.

---

## 25. Write Leases / Concurrent Mutation

Parallel agents eventually need a defined mechanism preventing overlapping uncontrolled writes.

Possible abstraction:

`write lease`

The exact implementation is open, but the required invariant is clear:

> Two ordinary agents must not unknowingly mutate the same authoritative resource concurrently.

Worktree isolation solves part of this problem but not all integration/resource conflicts.

---

## 26. Tool Identity

Capabilities should describe not just an abstract action but the actual tool/runtime authorized to perform it where relevant.

Tendril needs to distinguish things such as:

* shell capability
* filesystem read
* filesystem write
* Git integration
* network fetch
* provider API
* verifier
* database access

Tool identity must be observable rather than implicitly trusted.

---

## 27. Secrets as Capabilities

Secrets should not become ordinary files visible inside an agent workspace.

The eventual launcher should inject authorized secrets through the execution environment/capability boundary.

Requirements include:

* task-specific authorization
* minimal exposure
* no copying into worktrees
* no persistence in reports
* no accidental reasoning/log disclosure
* revocation/cleanup after execution

---

## 28. Structured Clarification

Ambiguity should not force an agent to invent missing requirements.

A structured `ClarificationRequest` concept is needed.

When an authorized task cannot safely materialize because information is genuinely missing, the execution path should produce a structured request to the human rather than improvising.

---

## 29. Discovery vs Execution

Tendril should distinguish:

* discovering possible work
* proposing work
* authorizing work
* executing work

An agent may discover:

`FOLLOW-UP CANDIDATE`

That does not authorize it.

This principle exists behaviorally in AGENTS.md, but the eventual Tendril data/API model still needs to represent the distinction explicitly.

---

# OPERATING-SYSTEM SECURITY

## 30. Real OS-Level Sandbox

Current OpenCode/OpenWork permission rules are application-level controls.

They are not the final security boundary.

Ordinary agents should eventually execute inside an OS-enforced environment preventing access outside their authorized project view.

Potential Linux mechanisms include:

* mount namespace
* bind mounts
* namespace isolation
* container/sandbox
* equivalent kernel-enforced filesystem boundary

The important requirement is structural isolation, not which mechanism is selected.

---

## 31. Project Perimeter

Ordinary agents should not be able to access arbitrary host directories simply because they know a path.

The final launcher should construct a finite visible filesystem such as conceptual mounts for:

* workspace
* approved knowledge
* approved inputs
* reports/output
* temporary execution storage

Host filesystem visibility should be deny-by-default.

---

## 32. Network Capability

Network access should eventually be a real capability, not merely a prompt instruction.

Tasks should be able to receive:

* no network
* specific provider access
* specific endpoint/domain access
* broader explicitly authorized network capability

The exact capability schema remains to be designed.

---

# GIT / WORKTREES / INTEGRATION

## 33. Agent Git Authority

Ordinary implementation agents should not own authoritative Git integration.

The preferred architecture is:

```text
agent modifies isolated candidate
→ trusted verification
→ human/controller decides acceptance
→ trusted integration mechanism stages/commits/merges
```

This avoids the implementation agent becoming both actor and authority.

---

## 34. Worktree Lifecycle

The real execution system needs explicit rules for:

* worktree creation
* baseline selection
* naming/identity
* task-to-worktree association
* cleanup
* preserved failed worktrees
* accepted work
* abandoned work
* concurrent execution
* integration

The `worktrees/` directories in the fresh rebuild are currently structure, not the complete lifecycle.

---

## 35. Git Integration Evidence

Trusted integration should preserve observable evidence including:

* baseline commit
* candidate diff
* verification result
* accepted files
* resulting commit
* human/controller approval
* provenance from execution to commit

The agent should not merely say "committed successfully."

---

## 36. Private Repository / Authorship / Licensing

The fresh Tendril repository still needs its durable Git/GitHub policy reconciled with the rebuild.

Previously established direction:

* Tendril remains private during development
* preserve authorship/provenance
* leave room for future licensing decisions
* authoritative repository history should be clean and durable
* corpus and stable/published workflow artifacts should live within a coherent versioned project boundary

Do not import the historical Baton repository structure blindly into the fresh rebuild.

---

# OPENWORK CONTROL PLANE

## 37. OpenWork Queue State Model

The intended OpenWork management model is still not fully materialized as Tendril project architecture.

Desired states:

```text
PLAN
READY
IN PROGRESS
REQUIRES ATTENTION
DONE
```

Human/Project Control owns task movement where authority matters.

Ordinary agents do not self-promote work.

---

## 38. Human Queue Authority

The human controls:

* which candidate becomes READY
* next task
* priority
* acceptance
* rework
* architectural decisions
* whether a follow-up candidate becomes real work

This currently exists as agent policy but should eventually become a real control-plane rule/state transition.

---

## 39. Project Control

A real Project Control capability/skill remains to be built.

It should manage OpenWork state without turning ordinary task agents into schedulers.

It should eventually handle:

* candidate task registration
* queue state
* readiness
* human attention
* completion evidence
* acceptance
* dependencies

---

## 40. Retire Manual `UP_NEXT`

`bootstrap/instructions/UP_NEXT.md` and the manual instruction log are temporary bootstrap mechanisms.

Once the OpenWork queue reliably controls task state and sequencing, these should stop acting as the live scheduler.

They may remain as provenance/history if useful.

---

## 41. Fresh Session Per Task

The successful bootstrap pattern should eventually become system behavior:

```text
one authorized task
→ one fresh execution/session
→ one bounded scope
→ one report
→ stop
```

Fresh sessions reduce context contamination and stale-policy carryover.

This should become a controller execution property rather than relying indefinitely on the human manually opening fresh sessions.

---

## 42. OpenWork Context Contamination Isolation

The user previously observed context contamination between OpenWork projects.

Tendril should not depend on informal UI behavior to prevent this.

Workspace/run identity, execution context, project root, policy, and session association should eventually be explicitly materialized and validated.

---

## 43. OpenWork/OpenCode Boundary

Current arrangement:

```text
OpenWork
→ orchestrates workspace/task UI
→ OpenCode performs model/tool execution
```

Reasoning telemetry was found in OpenCode rather than OpenWork's worker API.

This boundary should be documented so future harness work taps the correct source instead of treating OpenWork as the low-level runtime event authority.

---

# ONTOLOGICAL AGENT COMPILER / PROMPT SCRIBE

## 44. OAC Purpose

The Ontological Agent Compiler / Prompt Scribe remains a planned component rather than finished accepted architecture.

Its purpose is to translate broad human intent into candidate discrete work.

Conceptually:

```text
compound human request
→ analyze requirements
→ candidate bounded tasks
→ dependencies
→ scopes
→ completion conditions
→ ambiguities
→ human review
```

---

## 45. OAC Does Not Authorize Work

The compiler must not:

* authorize tasks
* execute tasks
* resolve architecture on behalf of the human
* promote candidate work
* self-sequence
* silently resolve genuine ambiguity

Its output is a candidate plan.

Human/Project Control remains authoritative.

---

## 46. OAC Output Contract

A formal compiler output schema is missing.

It should eventually represent at least:

* candidate task ID
* objective
* dependency relationships
* authorized-scope proposal
* expected artifacts
* done/verification conditions
* ambiguity list
* unresolved authority questions
* rationale/provenance back to source request

---

## 47. Compiler Versioning

Task translation should itself have provenance.

If compiler behavior changes, Tendril should be able to identify which compiler/policy version produced a candidate task decomposition.

Otherwise changes in the compiler can silently change project behavior.

---

## 48. Lazy Ontology Bootstrap

Do not require a perfect complete ontology before useful work can begin.

The emerging direction is a small stable kernel with ontology/contracts expanded as real workflow requires them.

Avoid building an enormous speculative schema before observed tasks justify it.

---

# DOCUMENTATION INGESTION AND REVIEW

## 49. Handover Extraction Standard

A draft handover-extraction standard exists under proposed documentation, but it has not yet been fully cleaned, accepted, and promoted.

Its purpose is to extract structured candidate knowledge from one source handover without granting that source authority.

It should remain separate from reconciliation.

---

## 50. Extraction Categories

The draft currently includes a canonical category set broadly covering:

* Decisions
* Architectural Invariants
* Behavioral / Operational Standards
* Logging / Reporting Standards
* Data and File Formats
* Naming Conventions
* Security / Permission Rules
* Implementation Requirements
* Plans / Candidate Tasks
* Terminology / Definitions
* Unresolved Questions
* Conflicts / Ambiguities
* Rejected / Superseded Ideas
* Proposed Documentation Changes
* Proposed Schema / Config / Code Changes
* Provenance

These need eventual review and acceptance rather than silently becoming ontology.

---

## 51. Extraction Metadata

Candidate extracted items currently use concepts such as:

`Source Strength`

* EXPLICIT
* INFERRED
* UNCERTAIN

and:

`Current State`

* UNKNOWN
* ALREADY REPRESENTED
* PARTIAL
* NEW
* CONFLICTING

The important rule is that a single-source extraction should normally leave project-current-state as UNKNOWN unless comparison against the project was explicitly authorized.

---

## 52. One Source → One Extraction

Extraction should operate on one source at a time.

It should preserve:

* provenance
* ambiguity
* contradictions
* uncertainty
* source specificity

It should not perform broad cross-document reconciliation during extraction.

---

## 53. Extraction Is Not Authority

An extraction:

* does not promote documentation
* does not resolve conflicts
* does not execute candidate tasks
* does not mutate `documentation/main`
* does not turn a source author's statement into Tendril authority

It is structured candidate material for later review.

---

## 54. Extraction Output Location

Planned extraction output:

`documentation/drafts/extractions/`

The current existence/readiness of this directory has not been confirmed.

It should not be assumed until explicitly created by an authorized task.

---

## 55. Known Extraction-Standard Defects

The current draft still needs cleanup before promotion.

Known issues include:

* repeated statements that the output remains draft
* duplicated per-item metadata requirements
* duplicated Source Section definition
* behavioral rules split ambiguously between Extraction Rules and Output Requirements
* provenance template wording that can make mandatory Source File provenance appear optional

These should be repaired in a bounded documentation task.

---

## 56. Full Documentation Integration Pipeline

The intended process is:

```text
RAW CHAT / HANDOVER
↓
verbatim source draft
↓
structured extraction
↓
cross-source / current-project reconciliation
↓
human adjudication
↓
materialization
```

Materialization may produce:

* accepted documentation
* decision records
* implementation plans
* candidate tasks
* schemas
* configuration
* tests
* code
* unresolved-question records

Each meaning-bearing transition should remain separately inspectable.

---

## 57. Reconciliation Stage

Reconciliation is distinct from extraction.

Its job is to compare candidate extracted material against:

* current accepted documentation
* other extractions
* newer decisions
* known conflicts
* implementation evidence

It should classify rather than silently resolve contradictions.

---

## 58. Human Adjudication

Meaning compression and authority promotion require a human boundary.

Models may assist with:

* extraction
* comparison
* grouping
* conflict detection
* candidate recommendations

They must not autonomously convert conflicting source material into accepted Tendril meaning.

---

## 59. Materialization as Separate Mutation

After human adjudication, each actual project mutation should still be a bounded task.

For example:

```text
human approves architecture ruling
↓
one task modifies owning architecture document
↓
independent verification
```

Do not let a reconciliation agent simultaneously rewrite the entire corpus.

---

# CORPUS / KNOWLEDGE ARCHITECTURE

## 60. Old Corpus Integration Into Fresh Rebuild

A substantial earlier Tendril/Baton corpus exists, including many `TENDRIL_CORPUS_UPDATE_*` files.

Those are not automatically current fresh-rebuild authority.

A serial integration process is still required:

```text
locate older material
→ classify authority/provenance
→ compare against fresh architecture
→ preserve useful decisions
→ reject obsolete implementation assumptions
→ human adjudicate conflicts
→ materialize into fresh owners
```

Older update files explicitly describe themselves as pending integration rather than canonical authority. 

---

## 61. Bible / Manifest Strategy

Older Tendril work used:

* `TENDRIL_BIBLE.md`
* `CORPUS_MANIFEST.json`
* artifact IDs
* hashes
* namespace ownership

The fresh rebuild has not yet established whether this exact structure is retained, simplified, or replaced.

This needs a deliberate decision rather than automatically importing the historical corpus machinery.

---

## 62. Projection Is Not Authority

A recurring Tendril invariant should survive the rebuild:

> A projection is not automatically canonical truth.

Examples:

* generated index
* search database
* SilverBullet index
* UI projection
* report summary
* derived graph
* reasoning analysis

Authoritative source state must remain reconstructable independently of disposable projections.

---

## 63. Additive History / Supersession

Meaning-bearing corrections should generally preserve history.

Prefer:

```text
old statement
→ superseded by
→ new accepted statement
```

over silently rewriting historical evidence as though the older state never existed.

Exact implementation remains to be designed.

---

## 64. Hash Domains

Hashes must state exactly what is being hashed.

Potential domains differ:

* source bytes
* normalized Git blob
* Execution Envelope
* artifact
* message packet
* corpus document
* report
* runtime evidence

Past launcher work demonstrated that working-copy bytes and canonical Git blob bytes can legitimately differ because of normalization.

Do not use an unspecified "hash" as universal identity.

---

# SILVERBULLET / LINUX / PERSISTENCE

## 65. SilverBullet Is Not Execution Authority

Accepted architectural invariant:

> Tendril must never require SilverBullet to reconstruct authoritative execution state.

SilverBullet is suitable as:

* corpus editor
* navigation surface
* index/query surface
* human-facing knowledge environment

It is not the authoritative Tendril execution database.

This ruling exists in older pending corpus material and needs integration into the fresh rebuild. 

---

## 66. Markdown + Git Corpus

Current direction is that corpus knowledge can remain durable Markdown tracked by Git.

SilverBullet indexes/views those files.

Its index should be rebuildable.

Do not conflate that with authoritative runtime/execution state.

---

## 67. Unresolved Corpus-Projection Fork

One important unresolved question remains:

> Are corpus Markdown files directly maintained canonical material, or generated projections from another authoritative store?

If directly maintained:

```text
Markdown + Git = corpus authority
SilverBullet = editor/index
```

If generated:

```text
authoritative store
→ generated Markdown projection
→ SilverBullet
```

Generated output would require read-only or round-trip editing semantics.

This must be resolved before introducing a needless projection pipeline.

---

## 68. Linux Native Filesystem

SilverBullet and corpus/path semantics make a native case-sensitive Linux filesystem the preferred canonical host.

Do not rely on `/mnt/c` or `/mnt/d` to magically remove NTFS semantics.

The fresh rebuild correctly lives under:

`/home/gabriel/project-tendril/`

This deployment choice should be documented as an implementation/environment decision.

---

# HEADLESS TENDRIL ARCHITECTURE

## 69. Tendril Must Be Functionally Headless

The complete functional operation of Tendril should theoretically work without a GUI.

The GUI is not part of executable meaning.

Older pending corpus material records this human ruling explicitly. 

This should be integrated into the fresh architecture.

---

## 70. Node Contracts Define Semantics

Node contracts should define:

* inputs
* outputs
* valid state
* execution requirements
* state transitions
* semantic behavior

The runtime should not depend on GUI-specific logic to determine what a node means.

---

## 71. Backend Is Authoritative

The backend/runtime owns durable and semantic state.

The frontend renders that state.

The frontend must not become an alternate semantic database.

---

## 72. Finite Frontend Surface

Frontend ownership should remain narrow and largely transient:

* viewport
* camera
* current selection
* panel layout
* drag state
* keyboard/mouse interaction
* visual preferences

It should not independently own:

* graph validity
* execution semantics
* durable topology
* provenance
* dependency resolution
* acceptance/publication semantics
* authoritative project state

---

## 73. GUI Action = Backend Command

Any meaning-bearing operation available from the GUI must be expressible as a backend command against the same contracts used by non-GUI clients.

No parallel GUI-only semantic path.

---

## 74. Replaceable Clients

The same runtime should eventually support clients such as:

* desktop GUI
* CLI
* browser interface
* automation
* agent client

All consume the same semantic backend.

---

## 75. Platform Split Is Not Ontology

A practical initial deployment can be:

```text
Windows
  frontend

        Tendril protocol

Linux / WSL
  backend
  runtime
  repository
  data
  tooling
```

But `Windows` and `Linux` must not become part of Tendril's conceptual ontology.

The architecture is the runtime/contracts/protocol boundary.

Older corpus material explicitly records this distinction. 

---

## 76. Transport Is Still Open

The headless ruling does **not** select the permanent transport.

Possible implementation technologies have not been canonically decided.

Do not prematurely freeze:

* HTTP
* WebSocket
* IPC
* gRPC
* another transport

The contract semantics come first.

---

## 77. Runtime Database Is Still Open

SilverBullet being rejected as execution authority does not automatically choose the runtime database.

SQLite has been discussed and is useful for local runtime state, but the fresh Tendril backend persistence schema still requires deliberate design.

---

# PRODUCT / GRAPH SEMANTICS

## 78. Version Zero Product Scope

The fresh rebuild still needs the actual Tendril product V0 specification materialized into accepted current files.

Previously settled V0 scope includes:

* local self-contained projects
* open/save/reopen
* single Prompt node
* one history input
* one output
* branching history edges
* node duplication with unique identity
* `derived_from` provenance
* selected-node inspector
* exact upstream context preview
* one OpenAI-compatible model call
* exact message packet persisted on immutable run record
* result persisted on Prompt node
* API key entry/storage/test/indicator

Do not expand V0 merely because later architecture concepts exist.

---

## 79. Upstream Run Selection

For a consuming node/history edge:

* select an upstream run
* default to latest successful when edge is created
* pin that run thereafter

This prevents downstream context silently changing because an upstream node executes again.

This needs to become explicit product/domain schema.

---

## 80. Operation Tag

Runs have an operation classification.

Previously settled V0 behavior:

* root Prompt defaults to `seed`
* executed Prompt run uses `solve`
* otherwise null where appropriate

Do not invent additional node classes merely to express this in V0.

---

## 81. Exact Message Packet

Every model execution should preserve the exact packet actually sent to the provider, including the exact resolved upstream context.

This is essential for:

* provenance
* reproducibility
* inspection
* debugging
* comparison
* later verification

A reconstructed prompt is not equivalent to the actual packet.

---

## 82. Context Preview

Before execution, the user should be able to inspect the exact context the node will receive.

This is a core Tendril feature, not debugging decoration.

---

## 83. Context Composer / Horse Blinkers

Human-controlled semantic distillation remains important.

The Human Context Composer concept exists to deliberately restrict/select what context enters downstream reasoning.

Core principle:

> Context should be selected deliberately, not dumped indiscriminately.

Automated model condensation must not silently become trusted project meaning.

---

## 84. Typed Channels

Longer-term Tendril graph edges/channels should carry meaning, not just arbitrary blobs.

Typed channels should preserve provenance to full evidence.

Acceptance semantics previously discussed include concepts such as:

* raw artifact
* published artifact
* authorized action

These require reconciliation before becoming frozen schemas.

---

## 85. Pull-Based Execution

The graph should behave conceptually like Houdini cooking:

```text
requested output
→ determine dependencies
→ resolve required upstream state
→ execute only what is needed
```

Effectful execution should remain explicit.

---

## 86. Topology as Logic

The visible network should communicate workflow logic.

Prefer composable visible nodes and edges over giant opaque orchestration nodes where practical.

Context routing, overrides, branching, and dependency structure should be inspectable directly in graph topology.

Older pending corpus updates contain this direction and should be reconciled into the fresh rebuild rather than assumed current. 

---

## 87. Graph-Native Foyer

A longer-term direction is that Tendril's own opening/control surfaces become projections of Tendril rather than an unrelated administrative shell.

Potential graph-native projections include:

* Projects
* Needs You
* System
* Corpus
* Models
* Runtime
* Packages
* Git
* review
* settings

Keep the irreducible native bootstrap kernel small.

This is post-foundational architecture, not something to implement before V0.

---

# CHAT / KNOWLEDGE COMPRESSION

## 88. Chat Compression Contract

Raw chat is useful source material but should not itself be treated as durable project memory.

Compression should produce two things:

1. stable decisions/information
2. a compressed narrative thread that references the stable material

Raw chat may then remain provenance/archive rather than the active knowledge surface.

---

## 89. Human Semantic Promotion Boundary

Models can assist with compression and extraction.

They must not silently decide what compressed meaning becomes trusted project knowledge.

Meaning-changing compression requires human acceptance.

---

# PROVIDER / MODEL ARCHITECTURE

## 90. Provider Flexibility

Tendril must not become coupled to one model provider.

The architecture should support replaceable model backends behind stable execution/node contracts.

Current working stack is operational convenience, not product ontology.

---

## 91. Current Operational Model Routing

Current working practice, if an operational policy is wanted:

* DeepSeek Flash for cheap bounded implementation
* DeepSeek Pro for harder/architecture-sensitive bounded work
* GLM for planning/review
* GPT for main architecture/build dialogue

This is mutable operational policy and should not be embedded as Tendril architecture.

---

# HISTORICAL MATERIAL / MIGRATION

## 92. Baton Is Evidence, Not Fresh Authority

The previous Baton/Tendril repository contains substantial implementation, tests, branches, worktrees, reports, and architecture archaeology.

The fresh rebuild exists specifically so that historical implementation complexity does not automatically dictate the new architecture.

Historical material should be treated as:

* evidence
* design history
* implementation archaeology
* reusable code candidate

not automatic current authority.

---

## 93. Historical Launcher Boundary

Older launcher work established that its verified package assumed its package root and Git verification root were the same.

A failed nested integration demonstrated that embedding it inside another repository was not just a filesystem copy.

Historical decision:

> Keep that launcher standalone unless relocatable package-root semantics are deliberately implemented.

This is useful architecture evidence, but whether that exact old launcher is reused in the fresh rebuild remains a separate decision. 

---

## 94. Repository Archaeology Workflow

Older Tendril work developed a strong scan approach:

```text
S0 census
→ frozen baseline
→ parallel structural scans
→ convergence
→ gap assessment
→ targeted semantic archaeology
→ convergence
→ readiness audit
```

The useful general principle is:

> Fan out independent cognition from a common frozen state; converge before dependent cognition.

This exists as older pending corpus material. 

It should be retained as a future repository/corpus archaeology protocol if still useful, not copied wholesale into the foundational runtime.

---

# CURRENT REPORTING / POLICY DEFECTS STILL TO RESOLVE

## 95. Agent Self-Diagnostics Are Not Trustworthy

The reporting standard should eventually stop asking the agent to assert things such as:

* no loops
* no repeated checks
* no decision revisions

unless these are clearly labelled agent observations rather than telemetry facts.

Harness analysis should own these fields.

---

## 96. `Reasoning Capture` Semantics

The meaning of:

* PRESENT
* PARTIAL
* UNAVAILABLE

needs to be defined from the perspective of the runtime/harness.

An agent saying `UNAVAILABLE` merely because it cannot see its own trace is different from the runtime actually failing to capture reasoning.

These concepts should be separated.

Possible distinction:

```text
Agent Reasoning Visibility
Harness Reasoning Capture
```

Do not finalize names without a bounded design task.

---

## 97. Reasoning Diagnostics Placement

Decide whether reasoning diagnostics belong:

* inside the main agent task report
* in a harness-generated companion telemetry file
* or as a harness-authored section appended after execution

Current evidence strongly favors harness ownership.

---

## 98. Timing Rule Consolidation

The reporting standard has accumulated timing rules through several iterative edits.

A later cleanup should reconcile duplicate/overlapping instructions covering:

* execution timing
* timing integrity
* live lifecycle
* phase timestamps
* terminal finalization

Do not change behavior while cleaning wording.

---

## 99. Telemetry Failure Classification

If timing/reasoning/runtime telemetry is missing, there should be a defined way to classify that condition.

At present, "telemetry failure" is conceptually required but not fully mapped to a single canonical issue/status representation.

This needs a small reconciliation task.

---

## 100. Fresh Timestamp Per Execution-Log Entry

A previous Flash execution gave every verification phase the same timestamp despite the run lasting substantially longer.

The standard should eventually make it unambiguous that a phase timestamp is either:

* freshly observed when the event is logged, or
* supplied by trusted harness telemetry

It must not be retrospectively copied across multiple phases.

---

# IMMEDIATE IMPLEMENTATION BOUNDARY

## 101. Bootstrap Must Not Become Shadow Tendril

The bootstrap system has now proven useful:

* one bounded task
* one fresh session
* one report
* human sequencing
* simple policy
* observable result

Do not keep adding orchestration features indefinitely to bootstrap.

Once the minimum trusted execution loop exists, move those capabilities into the real Tendril Controller/Launcher/runtime architecture.

---

## 102. No More Experiments as the Primary Mode

The current phase is building the real Tendril workflow.

Small verification tasks remain appropriate to validate each newly built mechanism, but they should serve implementation rather than become an endless experimental branch.

The foundational pattern is already proven.

---

# UNRESOLVED HIGH-LEVEL QUESTIONS

## 103. Exact Controller Implementation

Not yet frozen:

* language
* process topology
* daemon vs invoked controller
* persistence interface
* Controller API

Define semantics before implementation details.

---

## 104. Exact Sandbox Technology

Not yet frozen.

Requirement is strong isolation; implementation mechanism remains open.

---

## 105. Exact Runtime Persistence Schema

Not yet frozen.

Needs to support authoritative execution state independently of SilverBullet.

---

## 106. Corpus Markdown Authority Model

Still unresolved:

* directly maintained canonical Markdown
* generated Markdown projection
* hybrid with explicit ownership

Do not create a projection build pipeline until this decision is actually required and adjudicated.

---

## 107. Permanent Transport

Headless frontend/backend protocol semantics are accepted direction.

Permanent transport is still open.

---

## 108. Durable Entity Set

Older Tendril material contains richer durable entities such as:

* ProjectSpace
* ArchitectureVersion
* Performance
* ArchitectureChangeProposal
* HumanArchitectureDecision

Some are strongly grounded in historical architecture, but the fresh rebuild should verify each before freezing an exact entity count or schema.

Do not let old vocabulary create new obligations merely because it exists.

The older Bible itself records unresolved questions around exact durable entity claims. 

---

# COMPACT PRIORITY SUMMARY

The most important missing layers are:

**A. Harness**

* capture real reasoning/runtime events
* timestamp them
* correlate them with Report Number
* analyze the agent independently

**B. Controller**

* authorize
* materialize
* observe
* verify
* finalize

**C. Launcher**

* create real OS isolation
* expose bounded capabilities
* launch the untrusted agent

**D. Contracts**

* Task Contract
* Control Policy
* Execution Envelope
* Runtime Ledger
* Clarification Request
* Verification Result

**E. OpenWork control plane**

* real PLAN/READY/IN PROGRESS/REQUIRES ATTENTION/DONE state
* human sequencing
* Project Control
* fresh execution/session per task

**F. OAC / Prompt Scribe**

* compound intent → candidate bounded tasks
* no authority
* human approval before execution

**G. Documentation compiler workflow**

* source → extraction → reconciliation → human adjudication → materialization

**H. Fresh Tendril product architecture**

* V0 domain schema
* Prompt node
* runs
* exact message packets
* pinned upstream runs
* save/reopen
* context inspection
* provider abstraction

**I. Headless architecture**

* node contracts define semantics
* backend authoritative
* frontend replaceable
* Linux/Windows split remains implementation detail

**J. Corpus integration**

* reconcile useful older Tendril rulings into the fresh rebuild
* do not import historical implementation authority wholesale

---

# Handover Rule

For every topic in this document:

> First determine whether an accepted/current owner already exists under `/home/gabriel/project-tendril/documentation/main/` or another explicitly authoritative current file.

If yes:

> reconcile into that owner rather than creating parallel authority.

If no:

> create a proposed document beneath `documentation/drafts/proposed-main/` or another explicitly authorized draft location.

Do not promote draft material to `documentation/main/` without explicit human authorization.

Do not turn this handover itself into architecture authority merely by copying it into the project.

The next goal is not to document everything at once. It is to **preserve all missing material so it can be integrated one bounded topic at a time without losing the architecture developed in the conversations.**
