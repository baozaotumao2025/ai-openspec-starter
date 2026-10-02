# AI OpenSpec Starter 架构说明

本文档描述 AI OpenSpec Starter 的整体架构、设计边界和维护原则。

它不是某个业务项目的架构文档。

它描述的是：

```text
Starter 本身如何组织
Starter 如何和 OpenSpec 配合
Starter 如何适配不同项目
哪些内容属于规则
哪些内容属于项目事实
哪些内容属于 OpenSpec generated layer
```

---

# 1. 总体目标

AI OpenSpec Starter 的目标不是提供某一种技术栈。

它的目标是提供一套可复用的软件工程工作方式：

```text
需求明确
    ↓
规格明确
    ↓
设计明确
    ↓
任务明确
    ↓
实现受约束
    ↓
验证有证据
    ↓
变更可归档
```

---

# 2. Starter 的四层结构

整体可以理解为：

```text
ai-openspec-starter
│
├── OpenSpec Workflow Layer
│
├── Generic Engineering Rules
│
├── Conditional Specialty Rules
│
└── Project Fact Layer
```

展开后：

```text
OpenSpec Workflow Layer
├── Proposal
├── Specs
├── Design
├── Tasks
├── Apply
├── Verify
└── Archive

Generic Engineering Rules
├── Global
├── Git
├── Testing
├── Code Quality
├── Engineering Workflow
└── Session Continuity

Conditional Specialty Rules
├── Authorization
├── Database
├── External Dependency
└── UI / Frontend

Project Fact Layer
└── docs/context/
```

---

# 3. 第一层：OpenSpec Workflow Layer

OpenSpec 负责管理：

```text
Change
Artifact
Workflow
Artifact dependency
Generated integrations
Instruction generation
```

Starter 不重新实现这些能力。

Starter 在 OpenSpec 之上添加：

```text
工程治理
项目 Context Routing
验证方法
规则注入
部署和诊断工具
```

---

# 4. Change 是核心工作单元

一个 Change 应代表：

> 一个明确、有边界、可验证的软件变化。

典型目录：

```text
openspec/changes/<change-id>/
├── proposal.md
├── design.md
├── tasks.md
└── specs/
```

Change 是：

```text
短期变更上下文
```

而不是长期项目知识库。

---

# 5. Artifact 生命周期

Starter 当前基于：

```text
schema: spec-driven
```

主要 Artifact：

```text
Proposal
Specs
Design
Tasks
```

依赖关系：

```text
Proposal
   ↓
┌──┴────┐
Specs  Design
└──┬────┘
   ↓
 Tasks
```

---

# 6. Proposal 层

Proposal 负责：

```text
为什么改变
改变什么
影响什么
涉及哪些 Capability
```

它不负责详细实现。

对应：

```text
docs/rules/proposal.md
```

---

# 7. Specs 层

Specs 定义：

```text
系统必须表现出的行为
```

核心模型：

```text
Requirement
    ↓
Scenario
```

Specs 应尽量保持实现无关。

对应：

```text
docs/rules/specs.md
```

---

# 8. Design 层

Design 负责：

```text
如何实现
为什么这么实现
替代方案是什么
风险是什么
```

对应：

```text
docs/rules/design.md
```

---

# 9. Tasks 层

Tasks 将 Design 转化为：

```text
可执行
可追踪
可验证
```

的工作项。

对应：

```text
docs/rules/tasks.md
```

---

# 10. Apply 层

Apply 是实际修改代码的阶段。

它不仅执行 Task，还需要结合：

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

对应：

```text
docs/rules/apply.md
```

---

# 11. Verify 层

Starter 刻意区分两种 Verify。

第一种：

```text
OpenSpec Native Verify
```

第二种：

```text
Starter Project Verification
```

两者不是同一能力。

---

# 12. Native Verify

当前已验证基线：

```text
OpenSpec 1.14.0
```

generated Verify 会读取：

```text
openspec instructions apply
```

获取 planning context。

但它不会消费：

```text
operationGuidance
```

也不会自动加载：

```text
docs/rules/verify.md
```

---

# 13. Project Verification

Starter 的项目级验证规则：

