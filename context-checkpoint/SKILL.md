---
name: context-checkpoint
description: Create, update, or restore session checkpoint files from the current conversation context. Use when the user explicitly asks to update checkpoint files, create handoff context, prepare context before compaction, write CONTEXT.md and HISTORY.md, restore from an existing checkpoint, continue a prior session from checkpoint files, or rebuild task state from CONTEXT.md / HISTORY.md. Also use update automatically when the system is about to compact context, but do not trigger only because the user typed /compact unless they explicitly request checkpoint generation first.
---

# Context Checkpoint

## Table of Contents

- [Overview](#overview)
- [Command Selection](#command-selection)
- [Session Folder Resolution](#session-folder-resolution)
- [Update Workflow](#update-workflow)
- [Restore Workflow](#restore-workflow)
- [File Contracts](#file-contracts)
- [Output Style](#output-style)

## Overview

Provide exactly two capabilities:

- `update`: Create or refresh the current session checkpoint in `CONTEXT.md` and `HISTORY.md`.
- `restore`: Rebuild the current task state from existing checkpoint files.

Keep this skill narrow. Do not manage project wikis, create unrelated documents, or add broader session-management commands.

## Command Selection

Use `update` when:

- The user explicitly asks to generate, update, or refresh checkpoint files.
- The user asks for handoff context, cross-session continuation files, or pre-compaction context cleanup.
- The user asks to organize the current session into `CONTEXT.md` and `HISTORY.md`.
- The system is about to perform automatic context compaction.

Do not use `update` merely because the user manually invokes `/compact`. Use it only when the user explicitly asks to generate a checkpoint before compaction.

Use `restore` when:

- The user asks to continue a previous session from checkpoint files.
- The user asks to read the current session checkpoint.
- The user asks to rebuild task state from `CONTEXT.md` and `HISTORY.md`.
- A new session needs to take over from an existing checkpoint.

## Session Folder Resolution

Store checkpoint files under the project root:

```text
.agent-sessions/{YYYYMMDD}-{short-kebab-case-session-summary}/
```

Before creating a folder:

1. Determine whether the current conversation already has a session folder.
2. If a matching folder exists, reuse it.
3. If the current folder is unclear, inspect `.agent-sessions/` for a folder matching the current task goal or conversation topic.
4. Create a new folder only when no suitable existing folder can be identified.

Use lowercase kebab-case for the summary segment. Prefer concise task names.

## Update Workflow

When running `update`:

1. Resolve the current session folder.
2. Read existing `CONTEXT.md` and `HISTORY.md` if present.
3. Compare checkpoint content with the current conversation state and project files. Prefer current project files when they conflict with checkpoint documents.
4. Rewrite `CONTEXT.md` as a clean current-state snapshot. Do not mechanically append history.
5. Append one new entry to `HISTORY.md`. Do not merge new history into old entries.
6. Preserve useful existing history. Do not delete old entries unless the user explicitly requests cleanup.
7. Move stale process notes, rejected approaches, superseded assumptions, and decision rationale out of `CONTEXT.md` and into the new `HISTORY.md` entry when still useful.

`update` must create or update both files:

```text
CONTEXT.md
HISTORY.md
```

## Restore Workflow

When running `restore`:

1. Resolve the current session folder.
2. Read `CONTEXT.md` first when available.
3. Read `HISTORY.md` only when needed to understand decision background, troubleshooting rationale, rejected approaches, or historical uncertainty.
4. If only `CONTEXT.md` exists, restore from it.
5. If only `HISTORY.md` exists, reconstruct as much background as possible and state that the current-state snapshot is missing.
6. If neither file exists, state that no usable checkpoint files were found in the session folder.
7. Do not treat old history as current state.
8. Do not treat unverified assumptions as facts.
9. If `HISTORY.md` conflicts with `CONTEXT.md`, prefer `CONTEXT.md` for current state.
10. If checkpoint files conflict with current project files, prefer current project files.

Do not modify checkpoint files during `restore` unless the user explicitly asks to update them too.

## File Contracts

`CONTEXT.md` stores only current, still-valid information that affects future work. Use this structure:

```md
# CONTEXT.md

## Current Goal

## Current State

## Confirmed Decisions

## Active Constraints

## Relevant Files

## TODO

## Open Questions

## Known Risks

## Next Actions
```

Section intent:

- `Current Goal`: The current objective.
- `Current State`: The current implementation or task state.
- `Confirmed Decisions`: Decisions that remain valid.
- `Active Constraints`: Constraints future work must still obey.
- `Relevant Files`: Files, folders, or resources directly related to the task.
- `TODO`: Valid remaining task pool.
- `Open Questions`: Questions needing discussion, research, or validation.
- `Known Risks`: Known risks, pitfalls, or caveats.
- `Next Actions`: The top 1-3 concrete actions to take next, distilled from `TODO`.

`HISTORY.md` stores historical summaries, troubleshooting records, rejected or deferred approaches, and reasoning archives. Use a multi-entry structure:

```md
# HISTORY.md

## {YYYY-MM-DD} - {entry-title}

### Summary

### Important Findings

### Decisions

### Rejected / Deferred Approaches

### Assumptions

### Notes
```

For each new history entry:

- Use the actual entry date in `YYYY-MM-DD` format.
- Use a short descriptive entry title.
- Add one new level-two entry. Do not use repeated `Entry Date` or `Entry Title` headings.
- Mark rejected and deferred items explicitly, for example `[Rejected]` or `[Deferred]`.
- Mark assumptions explicitly, for example `[Verified]` or `[Unverified]`.

## Output Style

For `update`, keep the user-facing response brief. Mention the session folder and the files updated.

For `restore`, summarize the rebuilt task state instead of repeating all of `HISTORY.md`. Include:

- Current goal
- Current state
- Confirmed decisions
- Active constraints
- Relevant files
- TODO
- Open questions
- Known risks
- Next actions

Respect project-level formatting instructions for generated markdown when they do not conflict with the file contracts above.
