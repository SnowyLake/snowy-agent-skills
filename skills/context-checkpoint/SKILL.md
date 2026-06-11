---
name: context-checkpoint
description: Manage CONTEXT.md and HISTORY.md session checkpoints. Use for update, restore, handoff, or checkpoint-guided work review requests that refresh, rebuild, transfer, or audit session context.
---

# Context Checkpoint

## Table of Contents

- [Overview](#overview)
- [Command Selection](#command-selection)
- [Session Folder Resolution](#session-folder-resolution)
- [Access Modes](#access-modes)
- [Update Workflow](#update-workflow)
- [Restore Workflow](#restore-workflow)
- [Handoff Workflow](#handoff-workflow)
- [Review Workflow](#review-workflow)
- [Language and Formatting](#language-and-formatting)
- [File Contracts](#file-contracts)
- [Output Style](#output-style)

## Overview

Provide exactly four capabilities:

- `update`: Create or refresh the current session checkpoint in `CONTEXT.md` and `HISTORY.md`.
- `restore`: Rebuild the current session context from the current session checkpoint files or checkpoint files in an explicitly specified session folder.
- `handoff`: Rebuild the current conversation state from another session folder's checkpoint files, then save the rebuilt state into the current conversation's session folder.
- `review`: Objectively review the actual work referenced by checkpoint files in an explicitly specified session folder, then write the result to `REVIEW.md` in that session folder, without restoring or continuing implementation.

Keep this skill narrow. Do not manage project wikis, create unrelated documents, or add broader session-management commands.

## Command Selection

Prefer command-style requests or explicit natural-language requests that name `$context-checkpoint`. Fully implicit natural-language requests are allowed when they clearly ask for checkpoint update, restore, handoff, or review.

Use `update` when:

- The user explicitly asks to generate, update, or refresh checkpoint files.
- The user asks for handoff context or cross-session continuation files.
- The user asks to organize the current session into `CONTEXT.md` and `HISTORY.md`.

Use `restore` when:

- The user asks to read the current session checkpoint.
- The user asks to restore or rebuild session context from the current session's `CONTEXT.md` and `HISTORY.md`.
- The user asks to restore or rebuild session context from checkpoint files in a specified session folder.

Use `handoff` when:

- The user asks to continue, take over, or reconstruct context from another session folder and write that rebuilt context into the current session folder.
- The user asks to rebuild the current conversation from an older or different session checkpoint and save the rebuilt state.
- The user asks to migrate checkpoint context from session A into session B.
- A new session needs to take over from an existing checkpoint in another session folder and persist the rebuilt checkpoint into its own session folder.

Use `review` when:

- The user asks to review, audit, assess, inspect, or critique a specified session folder's actual work.
- The user asks whether a session completed its goal.
- The user asks whether a session's work has defects, edge cases, missing validation, conflicts, or inconsistencies.
- The user asks for an objective checkpoint-guided work review without restoring or continuing implementation.

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

For `restore`, resolve the source session folder:

1. If the user does not specify a session folder, resolve the current session folder.
2. If the user specifies a session folder, use it as the restore source.
3. If the user specifies a different session folder and the current conversation already has checkpoint files in its own session folder, stop and report the conflict. Do not read, merge, copy, or modify either checkpoint.
4. If the specified session folder is the current session folder, allow restore.
5. If the current folder is unclear and no path was specified, ask the user to specify an existing session folder.
6. Do not create a new session folder for `restore`.

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

For `review`, resolve the source session folder:

1. Require the user to specify a source session folder.
2. Do not default to the current session folder.
3. Do not create a source session folder.
4. Do not inspect `.agent-sessions/` to guess a semantically matching source folder unless the user explicitly asks for discovery or listing.

Use lowercase kebab-case for the summary segment. Prefer concise session names.

## Access Modes

`update`:

- May read related project files and existing checkpoint files in the current session folder.
- May create the current session folder when needed.
- May write only `CONTEXT.md` and `HISTORY.md` in the current session folder.
- Must not create or modify other artifacts unless the user explicitly asks for additional files.

`restore`:

- Read-only.
- May read checkpoint files in the restore source session folder and related project files.
- May read `REVIEW.md` in the restore source session folder when present, and surface its findings as open issues to re-verify.
- Must not copy checkpoint files, write the current session folder, modify project files, or execute TODO items unless the user explicitly asks for follow-up work.

`handoff`:

- Source session folder is read-only.
- Target session folder is readable and writable.
- May copy only non-checkpoint artifacts located inside the source session folder.
- Must not copy project files or any file outside the source session folder, even when `Work Artifacts` references them.
- Must not modify project files or execute TODO items unless the user explicitly asks for follow-up work.

`review`:

- May read checkpoint files in the specified source session folder and related project files.
- May write only `REVIEW.md` in the specified source session folder. This is the single allowed write exception for `review`.
- Must not modify source `CONTEXT.md`, source `HISTORY.md`, other source-folder artifacts, project files, or execute TODO items unless the user explicitly asks for follow-up work.
- Overwrites an existing `REVIEW.md` in the source session folder with the latest review result.
- Always outputs the review result and writes it to `REVIEW.md`.
- Treat checkpoint files as the review brief and navigation index. Do not make checkpoint-file quality the primary review target unless the user explicitly asks to review the checkpoint files themselves.

## Update Workflow

When running `update`:

1. Resolve the current session folder.
2. Read existing `CONTEXT.md` and `HISTORY.md` if present.
3. Compare checkpoint content with the current conversation state and project files. Prefer current project files when they conflict with checkpoint documents.
4. Rewrite `CONTEXT.md` as a clean current-state snapshot. Do not mechanically append history.
5. Maintain `Work Artifacts` in `CONTEXT.md` every time. It may be empty when no work artifacts exist.
6. Append one new entry to `HISTORY.md`. Do not merge new history into old entries.
7. Preserve useful existing history. Do not delete old entries unless the user explicitly requests cleanup.
8. Move stale process notes, rejected approaches, superseded assumptions, and decision rationale out of `CONTEXT.md` and into the new `HISTORY.md` entry when still useful.

`update` must create or update both files:

```text
CONTEXT.md
HISTORY.md
```

## Restore Workflow

When running `restore`:

1. Resolve the restore source session folder.
2. If the user specified a different source session folder and the current conversation already has checkpoint files in its own session folder, stop and report the conflict.
3. Read `CONTEXT.md` first when available.
4. Read `HISTORY.md` only when needed to understand decision background, troubleshooting rationale, rejected approaches, or historical uncertainty.
5. Read `Work Artifacts` to quickly understand the prior work scope, but do not treat it as a complete source of truth.
6. Read `REVIEW.md` when present in the restore source session folder. Surface its findings as open issues to re-verify, and state that they reflect the work state at review time and must be re-checked against current project files.
7. If only `CONTEXT.md` exists, restore from it.
8. If only `HISTORY.md` exists, reconstruct as much background as possible and state that the current-state snapshot is missing.
9. If neither file exists, state that no usable checkpoint files were found in the session folder.
10. Do not treat old history as current state.
11. Do not treat unverified assumptions as facts.
12. If `HISTORY.md` conflicts with `CONTEXT.md`, prefer `CONTEXT.md` for current state.
13. If checkpoint files conflict with current project files, prefer current project files.
14. When restored state is incomplete, inferred, or affected by conflicts, state where the information came from and how confident the reconstruction is.
15. During `restore`, do not modify project files, execute TODO items, copy checkpoint files, or continue implementation unless the user explicitly asks for follow-up work.

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
8. Read `Work Artifacts` to quickly understand the prior work scope, but do not treat it as a complete source of truth.
9. Scan other files in the source session folder.
10. Classify non-checkpoint files inside the source session folder as still-relevant artifacts or historical/stale artifacts.
11. Use the classification to decide which non-checkpoint source-folder artifacts to copy or discard without waiting for user confirmation.
12. Record copied and discarded artifacts in the handoff entry and final output so the user can request follow-up corrections if needed.
13. Create or update the target session folder.
14. Write target `CONTEXT.md` as the rebuilt current-state snapshot.
15. Write target `HISTORY.md` by preserving useful source history and appending a handoff entry.
16. Copy still-relevant artifacts from the source session folder into the target session folder.
17. Rewrite references in target `CONTEXT.md`, target `HISTORY.md`, and copied artifacts from source paths to target paths where needed.
18. Verify copied files and rewritten references.
19. Report the source folder, target folder, copied files, discarded files, and files updated.

Source session folder guardrails:

- Source files are read-only.
- `CONTEXT.md` is required for `handoff`.
- If the source session folder does not exist, stop and report the issue.
- If the source session folder exists but does not contain `CONTEXT.md`, stop and report the issue.
- If the source session folder contains only `HISTORY.md` or other generated documents, stop and report the missing `CONTEXT.md`.
- When source validation fails, do not create checkpoint files, infer missing checkpoint content, create a target folder, classify artifacts, copy files, or search other folders.

Non-checkpoint artifact handling:

- Do not blindly copy every generated document from the source session folder.
- Classify only non-checkpoint files located inside the source session folder.
- Do not copy project files or any file outside the source session folder.
- Treat paths in `Work Artifacts` as navigation hints, not as a copy allowlist.
- Classify source-folder artifacts using source `CONTEXT.md` sections such as `Relevant Files`, `Work Artifacts`, `TODO`, `Next Actions`, and `Known Risks`.
- Treat source-folder files that still affect future decisions or implementation as still-relevant artifacts.
- Treat rejected, deferred, superseded, stale, or purely historical process documents as historical/stale artifacts.
- Do not stop to ask for confirmation before copying or discarding non-checkpoint source-folder artifacts.
- Record copied and discarded artifacts in the handoff entry and final output so the user can review and request follow-up corrections.
- `Discarded` means not copied into the target session folder. Never delete source files.

Target checkpoint handling:

- Target `CONTEXT.md` must be a clean current-state snapshot, not a mechanical copy of source `CONTEXT.md`.
- Target `CONTEXT.md` must include one concise provenance note under `Current State` naming the source session folder.
- Detailed handoff records belong in target `HISTORY.md`, not target `CONTEXT.md`.
- Target `HISTORY.md` must preserve useful source history and append one handoff entry.
- The handoff entry must record source folder, target folder, copied checkpoint files, copied artifacts, discarded artifacts, reference rewrites, user-requested corrections, missing optional source files, and unresolved uncertainty.
- `handoff` does not modify project files, execute TODO items, or continue implementation unless the user explicitly asks for follow-up work.

## Review Workflow

When running `review`:

1. Resolve the explicitly specified source session folder.
2. Verify that the source session folder exists.
3. Verify that the source session folder contains `CONTEXT.md`.
4. If source validation fails, stop and report the issue. Do not create checkpoint files, create target folders, write `REVIEW.md`, modify project files, or search other folders.
5. Read source `CONTEXT.md`.
6. Read source `HISTORY.md` when available.
7. If `HISTORY.md` is missing, continue review and state that historical context is limited.
8. Use `CONTEXT.md` to understand the goal, current state, decisions, constraints, risks, open questions, TODO, next actions, relevant files, and work artifacts.
9. Build the review scope from `Current Goal`, `Work Artifacts`, `Relevant Files`, `TODO`, `Next Actions`, and any source-folder artifacts. `Work Artifacts` is the fastest pointer to the prior work scope, but not a complete source of truth.
10. Read the actual referenced project files, generated artifacts, diffs, tests, or configuration that represent the session's work before producing findings.
11. Review whether the actual work completed `Current Goal`.
12. Review the actual work content for defects, edge cases, missing validation, conflicts, or inconsistencies.
13. Do not list ordinary checkpoint-file quality issues as `Findings`. Put checkpoint clarity, freshness, missing sections, or internal checkpoint consistency issues under `Checkpoint Quality` unless they directly prevent assessing goal completion or hide the work scope.
14. Review `CONTEXT.md` and `HISTORY.md` as primary work artifacts only when the user's requested review target or the source session's `Current Goal` was specifically to create or update checkpoint files.
15. Prefer current project files over checkpoint claims when they conflict.
16. Do not restore session context as the active working context.
17. Do not modify source checkpoint files, project files, or execute TODO items unless the user explicitly asks for follow-up work.
18. Write the review result to `REVIEW.md` in the source session folder, overwriting any existing `REVIEW.md`, and also output it in the response.

## Language and Formatting

When writing checkpoint Markdown files or review output:

- Keep the required file names and section headings from the file contracts unless project-level instructions explicitly override them.
- Treat English headings in this skill as structural contracts, not as the default body language.
- Choose body text language according to project-level or user-level instructions first.
- If no project-level or user-level language instruction exists, use the current conversation language for body text.
- Apply this rule to checkpoint Markdown written by this skill, including `CONTEXT.md`, `HISTORY.md`, handoff entries, and `REVIEW.md`.

## File Contracts

`CONTEXT.md` stores only current, still-valid information that affects future work. Use this structure:

```md
# CONTEXT.md

## Current Goal

## Current State

## Confirmed Decisions

## Active Constraints

## Known Risks

## Open Questions

## TODO

## Next Actions

## Relevant Files

## Work Artifacts
```

Section intent:

- `Current Goal`: The current objective.
- `Current State`: The current implementation or session state.
- `Confirmed Decisions`: Decisions that remain valid.
- `Active Constraints`: Constraints future work must still obey.
- `Known Risks`: Known risks, pitfalls, or caveats.
- `Open Questions`: Questions needing discussion, research, or validation.
- `TODO`: Valid remaining work item pool.
- `Next Actions`: The top 1-3 concrete actions to take next, distilled from `TODO`.
- `Relevant Files`: Files, folders, or resources directly related to understanding the session.
- `Work Artifacts`: Main files created, modified, deleted, or moved by the session. This is a navigation index, not a complete diff, not a complete source of truth, and not a handoff copy allowlist.

Use this `Work Artifacts` item structure:

```md
- [Modified] `path/to/file.md`
  - Briefly explain what changed in this file.
```

Allowed `Work Artifacts` actions:

- `[Created]`: The session created the file.
- `[Modified]`: The session modified an existing file.
- `[Deleted]`: The session deleted the file.
- `[Moved]`: The session moved or renamed the file.

`Work Artifacts` must be maintained during every `update`, but it may be empty when no work artifacts exist.

During `handoff`, target `CONTEXT.md` must include one concise provenance note under `Current State` naming the source session folder. Do not place copied/discarded file lists, user-requested corrections, or detailed reference rewrite records in `CONTEXT.md`.

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

The handoff entry must record copied checkpoint files, copied artifacts, discarded artifacts, reference path rewrites, user-requested corrections, missing optional source files such as `HISTORY.md`, and unresolved uncertainty.

`REVIEW.md` stores the latest `review` result for a session folder. `review` writes it into the reviewed source session folder, overwriting any previous `REVIEW.md`. Use this structure:

```md
# REVIEW.md

## Reviewed Session

## Review Date

## Goal Completion

## Findings

## Checkpoint Quality

## Open Questions

## Summary
```

`REVIEW.md` section intent:

- `Reviewed Session`: The source session folder this review targets.
- `Review Date`: The review date in `YYYY-MM-DD` format.
- `Goal Completion`, `Findings`, `Checkpoint Quality`, `Open Questions`, `Summary`: Same intent as the `review` output sections defined in `Output Style`.

`REVIEW.md` is a review artifact, not a checkpoint file. `restore` and `handoff` treat it as a navigation hint, not as current state. `handoff` classifies it like any other non-checkpoint source-folder artifact.

## Output Style

For `update`, keep the user-facing response brief. Mention the session folder and the files updated.

For `restore`, summarize the rebuilt session state instead of repeating all of `HISTORY.md`. Include:

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

For `handoff`, first include a brief handoff result summary:

- Source session folder
- Target session folder
- Updated checkpoint files
- Copied artifacts
- Discarded artifacts
- Reference rewrites
- Unresolved risks or open questions

Then summarize the rebuilt session state instead of repeating all of `HISTORY.md`. Include:

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

For `review`, write the result to `REVIEW.md` in the source session folder and output the same result in the response. Use these sections in both:

```md
## Goal Completion

## Findings

## Checkpoint Quality

## Open Questions

## Summary
```

Review section intent:

- `Goal Completion`: State whether `Current Goal` is `Completed`, `Partially Completed`, `Not Completed`, or `Unclear`, and briefly explain the evidence.
- `Findings`: List concrete issues in the actual reviewed work, ordered by severity. Include implementation defects, logic gaps, edge cases, behavior risks, missing validation, project-file conflicts, or inconsistencies in files created, modified, deleted, moved, or otherwise referenced by the source session. For each finding, include severity, evidence, impact, and a recommended fix. If no concrete work issues are found after inspecting the relevant files, say so explicitly.
- `Checkpoint Quality`: Assess whether `CONTEXT.md` and optional `HISTORY.md` are reliable enough for future restore, handoff, or review. Include whether `Work Artifacts` points to the relevant work scope. Put checkpoint-only issues here unless they directly block assessment of the actual work.
- `Open Questions`: List questions that cannot be answered from checkpoint files and current project files.
- `Summary`: Provide a concise actionable conclusion.

Respect project-level language and formatting instructions for generated markdown and review output when they do not conflict with the file contracts above.
