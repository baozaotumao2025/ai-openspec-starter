# AI OpenSpec Starter 工作流指南

本文档说明 AI OpenSpec Starter 中各个 OpenSpec Workflow、Artifact、工程规则之间的关系。

它主要回答四个问题：

```text
一个 Change 从哪里开始？
每个阶段读取什么规则？
哪些规则由 OpenSpec 自动注入？
哪些规则属于 Starter 自己的项目级治理？
```

---

# 1. 总体工作流

Starter 当前分发 9 个 OpenSpec workflow：

```text
explore
propose
new
continue
apply
update
sync
archive
verify
```

其中核心变更流程可以理解为：

```text
Explore
   ↓
New / Propose
   ↓
Proposal
   ↓
Specs + Design
   ↓
Tasks
   ↓
Apply
   ↓
Verify
   ↓
Archive
```

`Continue`、`Update`、`Sync` 属于辅助工作流。

---

# 2. Artifact 依赖关系

在 `spec-driven` schema 下，一个典型 Change 使用：

```text
proposal.md
specs/
design.md
tasks.md
```

主要依赖关系：

```text
Proposal
   ↓
 ┌─┴────┐
Specs  Design
 └─┬────┘
   ↓
 Tasks
```

也就是说：

```text
Proposal 完成
→ Specs 和 Design 可以开始

Specs + Design 完成
→ Tasks 可以开始
```

---

# 3. Starter 的规则分层

Starter 的规则不是全部同时加载。

它们分成四类：

```text
项目级规则
Workflow 专用规则
Artifact 专用规则
条件式领域规则
```

---

# 4. 项目级规则

核心入口：

```text
docs/rules/global.md
```

它定义整个项目都应该遵守的开发原则。

OpenSpec 项目上下文可用时，会读取：

```text
docs/rules/global.md
docs/context/index.yaml
```

然后只加载当前 Change 真正需要的 Context。

---

# 5. Context Registry

项目事实登记在：

```text
docs/context/index.yaml
```

Starter 默认：

```yaml
contexts: {}
```

这意味着 Starter 本身不预设：

```text
技术栈
数据库
部署平台
品牌
业务模型
外部系统
权限模型
基础设施
```

这些都属于具体项目事实。

---

# 6. Context 的基本原则

Starter 使用：

```text
按需加载
```

而不是：

```text
每次加载全部项目资料
```

原因包括：

```text
减少上下文污染
减少过时信息影响
降低无关假设
减少 Token 消耗
提高当前 Change 的聚焦程度
```

---

# 7. Workflow 与规则关系总览

当前 Starter 的核心调用关系：

```text
openspec/config.yaml
│
├── project context
│   ├── docs/rules/global.md
│   └── docs/context/index.yaml
│
├── Explore
│   └── docs/rules/explore.md
│
├── Proposal
│   └── docs/rules/proposal.md
│
├── Specs
│   └── docs/rules/specs.md
│
├── Design
│   └── docs/rules/design.md
│
├── Tasks
│   └── docs/rules/tasks.md
│
├── Apply
│   └── docs/rules/apply.md
│
├── Verify
│   └── OpenSpec native verification
│
└── Archive
    └── docs/rules/archive.md
        └── docs/rules/verify.md
```

这是理解整个 Starter 最重要的图之一。

---

# 8. Proposal / Specs / Design / Tasks

这四个阶段通过 `openspec/config.yaml` 的 Artifact Rules 注入。

概念上：

```yaml
rules:
  proposal:
    - Read and follow docs/rules/proposal.md.

  specs:
    - Read and follow docs/rules/specs.md.

  design:
    - Read and follow docs/rules/design.md.

  tasks:
    - Read and follow docs/rules/tasks.md.
```

因此运行：

```bash
openspec instructions proposal --change <change> --json
```

应该返回 Proposal Rule。

其他 Artifact 同理。

---

# 9. Proposal

Proposal 解决的问题：

