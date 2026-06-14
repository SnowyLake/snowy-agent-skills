# Review Command

## Table of Contents

- [Session Folder Resolution](#session-folder-resolution)
- [Access Mode](#access-mode)
- [Workflow](#workflow)
- [Output Style](#output-style)

This reference covers the `review` command only. Apply it together with the `Global Invariants` in `SKILL.md`. Read `file-contracts.md` before writing or validating `REVIEW.md` or interpreting `CONTEXT.md`, `HISTORY.md`, and `Work Artifacts`.

## Session Folder Resolution

Resolve the reviewed session folder:

1. If the user does not specify a session folder, resolve the current session folder as the reviewed session folder.
2. If the user specifies a session folder, use it as the reviewed session folder.
3. If the current session folder is unclear and no path was specified, ask the user to specify an existing session folder.
4. Do not create a reviewed session folder.
5. Do not treat no-path review as relying on current conversation memory. The review target is still the checkpoint-guided actual work in the reviewed session folder.

## Access Mode

- May read checkpoint files in the reviewed session folder and related project files.
- May write only `REVIEW.md` in the reviewed session folder. This is the single allowed write exception for `review`.
- Must not modify reviewed `CONTEXT.md`, reviewed `HISTORY.md`, other reviewed-session-folder artifacts, or project files unless the user explicitly asks for follow-up work.
- Overwrites an existing `REVIEW.md` in the reviewed session folder with the latest review result.
- Always outputs the review result and writes it to `REVIEW.md`.
- Treat checkpoint files as the review brief and navigation index. Do not make checkpoint-file quality the primary review target unless the user explicitly asks to review the checkpoint files themselves.

## Workflow

1. Resolve the reviewed session folder.
2. Verify that the reviewed session folder exists.
3. Verify that the reviewed session folder contains `CONTEXT.md`.
4. If reviewed session validation fails, stop and report the issue. Do not create checkpoint files, create target folders, write `REVIEW.md`, modify project files, or search other folders.
5. Read reviewed `CONTEXT.md`.
6. Read reviewed `HISTORY.md` when available.
7. If `HISTORY.md` is missing, continue review and state that historical context is limited.
8. Use `CONTEXT.md` to understand the goal, current state, decisions, constraints, risks, open questions, TODO, next actions, relevant files, and work artifacts.
9. Build the review scope from `Current Goal`, `Work Artifacts`, `Relevant Files`, `TODO`, `Next Actions`, and any reviewed-session-folder artifacts.
10. Read the actual referenced project files, generated artifacts, diffs, tests, or configuration that represent the session's work before producing findings.
11. Review whether the actual work completed `Current Goal`.
12. Review the actual work content for defects, edge cases, missing validation, conflicts, or inconsistencies.
13. Do not list ordinary checkpoint-file quality issues as `Findings`. Put checkpoint clarity, freshness, missing sections, or internal checkpoint consistency issues under `Checkpoint Quality` unless they directly prevent assessing goal completion or hide the work scope.
14. Review `CONTEXT.md` and `HISTORY.md` as primary work artifacts only when the user's requested review target or the reviewed session's `Current Goal` was specifically to create or update checkpoint files.
15. Do not restore session context as the active working context.
16. Write the review result to `REVIEW.md` in the reviewed session folder, overwriting any existing `REVIEW.md`, and also output it in the response.

## Output Style

Write the result to `REVIEW.md` in the reviewed session folder and output the same result in the response. Use these sections in both:

```md
## Goal Completion

## Findings

## Checkpoint Quality

## Open Questions

## Summary
```

Review section intent:

- `Goal Completion`: State whether `Current Goal` is `Completed`, `Partially Completed`, `Not Completed`, or `Unclear`, and briefly explain the evidence.
- `Findings`: List concrete issues in the actual reviewed work, ordered by severity. Include implementation defects, logic gaps, edge cases, behavior risks, missing validation, project-file conflicts, or inconsistencies in files created, modified, deleted, moved, or otherwise referenced by the reviewed session. For each finding, include severity, evidence, impact, and a recommended fix. If no concrete work issues are found after inspecting the relevant files, say so explicitly.
- `Checkpoint Quality`: Assess whether `CONTEXT.md` and optional `HISTORY.md` are reliable enough for future restore, handoff, or review. Include whether `Work Artifacts` points to the relevant work scope. Put checkpoint-only issues here unless they directly block assessment of the actual work.
- `Open Questions`: List questions that cannot be answered from checkpoint files and current project files.
- `Summary`: Provide a concise actionable conclusion.

`REVIEW.md` additionally records `Reviewed Session` and `Review Date` headers before these sections, as defined in `file-contracts.md`.
