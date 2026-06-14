---
name: context-checkpoint
description: Manage CONTEXT.md and HISTORY.md session checkpoints. Use for update, restore, handoff, or checkpoint-guided work review requests that refresh, rebuild, transfer, or audit session context.
---

# Context Checkpoint

## Table of Contents

- [Overview](#overview)
- [Command Selection](#command-selection)
- [Execution](#execution)
- [Global Invariants](#global-invariants)
- [Language and Formatting](#language-and-formatting)

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

## Execution

Before running a command, read its reference file under `references/`. Each command reference defines that command's session folder resolution, access mode, workflow, and output style. Apply the `Global Invariants` in this file together with the command reference. Do not duplicate the routing logic or global rules inside the command references.

Read `references/file-contracts.md` before any command reads, writes, validates, summarizes, or outputs `CONTEXT.md`, `HISTORY.md`, `REVIEW.md`, `Work Artifacts`, or handoff entries. Do not reconstruct file structures from memory when the file contracts are available.

Command references:

- `references/update.md`: Refresh the current session checkpoint.
- `references/restore.md`: Rebuild session context from a checkpoint.
- `references/handoff.md`: Transfer a checkpoint into the current session folder.
- `references/review.md`: Review the actual work behind a checkpoint and write `REVIEW.md`.

Shared file contracts:

- `references/file-contracts.md`: Structure of `CONTEXT.md`, `HISTORY.md`, and `REVIEW.md`, including `Work Artifacts` and handoff entry formats.

## Global Invariants

These rules apply to every command. Command references must not repeat them.

- Store checkpoint files under the project root using `.agent-sessions/{YYYYMMDD}-{short-kebab-case-session-summary}/`. Use lowercase kebab-case for the summary segment and prefer concise session names.
- When a session folder is unclear, do not inspect `.agent-sessions/` to guess a semantically matching folder unless the user explicitly asks for discovery or listing.
- When checkpoint files conflict with current project files, prefer current project files.
- Treat `Work Artifacts` as a navigation index only. It is not a complete diff, not a source of truth, and not a handoff copy allowlist.
- Do not execute TODO items, modify project files, or continue implementation unless the user explicitly asks for follow-up work.

## Language and Formatting

When writing checkpoint Markdown files or review output:

- Keep the required file names and section headings from `references/file-contracts.md` unless project-level instructions explicitly override them.
- Treat English headings in this skill as structural contracts, not as the default body language.
- Choose body text language according to project-level or user-level instructions first.
- If no project-level or user-level language instruction exists, use the current conversation language for body text.
- Apply this rule to all checkpoint Markdown written by this skill, including `CONTEXT.md`, `HISTORY.md`, handoff entries, and `REVIEW.md`.
