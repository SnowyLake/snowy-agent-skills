# context-checkpoint

## Table of Contents

- [Overview](#overview)
- [Terminology](#terminology)
  - [Session Folder](#session-folder)
  - [Checkpoint Files](#checkpoint-files)
  - [Review File](#review-file)
- [Capabilities](#capabilities)
- [Usage Examples](#usage-examples)
- [Update](#update)
- [Restore](#restore)
- [Handoff](#handoff)
- [Review](#review)
- [Reference Workflows](#reference-workflows)
  - [Single Session](#single-session)
  - [Shared Session Collaboration](#shared-session-collaboration)
  - [Review Feedback Loop](#review-feedback-loop)
  - [Handoff or Branching](#handoff-or-branching)
  - [Restore Conflict Guard](#restore-conflict-guard)

Language: English | [中文](README.zh-CN.md)

## Overview

`context-checkpoint` is an agent-neutral context management skill for long-running, multi-session, handoff-based, or review-driven agent work.

The skill is organized around session folders and Markdown checkpoint files. A session folder is the context identity, while agents or conversations are interchangeable collaborators that read from or write to that context according to the command they run.

`SKILL.md` is a lightweight routing layer. Command details live under `references/`.

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
- `review`: Review the actual work referenced by checkpoint files in the current session folder or a specified session folder, then write the result to `REVIEW.md` in that folder.

## Usage Examples

Command-style requests:

```text
$context-checkpoint update
$context-checkpoint restore
$context-checkpoint restore .agent-sessions/20260605-example-session
$context-checkpoint handoff .agent-sessions/20260605-example-session
$context-checkpoint review
$context-checkpoint review .agent-sessions/20260605-example-session
```

Explicit natural-language requests:

```text
$context-checkpoint update context for this session.
$context-checkpoint restore context from the current session checkpoint.
$context-checkpoint restore context from .agent-sessions/20260605-example-session.
$context-checkpoint take over context from .agent-sessions/20260605-example-session into the current session.
$context-checkpoint review the current session folder.
$context-checkpoint review .agent-sessions/20260605-example-session.
```

Fully implicit natural-language requests are supported when the requested capability is clear, but explicitly calling `$context-checkpoint` is recommended.

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
- Rewrites `CONTEXT.md` as a clean current-state snapshot, moving stale, rejected, or no longer useful content out of `CONTEXT.md`.
- Appends one new `HISTORY.md` entry instead of merging new history into old entries.

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
- Classifies source-folder non-checkpoint artifacts before copying.
- Writes a concise provenance note in target `CONTEXT.md`.
- Appends a handoff audit entry to target `HISTORY.md`.

## Review

`review` objectively reviews the actual work referenced by checkpoint files in the current session folder or a specified session folder, then writes the result to `REVIEW.md` in that folder, without restoring or continuing implementation.

Permissions:

- Uses the current session folder when no path is provided.
- Uses the specified reviewed session folder when a path is provided.
- May read checkpoint files, reviewed-session-folder artifacts, and related project files.
- May write only `REVIEW.md` in the reviewed session folder.
- Must not modify reviewed checkpoint files, project files, other artifacts, or execute TODO items.

Behavior:

- Requires `CONTEXT.md` in the reviewed session folder.
- Treats `HISTORY.md` in the reviewed session folder as optional historical background.
- Uses `CONTEXT.md`, `HISTORY.md`, and `Work Artifacts` as the review brief and navigation index.
- Reviews the actual referenced work, such as modified project files, generated artifacts, tests, configuration, or documentation.
- First checks whether the session completed `Current Goal`.
- Then checks for defects, logic gaps, edge cases, missing validation, conflicts, or inconsistencies.
- Includes severity, evidence, impact, and recommended fix for each finding.
- Places checkpoint-only quality issues under `Checkpoint Quality`, not `Findings`, unless they directly prevent assessing the actual work.
- Writes `REVIEW.md` in the reviewed session folder, overwriting any previous `REVIEW.md`, and also returns the review in the response.

## Reference Workflows

### Single Session

One session runs `update` before context compaction, writing still-valid information into the checkpoint. After `/compact`, it runs `restore` to rebuild session context from the checkpoint and avoid losing useful information.

```text
[Session A work]
      |
      v
[update writes checkpoint]
      |
      v
[/compact compresses context]
      |
      v
[restore rebuilds session context]
      |
      v
[continue work]
      |
      v
[update refreshes checkpoint]
```

### Shared Session Collaboration

Multiple agents or conversations use the same session folder as one shared context line. Each collaborator runs `restore` on that folder, continues the work, then runs `update` to write the new state back.

```text
[Agent A work]
        |
        v
[Agent A update]
        |
        v
[Shared session folder]
        |
        v
[Agent B restore]
        |
        v
[Agent B work]
        |
        v
[Agent B update]
        |
        v
[Shared session folder]
        |
        v
[Agent A restore]
```

### Review Feedback Loop

A reviewer can run `review` against the shared session folder, writing the result to that folder's `REVIEW.md`. The implementer then runs `restore` on the same folder, consumes the review findings, fixes or continues the work, and runs `update` again. Repeat this loop until review passes. The reviewer may run a final `restore` to rebuild the completed shared context and close the loop.

```text
[Agent A plan]
          |
          v
[Agent A update]
          |
          v
[Shared session folder]
          |
          v
[Agent B restore]
          |
          v
[Agent B implement]
          |
          v
[Agent B update]
          |
          v
[Agent A review actual work]
          |
          v
[write REVIEW.md]
          |
          v
[Agent B restore review findings]
          |
          v
[Agent B fix and update]
          |
          v
[repeat until review passes]
          |
          v
[Agent A final restore]
```

### Handoff or Branching

One session folder is used as the read-only source session folder, while the current session folder becomes the writable target session folder. Use this when context should migrate or branch into a different session folder.

```text
[Source session folder]
  CONTEXT.md
  HISTORY.md
  artifacts
      |
      v
[handoff rebuilds context]
      |
      v
[Target session folder]
  CONTEXT.md
  HISTORY.md
  copied artifacts
```

### Restore Conflict Guard

If the current conversation already has checkpoint files and the user tries to `restore` a different session folder, `restore` stops instead of mixing two context lines. Use `handoff` for migration or use the same shared session folder for collaboration.

```text
[Current session already has checkpoint]
      |
      v
[restore another session folder]
      |
      v
[stop]
      |
      +-- migrate or branch: use handoff
      |
      +-- collaborate: share the same session folder
```

Future changes to this skill should preserve these workflow boundaries unless the workflow model is intentionally revised.