```text
WHY
WHAT CHANGES
IMPACT
CAPABILITIES
```

Proposal 不应该承担：

```text
详细代码设计
具体类名
SQL 实现细节
文件级任务分解
```

对应规则：

```text
docs/rules/proposal.md
```

---

# 10. Specs

Specs 解决的问题：

```text
系统必须具备什么行为？
```

核心形式：

```text
Requirement
   ↓
Scenario
```

对应规则：

```text
docs/rules/specs.md
```

Specs 应尽量保持实现无关。

---

# 11. Design

Design 解决的问题：

```text
我们准备怎么实现？
为什么这样实现？
有哪些替代方案？
有哪些风险？
```

对应：

```text
docs/rules/design.md
```

Design 可以包含：

```text
架构边界
数据流
模块关系
技术选择
迁移策略
风险和 Trade-off
```

但不能凭空发明项目事实。

---

# 12. Tasks

Tasks 将 Design 变成可执行工作。

对应：

```text
docs/rules/tasks.md
```

Task 应尽量同时包含：

```text
Implementation action
+
Verification evidence
```

例如：

```text
实现权限检查
+
验证越权请求被拒绝
```

而不是单纯：

```text
完成权限系统
```

---

# 13. Apply

Apply 与 Artifact Rule 不同。

它通过：

```yaml
operations:
  apply:
    guidance:
      - When implementing tasks, read and follow docs/rules/apply.md.
```

注入。

因此：

```bash
openspec instructions apply --change <change> --json
```

应该在：

```text
operationGuidance
```

中返回 Apply Rule。

---

# 14. Apply 阶段的职责

Apply 不是单纯执行 Tasks。

Starter 要求它同时考虑：

```text
Proposal
Specs
Design
Tasks
Project Context
Engineering Rules
Current Source Code
Tests
```

如果这些内容冲突，应报告冲突，而不是悄悄选择其中一个。

---

# 15. Apply 相关规则

`docs/rules/apply.md` 会进一步调用或要求遵守：

```text
engineering-workflow.md
git-workflow.md
testing.md
code-quality.md
```

并根据 Change 类型条件加载：

```text
authorization.md
database.md
external-dependency.md
ui-frontend.md
```

---

# 16. Engineering Workflow

对应：

```text
docs/rules/engineering-workflow.md
```

它定义实现过程中通用工程约束，例如：

```text
先理解再修改
保持修改范围最小
尊重现有项目边界
使用项目真实工具链
避免虚构命令
验证修改结果
```

---

# 17. Git Workflow

对应：

```text
docs/rules/git-workflow.md
```

Git 被视为：

```text
变更可追踪性工具
```

而不是自动化脚本可以随意操作的黑盒。

Starter 不应该在没有明确要求时：

```text
自动 commit
自动 push
改写历史
强制 reset
```

---

# 18. Testing

对应：

```text
docs/rules/testing.md
```

Starter 不假设项目一定使用：

```text
npm test
pytest
go test
cargo test
make test
```

而是要求根据项目实际工具链选择命令。

---

# 19. Code Quality

对应：

```text
docs/rules/code-quality.md
```

重点包括：

```text
可读性
边界清晰
最小修改
避免重复
错误处理
维护性
```

不绑定具体语言。

---

# 20. Authorization

当 Change 涉及：

```text
身份
权限
角色
资源访问
成员关系
API Key
服务身份
代理执行
```

时使用：

```text
docs/rules/authorization.md
```

Starter 的通用授权模型：

```text
principal
action
resource
context
identity source
decision point
enforcement point
```

---

# 21. Database

数据库相关规则：

```text
docs/rules/database.md
```

Starter 保留的架构思想：

```text
Vertical Slice
Domain Boundary
Ports & Adapters
Persistence Ownership
Centralized Migration
```

但不会假设具体 ORM 或数据库。

---

# 22. External Dependency

外部依赖规则：

```text
docs/rules/external-dependency.md
```

“外部”指：

```text
项目边界之外的任何组件
```

