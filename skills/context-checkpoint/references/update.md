# Update Command

## Table of Contents

- [Session Folder Resolution](#session-folder-resolution)
- [Access Mode](#access-mode)
- [Workflow](#workflow)
- [Output Style](#output-style)

This reference covers the `update` command only. Apply it together with the `Global Invariants` in `SKILL.md`. Read `file-contracts.md` before writing or validating `CONTEXT.md`, `HISTORY.md`, or `Work Artifacts`.

## Session Folder Resolution

Resolve the current session folder:

1. Determine whether the current conversation already has a session folder.
2. If a matching folder exists, reuse it.
3. If the current folder is unclear, ask the user whether to specify an existing session folder or create a new session folder.
4. Create a new folder only when the user chooses to create one or no existing session folder can be identified from the current conversation.

## Access Mode

- May read related project files and existing checkpoint files in the current session folder.
- May create the current session folder when needed.
- May write only `CONTEXT.md` and `HISTORY.md` in the current session folder.
- Must not create or modify other artifacts unless the user explicitly asks for additional files.

## Workflow

1. Resolve the current session folder.
2. Read existing `CONTEXT.md` and `HISTORY.md` if present.
3. Compare checkpoint content with the current conversation state and project files.
4. Rewrite `CONTEXT.md` as a clean current-state snapshot. Do not mechanically append history.
5. Maintain `Work Artifacts` in `CONTEXT.md` every time. It may be empty when no work artifacts exist.
6. Append one new entry to `HISTORY.md`. Do not merge new history into old entries.
7. Preserve useful existing history. Do not delete old entries unless the user explicitly requests cleanup.
8. Move stale process notes, rejected approaches, superseded assumptions, and decision rationale out of `CONTEXT.md` and into the new `HISTORY.md` entry when still useful.

`update` must create or update both `CONTEXT.md` and `HISTORY.md`. See `file-contracts.md` for both file structures.

## Output Style

Keep the user-facing response brief. Mention the session folder and the files updated.
