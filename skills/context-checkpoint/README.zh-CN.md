# context-checkpoint

## Table of Contents

- [概览](#概览)
- [名词定义](#名词定义)
  - [会话文件夹](#会话文件夹)
  - [Checkpoint 文件](#checkpoint-文件)
  - [Review 文件](#review-文件)
- [功能](#功能)
- [使用示例](#使用示例)
- [Update](#update)
- [Restore](#restore)
- [Handoff](#handoff)
- [Review](#review)
- [参考工作流](#参考工作流)
  - [单会话持续工作](#单会话持续工作)
  - [共享会话协作](#共享会话协作)
  - [审阅反馈闭环](#审阅反馈闭环)
  - [Handoff 或分支接管](#handoff-或分支接管)
  - [Restore 冲突保护](#restore-冲突保护)

语言: [English](README.md) | 中文

## 概览

`context-checkpoint` 是一个 agent 无关的上下文管理 skill, 用于在长任务或多会话工作中保存, 重建, 传递和审阅会话上下文.

这个 skill 围绕会话文件夹和 Markdown checkpoint 文件组织. 会话文件夹是上下文身份, agent 或会话只是按所运行命令读取或写入该上下文的协作者.

`SKILL.md` 是轻量路由层, 命令细节分别位于 `references/` 目录下.

## 名词定义

### 会话文件夹

会话文件夹用于保存一条上下文主线:

```text
.agent-sessions/{YYYYMMDD}-{short-kebab-case-session-summary}/
```

当会话文件夹不明确时, skill 会根据请求的功能询问用户指定已有文件夹, 或确认是否创建新文件夹.

### Checkpoint 文件

Checkpoint 文件用于重建会话上下文:

- `CONTEXT.md`: 只保存当前仍然有效且会影响后续工作的信息, 包括当前目标, 当前状态, 已确认决策, 生效中的约束, 已知风险, 开放问题, TODO, 下一步行动, 相关文件和工作产物.
- `HISTORY.md`: 保存历史摘要, 故障排查记录, 已拒绝或暂缓方案, 假设, 备注和 handoff 审计条目.

`CONTEXT.md` 是重建会话上下文的主入口. `HISTORY.md` 只在需要历史背景时读取.

### Review 文件

`REVIEW.md` 保存一个会话文件夹的最新 review 结果. 它由 `review` 创建, 可被 `restore` 作为导航提示读取.

`REVIEW.md` 不是 checkpoint 文件. 其中 findings 反映审阅时刻的工作状态, 后续工作前必须对照当前项目文件重新核验.

## 功能

这个 skill 提供四个核心功能:

- `update`: 创建或刷新当前会话 checkpoint.
- `restore`: 从当前会话 checkpoint 或指定会话文件夹中的 checkpoint 文件重建会话上下文.
- `handoff`: 从另一个会话 checkpoint 重建会话上下文, 并将重建后的 checkpoint 保存到当前会话文件夹.
- `review`: 审阅指定会话文件夹中 checkpoint 所指向的实际工作内容, 并将结果写入该文件夹的 `REVIEW.md`.

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

## Update

`update` 用于创建或刷新当前会话 checkpoint.

权限:

- 可以读取已有 checkpoint 文件和相关项目文件.
- 只可以写当前会话文件夹中的 `CONTEXT.md` 和 `HISTORY.md`.
- 不得修改项目文件或其他会话产物.

行为:

- 解析当前会话文件夹.
- 如果已有 `CONTEXT.md` 和 `HISTORY.md`, 会先读取它们.
- 当项目文件和 checkpoint 内容冲突时, 优先相信当前项目文件.
- 将 `CONTEXT.md` 重写为干净的当前状态快照, 将过时, 被否决或对后续工作无价值的内容移出 `CONTEXT.md`.
- 向 `HISTORY.md` 追加一个新的历史条目, 不把新历史合并进旧条目.

## Restore

`restore` 用于从当前会话 checkpoint 或显式指定的会话文件夹中的 checkpoint 文件重建会话上下文.

权限:

- 默认只读.
- 可以读取 checkpoint 文件, `REVIEW.md` 和相关项目文件.
- 不得复制 checkpoint 文件, 写会话文件夹, 修改项目文件或执行 TODO, 除非用户明确要求后续工作.

行为:

- 未提供路径时使用当前会话文件夹.
- 提供路径时使用指定文件夹作为恢复来源.
- 如果当前会话已有 checkpoint 文件, 且用户指定了另一个会话文件夹, 则停止执行.
- 如果存在 `CONTEXT.md`, 优先读取它.
- 只有在需要历史背景时读取 `HISTORY.md`.
- 当存在 `REVIEW.md` 时, 将其中 findings 作为需要重新核验的 open issues.
- 缺少或只有部分 checkpoint 文件时明确报告, 不自行猜测.
- 当项目文件和 checkpoint 内容冲突时, 优先相信当前项目文件.

## Handoff

`handoff` 用于从另一个会话 checkpoint 重建会话上下文, 并将重建后的 checkpoint 保存到当前会话文件夹.

权限:

- 源会话文件夹只读.
- 目标会话文件夹可读写.
- 只可以复制源会话文件夹内仍然有效的 non-checkpoint artifacts.
- 不得复制源会话文件夹外的文件.

行为:

- 要求源会话文件夹必须包含 `CONTEXT.md`.
- 源会话文件夹校验失败时停止执行.
- 不创建缺失的源会话文件夹 checkpoint 文件.
- 不搜索其他文件夹, 除非用户明确要求 discovery.
- 复制前先分类源会话文件夹内的 non-checkpoint artifacts.
- 在目标会话文件夹 `CONTEXT.md` 写入简短 provenance note.
- 向目标会话文件夹 `HISTORY.md` 追加 handoff 审计条目.

## Review

`review` 用于客观审阅指定会话文件夹中 checkpoint 所指向的实际工作内容, 再将结果写入该文件夹的 `REVIEW.md`, 不恢复上下文, 不继续实现.

权限:

- 必须显式指定被审阅会话文件夹.
- 可以读取 checkpoint 文件, 被审阅会话文件夹 artifacts 和相关项目文件.
- 只可以写被审阅会话文件夹中的 `REVIEW.md`.
- 不得修改被审阅会话文件夹的 checkpoint 文件, 项目文件, 其他 artifacts 或执行 TODO.

行为:

- 要求被审阅会话文件夹必须包含 `CONTEXT.md`.
- 将被审阅会话文件夹的 `HISTORY.md` 视为可选历史背景.
- 将 `CONTEXT.md`, `HISTORY.md` 和 `Work Artifacts` 作为 review brief 和导航索引.
- 审阅实际被引用的工作内容, 例如被修改的项目文件, 生成产物, 测试, 配置或文档.
- 首先判断会话是否完成 `Current Goal`.
- 然后审查是否存在缺陷, 逻辑漏洞, 边界问题, 遗漏验证, 冲突或不一致.
- 每条 finding 包含严重度, 证据, 影响和推荐修复方案.
- Checkpoint 自身质量问题放入 `Checkpoint Quality`, 不放入 `Findings`, 除非它直接导致无法评估实际工作.
- 将 `REVIEW.md` 写入被审阅会话文件夹, 覆盖此前的 `REVIEW.md`, 并同时在回复中输出 review.

## 参考工作流

### 单会话持续工作

单个会话在上下文压缩前运行 `update`, 将当前仍然有效的信息写入 checkpoint. 上下文压缩后运行 `restore`, 从 checkpoint 重建会话上下文, 避免有用信息因 `/compact` 丢失.

```text
[会话 A 工作]
      |
      v
[update 写入 checkpoint]
      |
      v
[/compact 压缩上下文]
      |
      v
[restore 重建会话上下文]
      |
      v
[继续工作]
      |
      v
[update 刷新 checkpoint]
```

### 共享会话协作

多个 agent 或多个会话使用同一个会话文件夹作为共享上下文主线. 每个协作者对该文件夹运行 `restore`, 继续工作, 再运行 `update` 把新状态写回.

```text
[Agent A 工作]
        |
        v
[Agent A update]
        |
        v
[共享会话文件夹]
        |
        v
[Agent B restore]
        |
        v
[Agent B 工作]
        |
        v
[Agent B update]
        |
        v
[共享会话文件夹]
        |
        v
[Agent A restore]
```

### 审阅反馈闭环

审阅者可以在另一个 agent 或会话中对被审阅会话文件夹运行 `review`, 将结果写入该文件夹的 `REVIEW.md`. 后续原会话或其他协作者对同一文件夹运行 `restore` 时, 会把这些 findings 浮出为需要重新核验的 open issues.

```text
[Agent A (Executor) update]
          |
          v
[被审阅会话文件夹]
          |
          v
[Agent B (Reviewer) review 实际工作内容]
          |
          v
[写入 REVIEW.md]
          |
          v
[Agent A (Executor) restore]
          |
          v
[浮出 findings 并重新核验]
```

### Handoff 或分支接管

一个会话文件夹作为只读源会话文件夹, 当前会话文件夹作为可写目标会话文件夹. 当上下文需要迁移或派生到不同会话文件夹时使用这个工作流.

```text
[源会话文件夹]
  CONTEXT.md
  HISTORY.md
  artifacts
      |
      v
[handoff 重建上下文]
      |
      v
[目标会话文件夹]
  CONTEXT.md
  HISTORY.md
  copied artifacts
```

### Restore 冲突保护

如果当前会话已经有 checkpoint 文件, 又尝试 `restore` 另一个会话文件夹, `restore` 会停止, 避免混合两条上下文主线. 需要迁移时使用 `handoff`, 需要协作时共享同一个会话文件夹.

```text
[当前会话已有 checkpoint]
      |
      v
[restore 另一个会话文件夹]
      |
      v
[停止]
      |
      +-- 迁移或分支: 使用 handoff
      |
      +-- 协作接力: 共享同一会话文件夹
```

后续迭代应保持这些工作流边界, 除非明确要调整工作流模型本身.