```text
docs/rules/verify.md
```

重点建立：

```text
Requirement
    ↓
Implementation
    ↓
Evidence
```

关系。

---

# 14. Archive 层

Archive 通过：

```text
docs/rules/archive.md
```

进入项目级最终验证。

调用关系：

```text
Archive
   ↓
archive.md
   ↓
verify.md
```

---

# 15. Archive 不是技术锁

必须明确：

```text
operationGuidance
```

属于 Prompt Policy。

它不是：

```text
不可绕过的 CLI Gate
```

真正的强制 Gate 应由：

```text
CI
Branch Protection
Release Pipeline
Deployment Control
```

实现。

---

# 16. 第二层：Generic Engineering Rules

这层定义：

```text
所有项目都可以复用的工程方法
```

不应该包含：

```text
某个品牌
某个数据库
某个产品
某个业务名词
某个部署平台
某个绝对路径
```

---

# 17. Global Rule

入口：

```text
docs/rules/global.md
```

它是整个 Starter 的项目级工程政策入口。

主要作用：

```text
统一工作方式
约束假设
控制 Context 加载
建立工程边界
```

---

# 18. Engineering Workflow Rule

文件：

```text
docs/rules/engineering-workflow.md
```

负责：

```text
先调查
再修改
控制范围
使用真实工具链
验证结果
报告限制
```

---

# 19. Git Workflow Rule

文件：

```text
docs/rules/git-workflow.md
```

核心思想：

```text
Git 是可追踪性机制
```

而不是允许 AI 随意：

```text
reset
commit
push
rewrite history
```

---

# 20. Testing Rule

文件：

```text
docs/rules/testing.md
```

它不绑定某一种测试框架。

Starter 不应该假设项目一定使用：

```text
pytest
go test
npm test
cargo test
mvn test
```

而应该从真实项目工具链中确认。

---

# 21. Code Quality Rule

文件：

```text
docs/rules/code-quality.md
```

关注：

```text
可读性
维护性
边界
重复
错误处理
修改范围
```

而不是语言专属风格。

---

# 22. Session Continuity

文件：

```text
docs/rules/session-continuity.md
```

用于支持长周期 Change。

推荐临时交接位置：

```text
openspec/changes/<change-id>/handoff.md
```

它属于：

```text
Change-local context
```

不是长期 Project Context。

---

# 23. 第三层：Conditional Specialty Rules

这层规则不是每个 Change 都需要。

只有涉及对应领域时才读取。

当前包括：

```text
Authorization
Database
External Dependency
UI / Frontend
```

---

# 24. Authorization Rule

文件：

```text
docs/rules/authorization.md
```

Starter 使用通用模型：

```text
principal
action
resource
context
identity source
decision point
enforcement point
```

这样避免预设：

```text
Tenant
Workspace
Organization
Knowledge Base
Project
```

等具体业务概念。

---

# 25. Database Rule

文件：

```text
docs/rules/database.md
```

Starter 保留：

```text
Vertical Slice
Domain Boundary
Ports & Adapters
Persistence Ownership
Centralized Migration
```

这些属于架构原则。

具体：

```text
PostgreSQL
MySQL
MongoDB
Prisma
GORM
SQLAlchemy
```

属于 Project Context。

---

# 26. Vertical Slice

Starter 倾向按照：

```text
业务能力
```

组织代码，而不是仅按照技术层拆分。

例如概念上：

```text
user/
billing/
search/
```

而不是强制整个项目统一：

```text
controllers/
services/
repositories/
```

---

# 27. Domain Boundary

每个 Domain 应尽量拥有：

```text
自己的业务规则
自己的 Application Logic
自己的 Persistence Behavior
```

跨 Domain 协作应通过：

```text
明确接口
ID
Contract
DTO
```

完成。

---

# 28. Ports & Adapters

Starter 保留：

```text
Domain
    ↓
Port
    ↓
Adapter
```

思想。

例如：

```text
Billing Domain
    ↓
PaymentGateway Port
    ↓
Stripe Adapter
```

但是 Starter 不预设一定存在 Stripe。

---

# 29. Persistence Ownership

Persistence 不应成为：

