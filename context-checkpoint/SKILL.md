---
name: context-checkpoint
description: Create, update, restore, or hand off session checkpoint files from conversation context. Use when the user explicitly asks to update checkpoint files, create handoff context, prepare context before compaction, write CONTEXT.md and HISTORY.md, restore the current session from checkpoint files, hand off another session into the current conversation, or rebuild task state from CONTEXT.md / HISTORY.md. Also use update automatically when the system is about to compact context, but do not trigger only because the user typed /compact unless they explicitly request checkpoint generation first.
---

# Context Checkpoint

## Table of Contents

- [Overview](#overview)
- [Command Selection](#command-selection)
- [Session Folder Resolution](#session-folder-resolution)
- [Update Workflow](#update-workflow)
- [Restore Workflow](#restore-workflow)
- [Handoff Workflow](#handoff-workflow)
- [File Contracts](#file-contracts)
- [Output Style](#output-style)

## Overview

Provide exactly three capabilities:

- `update`: Create or refresh the current session checkpoint in `CONTEXT.md` and `HISTORY.md`.
- `restore`: Rebuild the current task state from the current session checkpoint files.
- `handoff`: Rebuild the current conversation state from another session folder's checkpoint files, then save the rebuilt state into the current conversation's session folder.

Keep this skill narrow. Do not manage project wikis, create unrelated documents, or add broader session-management commands.

## Command Selection

Use `update` when:

- The user explicitly asks to generate, update, or refresh checkpoint files.
- The user asks for handoff context, cross-session continuation files, or pre-compaction context cleanup.
- The user asks to organize the current session into `CONTEXT.md` and `HISTORY.md`.
- The system is about to perform automatic context compaction.

Do not use `update` merely because the user manually invokes `/compact`. Use it only when the user explicitly asks to generate a checkpoint before compaction.

Use `restore` when:

- The user asks to read the current session checkpoint.
- The user asks to restore or rebuild task state from the current session's `CONTEXT.md` and `HISTORY.md`.

Use `handoff` when:

- The user asks to continue, take over, or reconstruct context from another session folder.
- The user asks to rebuild the current conversation from an older or different session checkpoint.
- The user asks to migrate checkpoint context from session A into session B.
- A new session needs to take over from an existing checkpoint in another session folder.

## Session Folder Resolution

Store checkpoint files under the project root:

```text
.agent-sessions/{YYYYMMDD}-{short-kebab-case-session-summary}/
```

For `update`, resolve the current session folder:

1. Determine whether the current conversation already has a session folder.
2. If a matching folder exists, reuse it.
3. If the current folder is unclear, ask the user whether to specify an existing session folder or create a new session folder.
4. Create a new folder only when the user chooses to create one or no existing session folder can be identified from the current conversation.

For `restore`, resolve the current session folder:

1. Determine whether the current conversation already has a session folder.
2. If a matching folder exists, reuse it.
3. If the current folder is unclear, ask the user to specify an existing session folder.
4. Do not create a new session folder for `restore`.

For `handoff`, resolve two session folders:

- Source session folder: the old session folder that `handoff` reads from.
- Target session folder: the current conversation's session folder that `handoff` writes to.

When resolving the source session folder:

1. If the user specifies a source session folder, use it.
2. If the user does not specify a source session folder, ask the user to specify an existing session folder.
3. Do not create a source session folder.
4. Do not inspect `.agent-sessions/` to guess a semantically matching source folder unless the user explicitly asks for discovery or listing.

When resolving the target session folder:

1. If the current conversation already has a clear session folder, use it.
2. If the target folder is unclear, ask the user whether to specify an existing session folder or create a new session folder.
3. Create a new target folder only when the user chooses to create one or no existing target session folder can be identified from the current conversation.
4. Do not use the source session folder as the target session folder unless the user explicitly chooses to write handoff results back to the source folder.

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
11. Mark reconstructed state with its source and confidence when the source is partial, inferred, or conflict-prone.
12. During `restore`, do not modify project files, execute TODO items, or continue implementation unless the user explicitly asks for follow-up work.

Do not modify checkpoint files during `restore` unless the user explicitly asks to update them too.

## Handoff Workflow

When running `handoff`:

1. Resolve the source session folder.
2. Verify that the source session folder exists.
3. Verify that the source session folder contains `CONTEXT.md`.
4. If source validation fails, stop and report the issue. Do not create checkpoint files, create target folders, classify artifacts, copy files, or search other folders.
5. Resolve the target session folder.
6. Read source `CONTEXT.md`.
7. Read source `HISTORY.md` when available.
8. Scan other files in the source session folder.
9. Classify non-checkpoint files as still-relevant artifacts or historical/stale artifacts.
10. Present the classification to the user and wait for confirmation before copying non-checkpoint files.
11. Apply user feedback to the copy/discard plan.
12. Create or update the target session folder.
13. Write target `CONTEXT.md` as the rebuilt current-state snapshot.
14. Write target `HISTORY.md` by preserving useful source history and appending a handoff entry.
15. Copy confirmed still-relevant artifacts into the target session folder.
16. Rewrite references in target `CONTEXT.md`, target `HISTORY.md`, and copied artifacts from source paths to target paths where needed.
17. Verify copied files and rewritten references.
18. Report the source folder, target folder, copied files, discarded files, and files updated.

Source session folder guardrails:

- Source files are read-only.
- `CONTEXT.md` is required for `handoff`.
- If the source session folder does not exist, stop and report the issue.
- If the source session folder exists but does not contain `CONTEXT.md`, stop and report the issue.
- If the source session folder contains only `HISTORY.md` or other generated documents, stop and report the missing `CONTEXT.md`.
- When source validation fails, do not create checkpoint files, infer missing checkpoint content, create a target folder, classify artifacts, copy files, or search other folders.

Non-checkpoint artifact handling:

- Do not blindly copy every generated document from the source session folder.
- Classify non-checkpoint files using source `CONTEXT.md` sections such as `Relevant Files`, `TODO`, `Next Actions`, and `Known Risks`.
- Treat files that still affect future decisions or implementation as still-relevant artifacts.
- Treat rejected, deferred, superseded, stale, or purely historical process documents as historical/stale artifacts.
- Ask the user to confirm the classification before copying or discarding non-checkpoint files.
- Let the user accept the classification, move files between copy and discard, copy all artifacts, or copy only checkpoint files.
- `Discarded` means not copied into the target session folder. Never delete source files.

Target checkpoint handling:

- Target `CONTEXT.md` must be a clean current-state snapshot, not a mechanical copy of source `CONTEXT.md`.
- Target `CONTEXT.md` must include one concise provenance note under `Current State` naming the source session folder.
- Detailed handoff records belong in target `HISTORY.md`, not target `CONTEXT.md`.
- Target `HISTORY.md` must preserve useful source history and append one handoff entry.
- The handoff entry must record source folder, target folder, copied checkpoint files, copied artifacts, discarded artifacts, reference rewrites, user overrides, missing optional source files, and unresolved uncertainty.
- `handoff` does not modify project files, execute TODO items, or continue implementation unless the user explicitly asks for follow-up work.

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

During `handoff`, target `CONTEXT.md` must include one concise provenance note under `Current State` naming the source session folder. Do not place copied/discarded file lists, user overrides, or detailed reference rewrite records in `CONTEXT.md`.

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

For each `handoff`, append one handoff entry to target `HISTORY.md`. Use this structure:

```md
## {YYYY-MM-DD} - Handoff from {source-session-folder}

### Summary

### Source

### Target

### Copied Files

### Discarded Files

### Reference Rewrites

### User Overrides

### Assumptions

### Notes
```

The handoff entry must record copied checkpoint files, copied artifacts, discarded artifacts, reference path rewrites, user classification overrides, missing optional source files such as `HISTORY.md`, and unresolved uncertainty.

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
- Source and confidence notes for reconstructed state

For `handoff`, first include a brief handoff result summary:

- Source session folder
- Target session folder
- Updated checkpoint files
- Copied artifacts
- Discarded artifacts
- Reference rewrites
- Unresolved risks or open questions

Then summarize the rebuilt task state instead of repeating all of `HISTORY.md`. Include:

- Current goal
- Current state
- Confirmed decisions
- Active constraints
- Relevant files
- TODO
- Open questions
- Known risks
- Next actions
- Source and confidence notes for reconstructed state

Respect project-level formatting instructions for generated markdown when they do not conflict with the file contracts above.
