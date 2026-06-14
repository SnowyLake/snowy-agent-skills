# Handoff Command

## Table of Contents

- [Session Folder Resolution](#session-folder-resolution)
- [Access Mode](#access-mode)
- [Workflow](#workflow)
- [Source Guardrails](#source-guardrails)
- [Non-Checkpoint Artifact Handling](#non-checkpoint-artifact-handling)
- [Target Checkpoint Handling](#target-checkpoint-handling)
- [Output Style](#output-style)

This reference covers the `handoff` command only. Apply it together with the `Global Invariants` in `SKILL.md`. Read `file-contracts.md` before writing or validating target `CONTEXT.md`, target `HISTORY.md`, handoff entries, or `Work Artifacts`.

## Session Folder Resolution

`handoff` resolves two session folders:

- Source session folder: the old session folder that `handoff` reads from.
- Target session folder: the current conversation's session folder that `handoff` writes to.

When resolving the source session folder:

1. If the user specifies a source session folder, use it.
2. If the user does not specify a source session folder, ask the user to specify an existing session folder.
3. Do not create a source session folder.

When resolving the target session folder:

1. If the current conversation already has a clear session folder, use it.
2. If the target folder is unclear, ask the user whether to specify an existing session folder or create a new session folder.
3. Create a new target folder only when the user chooses to create one or no existing target session folder can be identified from the current conversation.
4. Do not use the source session folder as the target session folder unless the user explicitly chooses to write handoff results back to the source folder.

## Access Mode

- Source session folder is read-only.
- Target session folder is readable and writable.
- May copy only non-checkpoint artifacts located inside the source session folder.
- Must not copy project files or any file outside the source session folder, even when `Work Artifacts` references them.
- Must not modify project files unless the user explicitly asks for follow-up work.

## Workflow

1. Resolve the source session folder.
2. Verify that the source session folder exists.
3. Verify that the source session folder contains `CONTEXT.md`.
4. If source validation fails, stop and report the issue. Do not create checkpoint files, create target folders, classify artifacts, copy files, or search other folders.
5. Resolve the target session folder.
6. Read source `CONTEXT.md`.
7. Read source `HISTORY.md` when available.
8. Read `Work Artifacts` to quickly understand the prior work scope.
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

## Source Guardrails

- Source files are read-only.
- `CONTEXT.md` is required for `handoff`.
- If the source session folder does not exist, stop and report the issue.
- If the source session folder exists but does not contain `CONTEXT.md`, stop and report the missing `CONTEXT.md`.
- If the source session folder contains only `HISTORY.md` or other generated documents, stop and report the missing `CONTEXT.md`.
- When source validation fails, do not create checkpoint files, infer missing checkpoint content, create a target folder, classify artifacts, copy files, or search other folders.

## Non-Checkpoint Artifact Handling

- Classify only non-checkpoint files located inside the source session folder.
- Do not copy project files or any file outside the source session folder.
- Classify source-folder artifacts using source `CONTEXT.md` sections such as `Relevant Files`, `Work Artifacts`, `TODO`, `Next Actions`, and `Known Risks`.
- Treat source-folder files that still affect future decisions or implementation as still-relevant artifacts.
- Treat rejected, deferred, superseded, stale, or purely historical process documents as historical/stale artifacts.
- Do not stop to ask for confirmation before copying or discarding non-checkpoint source-folder artifacts.
- Record copied and discarded artifacts in the handoff entry and final output so the user can review and request follow-up corrections.
- `Discarded` means not copied into the target session folder. Never delete source files.

## Target Checkpoint Handling

- Target `CONTEXT.md` must be a clean current-state snapshot, not a mechanical copy of source `CONTEXT.md`.
- Target `CONTEXT.md` must include one concise provenance note under `Current State` naming the source session folder.
- Detailed handoff records belong in target `HISTORY.md`, not target `CONTEXT.md`.
- Target `HISTORY.md` must preserve useful source history and append one handoff entry.
- The handoff entry must record source folder, target folder, copied checkpoint files, copied artifacts, discarded artifacts, reference rewrites, user-requested corrections, missing optional source files, and unresolved uncertainty. See `file-contracts.md` for the handoff entry structure.

## Output Style

First include a brief handoff result summary:

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
