# context-checkpoint-skill

语言: [English](README.md) | 中文

## Table of Contents

- [概览](#概览)
- [能力](#能力)
- [Checkpoint 文件](#checkpoint-文件)
- [会话文件夹](#会话文件夹)
- [Update 行为](#update-行为)
- [Restore 行为](#restore-行为)
- [Handoff 行为](#handoff-行为)
- [Scripts](#scripts)
- [仓库结构](#仓库结构)

## 概览

`context-checkpoint-skill` 是一个轻量级 Codex skill, 用于在长任务或多会话工作中保存和重建任务上下文.

它使用 `CONTEXT.md` 保存当前仍然有效的任务状态, 使用 `HISTORY.md` 保存历史决策, 重要发现, 已拒绝方案和 handoff 记录.

## 能力

这个 skill 定义了三个聚焦能力:

- `update`: 创建或刷新当前会话 checkpoint.
- `restore`: 从当前会话 checkpoint 重建任务上下文, 适用于上下文被压缩后的恢复.
- `handoff`: 从另一个会话 checkpoint 重建当前会话任务上下文, 适用于多会话间上下文的传递.

## Checkpoint 文件

`CONTEXT.md` 保存仍然影响后续工作的当前任务状态, 包括:

- 当前目标: 本会话正在处理的目标.
- 当前状态: 最新仍然有效的实现状态或任务状态.
- 已确认决策: 后续工作仍需遵守的决策.
- 生效中的约束: 仍然需要遵守的要求, 限制或规则.
- 相关文件: 与任务直接相关的文件, 文件夹或资源.
- 待办事项: 仍然有效的剩余工作项.
- 开放问题: 需要讨论, 研究或验证的问题.
- 已知风险: 需要留意的风险, 陷阱或不确定点.
- 下一步行动: 接下来最具体的 1-3 个行动.

`HISTORY.md` 保存历史上下文, 包括:

- 重要发现: 解释任务背景的重要发现.
- 决策: 历史选择及其原因.
- 已拒绝或暂缓的方案: 已被否决或推迟的选项.
- 假设: 会话中形成的已验证或未验证假设.
- 备注: 便于之后追溯的额外上下文.
- Handoff 审计条目: 记录复制文件, 丢弃文件, 引用路径修正和用户要求的后续修正.

## 会话文件夹

Checkpoint 文件保存在:

```text
.agent-sessions/{YYYYMMDD}-{short-kebab-case-session-summary}/
```

当会话文件夹不明确时, skill 不会自行猜测. 它会询问用户是指定已有会话文件夹, 还是创建新的会话文件夹.

## Update 行为

`update` 用于创建或刷新当前会话 checkpoint.

在 update 过程中:

- skill 会解析当前会话文件夹.
- 如果已有 `CONTEXT.md` 和 `HISTORY.md`, 会先读取它们.
- 当项目文件和 checkpoint 内容冲突时, 优先相信当前项目文件.
- `CONTEXT.md` 会被重写为干净的当前状态快照.
- `HISTORY.md` 会追加一个新的历史条目, 不会把新历史合并进旧条目.
- 已有的有用历史记录会被保留.
- 仍然有用的过期过程记录和已被取代的假设会从 `CONTEXT.md` 移入 `HISTORY.md`.

## Restore 行为

`restore` 用于从当前会话 checkpoint 重建任务上下文, 适用于上下文被压缩后的恢复.

在 restore 过程中:

- skill 会解析当前会话文件夹.
- 如果存在 `CONTEXT.md`, 优先读取它.
- 只有在需要历史背景时才读取 `HISTORY.md`.
- 如果只有 `CONTEXT.md`, skill 会从它恢复.
- 如果只有 `HISTORY.md`, skill 会尽量重建背景, 并说明缺少当前状态快照.
- 如果两个文件都不存在, skill 会报告没有找到可用 checkpoint 文件.
- 当项目文件和 checkpoint 内容冲突时, 优先相信当前项目文件.
- restore 默认只读, 除非用户明确要求后续工作.

## Handoff 行为

`handoff` 用于从另一个会话 checkpoint 重建当前会话任务上下文, 适用于多会话间上下文的传递.

在 handoff 过程中:

- source session folder 只读.
- source session folder 必须包含 `CONTEXT.md`.
- 如果 source 校验失败, skill 会停止并报告问题.
- skill 不会创建缺失的 source checkpoint 文件.
- skill 不会搜索其他文件夹, 除非用户明确要求 discovery.
- 非 checkpoint 工作产物会先分类, 再决定是否复制.
- skill 会直接复制仍然有效的工作产物, 跳过历史性或过期工作产物, 不在中途阻塞等待确认.
- 最终输出会报告 copied artifact 和 discarded artifact, 用户如不满意可再要求后续修正.
- target `CONTEXT.md` 会在 `Current State` 下包含简短 provenance note.
- target `HISTORY.md` 会记录 copied files, discarded files, reference rewrites, user-requested corrections 和 unresolved uncertainty.

## Scripts

`scripts/` 文件夹包含用于向 Codex skills 目录安装或移除本 skill 的 Windows batch 脚本:

- `codex-install-symbolic-link.bat`: 删除已有的 `%USERPROFILE%\.codex\skills\context-checkpoint` 条目, 然后以目录 symbolic link 形式安装本 skill.
- `codex-install-copy.bat`: 删除已有的 `%USERPROFILE%\.codex\skills\context-checkpoint` 条目, 然后通过完整复制 skill 目录安装本 skill.
- `codex-uninstall.bat`: 如果 `%USERPROFILE%\.codex\skills\context-checkpoint` 存在, 则移除它.

每个脚本都会在退出前暂停, 方便双击运行时查看结果.

## 仓库结构

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
