# AI OpenSpec Starter 新手入门

这是一份面向第一次使用 AI OpenSpec Starter 的实践教程。

如果你已经完成安装，并且：

```bash
./scripts/doctor.sh
./scripts/smoke-test.sh
```

都通过，那么可以从这里开始。

本教程会带你完成：

```text
创建 Change
    ↓
Proposal
    ↓
Specs
    ↓
Design
    ↓
Tasks
    ↓
Apply
    ↓
Verify
    ↓
Archive
```

---

# 1. 先理解一个核心概念

OpenSpec 的基本单位是：

```text
Change
```

一个 Change 代表：

> 一次明确、有边界、可以验证的软件变更。

例如：

```text
add-user-profile
add-password-reset
improve-search-ranking
support-dark-theme
refactor-payment-adapter
```

不要把 Change 写成：

```text
fix-stuff
update-project
do-everything
```

Change 应该尽量表达一个明确目标。

---

# 2. 开始之前

进入你的项目：

```bash
cd /path/to/my-project
```

先确认当前 OpenSpec 状态：

```bash
openspec list --json
```

正常情况下应该看到：

```json
{
  "changes": [],
  "root": {
    "path": "/path/to/my-project",
    "source": "nearest"
  }
}
```

如果 `root.path` 不是当前项目，应先停止并检查目录。

---

# 3. 创建第一个 Change

假设我们要增加：

```text
用户个人资料页面
```

创建 Change：

```bash
openspec new change add-user-profile
```

OpenSpec 会创建类似：

```text
openspec/changes/add-user-profile/
```

然后查看状态：

```bash
openspec status --change add-user-profile --json
```

最开始通常会看到：

```text
proposal = ready
specs    = blocked
design   = blocked
tasks    = blocked
```

这是正常的。

因为后续 artifact 有依赖关系。

---

# 4. Proposal：先回答“为什么做”

在写 Proposal 之前，先获取 OpenSpec 指令：

```bash
openspec instructions proposal \
  --change add-user-profile \
  --json
```

你会看到类似字段：

```text
instruction
context
rules
template
dependencies
unlocks
```

其中：

```text
context
```

是项目级上下文约束。

```text
rules
```

应该包含：

```text
Read and follow docs/rules/proposal.md.
```

这表示 Starter 的 Proposal 规则已经生效。

---

# 5. Proposal 应该写什么

Proposal 重点回答：

```text
为什么要做？
要改变什么？
影响哪些能力？
```

例如：

```markdown
# Proposal

## Why

Users currently cannot view or update their profile information.

## What Changes

- Add a profile page.
- Allow users to update their display name.
- Allow users to view their account email.

## Capabilities

### New Capabilities

- `user-profile`: User profile viewing and editing behavior.

### Modified Capabilities

None.

## Impact

- User-facing profile UI.
- Profile application service.
- User persistence layer.
```

Proposal 不应该详细写：

```text
React component 名称
SQL 字段实现
函数签名
具体代码步骤
```

这些属于后面的 Design 或 Tasks。

---

# 6. Proposal 写完以后

再次运行：

```bash
openspec status --change add-user-profile --json
```

如果 Proposal 被识别为完成，通常会看到：

```text
proposal = done
specs    = ready
design   = ready
tasks    = blocked
```

这说明：

```text
Specs
Design
```

已经可以开始。

---

# 7. Specs：定义系统必须表现出的行为

先获取 Specs 指令：

```bash
openspec instructions specs \
  --change add-user-profile \
  --json
```

确认：

```text
rules
```

包含：

```text
Read and follow docs/rules/specs.md.
```

然后根据 Proposal 中的 capability 创建：

```text
openspec/changes/add-user-profile/
└── specs/
    └── user-profile/
        └── spec.md
```

---

# 8. Specs 示例

一个简单的行为规范：

```markdown
# Spec Delta

## Purpose

Defines how authenticated users view and update their profile information.

## ADDED Requirements

### Requirement: User can view profile
The system SHALL allow an authenticated user to view their own profile information.

#### Scenario: View own profile
- **WHEN** an authenticated user opens their profile
- **THEN** the system returns that user's profile information

### Requirement: User can update display name
The system SHALL allow an authenticated user to update their own display name.

#### Scenario: Update display name
- **WHEN** the user submits a valid new display name
- **THEN** the system stores and returns the updated display name
```

---

# 9. Specs 最重要的原则

Specs 描述：

```text
WHAT
```

不是：

```text
HOW
```

应该写：

```text
系统 SHALL 做什么
```