```text
全项目无边界共享工具层
```

而应尊重 Domain Ownership。

这可以减少：

```text
跨 Domain 数据耦合
共享 Repository 泛化
隐式事务边界
```

---

# 30. Centralized Migration

即使 Persistence 行为由 Domain 拥有：

```text
Schema Migration
```

仍建议集中管理。

原因：

```text
数据库 Schema 是共享物理资源
Migration 需要全局顺序
部署需要统一控制
```

---

# 31. External Dependency Rule

文件：

```text
docs/rules/external-dependency.md
```

“External” 指：

```text
项目边界之外
```

包括：

```text
第三方 API
外部服务
SDK
另一个仓库
基础设施
模型服务
```

---

# 32. External Dependency 不代表项目一定有外部系统

这是非常重要的架构边界。

Starter 不应该说：

```text
读取 external-system-evidence.md
```

作为全局默认行为。

因为很多项目根本不存在对应系统。

---

# 33. External Evidence 的生命周期

外部依赖调查结果默认属于：

```text
当前 Change
```

只有当它变成：

```text
长期
稳定
多个 Change 会使用
有明确证据
```

的项目事实时，才提升到：

```text
docs/context/
```

---

# 34. UI / Frontend Rule

文件：

```text
docs/rules/ui-frontend.md
```

负责通用 UI 和品牌方法。

不绑定：

```text
React
Vue
Angular
Tailwind
CSS Modules
Figma
```

---

# 35. Token Architecture

Starter 的 UI 抽象：

```text
Brand Token
    ↓
Semantic Token
    ↓
Component
```

---

# 36. Brand Token

表达：

```text
品牌原始视觉值
```

例如概念上：

```text
brand-primary
brand-secondary
brand-font
```

---

# 37. Semantic Token

表达：

```text
界面语义
```

例如：

```text
surface-primary
text-muted
action-primary
border-danger
```

---

# 38. Component

Component 应消费：

```text
Semantic Token
```

而不是直接硬编码 Brand Token。

这样：

```text
Theme
Skin
White-label
```

更容易解耦。

---

# 39. Theme 与业务逻辑分离

Theme 不应该改变：

```text
Authorization
Business Rules
State Transition
Data Ownership
```

Theme 属于：

```text
Presentation Layer Concern
```

---

# 40. 第四层：Project Fact Layer

目录：

```text
docs/context/
```

入口：

```text
docs/context/index.yaml
```

它描述：

```text
当前具体项目真实存在的事实
```

---

# 41. Starter 默认没有项目事实

初始：

```yaml
contexts: {}
```

这是故意的。

意味着：

```text
没有品牌假设
没有数据库假设
没有框架假设
没有基础设施假设
没有外部依赖假设
```

---

# 42. Rule 与 Context 的分工

最重要的架构边界：

```text
Rule
=
HOW TO WORK
```

```text
Context
=
WHAT IS TRUE
```

---

# 43. 一个典型错误

错误：

```text
docs/rules/database.md
```

里面写：

```text
项目使用 PostgreSQL 17
```

这是 Project Fact，不应该进入通用 Rule。

---

# 44. 正确拆分

Rule：

```text
Migration 必须可验证并集中管理。
```

Context：

```text
生产数据库是 PostgreSQL 17。
Migration 位于 migrations/。
```

---

# 45. Context Routing

Context 不应全量加载。

正确流程：

```text
Current Change
    ↓
docs/context/index.yaml
    ↓
选择相关 Context
    ↓
读取需要的文件
```

---

# 46. 为什么使用 Registry

如果没有 Registry，AI 通常只能：

```text
扫描整个 docs/context/
```

这会导致：

```text
上下文过载
无关内容进入推理
Token 浪费
错误事实传播
```

---

# 47. index.yaml 的作用

它不是简单目录。

它是：

```text
Context Routing Table
```

例如：

```yaml
contexts:
  tech-stack:
    path: docs/context/tech-stack.md
    description: Runtime, framework, build and test tooling
```

---

# 48. Project Context 不应该保存 Secret

可以记录：

```text
Secret 来自 External Secrets
```

不能记录：

```text
实际 Secret Value
```

