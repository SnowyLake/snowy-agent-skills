# context-checkpoint-skill

Language: English | [中文](README.zh-CN.md)

## Table of Contents

- [Overview](#overview)
- [Capabilities](#capabilities)
- [Checkpoint Files](#checkpoint-files)
- [Session Folders](#session-folders)
- [Update Behavior](#update-behavior)
- [Restore Behavior](#restore-behavior)
- [Handoff Behavior](#handoff-behavior)
- [Repository Layout](#repository-layout)
- [Scripts](#scripts)

## Overview

`context-checkpoint-skill` is a lightweight Codex skill for preserving and rebuilding task context across long-running or multi-session work.

It uses `CONTEXT.md` for the current still-valid task state and `HISTORY.md` for historical decisions, findings, rejected approaches, and handoff records.

## Capabilities

The skill defines three focused capabilities:

- `update`: Create or refresh the current session checkpoint.
- `restore`: Rebuild task state from the current session checkpoint.
- `handoff`: Rebuild the current conversation from another session folder, then save the rebuilt state into the current session folder.

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
- Handoff audit entries: records of copied files, discarded files, reference rewrites, and user overrides.

## Session Folders

Checkpoint files are stored under:

```text
.agent-sessions/{YYYYMMDD}-{short-kebab-case-session-summary}/
```

The skill avoids guessing when a session folder is unclear. It asks the user whether to specify an existing session folder or create a new one.

## Update Behavior

`update` creates or refreshes the checkpoint for the current session.

During update:

- The skill resolves the current session folder.
- Existing `CONTEXT.md` and `HISTORY.md` are read when present.
- Current project files take priority over conflicting checkpoint content.
- `CONTEXT.md` is rewritten as a clean current-state snapshot.
- `HISTORY.md` receives one new entry instead of merging new history into old entries.
- Useful historical records are preserved.
- Stale process notes and superseded assumptions are moved out of `CONTEXT.md` and into `HISTORY.md` when still useful.

## Restore Behavior

`restore` rebuilds task state from the current session checkpoint.

During restore:

- The skill resolves the current session folder.
- `CONTEXT.md` is read first when available.
- `HISTORY.md` is read only when historical background is needed.
- If only `CONTEXT.md` exists, the skill restores from it.
- If only `HISTORY.md` exists, the skill reconstructs what it can and reports that the current-state snapshot is missing.
- If neither file exists, the skill reports that no usable checkpoint files were found.
- Project files take priority over conflicting checkpoint content.
- Restore is read-only unless the user explicitly asks for follow-up work.

## Handoff Behavior

`handoff` is designed for cross-session context reconstruction.

During handoff:

- The source session folder is read-only.
- The source session folder must contain `CONTEXT.md`.
- If source validation fails, the skill stops and reports the issue.
- The skill does not create missing source checkpoint files.
- The skill does not search other folders unless the user explicitly asks for discovery.
- Non-checkpoint artifacts are classified before copying.
- The user confirms which artifacts should be copied or discarded.
- Target `CONTEXT.md` includes a concise provenance note under `Current State`.
- Target `HISTORY.md` records copied files, discarded files, reference rewrites, user overrides, and unresolved uncertainty.

## Repository Layout

```text
context-checkpoint-skill/
|-- context-checkpoint/
|   |-- SKILL.md
|   `-- agents/
|       `-- openai.yaml
|-- scripts/
|   |-- codex-install-copy.bat
|   |-- codex-install-symbolic-link.bat
|   `-- codex-uninstall.bat
|-- README.md
|-- README.zh-CN.md
`-- LICENSE
```

## Scripts

The `scripts/` folder contains Windows batch scripts for installing or removing this skill from the Codex skills directory:

- `codex-install-symbolic-link.bat`: Remove any existing `%USERPROFILE%\.codex\skills\context-checkpoint` entry, then install this skill as a directory symbolic link.
- `codex-install-copy.bat`: Remove any existing `%USERPROFILE%\.codex\skills\context-checkpoint` entry, then install this skill by copying the full skill directory.
- `codex-uninstall.bat`: Remove `%USERPROFILE%\.codex\skills\context-checkpoint` when it exists.

Each script pauses before exiting so the result remains visible when launched by double-clicking.