而不是：

```text
调用 UserProfileService.updateName()
```

因为实现可以变化。

行为契约不应该跟着内部类名一起变化。

---

# 10. Scenario 为什么重要

每个 Requirement 至少应该有一个 Scenario。

Scenario 最终应该可以映射到：

```text
测试
运行验证
可观察行为
```

理想链路：

```text
Requirement
    ↓
Scenario
    ↓
Implementation
    ↓
Test
```

---

# 11. Design：决定怎么做

先获取 Design 指令：

```bash
openspec instructions design \
  --change add-user-profile \
  --json
```

确认规则：

```text
Read and follow docs/rules/design.md.
```

Design 描述：

```text
HOW
```

---

# 12. Design 示例

```markdown
# Design

## Context

The project already has authenticated users and a user persistence boundary.

## Goals / Non-Goals

**Goals:**
- Add profile reading and editing.
- Preserve the existing authentication model.
- Keep profile persistence owned by the user domain.

**Non-Goals:**
- Avatar uploads.
- Public profiles.
- Social features.

## Decisions

### Keep profile behavior inside the user domain

The user domain already owns user identity and persistence.

Alternative considered:

Creating a separate profile service.

Rejected because it would split ownership of closely related user data.

## Risks / Trade-offs

- Existing user records may not contain all future profile fields
  → introduce compatible defaults and migrations when required.
```

---

# 13. Design 中不要猜项目事实

例如你不知道项目到底使用：

```text
PostgreSQL
MySQL
SQLite
MongoDB
```

就不能直接在 Design 中写：

```text
Use PostgreSQL JSONB
```

应该先检查真实项目 Context、配置或源码。

Starter 的基本原则是：

> 不知道的事实，不猜。

---

# 14. 项目 Context 从哪里来

项目长期事实通过：

```text
docs/context/index.yaml
```

登记。

例如：

```yaml
contexts:
  tech-stack:
    path: docs/context/tech-stack.md
    description: Project runtime and framework facts
```

然后 AI 根据当前 Change 按需读取。

详细说明见：

```text
docs/ai-openspec/project-context.md
```

---

# 15. Specs 和 Design 完成以后

再次检查：

```bash
openspec status --change add-user-profile --json
```

理想状态：

```text
proposal = done
specs    = done
design   = done
tasks    = ready
```

现在才开始写 Tasks。

---

# 16. Tasks：把设计拆成可验证工作

获取 Tasks 指令：

```bash
openspec instructions tasks \
  --change add-user-profile \
  --json
```

确认：

```text
Read and follow docs/rules/tasks.md.
```

然后创建任务列表。

---

# 17. 好的 Task 长什么样

不要只写：

```markdown
- [ ] Implement profile
```

应该写：

```markdown
# Tasks

## 1. Profile Read Flow

- [ ] 1.1 Add the profile read use case and verify the authenticated-user profile test passes.
- [ ] 1.2 Expose the profile read endpoint and verify the contract test returns the expected fields.

## 2. Profile Update Flow

- [ ] 2.1 Implement display-name updates and verify valid updates persist.
- [ ] 2.2 Add validation for invalid display names and verify rejection scenarios.
```

每个 Task 最好回答两个问题：

```text
做什么？
怎么证明完成？
```

---

# 18. 为什么 Task 必须带验证方式

因为：

```text
checkbox 被打勾
```

并不能证明功能正确。

例如：

```markdown
- [x] Implement authorization
```

本身没有告诉你：

```text
权限是否真的生效？
跨用户访问是否被拒绝？
管理员路径是否正确？
```

所以 Starter 强调：

```text
Task completion
≠
Verification
```

---

# 19. 进入 Apply

Tasks 完成后运行：

```bash
openspec instructions apply \
  --change add-user-profile \
  --json
```

你应该看到：

```text
contextFiles
progress
tasks
state
instruction
context
operationGuidance
```

其中：

```text
operationGuidance
```

应该包含：

```text
When implementing tasks, read and follow docs/rules/apply.md.
```

这表示 Starter 的 Apply 规则生效。

---

# 20. Apply 的正确工作方式

Apply 阶段应该：

```text
读取 Proposal
读取 Specs
读取 Design
读取 Tasks
读取相关 Context
读取工程规则
然后实现
```

而不是：

```text
看到 Task
↓
直接写代码
```

---

# 21. Apply 遇到问题怎么办

如果实现过程中发现：

```text
Design 不合理
Spec 缺失
需求有歧义
任务范围不够
外部依赖行为与假设不同
```

