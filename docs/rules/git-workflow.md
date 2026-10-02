# Git 工作流规则

## 基本原则

OpenSpec Change 与 Git 分支生命周期保持对应。

涉及业务代码的 Change 不直接在主分支上实施。

## Change 分支

每个 OpenSpec Change 使用独立分支：

`change/<change-id>`

该分支贯穿：

- proposal；
- specs；
- design；
- tasks；
- apply；
- verify；
- archive 前的最终确认。

不得将多个无关 Change 混入同一开发分支。

## 主分支保护

默认不得：

- 直接在主分支实施业务 Change；
- 对主分支执行 force push；
- 为绕过冲突重写已经共享的主分支历史。

如果仓库实际默认分支不是 `main`，以当前仓库真实默认分支为准。

## 原子提交

一个提交应对应一个逻辑完整且已经验证的原子 Task。

不得：

- 将多个无关 Task 混为一次提交；
- 把与当前 Change 无关的清理或格式化混入提交；
- 为了制造“干净历史”而隐藏失败过程对应的必要修复。

提交前必须执行当前 Task 要求的确定性验证。

## 提交信息

默认采用 Conventional Commits 风格：

`<type>(<scope>): <description>`

常见 type 包括：

- `feat`
- `fix`
- `refactor`
- `test`
- `docs`
- `chore`

如果项目后续建立更具体的提交规范，以正式项目规则为准。

## 归档与合流

Change 完成实施与验证后：

1. 完成 OpenSpec 归档流程；
2. 确认长期行为已正确进入主 Specs；
3. 确认开发分支不存在未提交的 Change 相关修改；
4. 再按仓库当前协作流程合流到默认分支。

不得把“Git 已合并”当作“OpenSpec 已归档”的替代。

## 冲突处理

发生合并或变基冲突时：

- 根据当前 Specs、Design 和实际代码语义解决；
- 不得只选择 ours / theirs 来机械消除冲突；
- 涉及行为变化时重新执行相关验证。

## 仓库事实优先

执行 Git 操作前应确认：

- 当前分支；
- 默认分支；
- 工作区状态；
- 是否存在未提交修改。

不得假设默认分支一定叫 `main`，也不得覆盖用户已有的未提交工作。
