# context-checkpoint-skill

Language: English | [中文](README.zh-CN.md)

## Table of Contents

- [Overview](#overview)
- [Capabilities](#capabilities)
- [Usage Examples](#usage-examples)
- [Checkpoint Files](#checkpoint-files)
- [Session Folders](#session-folders)
- [Update](#update)
- [Restore](#restore)
- [Handoff](#handoff)
- [Repository Layout](#repository-layout)

## Overview

`context-checkpoint-skill` is a lightweight, general-purpose agent skill for preserving and rebuilding task context across long-running or multi-session work.

A checkpoint is a context snapshot of the current session. Each checkpoint contains two files: `CONTEXT.md` and `HISTORY.md`.

`CONTEXT.md` stores the current still-valid task state. `HISTORY.md` stores historical decisions, findings, rejected approaches, and handoff records.

## Capabilities

The skill provides three core capabilities:

- `update`: Create or refresh the current session's checkpoint.
- `restore`: Rebuild task context from the current session's checkpoint, for recovery after single-session context has been compacted.
- `handoff`: Rebuild the current session task context from another session's checkpoint, for passing and sharing context across sessions.

## Usage Examples

Command-style requests:

```text
$context-checkpoint update
$context-checkpoint restore
$context-checkpoint handoff .agent-sessions/20260605-example-session
```

Explicit natural-language requests:

```text
$context-checkpoint update context for this session.
$context-checkpoint restore context from the current session checkpoint.
$context-checkpoint hand off context from .agent-sessions/20260605-example-session into this session.
```

Fully implicit natural-language requests are supported, but explicitly calling `$context-checkpoint` is recommended.

## Checkpoint Files

`CONTEXT.md` stores current task state that still affects future work, including:

- Current goal: the active objective for the session.
- Current state: the latest valid implementation or task status.
- Confirmed decisions: decisions that still guide future work.
- Active constraints: requirements, limits, or rules that must still be followed.
- Relevant files: files, folders, or resources directly related to the task.
- TODO: remaining valid work items.
- Open questions: unresolved questions that need discussion, research, or validation.
- Known risks: pitfalls, caveats, or uncertain areas to watch.
- Next actions: the top concrete actions to take next.

`HISTORY.md` stores historical context, including:

- Important findings: discoveries that explain the task background.
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

The skill avoids guessing when a session folder is unclear. It asks the user whether to specify an existing session folder or create a new one.

## Update

`update` creates or refreshes the current session checkpoint.

During update:

- The skill resolves the current session folder.
- Existing `CONTEXT.md` and `HISTORY.md` are read when present.
- Current project files take priority over conflicting checkpoint content.
- `CONTEXT.md` is rewritten as a clean current-state snapshot.
- `HISTORY.md` receives one new entry instead of merging new history into old entries.
- Useful historical records are preserved.
- Stale process notes and superseded assumptions are moved out of `CONTEXT.md` and into `HISTORY.md` when still useful.

## Restore

`restore` rebuilds task context from the current session checkpoint, for recovery after context has been compacted.

During restore:

- The skill resolves the current session folder.
- `CONTEXT.md` is read first when available.
- `HISTORY.md` is read only when historical background is needed.
- If only `CONTEXT.md` exists, the skill restores from it.
- If only `HISTORY.md` exists, the skill reconstructs what it can and reports that the current-state snapshot is missing.
- If neither file exists, the skill reports that no usable checkpoint files were found.
- Project files take priority over conflicting checkpoint content.
- Restore is read-only unless the user explicitly asks for follow-up work.

## Handoff

`handoff` rebuilds the current session task context from another session checkpoint, for passing context across sessions.

During handoff:

- The source session folder is read-only.
- The source session folder must contain `CONTEXT.md`.
- If source validation fails, the skill stops and reports the issue.
- The skill does not create missing source checkpoint files.
- The skill does not search other folders unless the user explicitly asks for discovery.
- Non-checkpoint artifacts are classified before copying.
- The skill copies still-relevant artifacts and skips historical or stale artifacts without blocking for confirmation.
- The final output reports copied and discarded artifacts so the user can request follow-up corrections if needed.
- Target `CONTEXT.md` includes a concise provenance note under `Current State`.
- Target `HISTORY.md` records copied files, discarded files, reference rewrites, user-requested corrections, and unresolved uncertainty.

## Repository Layout

```text
context-checkpoint-skill/
|-- context-checkpoint/
|   |-- SKILL.md
|   `-- agents/
|       `-- openai.yaml
|-- README.md
|-- README.zh-CN.md
`-- LICENSE
```