不要偷偷调整实现来“凑过去”。

应该停止并明确报告。

可能需要：

```text
更新 Proposal
更新 Specs
更新 Design
更新 Tasks
```

然后再继续 Apply。

---

# 22. 权限相关任务

如果任务涉及：

```text
登录
身份
角色
权限
成员关系
资源访问
跨用户访问
API Key
服务账号
代理执行
```

Starter 会要求读取：

```text
docs/rules/authorization.md
```

通用授权模型是：

```text
principal
action
resource
context
identity source
decision point
enforcement point
```

不要默认项目一定使用：

```text
Tenant
Organization
Workspace
```

这些属于项目自己的业务模型。

---

# 23. 数据库相关任务

如果涉及：

```text
Schema
Migration
Repository
Persistence
Transaction
Data Ownership
```

应该遵循：

```text
docs/rules/database.md
```

Starter 保留的工程原则包括：

```text
Vertical Slice
Domain Boundary
Ports & Adapters
Persistence Ownership
Centralized Migration
```

---

# 24. 外部依赖相关任务

如果实现依赖：

```text
第三方 API
SDK
另一个仓库
外部服务
模型服务
基础设施
```

应该读取：

```text
docs/rules/external-dependency.md
```

不要凭印象写：

```text
“这个 API 应该支持……”
```

应该查：

```text
正式契约
源码
配置
确定性运行结果
```

---

# 25. UI / Brand 相关任务

涉及：

```text
Frontend
UI
Logo
Brand
Theme
Design Token
Skin
White-label
```

时应该读取：

```text
docs/rules/ui-frontend.md
```

Starter 的基本模型：

```text
Brand Token
    ↓
Semantic Token
    ↓
Component
```

但不假设具体框架。

---

# 26. Apply 中的 Task 完成

每完成一个 Task：

```markdown
- [ ] 1.1 ...
```

改为：

```markdown
- [x] 1.1 ...
```

OpenSpec 会读取 checkbox 状态。

重新运行：

```bash
openspec instructions apply \
  --change add-user-profile \
  --json
```

查看：

```text
progress.total
progress.complete
progress.remaining
state
```

全部完成时：

```text
state = all_done
```

---

# 27. 但 all_done 不等于真正验证通过

这是非常重要的一点。

```text
all_done
```

只说明：

```text
所有被跟踪 Task 都打勾了
```

不代表：

```text
所有 Requirement 正确实现
所有 Scenario 已验证
所有高风险行为正确
所有测试通过
```

所以还需要 Verify。

---

# 28. OpenSpec 原生 Verify

Starter 保留 OpenSpec 自带 Verify workflow。

它可以作为：

```text
Change
Implementation
Artifacts
```

之间的一致性检查。

但是当前验证基线 OpenSpec 1.14.0 中：

> 原生 Verify 不会自动加载 `docs/rules/verify.md`。

不要把这两个概念混在一起。

---

# 29. Starter 项目级 Verify

Starter 自己的验证规则位于：

```text
docs/rules/verify.md
```

它重点要求：

```text
Requirement
    ↓
Implementation
    ↓
Test / Verification
```

进行可追踪验证。

主要检查：

```text
Completeness
Correctness
Coherence
```

---

# 30. Verification Report

项目级 Verify 会区分：

```text
CRITICAL
WARNING
SUGGESTION
NOT VERIFIED
NOT APPLICABLE
```

特别重要：

```text
没有验证
```

不能写成：

```text
通过
```

应该写：

```text
NOT VERIFIED
```

---

# 31. 高风险行为

以下内容通常需要更严格验证：

```text
Authorization
State transition
Money / amount
Deadline
Idempotency
Concurrency
Migration
External system behavior
Critical business invariant
```

不能只因为单元测试绿了就宣布全部正确。

---

# 32. Archive 前检查

获取 Archive 指令：

```bash
openspec instructions archive \
  --change add-user-profile \
  --json
```

应该看到：

```text
operationGuidance
```

包含：

```text
Read and follow docs/rules/archive.md before archiving a change.
```

---

# 33. Archive 与项目级 Verify 的关系

Starter 的项目级链路是：

```text
Archive
   ↓
docs/rules/archive.md
   ↓
docs/rules/verify.md
```

也就是说：

> Archive 是项目级最终验证规范的重要入口。

---

# 34. operationGuidance 不是技术锁

必须知道：

```text
operationGuidance
```

属于：

```text
prompt policy
```

不是：

```text
CLI 强制锁
```