---

# 49. Generated Integration Layer

Starter 还包含一层：

```text
OpenSpec Generated Integrations
```

主要目录：

```text
.agents/
.claude/
.cline/
.clinerules/
```

---

# 50. Generated Layer 的性质

这些文件主要由：

```text
OpenSpec CLI
```

生成。

因此它们不是主要人工维护层。

---

# 51. 为什么不要手工 Patch

如果人工修改 generated workflow：

```text
短期可能能工作
```

但是升级 OpenSpec 后：

```text
重新生成
```

很可能覆盖修改。

同时多套 integration 之间还可能出现：

```text
行为漂移
```

---

# 52. 正确升级方式

应该：

```text
升级 OpenSpec
    ↓
重新生成 Integration
    ↓
审计 Generated Behavior
    ↓
确认 Starter Governance Boundary
    ↓
Doctor
    ↓
Smoke Test
```

---

# 53. Starter 当前分发的 Workflows

当前一共：

```text
9
```

分别：

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

---

# 54. 为什么没有 Onboard

Starter 当前故意不分发：

```text
onboard
```

因为经过审计的 Onboard 是：

```text
组合式高层自动流程
```

它可能直接推进：

```text
Task
Implementation
Verification
Archive
```

从而弱化显式治理阶段。

---

# 55. 不修改机器级 OpenSpec Profile

Starter 不会为了移除 Onboard 而修改：

```text
用户全局 OpenSpec Config
```

因为机器级设置可能被：

```text
其他仓库
其他项目
```

使用。

---

# 56. Project Config

Starter 的 OpenSpec 项目入口：

```text
openspec/config.yaml
```

它负责：

```text
Context routing
Artifact rules
Apply guidance
Archive guidance
```

---

# 57. Config 不应该承担所有逻辑

不要把整个 Starter 的规则都塞进：

```text
openspec/config.yaml
```

Config 应主要负责：

```text
Routing
```

真正的规范放：

```text
docs/rules/
```

---

# 58. 为什么规则拆成独立文件

因为可以：

```text
独立审查
独立更新
按需加载
清晰引用
减少 config 体积
```

---

# 59. Explore Rule 的特殊地位

`explore.md` 不是全局规则。

原因是 Explore 强调：

```text
调查
理解
证据
```

如果每个 Apply 默认都进入 Explore 风格，可能导致：

```text
过度调查
实现停滞
```

---

# 60. CodeGraph 层

Starter 包含：

```text
.codegraph/
```

但 CodeGraph 是：

```text
Optional Capability
```

---

# 61. CodeGraph 不应该成为硬依赖

如果 CodeGraph 不可用，应使用：

```text
LSP
IDE references
AST
rg
Repository Search
Direct Source Inspection
```

替代。

---

# 62. 为什么保留 CodeGraph 支持

大型仓库中，CodeGraph 可以帮助：

```text
调用关系
符号关系
依赖路径
影响范围
```

调查。

但不应该让 Starter 因为缺少它而无法工作。

---

# 63. 安装层架构

Starter 还提供：

```text
scripts/install.sh
scripts/upgrade.sh
scripts/uninstall.sh
scripts/doctor.sh
scripts/smoke-test.sh
```

用于产品化部署。

---

# 64. Install

`install.sh` 的原则：

```text
先检查
后复制
不覆盖未知文件
记录 manifest
```

---

# 65. Manifest

安装后创建：

```text
.ai-openspec-starter/manifest.sha256
```

记录：

```text
文件路径
安装时 Hash
```

---

# 66. 为什么需要 Manifest

没有 Manifest 时，升级器无法区分：

```text
Starter 原始文件
```

和：

```text
用户后来修改过的文件
```

---

# 67. Upgrade

`upgrade.sh` 使用：

```text
旧 Manifest
+
新 Starter 文件集
```

判断：

```text
哪些可以更新
哪些已被用户修改
哪些需要新增
哪些已经废弃
```

---

# 68. Upgrade 默认保护本地修改

如果受管文件被修改：

```text
Upgrade 停止
```

而不是：

```text
静默覆盖
```

---

# 69. Uninstall

`uninstall.sh` 只删除：