例如：

```text
第三方 API
另一个代码仓库
SDK
模型服务
基础设施平台
远程服务
```

Starter 不假设项目一定存在外部依赖。

只有当前 Change 真正依赖它时才加载相关规则。

---

# 23. External Dependency 的证据优先级

不要依据：

```text
记忆
猜测
类似项目经验
```

来判断外部系统行为。

应优先依据：

```text
正式契约
当前源码
真实配置
确定性测试
实际运行结果
```

---

# 24. UI / Frontend

UI 相关规则：

```text
docs/rules/ui-frontend.md
```

只在 Change 涉及：

```text
Frontend
Visual Design
Brand
Logo
Theme
Skin
White-label
Design Tokens
```

时加载。

---

# 25. UI Token 模型

Starter 使用通用层次：

```text
Brand Token
    ↓
Semantic Token
    ↓
Component
```

它不绑定：

```text
React
Vue
Tailwind
CSS Variables
某个 Design System
```

具体实现属于项目 Context。

---

# 26. Explore

Explore 用于：

```text
调查问题
理解代码
梳理方案
发现未知信息
评估风险
```

对应：

```text
docs/rules/explore.md
```

一个重要原则：

```text
Explore
≠
Implementation
```

Explore 的主要输出应该是理解和证据。

---

# 27. Explore Rule 的特殊性

`explore.md` 不应该成为所有工作流的默认规则。

它只应该：

```text
在 Explore 模式使用
```

或者在其他阶段明确需要调查时使用。

这样可以避免：

```text
每次 Apply 都无限调查
每次 Proposal 都进入源码深挖
```

---

# 28. Native Verify

Starter 保留 OpenSpec 原生：

```text
verify
```

workflow。

但是必须区分：

```text
OpenSpec Native Verify
```

和：

```text
Starter Project Verification Rule
```

它们不是同一个东西。

---

# 29. OpenSpec 1.14.0 的 Verify 边界

当前经过实际 Smoke Test 验证的 OpenSpec 1.14.0 generated Verify 会调用：

```bash
openspec instructions apply --change "<name>" --json
```

获取 planning context。

但是 generated Verify workflow：

```text
不会消费 operationGuidance
```

也没有项目级：

```text
verify guidance
```

注入点。

---

# 30. 因此 config 不应该伪造 Verify 注入

Starter 不会在：

```text
openspec/config.yaml
```

中声称：

```text
Verify automatically reads docs/rules/verify.md
```

因为在当前验证版本中并不成立。

---

# 31. docs/rules/verify.md 的实际角色

项目级验证规则仍然非常重要。

它由：

```text
docs/rules/archive.md
```

显式读取。

因此 Starter 的项目级最终链路是：

```text
Archive
    ↓
archive.md
    ↓
verify.md
```

---

# 32. Verification 的核心目标

项目级 Verify Rule 重点建立：

```text
Requirement
    ↓
Implementation
    ↓
Evidence
```

可追踪关系。

验证主要关注：

```text
Completeness
Correctness
Coherence
```

---

# 33. Verification 状态

Starter 区分：

```text
CRITICAL
WARNING
SUGGESTION
NOT VERIFIED
NOT APPLICABLE
```

其中：

```text
NOT VERIFIED
```

不能被当作：

```text
PASS
```

---

# 34. Archive

Archive guidance 配置在：

```yaml
operations:
  archive:
    guidance:
      - Read and follow docs/rules/archive.md before archiving a change.
```

因此：

```bash
openspec instructions archive --change <change> --json
```

应该返回对应：

```text
operationGuidance
```

---

# 35. Archive 的职责

Starter 希望 Archive 前确认：

```text
Change 是否完成
Specs 是否一致
Design 是否漂移
高风险行为是否验证
Migration 是否验证
是否存在 CRITICAL
```

但是这里必须理解一个重要能力边界。

---

# 36. Archive Guidance 不是 CLI 强制 Gate

OpenSpec 的：

```text
operationGuidance
```

