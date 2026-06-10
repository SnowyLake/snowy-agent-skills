# context-checkpoint

Language: English | [中文](README.zh-CN.md)

## Table of Contents

- [Overview](#overview)
- [Capabilities](#capabilities)
- [Usage Examples](#usage-examples)
- [Checkpoint Files](#checkpoint-files)
- [Session Folders](#session-folders)
- [Access Modes](#access-modes)
- [Update](#update)
- [Restore](#restore)
- [Handoff](#handoff)
- [Review](#review)

## Overview

`context-checkpoint` is an agent-neutral context management skill for preserving, rebuilding, transferring, and reviewing session context across long-running or multi-session work.

A checkpoint is a context snapshot of the current session. Each checkpoint contains two files: `CONTEXT.md` and `HISTORY.md`.

- `CONTEXT.md` stores only current, still-valid information that affects future work.
- `HISTORY.md` stores historical summaries, troubleshooting records, rejected or deferred approaches, and reasoning archives.

## Capabilities

The skill provides four core capabilities:

- `update`: Create or refresh the current session's checkpoint.
- `restore`: Rebuild session context from the current session's checkpoint or checkpoint files in a specified session folder.
- `handoff`: Rebuild session context from another session's checkpoint, then save the rebuilt checkpoint into the current session folder.
- `review`: Objectively review the actual work referenced by checkpoint files in a specified session folder without restoring or continuing implementation.

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

## Checkpoint Files

`CONTEXT.md` stores current session information that still affects future work, including:

- Current goal: the active objective for the session.
- Current state: the latest valid implementation or session status.
- Confirmed decisions: decisions that still guide future work.
- Active constraints: requirements, limits, or rules that must still be followed.
- Known risks: pitfalls, caveats, or uncertain areas to watch.
- Open questions: unresolved questions that need discussion, research, or validation.
- TODO: remaining valid work items.
- Next actions: the top concrete actions to take next.
- Relevant files: files, folders, or resources directly related to understanding the session.
- Work artifacts: main files created, modified, deleted, or moved by the session.

`HISTORY.md` stores historical context, including:

- Important findings: discoveries that explain the session background.
- Decisions: historical choices and their rationale.
- Rejected or deferred approaches: options that were ruled out or postponed.
- Assumptions: verified or unverified assumptions made during the session.
- Notes: extra context useful for later review.
- Handoff audit entries: records of copied files, discarded files, reference rewrites, and user-requested corrections.

## Session Folders

Checkpoint files are stored under:

```text
.agent-sessions/{YYYYMMDD}-{short-kebab-case-session-summary}/
```

The skill avoids guessing when a session folder is unclear. It asks the user to specify an existing session folder or choose whether to create a new one according to the requested capability.

## Access Modes

- `update`: May read related files, and may write only `CONTEXT.md` and `HISTORY.md` in the current session folder.
- `restore`: Read-only. It does not copy checkpoint files, write session folders, modify project files, or execute TODO items by default.
- `handoff`: Source session folder is read-only. Target session folder is readable and writable. It may copy only non-checkpoint artifacts located inside the source session folder.
- `review`: Read-only. It outputs review results by default and does not modify checkpoint files, project files, or execute TODO items.

## Update

`update` creates or refreshes the current session checkpoint.

During update:

- The skill resolves the current session folder.
- Existing `CONTEXT.md` and `HISTORY.md` are read when present.
- Related project files may be read.
- Current project files take priority over conflicting checkpoint content.
- `CONTEXT.md` is rewritten as a clean current-state snapshot.
- `Work Artifacts` is maintained every time and may be empty.
- `HISTORY.md` receives one new entry instead of merging new history into old entries.
- Useful historical records are preserved.
- Stale process notes and superseded assumptions are moved out of `CONTEXT.md` and into `HISTORY.md` when still useful.

## Restore

`restore` rebuilds session context from the current session checkpoint or from checkpoint files in an explicitly specified session folder.

During restore:

- The skill resolves the restore source session folder.
- If no path is provided, the current session folder is used.
- If a path is provided, that folder is used as the restore source.
- If the current session folder already has checkpoint files and a different session folder is specified, restore stops instead of mixing two contexts.
- `CONTEXT.md` is read first when available.
- `HISTORY.md` is read only when historical background is needed.
- `Work Artifacts` is read to quickly understand the prior work scope, but it is not treated as a complete source of truth.
- If only `CONTEXT.md` exists, the skill restores from it.
- If only `HISTORY.md` exists, the skill reconstructs what it can and reports that the current-state snapshot is missing.
- If neither file exists, the skill reports that no usable checkpoint files were found.
- Project files take priority over conflicting checkpoint content.
- Restore is read-only unless the user explicitly asks for follow-up work.

## Handoff

`handoff` rebuilds session context from another session checkpoint, then saves the rebuilt checkpoint into the current session folder.

During handoff:

- The source session folder is read-only.
- The target session folder is readable and writable.
- The source session folder must contain `CONTEXT.md`.
- If source validation fails, the skill stops and reports the issue.
- The skill does not create missing source checkpoint files.
- The skill does not search other folders unless the user explicitly asks for discovery.
- `Work Artifacts` is read to quickly understand the prior work scope, but it is not treated as a complete source of truth.
- Non-checkpoint artifacts inside the source session folder are classified before copying.
- The skill may copy only still-relevant source-folder artifacts, and must not copy files outside the source session folder.
- The final output reports copied and discarded artifacts so the user can request follow-up corrections if needed.
- Target `CONTEXT.md` includes a concise provenance note under `Current State`.
- Target `HISTORY.md` records copied files, discarded files, reference rewrites, user-requested corrections, and unresolved uncertainty.

## Review

`review` objectively reviews the actual work referenced by checkpoint files in a specified session folder without restoring or continuing implementation.

During review:

- The user must specify a source session folder.
- The source session folder must contain `CONTEXT.md`.
- `HISTORY.md` is optional. If it is missing, review continues and reports that historical context is limited.
- `CONTEXT.md`, `HISTORY.md`, and `Work Artifacts` are used as the review brief and navigation index.
- The actual review target is the work referenced by the checkpoint, such as modified project files, generated artifacts, tests, configuration, or documentation.
- `Work Artifacts` is read to quickly understand the prior work scope, but it is not treated as a complete source of truth.
- The first review question is whether the session completed `Current Goal`.
- The review then checks the actual referenced work content for defects, logic gaps, edge cases, missing validation, conflicts, or inconsistencies.
- Each finding should include severity, evidence, impact, and a recommended fix.
- Checkpoint-only quality issues belong under `Checkpoint Quality`, not `Findings`, unless they directly prevent assessing the actual work.
- Current project files take priority over checkpoint claims when they conflict.
- Review is read-only and outputs review results by default.

Review output uses these sections:

```md
## Goal Completion

## Findings

## Checkpoint Quality

## Open Questions

## Summary
```
