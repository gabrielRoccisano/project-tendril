# Executor Prompt Template

Replace every angle-bracket placeholder before issuing this prompt. Use DeepSeek V4 Flash in a new OpenWork session or execution context.

```text
Task:
<task-name>

Objective:
Implement the bounded plan at `documentation/drafts/plans/<plan-name>.md` exactly, verify the result, and create the authorized commit without pushing.

Plan Alignment:
Manifest: documentation/main/PROJECT_BUILD_MANIFEST.md
Plan Phase: <plan-phase>
Plan Item: <plan-item>
Plan Alignment: <ALIGNED-or-HUMAN_OVERRIDE>

Scope:
Read:
- documentation/drafts/plans/<plan-name>.md
- <current-code-file-1>
- <current-code-file-2>

Modify/Create exactly:
- <authorized-file-1>
- <authorized-file-2>

Execute:
- <verification-command-1>
- <verification-command-2>
- git add -- <authorized-file-1> <authorized-file-2>
- git commit -m "<commit-message>"

Do not:
- Modify files outside the exact authorized scope.
- Invent code or behavior not present in the plan.
- Substitute a different implementation design.
- Refactor, fix, or reformat adjacent code.
- Stage or commit unrelated worktree changes.
- Push to GitHub.

Instructions:
1. Initialize a new task report per current policy before substantive work.
2. Read `documentation/main/PROJECT_BUILD_MANIFEST.md`, confirm Plan Phase, Plan Item, and Plan Alignment, and record them in the report.
3. Read `documentation/drafts/plans/<plan-name>.md` completely.
4. Read the current code files listed in Scope and confirm the plan's snippets and insertion points still match.
5. Apply the exact snippets from the plan in the prescribed order.
6. Do not invent missing code. If a snippet cannot be applied exactly and safely because current code or authority differs, report `BLOCKED`, state the conflict and minimum required decision, and stop without improvising.
7. Run every verification step from the plan, including the commands listed above. Record only observed results.
8. Inspect `git status` and `git diff`. Confirm only the authorized files contain intended changes.
9. Execute `git add -- <authorized-file-1> <authorized-file-2>` with the complete authorized file list.
10. Execute `git commit -m "<commit-message>"`.
11. Verify `git log --oneline -1` shows the new commit and inspect its file list.
12. Do not push to GitHub.
13. Report `PASS`, `PARTIAL`, `BLOCKED`, or `FAIL`, then stop.

Verification:
1. A new execution report was initialized for this task.
2. Every implementation and verification step in `documentation/drafts/plans/<plan-name>.md` was executed or explicitly reported incomplete.
3. No file outside the authorized scope was modified by this execution.
4. The requested commit exists and contains only authorized files.
5. No push was performed.
```