属于：

```text
Prompt-level guidance
```

不是：

```text
不可绕过的 CLI technical lock
```

OpenSpec 原生 Archive 自己仍然控制：

```text
Artifact completeness checks
Task warnings
User confirmations
Archive execution
```

---

# 37. 如果需要真正强制 Gate

例如组织要求：

```text
测试失败绝不能合并
未完成 Migration 验证绝不能发布
CRITICAL 必须阻止部署
```

应使用：

```text
CI
Branch Protection
Release Pipeline
Deployment Gate
受控入口
```

实现。

不要声称只靠 Prompt Rule 就形成了技术锁。

---

# 38. Continue

`continue` workflow 用于：

```text
继续一个已有 Change
```

它会根据当前 Change 状态判断下一步 artifact。

适合：

```text
长周期任务
多次会话
中途恢复
```

---

# 39. Session Continuity

Starter 提供：

```text
docs/rules/session-continuity.md
```

长期 Change 如果需要跨会话交接，可以使用：

```text
openspec/changes/<change-id>/handoff.md
```

作为临时交接文件。

它属于：

```text
当前 Change 临时上下文
```

而不是长期项目 Context。

---

# 40. New

`new` workflow 用于创建新的 Change。

底层对应：

```bash
openspec new change <change-name>
```

它主要建立 Change 目录和基础状态。

---

# 41. Propose

`propose` workflow 是一个面向 AI 的 Proposal 工作流。

它通常围绕：

```text
理解目标
建立 Proposal
推进前期 Artifact
```

工作。

具体 generated behavior 应以当前安装的 OpenSpec integration 为准。

---

# 42. Update

`update` 用于更新已有 Change。

常见情况：

```text
需求调整
Design 变化
Tasks 修正
已有 Artifact 需要同步
```

修改时仍然应遵守对应 Artifact Rule。

---

# 43. Sync

`sync` 用于处理 Change Specs 与主 Specs 之间的同步。

它属于规格生命周期的一部分。

同步前应确认：

```text
Change Specs 确实代表最终期望行为
```

而不是把临时实验或错误设计同步成长期规范。

---

# 44. 为什么 Starter 不分发 Onboard

Starter 当前故意不分发：

```text
onboard
```

workflow。

因为经过审计的 generated Onboard 属于高层组合工作流。

它可能：

```text
创建任务
实施任务
直接推进验证
进入 Archive
```

这会弱化 Starter 希望保留的：

```text
Proposal
Specs
Design
Tasks
Apply
Verification
Archive
```

显式治理链。

---

# 45. 不删除机器级 Onboard

Starter 不会因为自己不分发 Onboard 就修改：

```text
用户机器级 OpenSpec config
```

原因：

```text
机器配置可能被其他项目使用
```

Starter 只管理当前项目分发的 integration 文件。

---

# 46. Generated Integration

当前 Starter 分发 OpenSpec generated integration 到：

```text
.agents/
.claude/
.cline/
.clinerules/
```

它们属于：

```text
生成层
```

而不是主要人工维护层。

---

# 47. 不要直接 Patch Generated Workflow

如果发现 generated workflow 与期望不一致：

不要直接：

```text
修改几十份 generated 文件
```

更合理的流程：

```text
确认 OpenSpec 版本
    ↓
确认官方 generated behavior
    ↓
重新生成
    ↓
审计差异
    ↓
重新应用 Starter 策略
    ↓
Doctor
    ↓
Smoke Test
```

---

# 48. CodeGraph

`.codegraph/` 属于可选工具层。

Starter 不把 CodeGraph 当作开发硬依赖。

如果不可用，仍可使用：

```text
LSP
IDE
AST
Repository Search
rg
Direct Source Inspection
```

完成调查。

---

# 49. Workflow 状态检查

任何时候都可以运行：

```bash
openspec status --change <change-name> --json
```

主要状态：

```text
ready
blocked
done
```

不要仅靠记忆判断下一步。

---

