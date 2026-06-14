# SnowyAgentSkills

语言: [English](README.md) | 中文

## Table of Contents

- [概览](#概览)
- [可用 Skills](#可用-skills)
  - [context-checkpoint](#context-checkpoint)
- [新增 Skills](#新增-skills)
- [仓库结构](#仓库结构)

## 概览

SnowyAgentSkills 是一个可复用 agent skills 集合仓库.

每个 skill 都位于 `skills/<skill-name>/` 下, 并作为自包含目录独立维护. 仓库目标是保持 agent-neutral, 让不同 agent runtime 都能按自己的加载模型采用合适的 skill 内容.

## 可用 Skills

### context-checkpoint

- 简介: 管理 long-running, multi-session, handoff-based 或 review-driven agent work 中的会话上下文.

- 文档: [English](skills/context-checkpoint/README.md), [中文](skills/context-checkpoint/README.zh-CN.md)

## 新增 Skills

新增 skill 时放入:

```text
skills/<skill-name>/
```

每个 skill 文件夹必须包含:

- `SKILL.md`: 必需的 skill 元数据和说明.

只有在 skill 需要时才添加可选资源:

- `README.md`
- `README.zh-CN.md`
- `agents/`
- `scripts/`
- `references/`
- `assets/`

`agents/` 用于可选 runtime-specific metadata, 例如 `agents/openai.yaml`.

保持每个 skill 自包含, 不要把 skill 专属文档放在仓库根目录.

## 仓库结构

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
