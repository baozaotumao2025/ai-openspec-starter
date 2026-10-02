# 会话连续性规则

## 适用范围

本规则用于正在实施中的 OpenSpec Change。

当工作需要跨会话继续、被中断、出现阻塞，或当前任务已经复杂到难以在现有上下文中安全继续时，使用 Handoff 保存实施状态。

## Handoff 位置

当前 Change 的会话交接文件统一保存在：

`openspec/changes/<change-id>/handoff.md`

Handoff 属于当前 Change 的临时实施信息。

不得写入：

- `openspec/specs/`
- `docs/context/`
- 项目级长期规则

Change 归档后，handoff 随 Change 一并保存。

## 创建 Handoff 的触发条件

出现以下任一情况时，应创建或更新 `handoff.md`：

- 工作将在另一个会话继续；
- 当前工作需要暂停；
- 出现无法继续实施的阻塞项；
- 已完成多个步骤，剩余工作仍较多；
- 当前上下文已经不足以安全保留关键实现细节。

不要依赖不可观察的 token 百分比作为唯一触发条件。

## Handoff 内容

`handoff.md` 至少包含：

### STATUS

当前 Change 和当前 Task 的状态。

### DONE

已经完成并验证的工作。

只记录已经实际完成的内容。

### NEXT

下一步应执行的具体 Task 或动作。

必须足够明确，使新的 Agent 无需重新探索整个 Change 就能继续。

### DECISIONS

本次实施过程中已经确认、且会影响后续工作的决定。

如果决定已经正式写入 Specs 或 Design，只记录引用，不复制完整内容。

### BLOCKED

当前阻塞项，包括：

- 错误；
- 未决决策；
- 缺失依赖；
- 未完成验证。

不存在阻塞时明确写：

`None`

## 恢复工作

恢复一个存在 `handoff.md` 的 Change 时：

1. 读取当前 Change 的 artifacts；
2. 读取 `tasks.md`；
3. 读取 `handoff.md`；
4. 确认 DONE 与实际 Git / Task 状态一致；
5. 从 NEXT 指定的位置继续。

不得仅凭 handoff 内容跳过 OpenSpec artifacts。

## 恢复汇报

继续实施前，应简要说明：

- 当前进度；
- 已完成内容；
- 关键 Decisions；
- 当前 Blocked；
- 接下来执行的 Task。

如果 handoff 与代码、Git 或 tasks 状态冲突，以可验证的当前项目状态为准，并明确指出差异。

## Handoff 边界

Handoff 不是：

- 新需求说明；
- Specs 替代品；
- Design 替代品；
- 长期项目知识库。

长期有效的信息应更新到对应 OpenSpec artifact 或正式项目文档，而不是永久堆积在 handoff 中。