# 50. Apply 状态检查

运行：

```bash
openspec instructions apply --change <change-name> --json
```

重点观察：

```text
progress.total
progress.complete
progress.remaining
state
```

全部任务完成时通常：

```text
state = all_done
```

但再次强调：

```text
all_done
≠
verified
```

---

# 51. 严格 OpenSpec Validation

在适当阶段运行：

```bash
openspec validate <change-name> --strict
```

它检查 OpenSpec Artifact 结构和规范。

它不等于完整业务正确性验证。

---

# 52. Doctor

Starter 自己提供：

```bash
./scripts/doctor.sh
```

用于检查安装完整性。

主要检查：

```text
OpenSpec
Core Rules
Context Registry
Config
Generated Integration
9 Workflows
Onboard Absence
Verify Boundary
Starter Scripts
Documentation
```

---

# 53. Smoke Test

运行：

```bash
./scripts/smoke-test.sh
```

会自动执行一个临时 Change：

```text
New
Proposal
Specs
Design
Tasks
Apply
Validate
Archive Guidance
Verify Boundary
Cleanup
```

它不会 Archive 临时 Change。

这是故意的。

---

# 54. 为什么 Smoke Test 不真正 Archive

真正 Archive 可能：

```text
同步临时 Spec
写入归档目录
污染 Starter 的长期规格
```

因此 Smoke Test 只验证：

```text
Archive instruction / guidance
```

然后删除临时 Change。

---

# 55. Smoke Test 当前基线

Starter 当前已实际验证：

```text
OpenSpec 1.14.0
```

Smoke Test 成功结果：

```text
PASS: 28
FAIL: 0
```

未来 OpenSpec 版本如果改变 generated behavior，Smoke Test 可能失败。

这不是一定意味着新版本有问题。

它意味着：

```text
需要重新审计 Starter 与新版 OpenSpec 的契约
```

---

# 56. Starter 与 OpenSpec 的责任边界

OpenSpec 负责：

```text
Change lifecycle
Artifact dependency
Instruction generation
Generated integrations
Native workflows
```

Starter 负责：

```text
Project governance
Engineering policy
Context routing
Domain methodology
Verification methodology
Safe deployment tooling
```

---

# 57. 规则和项目事实不要混在一起

规则回答：

```text
HOW TO WORK
```

Context 回答：

```text
WHAT IS TRUE IN THIS PROJECT
```

例如：

```text
“外部 API 必须依据真实契约验证”
```

属于 Rule。

而：

```text
“Payment API 当前版本是 v3”
```

属于 Project Context。

---

# 58. Change 临时事实与长期 Context

调查过程中发现的信息，默认先放：

```text
当前 Change
```

只有当它满足：

```text
长期有效
多个 Change 会复用
属于项目真实事实
有明确证据
```

时，才应提升到：

```text
docs/context/
```

---

# 59. 推荐的日常使用模型

最简单的工作方式：

```text
先 Explore 不确定性
      ↓
建立 Change
      ↓
Proposal 定范围
      ↓
Specs 定行为
      ↓
Design 定实现方案
      ↓
Tasks 定工作步骤
      ↓
Apply 修改
      ↓
Verify 找证据
      ↓
Archive 收尾
```

---

# 60. 最重要的几个判断

日常使用 Starter 时，可以反复问：

```text
这是规则还是项目事实？
这是 Requirement 还是 Implementation？
这是 Task 完成还是已经验证？
这是 Prompt Policy 还是 Technical Gate？
这是当前 Change 信息还是长期 Context？
这是项目源码还是 Generated Integration？
```

能区分这些概念，基本就能正确使用这套 Starter。

---

# 61. 下一步阅读

第一次使用：

```text
getting-started.md
```

配置项目事实：

```text
project-context.md
```

理解 Starter 内部设计：

```text
architecture.md
```

升级：

```text
upgrade.md
```

卸载：

```text
uninstall.md
```

遇到问题：

```text
troubleshooting.md
```