```text
Manifest 明确记录
并且仍然匹配安装 Hash
```

的文件。

---

# 70. 为什么不做 force delete 默认行为

因为项目使用 Starter 一段时间以后：

```text
某些文件可能已经被项目团队定制
```

无条件删除可能破坏真实工程资产。

---

# 71. Doctor

Doctor 是：

```text
静态健康检查
```

检查：

```text
命令
文件
OpenSpec Root
Rules
Config
Generated Workflows
Onboard
Verify Boundary
Scripts
Documentation
```

---

# 72. Doctor 不证明业务正确

Doctor 可以证明：

```text
Starter 安装结构基本正确
```

不能证明：

```text
项目业务逻辑正确
```

---

# 73. Smoke Test

Smoke Test 是：

```text
动态契约测试
```

它真正调用：

```text
OpenSpec CLI
```

验证 Starter 与当前 OpenSpec 行为是否匹配。

---

# 74. Smoke Test 验证内容

当前覆盖：

```text
Root
New Change
Proposal
Specs
Design
Tasks
Apply
Strict Validation
Archive Guidance
Verify Boundary
Cleanup
```

---

# 75. 为什么 Doctor 和 Smoke Test 都需要

Doctor：

```text
结构检查
```

Smoke Test：

```text
行为检查
```

两者互补。

---

# 76. Smoke Test 不测试业务源码

Starter Smoke Test 的目标是：

```text
测试 Starter 自己
```

而不是测试目标项目业务。

因此它只创建：

```text
临时 OpenSpec Change
```

---

# 77. Starter 自己也需要版本管理

建议 Starter 仓库维护：

```text
VERSION
```

例如：

```text
1.0.0
```

这样安装后的：

```text
.ai-openspec-starter/version
```

可以明确表示来源版本。

---

# 78. Starter Version 与 OpenSpec Version 不同

要区分：

```text
Starter Version
```

和：

```text
OpenSpec CLI Version
```

例如：

```text
Starter 1.0.0
OpenSpec 1.14.0
```

是两个独立版本。

---

# 79. Compatibility

Starter 应明确记录：

```text
Validated OpenSpec Baseline
```

当前是：

```text
1.14.0
```

未来版本不能仅因为：

```text
openspec --version
```

变大，就假设兼容。

---

# 80. OpenSpec 升级属于契约变化

OpenSpec generated workflow 如果变化，可能影响：

```text
Instruction JSON
operationGuidance
Artifact Rules
Generated File Paths
Archive Behavior
Verify Behavior
```

因此必须重新 Smoke Test。

---

# 81. Starter 的核心设计原则

可以浓缩成：

```text
OpenSpec 管生命周期
Rules 管工作方式
Context 管项目事实
Generated Layer 管工具集成
Scripts 管部署安全
Tests 管兼容性验证
```

---

# 82. 一个完整调用关系

```text
Developer / AI
      ↓
OpenSpec Workflow
      ↓
openspec/config.yaml
      ↓
Rules + Context Routing
      ↓
Current Change Artifacts
      ↓
Project Source Code
      ↓
Tests / Evidence
      ↓
Verification
      ↓
Archive
```

---

# 83. 不应该出现的架构耦合

通用 Starter 中不应该出现：

```text
特定项目名
特定客户名
内部绝对路径
真实业务实体
具体第三方账号
生产凭证
固定品牌资产
某个项目专属数据库 Schema
```

---

# 84. Starter 的可移植性标准

一个好的 Starter 应该能够被复制到：

```text
Web App
API Service
CLI
Backend
Frontend
Monorepo
Library
AI Application
Internal Tool
```

而不需要先删除大量旧项目残留。

---

# 85. 什么属于 Starter

适合进入 Starter：

```text
通用工程规则
OpenSpec Governance
安全部署工具
Context Routing 方法
验证方法
架构原则
```

---

# 86. 什么不属于 Starter

不适合进入 Starter：

```text
某个项目真实 Brand
某个客户系统 API
某个业务 Domain Spec
某个公司的部署拓扑
某个生产环境地址
某个真实数据库表结构
```

---

# 87. 一个判断方法

