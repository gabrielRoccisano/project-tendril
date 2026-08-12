# Track A Operating Doctrine

> One task, one objective, one bounded scope, one minimal context, one observable result.

## Core Invariants

1. **Atomicity** — one instruction produces one bounded result. No compound work.
2. **Minimal Context** — supply only the context required for the specific result.
3. **Minimal Scope** — expose only the paths and capabilities required for the instruction.
4. **Explicit Completion** — every instruction states exactly how completion is determined.
5. **No Inference Expansion** — missing authority or information causes `BLOCKED`, not guessing.
6. **No Opportunistic Work** — newly discovered work becomes a `FOLLOW-UP CANDIDATE`; it is not performed.
7. **Fresh Evidence** — results are judged from observable evidence, not conversational memory.
8. **Instruction Preservation** — preserve the exact instruction before substantive execution begins.
9. **Human Sequencing** — the human decides the next instruction. The agent does not self-sequence.
10. **No Scope Expansion** — an execution cannot enlarge its own objective, context, paths, tools, effects, permissions, or output requirements.

## Fresh Execution Bootstrap

Every agent execution must begin from a fresh governing state.

1. The current agent policy must be loaded for every execution.
2. The current instruction must be loaded for every execution.
3. Previous session memory is never authority.
4. Any change to tools, permissions, policy, or instruction requires a fresh agent session before testing or execution.
5. If the current policy or instruction cannot be loaded unambiguously, execution must stop as `BLOCKED`.


## Track A Stopping Rule

Do not build a shadow Tendril inside Bootstrap.

Track A should stop expanding once this works reliably:

- one instruction;
- one agent;
- bounded scope;
- minimal context;
- observable actions;
- reviewable result;
- durable record;
- human-selected next instruction.

After that, effort moves primarily to Track B.


