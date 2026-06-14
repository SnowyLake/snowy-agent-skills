# Restore Command

## Table of Contents

- [Session Folder Resolution](#session-folder-resolution)
- [Access Mode](#access-mode)
- [Workflow](#workflow)
- [Output Style](#output-style)

This reference covers the `restore` command only. Apply it together with the `Global Invariants` in `SKILL.md`. Read `file-contracts.md` before interpreting or summarizing `CONTEXT.md`, `HISTORY.md`, `REVIEW.md`, or `Work Artifacts`.

## Session Folder Resolution

Resolve the restore source session folder:

1. If the user does not specify a session folder, resolve the current session folder.
2. If the user specifies a session folder, use it as the restore source.
3. If the user specifies a different session folder and the current conversation already has checkpoint files in its own session folder, stop and report the conflict. Do not read, merge, copy, or modify either checkpoint.
4. If the specified session folder is the current session folder, allow restore.
5. If the current folder is unclear and no path was specified, ask the user to specify an existing session folder.
6. Do not create a new session folder for `restore`.

## Access Mode

- Read-only.
- May read checkpoint files in the restore source session folder and related project files.
- May read `REVIEW.md` in the restore source session folder when present, and surface its findings as open issues to re-verify.
- Must not copy checkpoint files, write the current session folder, or modify project files unless the user explicitly asks for follow-up work.

## Workflow

1. Resolve the restore source session folder.
2. If the user specified a different source session folder and the current conversation already has checkpoint files in its own session folder, stop and report the conflict.
3. Read `CONTEXT.md` first when available.
4. Read `HISTORY.md` only when needed to understand decision background, troubleshooting rationale, rejected approaches, or historical uncertainty.
5. Read `Work Artifacts` to quickly understand the prior work scope.
6. Read `REVIEW.md` when present in the restore source session folder. Surface its findings as open issues to re-verify, and state that they reflect the work state at review time and must be re-checked against current project files.
7. If only `CONTEXT.md` exists, restore from it.
8. If only `HISTORY.md` exists, reconstruct as much background as possible and state that the current-state snapshot is missing.
9. If neither file exists, state that no usable checkpoint files were found in the session folder.
10. Do not treat old history as current state.
11. Do not treat unverified assumptions as facts.
12. If `HISTORY.md` conflicts with `CONTEXT.md`, prefer `CONTEXT.md` for current state.
13. When restored state is incomplete, inferred, or affected by conflicts, state where the information came from and how confident the reconstruction is.

Do not modify checkpoint files during `restore` unless the user explicitly asks to update them too.

## Output Style

Summarize the rebuilt session state instead of repeating all of `HISTORY.md`. Include:

- Current goal
- Current state
- Confirmed decisions
- Active constraints
- Known risks
- Open questions
- TODO
- Next actions
- Relevant files
- Work artifacts
- Source and confidence notes for reconstructed state
- When the source session folder contains `REVIEW.md`, list its findings as open issues to re-verify against current project files, and note that they reflect the work state at review time.
