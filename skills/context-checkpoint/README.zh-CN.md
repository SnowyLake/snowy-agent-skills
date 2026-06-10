# context-checkpoint

语言: [English](README.md) | 中文

## Table of Contents

- [概览](#概览)
- [功能](#功能)
- [使用示例](#使用示例)
- [Checkpoint 文件](#checkpoint-文件)
- [会话文件夹](#会话文件夹)
- [Access Modes](#access-modes)
- [Update](#update)
- [Restore](#restore)
- [Handoff](#handoff)
- [Review](#review)

## 概览

`context-checkpoint` 是一个 agent 无关的上下文管理 skill, 用于在长任务或多会话工作中保存, 重建, 传递和审阅会话上下文.

checkpoint 是当前会话的上下文快照, 每个 checkpoint 包含两个文件: `CONTEXT.md` 和 `HISTORY.md`.

- `CONTEXT.md` 只保存当前仍然有效且会影响后续工作的信息.
- `HISTORY.md` 保存历史摘要, 故障排查记录, 已拒绝或暂缓方案和推理归档.

## 功能

这个 skill 提供四个核心功能:

- `update`: 创建或刷新当前会话的 checkpoint.
- `restore`: 从当前会话 checkpoint 或指定 session folder 中的 checkpoint 重建会话上下文.
- `handoff`: 从另一个会话 checkpoint 重建会话上下文, 并将重建后的 checkpoint 保存到当前会话文件夹.
- `review`: 客观审阅指定 session folder 中的 checkpoint 所指向的实际工作内容, 默认不恢复上下文, 不继续实现.

## 使用示例

命令式请求:

```text
$context-checkpoint update
$context-checkpoint restore
$context-checkpoint restore .agent-sessions/20260605-example-session
$context-checkpoint handoff .agent-sessions/20260605-example-session
$context-checkpoint review .agent-sessions/20260605-example-session
```

显式自然语言请求:

```text
$context-checkpoint 更新上下文.
$context-checkpoint 从当前会话 checkpoint 恢复上下文.
$context-checkpoint 从 .agent-sessions/20260605-example-session 恢复上下文.
$context-checkpoint 从 .agent-sessions/20260605-example-session handoff 上下文到当前会话.
$context-checkpoint review .agent-sessions/20260605-example-session.
```

完全隐式的自然语言请求不被禁止, 但推荐显式调用 `$context-checkpoint`.

## Checkpoint 文件

`CONTEXT.md` 保存仍然影响后续工作的当前会话信息, 包括:

- 当前目标: 本会话正在处理的目标.
- 当前状态: 最新仍然有效的实现状态或会话状态.
- 已确认决策: 后续工作仍需遵守的决策.
- 生效中的约束: 仍然需要遵守的要求, 限制或规则.
- 已知风险: 需要留意的风险, 陷阱或不确定点.
- 开放问题: 需要讨论, 研究或验证的问题.
- 待办事项: 仍然有效的剩余工作项.
- 下一步行动: 接下来最具体的行动.
- 相关文件: 与理解本会话直接相关的文件, 文件夹或资源.
- 工作产物: 本会话创建, 修改, 删除或移动过的主要文件.

`HISTORY.md` 保存历史上下文, 包括:

- 重要发现: 解释会话背景的重要发现.
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

当会话文件夹不明确时, skill 会根据请求的 capability 询问用户指定已有会话文件夹, 或选择是否创建新的会话文件夹.

## Access Modes

- `update`: 可读取相关文件, 只可写当前会话文件夹中的 `CONTEXT.md` 和 `HISTORY.md`.
- `restore`: 只读. 默认不复制 checkpoint 文件, 不写会话文件夹, 不修改项目文件, 不执行 TODO.
- `handoff`: source session folder 只读. target session folder 可读写. 只能复制 source session folder 内的 non-checkpoint artifacts.
- `review`: 只读. 默认只输出 review 结果, 不修改 checkpoint 文件, 不修改项目文件, 不执行 TODO.

## Update

`update` 用于创建或刷新当前会话 checkpoint.

在 update 过程中:

- skill 会解析当前会话文件夹.
- 如果已有 `CONTEXT.md` 和 `HISTORY.md`, 会先读取它们.
- 可以读取相关项目文件.
- 当项目文件和 checkpoint 内容冲突时, 优先相信当前项目文件.
- `CONTEXT.md` 会被重写为干净的当前状态快照.
- 每次都要维护 `Work Artifacts`, 但允许为空.
- `HISTORY.md` 会追加一个新的历史条目, 不会把新历史合并进旧条目.
- 已有的有用历史记录会被保留.
- 仍然有用的过期过程记录和已被取代的假设会从 `CONTEXT.md` 移入 `HISTORY.md`.

## Restore

`restore` 用于从当前会话 checkpoint 或显式指定的 session folder 中的 checkpoint 重建会话上下文.

在 restore 过程中:

- skill 会解析 restore source session folder.
- 如果没有提供路径, 默认使用当前会话文件夹.
- 如果提供路径, 使用该文件夹作为 restore source.
- 如果当前会话文件夹已有 checkpoint 文件, 且用户指定了另一个 session folder, restore 会停止, 避免混合两个上下文.
- 如果存在 `CONTEXT.md`, 优先读取它.
- 只有在需要历史背景时才读取 `HISTORY.md`.
- 读取 `Work Artifacts` 来快速了解先前工作范围, 但不把它当作完整事实来源.
- 如果只有 `CONTEXT.md`, skill 会从它恢复.
- 如果只有 `HISTORY.md`, skill 会尽量重建背景, 并说明缺少当前状态快照.
- 如果两个文件都不存在, skill 会报告没有找到可用 checkpoint 文件.
- 当项目文件和 checkpoint 内容冲突时, 优先相信当前项目文件.
- restore 默认只读, 除非用户明确要求后续工作.

## Handoff

`handoff` 用于从另一个会话 checkpoint 重建会话上下文, 并将重建后的 checkpoint 保存到当前会话文件夹.

在 handoff 过程中:

- source session folder 只读.
- target session folder 可读写.
- source session folder 必须包含 `CONTEXT.md`.
- 如果 source 校验失败, skill 会停止并报告问题.
- skill 不会创建缺失的 source checkpoint 文件.
- skill 不会搜索其他文件夹, 除非用户明确要求 discovery.
- 读取 `Work Artifacts` 来快速了解先前工作范围, 但不把它当作完整事实来源.
- 非 checkpoint 工作产物会先分类, 再决定是否复制.
- skill 只能复制 source session folder 内仍然有效的工作产物, 不得复制 source session folder 外的文件.
- 最终输出会报告 copied artifact 和 discarded artifact, 用户如不满意可再要求后续修正.
- target `CONTEXT.md` 会在 `Current State` 下包含简短 provenance note.
- target `HISTORY.md` 会记录 copied files, discarded files, reference rewrites, user-requested corrections 和 unresolved uncertainty.

## Review

`review` 用于客观审阅指定 session folder 中的 checkpoint 所指向的实际工作内容, 默认不恢复上下文, 不继续实现.

在 review 过程中:

- 用户必须指定 source session folder.
- source session folder 必须包含 `CONTEXT.md`.
- `HISTORY.md` 可选. 如果缺失, review 继续执行, 但需要说明历史背景不足.
- `CONTEXT.md`, `HISTORY.md` 和 `Work Artifacts` 用作 review brief 和导航索引.
- 实际 review 目标是 checkpoint 指向的工作内容, 例如被修改的项目文件, 生成产物, 测试, 配置或文档.
- 读取 `Work Artifacts` 来快速了解先前工作范围, 但不把它当作完整事实来源.
- 首要审阅问题是该会话是否完成 `Current Goal`.
- 然后审阅实际被引用的工作内容是否存在缺陷, 逻辑漏洞, 边界问题, 遗漏验证, 冲突或不一致.
- 每条 finding 应包含严重度, 证据, 影响和推荐修复方案.
- checkpoint 自身的质量问题应放在 `Checkpoint Quality`, 不放在 `Findings`, 除非它直接导致无法评估实际工作.
- 当项目文件和 checkpoint 声明冲突时, 优先相信当前项目文件.
- review 只读, 默认只输出 review 结果.

Review 输出使用以下章节:

```md
## Goal Completion

## Findings

## Checkpoint Quality

## Open Questions

## Summary
```
