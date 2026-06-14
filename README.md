# SnowyAgentSkills

Language: English | [中文](README.zh-CN.md)

## Table of Contents

- [Overview](#overview)
- [Available Skills](#available-skills)
  - [context-checkpoint](#context-checkpoint)
- [Add Skills](#add-skills)
- [Repository Layout](#repository-layout)

## Overview

SnowyAgentSkills is a collection repository for reusable agent skills.

Each skill lives under `skills/<skill-name>/` as a self-contained folder. The repository is intended to stay agent-neutral so different agent runtimes can adopt the skill content that fits their own loading model.

## Available Skills

### context-checkpoint

- Description: Manage session context for long-running, multi-session, handoff-based, or review-driven agent work.

- Documentation: [English](skills/context-checkpoint/README.md), [中文](skills/context-checkpoint/README.zh-CN.md)

## Add Skills

Add new skills under:

```text
skills/<skill-name>/
```

Each skill folder must include:

- `SKILL.md`: Required skill metadata and instructions.

Optional resources can be added only when the skill needs them:

- `README.md`
- `README.zh-CN.md`
- `agents/`
- `scripts/`
- `references/`
- `assets/`

Use `agents/` for optional runtime-specific metadata, such as `agents/openai.yaml`.

Keep each skill self-contained and avoid placing skill-specific documentation in the repository root.

## Repository Layout

```text
SnowyAgentSkills/
|-- skills/
|   `-- context-checkpoint/
|       |-- SKILL.md
|       |-- README.md
|       |-- README.zh-CN.md
|       |-- references/
|       `-- agents/
|           `-- openai.yaml
|-- README.md
|-- README.zh-CN.md
|-- LICENSE
`-- .gitignore
```