如果项目真的要求：

```text
未通过测试绝对不能合并
未通过权限验证绝对不能发布
```

应该使用：

```text
CI
Branch Protection
Release Pipeline
受控部署入口
```

来强制。

---

# 35. Archive 完成以后

主 Specs 应代表系统长期行为。

Change 则进入历史记录。

可以理解成：

```text
Change
    ↓
完成实施
    ↓
验证
    ↓
归档
    ↓
长期 Specs 保留稳定行为
```

---

# 36. 一个完整 Change 的心理模型

日常工作可以记成：

```text
我想改变什么？
        ↓
Proposal

系统应该表现成什么样？
        ↓
Specs

准备怎么实现？
        ↓
Design

具体要做哪些工作？
        ↓
Tasks

开始改代码
        ↓
Apply

实现真的符合要求吗？
        ↓
Verify

这次变更可以结束了吗？
        ↓
Archive
```

---

# 37. 新手最容易犯的错误

## 错误一：直接让 AI 写代码

错误：

```text
帮我做一个用户系统
```

然后直接开始修改几十个文件。

更好的方式：

```text
先 Explore
再 Proposal
再 Specs
再 Design
再 Tasks
```

---

# 38. 错误二：把 Spec 当技术设计

错误：

```text
Requirement:
Use React Query and PostgreSQL.
```

这些通常属于实现选择。

Specs 应描述：

```text
系统行为
```

---

# 39. 错误三：不知道项目事实就猜

例如：

```text
项目应该使用 Redis
```

除非代码、配置或项目 Context 支持这个结论，否则不要这么写。

---

# 40. 错误四：把 Task 完成当验证通过

```text
[x]
```

不是验证证据。

应该继续检查：

```text
Requirement
Implementation
Test
Runtime behavior
```

---

# 41. 错误五：直接修改 generated workflow

不要为了临时解决问题去 patch：

```text
.agents/
.claude/
.cline/
.clinerules/
```

中的 generated OpenSpec workflow。

这些应该通过重新生成和升级流程管理。

---

# 42. 错误六：把所有 Context 都加载进来

不要每次都加载：

```text
全部技术栈
全部基础设施
全部品牌资料
全部外部系统
全部业务说明
```

只加载当前 Change 需要的事实。

---

# 43. 如何知道环境是否健康

随时运行：

```bash
./scripts/doctor.sh
```

如果你修改了 Starter 或升级了 OpenSpec：

```bash
./scripts/smoke-test.sh
```

---

# 44. 推荐的新项目初始化顺序

一个全新项目接入 Starter 后，建议：

```text
1. doctor
2. smoke test
3. 建立 tech-stack Context
4. 建立必要的 infrastructure Context
5. 建立必要的 brand Context
6. 开始第一个真实 Change
```

不需要一次把所有 Context 都写完。

按真实项目需求逐步增加。

---

# 45. 推荐日常命令

查看 Change：

```bash
openspec list --json
```

查看 Specs：

```bash
openspec list --specs
```

查看 Change 状态：

```bash
openspec status --change <change-name> --json
```

获取 artifact 指令：

```bash
openspec instructions proposal --change <change-name> --json
openspec instructions specs --change <change-name> --json
openspec instructions design --change <change-name> --json
openspec instructions tasks --change <change-name> --json
```

获取 Apply 指令：

```bash
openspec instructions apply --change <change-name> --json
```

检查 Archive guidance：

```bash
openspec instructions archive --change <change-name> --json
```

严格验证：

```bash
openspec validate <change-name> --strict
```

---

# 46. 如果你不知道下一步做什么

运行：

```bash
openspec status --change <change-name> --json
```

观察：

```text
ready
blocked
done
```

OpenSpec 会告诉你下一步可创建哪个 artifact。

---

# 47. 如果项目规则和实际情况冲突

不要强行继续。

先找出：

```text
规则是否过时？
项目事实是否缺失？
Change 是否设计错误？
OpenSpec 是否升级导致行为变化？
```

然后修正权威来源。

不要用局部 workaround 把问题藏起来。

---

# 48. 下一步阅读

掌握基本流程后，阅读：

```text
docs/ai-openspec/workflow-guide.md
```

了解整个工作流和规则之间的关系。

然后阅读：

```text
docs/ai-openspec/project-context.md
```

学习怎样让 AI 正确理解你的真实项目。

如果你负责 Starter 维护：

```text
docs/ai-openspec/architecture.md
docs/ai-openspec/upgrade.md
```

也应该阅读。
