# context-checkpoint

## Table of Contents

- [Overview](#overview)
- [Terminology](#terminology)
  - [Session Folder](#session-folder)
  - [Checkpoint Files](#checkpoint-files)
  - [Review File](#review-file)
- [Capabilities](#capabilities)
- [Usage Examples](#usage-examples)
- [Reference Workflows](#reference-workflows)
  - [Single Session](#single-session)
  - [Shared Session Collaboration](#shared-session-collaboration)
  - [Review Feedback Loop](#review-feedback-loop)
  - [Handoff or Branching](#handoff-or-branching)
  - [Restore Conflict Guard](#restore-conflict-guard)
- [Update](#update)
- [Restore](#restore)
- [Handoff](#handoff)
- [Review](#review)

Language: English | [中文](README.zh-CN.md)

## Overview

`context-checkpoint` is an agent-neutral context management skill for preserving, rebuilding, transferring, and reviewing session context across long-running or multi-session work.

The skill is organized around session folders and Markdown checkpoint files. A session folder is the context identity, while agents or conversations are interchangeable collaborators that read from or write to that context according to the command they run.

`SKILL.md` is a lightweight routing layer. Command details live in `references/update.md`, `references/restore.md`, `references/handoff.md`, and `references/review.md`. Shared file structures live in `references/file-contracts.md`.

## Terminology

### Session Folder

A session folder is the directory that stores one context line:

```text
.agent-sessions/{YYYYMMDD}-{short-kebab-case-session-summary}/
```

The skill avoids guessing when a session folder is unclear. It asks the user to specify an existing folder or confirm a new one according to the requested capability.

### Checkpoint Files

Checkpoint files rebuild session context:

- `CONTEXT.md`: Stores only current, still-valid information that affects future work, including the current goal, current state, confirmed decisions, active constraints, known risks, open questions, TODO, next actions, relevant files, and work artifacts.
- `HISTORY.md`: Stores historical summaries, troubleshooting records, rejected or deferred approaches, assumptions, notes, and handoff audit entries.

`CONTEXT.md` is the primary restore entry point. `HISTORY.md` is read only when historical background is needed.

### Review File

`REVIEW.md` stores the latest review result for a session folder. It is created by `review` and may be read by `restore` as a navigation hint.

`REVIEW.md` is not a checkpoint file. Its findings reflect the work state at review time and must be re-verified against current project files before follow-up work.

## Capabilities

The skill provides four core capabilities:

- `update`: Create or refresh the current session checkpoint.
- `restore`: Rebuild session context from the current session checkpoint or checkpoint files in a specified session folder.
- `handoff`: Rebuild session context from another session checkpoint, then save the rebuilt checkpoint into the current session folder.
- `review`: Review the actual work referenced by checkpoint files in a specified session folder, then write the result to `REVIEW.md` in that folder.

## Usage Examples

Command-style requests:

```text
$context-checkpoint update
$context-checkpoint restore
$context-checkpoint restore .agent-sessions/20260605-example-session
$context-checkpoint handoff .agent-sessions/20260605-example-session
$context-checkpoint review .agent-sessions/20260605-example-session
```

Explicit natural-language requests:

```text
$context-checkpoint update context for this session.
$context-checkpoint restore context from the current session checkpoint.
$context-checkpoint restore context from .agent-sessions/20260605-example-session.
$context-checkpoint hand off context from .agent-sessions/20260605-example-session into this session.
$context-checkpoint review .agent-sessions/20260605-example-session.
```

Fully implicit natural-language requests are supported when the requested capability is clear, but explicitly calling `$context-checkpoint` is recommended.

## Reference Workflows

### Single Session

One session works, runs `update`, later runs `restore`, then continues and updates again.

### Shared Session Collaboration

Multiple agents or conversations use the same session folder as one shared context line. Each collaborator runs `restore` on that folder, continues the work, then runs `update` to write the new state back.

### Review Feedback Loop

A reviewer runs `review` against a source session folder. The result is written to that folder's `REVIEW.md`. A later `restore` of the same folder surfaces those findings as open issues to re-verify before follow-up work.

### Handoff or Branching

One session folder is used as the read-only source, while the current session folder becomes the writable target. Use this when context should migrate or branch into a different session folder.

### Restore Conflict Guard

If the current conversation already has checkpoint files and the user tries to `restore` a different session folder, `restore` stops instead of mixing two context lines. Use `handoff` for migration or use the same shared session folder for collaboration.

Future changes to this skill should preserve these workflow boundaries unless the workflow model is intentionally revised.

## Update

`update` creates or refreshes the current session checkpoint.

Permissions:

- May read existing checkpoint files and related project files.
- May write only `CONTEXT.md` and `HISTORY.md` in the current session folder.
- Must not modify project files or other session artifacts.

Behavior:

- Resolves the current session folder.
- Reads existing `CONTEXT.md` and `HISTORY.md` when present.
- Prioritizes current project files over conflicting checkpoint content.
- Rewrites `CONTEXT.md` as a clean current-state snapshot.
- Maintains `Work Artifacts` every time, even when empty.
- Appends one new `HISTORY.md` entry instead of merging new history into old entries.
- Preserves useful historical records and moves stale process notes out of `CONTEXT.md` when they remain useful.

## Restore

`restore` rebuilds session context from the current session checkpoint or checkpoint files in an explicitly specified session folder.

Permissions:

- Read-only by default.
- May read checkpoint files, `REVIEW.md`, and related project files.
- Must not copy checkpoint files, write session folders, modify project files, or execute TODO items unless the user explicitly asks for follow-up work.

Behavior:

- Uses the current session folder when no path is provided.
- Uses the specified folder as the restore source when a path is provided.
- Stops if the current session already has checkpoint files and the user specifies a different session folder.
- Reads `CONTEXT.md` first when available.
- Reads `HISTORY.md` only when historical background is needed.
- Uses `Work Artifacts` as a navigation index, not as a complete source of truth.
- Surfaces `REVIEW.md` findings as open issues to re-verify when that file exists.
- Reports missing or partial checkpoint files instead of guessing.
- Prioritizes current project files over conflicting checkpoint content.

## Handoff

`handoff` rebuilds session context from another session checkpoint, then saves the rebuilt checkpoint into the current session folder.

Permissions:

- Source session folder is read-only.
- Target session folder is readable and writable.
- May copy only still-relevant non-checkpoint artifacts located inside the source session folder.
- Must not copy files from outside the source session folder.

Behavior:

- Requires the source session folder to contain `CONTEXT.md`.
- Stops when source validation fails.
- Does not create missing source checkpoint files.
- Does not search other folders unless the user explicitly asks for discovery.
- Uses `Work Artifacts` as a navigation index, not as a complete source of truth or copy allowlist.
- Classifies source-folder non-checkpoint artifacts before copying.
- Writes a concise provenance note in target `CONTEXT.md`.
- Appends a handoff audit entry to target `HISTORY.md` covering copied files, discarded files, reference rewrites, user-requested corrections, and unresolved uncertainty.

## Review

`review` objectively reviews the actual work referenced by checkpoint files in a specified session folder, then writes the result to `REVIEW.md` in that folder, without restoring or continuing implementation.

Permissions:

- Requires an explicit source session folder.
- May read checkpoint files, source-folder artifacts, and related project files.
- May write only `REVIEW.md` in the source session folder.
- Must not modify source checkpoint files, project files, other source artifacts, or execute TODO items.

Behavior:

- Requires source `CONTEXT.md`.
- Treats source `HISTORY.md` as optional historical background.
- Uses `CONTEXT.md`, `HISTORY.md`, and `Work Artifacts` as the review brief and navigation index.
- Reviews the actual referenced work, such as modified project files, generated artifacts, tests, configuration, or documentation.
- First checks whether the session completed `Current Goal`.
- Then checks for defects, logic gaps, edge cases, missing validation, conflicts, or inconsistencies.
- Includes severity, evidence, impact, and recommended fix for each finding.
- Places checkpoint-only quality issues under `Checkpoint Quality`, not `Findings`, unless they directly prevent assessing the actual work.
- Writes `REVIEW.md` in the source session folder, overwriting any previous `REVIEW.md`, and also returns the review in the response.
