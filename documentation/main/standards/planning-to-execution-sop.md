# Planning-to-Execution Standard Operating Procedure

Status: CURRENT

## Purpose

This SOP defines the human-governed handoff from a bounded implementation plan to its execution. It applies the Track A operating doctrine: one atomic task, no scope creep, observable verification, and mechanical silence for deterministic lookups and prescribed actions.

The plan is an execution instruction, not authority to bypass the current human task, `AGENTS.md`, the Primary Build Manifest, or accepted project contracts. If the plan conflicts with current authority or current code, the active model stops and reports `BLOCKED` rather than improvising.

## Phase 1: Planning (GPT-Sol Pro High)

The Planner performs one reported planning execution.

1. Initialize a new task report under current policy.
2. Read `documentation/main/PROJECT_BUILD_MANIFEST.md` and record Plan Phase, Plan Item, and Plan Alignment.
3. Read the authorized audits and existing plans needed to identify unresolved work without duplicating it.
4. Select exactly one bounded task:
   - a Critical or High unresolved audit finding, or
   - the next feature in the manifest's Current Focus.
5. Read the relevant current code before prescribing changes.
6. Write one plan at `documentation/drafts/plans/<plan-name>.md`.
7. Include:
   - Objective
   - exact files to modify
   - exact, copy-paste-ready GDScript or Python snippets
   - no pseudocode
   - ordered implementation steps
   - exact verification commands and expected outcomes
   - the required Git commit message when one is authorized
8. Verify that the plan is internally consistent, bounded, and does not duplicate completed work.
9. Commit only the authorized plan artifacts when the task requires a commit.
10. Stop without implementing the plan.

The Planner must not broaden the selected task to include adjacent fixes. Discovered adjacent work is a follow-up candidate for human consideration.

## The Handoff

The human owns the transition from planning to implementation.

1. Review the committed plan and decide whether it is authorized for execution.
2. Start a new OpenWork session or execution context.
3. Select DeepSeek V4 Flash as the Executor model.
4. Fill in `documentation/drafts/plans/executor-prompt-template.md` with the exact plan path, scope, verification, and commit message.
5. Issue the completed prompt as a new task.

The Executor receives a new task identity, Report Number, task report, and authorization envelope. It must not reuse the Planner's execution or report. A committed plan is not self-authorizing; the human explicitly starts and scopes the implementation execution.

## Phase 2: Implementation (DeepSeek V4 Flash)

The Executor performs one reported mutation execution.

1. Initialize a new task report under current policy.
2. Read the Primary Build Manifest and confirm the task's Plan Alignment.
3. Read the specified plan completely.
4. Read every current code file that the plan authorizes for modification.
5. Confirm that the plan's snippets and insertion points match the current implementation.
6. Apply the exact snippets from the plan in the prescribed order.
7. Do not invent code, expand scope, refactor adjacent code, or substitute an alternative design not present in the plan.
8. If an exact snippet cannot be applied safely because the current code or authority differs, stop and report `BLOCKED` with the minimum required human or Planner decision.
9. Run every verification step in the plan and record observed results. Do not claim checks that were not run.
10. Inspect the final diff and confirm that only authorized files changed.
11. Stage only authorized implementation artifacts and commit with the specified message.
12. Do not push to GitHub.
13. Finalize the task report with `PASS`, `PARTIAL`, `BLOCKED`, or `FAIL`, then stop.

## Operating Constraints

### Atomicity

One plan produces one bounded implementation execution and one intended commit. The Executor does not begin another task after reaching a terminal result.

### No Scope Creep

Only files and changes explicitly authorized by the current task and plan may be modified. Unrelated existing worktree changes remain untouched and uncommitted. Newly discovered defects are reported as follow-up candidates only.

### Mechanical Silence

Deterministic lookups, exact snippet application, prescribed commands, and routine verification are performed without unnecessary narration. Reasoning is reserved for genuine ambiguity, conflict, failure, or a required decision.

### Evidence

Completion requires observable evidence: the intended diff, verification output, and the requested commit. Agent claims do not replace test or command results.

## Terminal Outcomes

- `PASS`: The exact bounded plan was implemented, all required verification passed, and the authorized commit exists.
- `PARTIAL`: Authorized work was completed, but one or more required outcomes remain incomplete.
- `BLOCKED`: Authority, plan applicability, dependency, or required capability prevented safe completion.
- `FAIL`: Execution was attempted but did not produce the required result.
