# Ready-to-Execute Frontend State Integrity Prompt

Use DeepSeek V4 Flash in a new OpenWork session or execution context. Paste the following prompt exactly.

```text
Task:
execute-plan-frontend-state-integrity-fixes

Objective:
Implement the bounded plan at `documentation/drafts/plans/frontend-state-integrity-fixes-plan.md` exactly, verify the result, and create the authorized commit without pushing.

Plan Alignment:
Manifest: documentation/main/PROJECT_BUILD_MANIFEST.md
Plan Phase: P10
Plan Item: Frontend State Integrity Fixes
Plan Alignment: ALIGNED

Scope:
Read:
- documentation/drafts/plans/frontend-state-integrity-fixes-plan.md
- product/tendril/gui/main.gd

Modify/Create exactly:
- product/tendril/gui/main.gd

Execute:
- Perform all eight scenarios in the plan's `Implementation Verification` section.
- git diff --check -- product/tendril/gui/main.gd
- git diff -- product/tendril/gui/main.gd
- git add -- product/tendril/gui/main.gd
- git commit -m "Implement frontend state integrity fixes"

Do not:
- Modify files outside the exact authorized scope.
- Create temporary verification files or directories.
- Invent code or behavior not present in the plan.
- Substitute a different implementation design.
- Refactor, fix, or reformat adjacent code.
- Stage or commit unrelated worktree changes.
- Push to GitHub.

Instructions:
1. Initialize a new task report per current policy before substantive work.
2. Read `documentation/main/PROJECT_BUILD_MANIFEST.md`, confirm Plan Phase, Plan Item, and Plan Alignment, and record them in the report.
3. Read `documentation/drafts/plans/frontend-state-integrity-fixes-plan.md` completely.
4. Read `product/tendril/gui/main.gd` and confirm the plan's snippets and insertion points still match.
5. Apply the exact snippets from the plan in the prescribed order to `product/tendril/gui/main.gd` only.
6. Do not invent missing code. If a snippet cannot be applied exactly and safely, if the plan requires logic without supplying exact code, or if the current file already contains the planned implementation, report `BLOCKED`, state the conflict and minimum required decision, and stop without improvising or creating a duplicate commit.
7. Run every verification step from the plan. Record only observed results. Do not claim an interactive Godot scenario passed unless it was actually performed.
8. Verify all of the following plan scenarios:
   - Force a text PATCH failure; confirm the TextEdit returns to the confirmed cache value and an error dialog appears.
   - Send two text, file-path, position, and edge-toggle operations in rapid succession; delay the first response and confirm it cannot overwrite the later confirmed result.
   - Start two workspace fetches; complete the older one last and confirm it is ignored.
   - Cook two nodes before either monitor request completes; confirm each monitor is positioned and connected to its own source.
   - Trigger a workspace refresh while a TextEdit is focused; confirm teardown sends no PATCH.
   - Add an input and edit the template rapidly; confirm both accepted updates survive in the backend workspace response.
   - Rebuild the workspace repeatedly; confirm one handler invocation per user action and no duplicate signal connections.
   - Fork text, file, and composite nodes; confirm the UI displays only backend-provided state and creates no invalid dataflow noodle.
9. Execute `git diff --check -- product/tendril/gui/main.gd` and require exit status 0.
10. Inspect `git status` and `git diff -- product/tendril/gui/main.gd`. Confirm only `product/tendril/gui/main.gd` contains intended task changes.
11. Execute `git add -- product/tendril/gui/main.gd`.
12. Execute `git commit -m "Implement frontend state integrity fixes"`.
13. Verify `git log --oneline -1` shows the new commit and inspect its file list to confirm it contains only `product/tendril/gui/main.gd`.
14. Do not push to GitHub.
15. Report `PASS`, `PARTIAL`, `BLOCKED`, or `FAIL`, then stop.

Verification:
1. A new execution report was initialized for this task.
2. Every implementation and verification step in `documentation/drafts/plans/frontend-state-integrity-fixes-plan.md` was executed or explicitly reported incomplete.
3. `git diff --check -- product/tendril/gui/main.gd` exited successfully.
4. No file outside `product/tendril/gui/main.gd` was modified by this execution.
5. The requested commit exists and contains only `product/tendril/gui/main.gd`.
6. No push was performed.
```
