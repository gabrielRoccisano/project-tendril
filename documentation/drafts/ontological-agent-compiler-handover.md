 
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