当考虑是否把内容加入 Starter 时，可以问：

```text
这个内容换一个完全不同的项目还成立吗？
```

如果答案是：

```text
No
```

它大概率应该进入：

```text
Project Context
```

或者：

```text
具体项目代码
```

而不是 Starter Rule。

---

# 88. Starter 的维护入口

维护 Starter 时主要关注：

```text
openspec/config.yaml
docs/rules/
docs/ai-openspec/
scripts/
generated integrations
```

---

# 89. Generated Integration 升级需要特别谨慎

因为同一个 Workflow 会分发到：

```text
Agents
Claude
Cline
Cline Rules
```

多个目标。

必须避免：

```text
其中一个更新
其他几个仍旧
```

---

# 90. Generated Workflow 一致性

Doctor 会检查：

```text
agents = 9
claude skills = 9
claude commands = 9
cline skills = 9
clinerules = 9
```

这是基本一致性检查。

---

# 91. 为什么不用简单文件数量代表完全正确

因为：

```text
9 个文件存在
```

不代表：

```text
内容完全一致
```

所以仍然需要：

```text
Smoke Test
审计
```

---

# 92. Verification Architecture

Starter 验证可以看成三层：

```text
Layer 1
OpenSpec Structural Validation

Layer 2
Starter Workflow Smoke Test

Layer 3
Project Requirement Verification
```

---

# 93. Structural Validation

例如：

```bash
openspec validate <change> --strict
```

验证：

```text
Artifact Structure
Spec Format
OpenSpec Schema
```

---

# 94. Workflow Smoke Test

验证：

```text
Starter 与 OpenSpec CLI 的契约
```

例如：

```text
Rule injection
Guidance injection
Workflow state
Verify boundary
```

---

# 95. Project Verification

验证：

```text
Requirement 是否真正实现
```

这是最高层。

必须结合：

```text
源码
测试
运行行为
Migration
权限
外部系统
```

等真实证据。

---

# 96. Architecture 的最终目标

这套架构最终希望实现：

```text
AI 不只是会写代码
```

而是：

```text
AI 在明确规则
明确项目事实
明确 Change
明确 Requirement
明确 Design
明确 Verification
的环境中工作
```

---

# 97. 推荐维护原则

长期维护 Starter 时：

```text
先保护边界
再增加能力
```

不要为了一个具体项目方便，就把：

```text
项目事实
```

塞进：

```text
通用规则
```

---

# 98. 推荐升级顺序

当 Starter 或 OpenSpec 发生重大变化：

```text
更新源 Starter
    ↓
审计 Generated Integrations
    ↓
检查 Rules
    ↓
检查 Config Routing
    ↓
Doctor
    ↓
Smoke Test
    ↓
更新 Documentation
    ↓
发布 Starter Version
```

---

# 99. 架构健康标准

可以认为 Starter 架构健康，当：

```text
通用规则没有项目残留
Project Context 默认为空
Generated Workflows 一致
Onboard 不被分发
Doctor 通过
Smoke Test 通过
文档和脚本行为一致
安装/升级/卸载不会静默覆盖用户内容
```

---

# 100. 最终模型

整个 Starter 可以浓缩成：

```text
                    ┌─────────────────────┐
                    │     OpenSpec        │
                    │  Change Lifecycle   │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │   Starter Rules     │
                    │    HOW TO WORK      │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │ Project Context     │
                    │    WHAT IS TRUE     │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │   Project Source    │
                    │ Implementation      │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │ Tests / Evidence    │
                    │   Verification      │
                    └─────────────────────┘
```

Starter 的职责不是替项目决定一切。

它的职责是建立：

```text
清晰边界
可靠上下文
稳定工作流
可验证过程
安全维护方式
```

让不同项目都能够在同一套工程方法下工作。

---

# 101. 下一步阅读

如果准备升级 Starter：

```text
docs/ai-openspec/upgrade.md
```

如果准备卸载：

```text
docs/ai-openspec/uninstall.md
```

如果运行时出现异常：

```text
docs/ai-openspec/troubleshooting.md
```

如果第一次实际使用：

```text
docs/ai-openspec/getting-started.md
```
