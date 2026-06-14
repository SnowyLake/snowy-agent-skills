# File Contracts

## Table of Contents

- [CONTEXT.md](#contextmd)
- [Work Artifacts](#work-artifacts)
- [HISTORY.md](#historymd)
- [Handoff Entry](#handoff-entry)
- [REVIEW.md](#reviewmd)

This reference defines the structure of the checkpoint and review files shared by all `context-checkpoint` commands. Command references point here instead of repeating these structures.

## CONTEXT.md

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

During `handoff`, target `CONTEXT.md` must include one concise provenance note under `Current State` naming the source session folder. Do not place copied/discarded file lists, user-requested corrections, or detailed reference rewrite records in `CONTEXT.md`.

## Work Artifacts

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

## HISTORY.md

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

## Handoff Entry

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

## REVIEW.md

`REVIEW.md` stores the latest `review` result for a session folder. `review` writes it into the reviewed session folder, overwriting any previous `REVIEW.md`. Use this structure:

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

- `Reviewed Session`: The reviewed session folder this review targets.
- `Review Date`: The review date in `YYYY-MM-DD` format.
- `Goal Completion`, `Findings`, `Checkpoint Quality`, `Open Questions`, `Summary`: Same intent as the `review` output sections defined in `review.md`.

`REVIEW.md` is a review artifact, not a checkpoint file. `restore` and `handoff` treat it as a navigation hint, not as current state. `handoff` classifies it like any other non-checkpoint source-folder artifact.
