# AI OpenSpec Starter 项目 Context 指南

本文档说明如何使用：

```text
docs/context/
docs/context/index.yaml
```

向 AI 和 OpenSpec 提供当前项目的真实长期事实。

这是 AI OpenSpec Starter 中非常重要的一层。

Starter 自己负责定义：

```text
HOW TO WORK
```

项目 Context 负责定义：

```text
WHAT IS TRUE IN THIS PROJECT
```

两者不要混在一起。

---

# 1. 为什么需要 Project Context

通用 Starter 不应该预先假设你的项目使用：

```text
React
Vue
Go
Python
Java
PostgreSQL
MySQL
Kubernetes
AWS
某个品牌
某个权限系统
某个外部 API
```

这些都属于具体项目事实。

如果把这些事实硬编码进通用规则，Starter 很快就会变成：

```text
只能用于某一个项目的模板
```

因此 Starter 默认：

```yaml
contexts: {}
```

也就是：

> 默认不知道任何项目专属事实。

这是正确状态。

---

# 2. Context 的职责

Project Context 用来记录长期、稳定、可复用的项目事实。

例如：

```text
项目技术栈是什么？
后端运行时是什么？
前端框架是什么？
数据库是什么？
代码目录如何组织？
部署环境是什么？
哪些外部系统存在？
品牌 Token 从哪里定义？
身份来源是什么？
Migration 工具是什么？
```

---

# 3. Context 不是什么

Context 不是：

```text
开发规则
编码规范
一次 Change 的临时笔记
任务列表
猜测
AI 推断
未经验证的结论
```

例如：

```text
所有外部依赖都必须依据真实证据调查
```

这是规则。

应该放在：

```text
docs/rules/external-dependency.md
```

而：

```text
项目使用 Stripe API 2026-09 版本
```

如果经过项目证据确认，则属于 Context。

---

# 4. Rule 和 Context 的区别

可以记住：

```text
Rule
=
你应该怎么工作
```

而：

```text
Context
=
当前项目实际上是什么样
```

例如：

```text
不要凭空猜数据库类型
```

属于 Rule。

而：

```text
当前项目生产数据库是 PostgreSQL 17
```

属于 Context。

---

# 5. Context Registry

所有长期 Context 通过：

```text
docs/context/index.yaml
```

登记。

Starter 初始内容：

```yaml
contexts: {}
```

不要因为这个文件是空的就认为配置失败。

它表示：

> 当前还没有项目专属 Context 被登记。

---

# 6. Context 文件目录

推荐把长期 Context 放在：

```text
docs/context/
```

例如：

```text
docs/context/
├── index.yaml
├── tech-stack.md
├── repository-structure.md
├── infrastructure.md
├── database.md
├── authentication.md
├── integrations.md
├── brand.md
└── frontend.md
```

不要求每个项目都拥有这些文件。

只创建真实需要的。

---

# 7. 不要一次创建全部 Context

一个新项目刚接入 Starter 时，不需要立即创建：

```text
tech-stack
database
brand
infrastructure
integrations
frontend
authorization
deployment
observability
```

全部文档。

推荐：

```text
先使用
↓
遇到稳定且会重复使用的项目事实
↓
再创建 Context
```

这样可以减少：

```text
无效文档
过时文档
重复维护
凭空设计
```

---

# 8. 第一个 Context：技术栈

大多数项目最先需要：

```text
docs/context/tech-stack.md
```

它可以记录：

```text
运行时
主要语言
框架
包管理器
构建工具
测试工具
格式化工具
Lint 工具
```

例如：

```markdown
# Tech Stack

## Backend

- Language: Go
- Runtime: Go 1.25
- HTTP framework: standard net/http
- Module management: Go Modules

## Frontend

- Language: TypeScript
- Framework: React
- Build tool: Vite

## Testing

- Backend: go test
- Frontend: Vitest
```

---

# 9. 不要把版本写成猜测

错误：

```text
Probably Node 22.
```

或者：

```text
应该是 PostgreSQL 16。
```

长期 Context 应来自确定证据。

例如：

```text
package.json
go.mod
pyproject.toml
Dockerfile
CI config
runtime config
deployment manifests
实际命令输出
```

---

# 10. Context 中最好注明证据来源

例如：

```markdown
## Runtime

- Go 1.25

Evidence:
- `go.mod`
- `.github/workflows/test.yml`
```

这样以后项目升级时，可以重新验证。

---

# 11. 注册 Context

假设创建：

```text
docs/context/tech-stack.md
```

然后修改：

```text
docs/context/index.yaml
```

例如：

```yaml
contexts:
  tech-stack:
    path: docs/context/tech-stack.md
    description: Runtime, language, framework, package management, build and test tooling
```

这样 AI 就知道：

```text
tech-stack
```

这个 Context 存在，以及它描述什么内容。

---

# 12. Context Key

推荐 Context Key 使用：

```text
小写
短横线
稳定名称
```

例如：

```text
tech-stack
repository-structure
infrastructure
database
authentication
integrations
brand
frontend
deployment
observability
```

避免：

```text
my-file-2
new-context
misc
stuff
important-info
```

---

# 13. description 很重要

`description` 不应该只是重复文件名。

较差：

```yaml
tech-stack:
  path: docs/context/tech-stack.md
  description: Tech stack
```

更好：

```yaml
tech-stack:
  path: docs/context/tech-stack.md
  description: Runtime, framework, package manager, build tooling, test tooling and supported versions
```

因为 AI 可以根据描述判断：

```text
当前 Change 是否需要读取它
```

---

# 14. Context 应该按需加载

Starter 的核心原则是：

```text
只加载当前 Change 需要的 Context
```

例如：

一个纯后端数据库 Migration Change，通常不需要读取：

```text
brand.md
frontend.md
```

一个 Logo 替换 Change，通常不需要读取：

```text
database.md
```

---

# 15. 为什么不应该全部加载

全部加载可能导致：

```text
上下文噪音
无关信息干扰
过时事实影响决策
Token 浪费
错误关联
```

因此 Starter 在：

```text
openspec/config.yaml
```

中明确要求：

> Select only the project context relevant to the current change.

---

# 16. 推荐 Context 分类

以下分类只是参考。

不是要求。

## 技术栈

```text
tech-stack
```

## 仓库结构

```text
repository-structure
```

## 数据库

```text
database
```

## 身份与认证

```text
authentication
```

## 基础设施

```text
infrastructure
```

## 外部系统

```text
integrations
```

## UI / Brand

```text
brand
frontend
```

## 部署

```text
deployment
```

## 可观测性

```text
observability
```

---

# 17. Repository Structure Context

大型项目建议建立：

```text
docs/context/repository-structure.md
```

可以记录：

```text
主要目录
Domain Boundary
Application Boundary
Adapter 位置
Migration 位置
Frontend 位置
Generated Code 位置
测试目录
```

例如：

```markdown
# Repository Structure

## Backend

`internal/user/`
owns the user domain.

`internal/billing/`
owns billing behavior.

## Adapters

`internal/adapters/`
contains infrastructure adapters.

## Database migrations

`migrations/`
is the only supported migration location.
```

---

# 18. 为什么仓库结构值得长期记录

AI 经常会因为看到类似目录名而猜：

```text
这个目录应该放 Service
那个目录应该放 Repository
```

项目 Context 可以告诉它真实边界。

例如：

```text
Persistence adapters belong inside each domain slice.
```

如果这是项目真实事实，就可以记录。

---

# 19. Database Context

如果项目数据库结构复杂，可以创建：

```text
docs/context/database.md
```

记录：

```text
数据库类型
Migration 工具
Migration 目录
Schema ownership
Transaction 边界
连接方式
测试数据库策略
```

不要把通用数据库原则复制进去。

通用原则已经在：

```text
docs/rules/database.md
```

---

# 20. Database Rule 与 Context 示例

Rule：

```text
Migration 必须集中管理并可以验证。
```

Context：

```text
本项目 Migration 存放在 migrations/，
使用 Atlas 管理。
```

这是两个不同层次。

---

# 21. Authentication Context

可以建立：

```text
docs/context/authentication.md
```

记录：

```text
身份来源
登录机制
Session 机制
Token 类型
服务身份
Claims 来源
认证中间件位置
```

例如：

```markdown
# Authentication

## User identity source

Authenticated user identity comes from the gateway-issued JWT.

## Backend extraction

The HTTP authentication middleware validates the token and stores the
authenticated principal in request context.
```

---

# 22. Authentication 不等于 Authorization

Authentication 回答：

```text
你是谁？
```

Authorization 回答：

```text
你是否可以做这件事？
```

Starter 的通用 Authorization 方法位于：

```text
docs/rules/authorization.md
```

项目 Context 只描述本项目真实身份来源和权限机制。

---

# 23. Authorization 项目事实

如果项目确实存在：

```text
Organization
Workspace
Tenant
Role
Membership
ACL
RBAC
ABAC
```

可以在 Context 中记录。

但是 Starter 本身不会预设这些概念存在。

---

# 24. Infrastructure Context

基础设施 Context：

```text
docs/context/infrastructure.md
```

可以记录：

```text
运行环境
Container Runtime
Kubernetes
Cloud
Network Boundary
Secret 来源
Storage
Queue
Cache
Service topology
```

例如：

```markdown
# Infrastructure

## Runtime

Production workloads run in Kubernetes.

## Secrets

Application secrets are injected through External Secrets.

## Redis

Redis is provided as an external managed service.
```

---

# 25. Deployment Context

如果部署流程本身复杂，可以独立：

```text
docs/context/deployment.md
```

记录：

```text
环境
部署入口
CI/CD
Release 流程
Artifact
Rollback 方法
Migration 时机
```

---

# 26. Context 中不要存秘密

不要把：

```text
Password
API Token
Secret Key
Private Key
Database Password
Session Secret
```

直接写进 Context。

Context 应写：

```text
秘密从哪里来
```

而不是：

```text
秘密本身是什么
```

例如：

```text
Database credentials are injected by the deployment platform.
```

---

# 27. External Integration Context

只有项目确实存在外部依赖时才创建。

例如：

```text
docs/context/integrations.md
```

可以记录：

```text
系统名称
用途
版本
协议
客户端位置
配置入口
官方契约位置
```

---

# 28. 外部依赖 Context 不应该变成猜测仓库

不要写：

```text
The API probably returns 404 when...
```

长期 Context 必须有可靠依据。

不确定行为应该留在：

```text
当前 Change 调查
```

中。

---

# 29. External Dependency Rule

外部系统调查方法统一由：

```text
docs/rules/external-dependency.md
```

负责。

它告诉 AI：

```text
怎么调查
怎么判断证据
怎么处理未知信息
```

Context 则告诉 AI：

```text
这个项目实际依赖了哪些系统
```

---

# 30. Brand Context

如果项目涉及固定品牌，可以创建：

```text
docs/context/brand.md
```

记录：

```text
品牌名
Logo 来源
字体
Brand Token
官方视觉资产位置
Theme 约束
White-label 模式
```

---

# 31. 不要凭空创造 Brand

如果项目没有正式品牌资料，就不要让 AI：

```text
自创品牌色
自创 Logo
自创字体
自创视觉风格
```

Starter 的 UI Rule 明确要求：

```text
没有项目 Context 就不要发明这些事实。
```

---

# 32. UI Context

大型前端可以创建：

```text
docs/context/frontend.md
```

记录：

```text
框架
Router
State management
CSS strategy
Component library
Token system
Directory structure
Testing tools
```

---

# 33. Brand Token 模型

Starter 的通用方法：

```text
Brand Token
    ↓
Semantic Token
    ↓
Component
```

这是 Rule。

具体项目可能是：

```text
CSS Variables
Tailwind Theme
Design System Variables
Figma Variables
JS Theme Object
```

这些才属于 Context。

---

# 34. Context 的粒度

不要建立一个超大：

```text
project-context.md
```

把所有东西塞进去。

较好的方式是按稳定主题拆分。

例如：

```text
tech-stack.md
database.md
infrastructure.md
brand.md
```

这样 AI 才能按需加载。

---

# 35. 也不要拆得过细

另一种极端：

```text
node-version.md
npm-version.md
database-host-type.md
frontend-router.md
css-tool.md
```

每一个事实一个文件。

这会导致管理成本过高。

推荐：

```text
一个文件描述一个稳定领域
```

---

# 36. Context 是否应该包含代码示例

可以。

但应该只在示例有长期价值时使用。

例如：

```markdown
## Repository convention

New HTTP adapters are registered in:

`internal/platform/http/router.go`
```

这是有价值的。

而复制几十行当前实现代码通常没有必要。

---

# 37. Context 是否应该包含绝对路径

尽量不要。

错误：

```text
/root/user/workspace/project/src
```

更好：

```text
src/
```

因为绝对路径：

```text
机器相关
用户相关
不可移植
```

---

# 38. Context 是否应该包含个人信息

不应该。

项目 Context 应保持：

```text
项目级
团队可共享
可提交到 Git
```

不要加入：

```text
个人机器配置
个人用户名
个人 Home 路径
私人凭证
个人账号信息
```

---

# 39. Context 是否应该提交到 Git

通常应该。

因为它属于：

```text
项目真实工程知识
```

可以和代码一起版本化。

这样 Context 变化有：

```text
Git History
Review
Diff
Rollback
```

---

# 40. Context 更新时机

以下情况通常需要更新：

```text
升级主要 Runtime
替换数据库
修改部署平台
更换 Authentication
新增重要外部系统
改变仓库架构
替换 UI Framework
重新设计品牌 Token
```

---

# 41. Change 完成后是否要更新 Context

不一定。

先问：

```text
这个变化是否成为新的长期项目事实？
```

如果只是：

```text
一次功能实现
```

通常不需要。

如果 Change 导致：

```text
项目从 npm 改成 pnpm
```

那么：

```text
tech-stack.md
```

应该更新。

---

# 42. 临时调查结果不要直接提升

例如在某个 Change 中发现：

```text
API 当前测试环境返回字段 X
```

先判断：

```text
这是稳定契约吗？
还是当前环境观察？
```

只有稳定项目事实才值得进入长期 Context。

---

# 43. Change-local Evidence

短期调查证据可以留在：

```text
openspec/changes/<change-id>/
```

例如：

```text
design.md
handoff.md
调查笔记
```

而不是全部沉淀到：

```text
docs/context/
```

---

# 44. Handoff 和 Context 的区别

`handoff.md`：

```text
短期
Change-specific
用于跨会话继续工作
```

Project Context：

```text
长期
Project-wide
多个 Change 可复用
```

不要混淆。

---

# 45. 如何判断一个事实是否值得进入 Context

可以问四个问题：

```text
它是真的吗？
有证据吗？
它长期有效吗？
未来多个 Change 会使用吗？
```

如果四个答案大多是：

```text
Yes
```

才适合进入 Project Context。

---

# 46. Context Evidence Ladder

推荐证据优先级：

```text
项目真实配置
    ↓
源码
    ↓
正式契约
    ↓
确定性测试结果
    ↓
已确认运行行为
    ↓
团队正式文档
```

不要把：

```text
AI 推断
记忆
类似项目经验
```

作为长期事实来源。

---

# 47. Context 内容应该简洁

Context 不是项目百科全书。

应该保留：

```text
AI 做工程决策真正需要的事实
```

而不是：

```text
所有公司历史
所有会议记录
所有产品描述
```

---

# 48. Tech Stack 示例

完整示例：

```markdown
# Tech Stack

## Backend

- Language: Go
- Supported version: Go 1.25
- Dependency management: Go Modules
- HTTP transport: standard net/http

Evidence:
- `go.mod`
- backend CI workflow

## Frontend

- Language: TypeScript
- Framework: React
- Build tool: Vite
- Test runner: Vitest

Evidence:
- `package.json`
- `vite.config.ts`

## Repository tooling

- Git is the source-control system.
- Formatting and test commands must be read from repository configuration.
```

---

# 49. Database 示例

```markdown
# Database

## Database engine

Production uses PostgreSQL.

Evidence:
- deployment configuration
- application database driver

## Migrations

Migrations live under:

`migrations/`

Migrations are applied by the deployment pipeline before application rollout.

## Ownership

Each domain owns its persistence behavior.

Schema migration files remain centralized under `migrations/`.
```

---

# 50. Integration 示例

```markdown
# Integrations

## Payment Provider

Purpose:
Processes card payments.

Protocol:
HTTPS API.

Client location:
`internal/billing/adapters/payment/`

Configuration:
Environment-based configuration injected at deployment.

Contract source:
Vendor API documentation and pinned SDK version.

Do not infer undocumented provider behavior.
```

---

# 51. Brand 示例

```markdown
# Brand

## Brand assets

Canonical Logo assets live under:

`web/assets/brand/`

## Token ownership

Brand primitives are defined centrally.

Components consume semantic tokens rather than hard-coded brand values.

## Theme

The application currently supports one production theme.

Do not introduce additional themes without an explicit Change.
```

---

# 52. index.yaml 示例

随着项目增长：

```yaml
contexts:
  tech-stack:
    path: docs/context/tech-stack.md
    description: Runtime, language, framework, package manager, build and test tooling

  repository-structure:
    path: docs/context/repository-structure.md
    description: Repository boundaries, domain locations, adapters, migrations and generated-code locations

  database:
    path: docs/context/database.md
    description: Database engine, migration tooling, schema ownership and persistence conventions

  authentication:
    path: docs/context/authentication.md
    description: Identity sources, authentication mechanisms, tokens, sessions and middleware locations

  infrastructure:
    path: docs/context/infrastructure.md
    description: Runtime infrastructure, managed services, networking and secret-delivery facts

  integrations:
    path: docs/context/integrations.md
    description: External systems, integration boundaries, protocols, clients and contract sources

  frontend:
    path: docs/context/frontend.md
    description: Frontend framework, routing, state management, styling, component and test tooling

  brand:
    path: docs/context/brand.md
    description: Canonical brand assets, design tokens, theme facts and white-label constraints
```

---

# 53. 这只是示例

不要把上面全部复制到一个真实项目。

如果项目不存在：

```text
brand
frontend
external integration
```

就不要登记它们。

---

# 54. Context Path 应真实存在

如果：

```yaml
contexts:
  database:
    path: docs/context/database.md
```

那么：

```text
docs/context/database.md
```

应该真实存在。

不要留下死链接。

---

# 55. Context 文件删除时

如果删除：

```text
docs/context/database.md
```

同时要从：

```text
docs/context/index.yaml
```

移除对应登记。

否则 AI 可能被引导读取不存在的文件。

---

# 56. Context 更名时

如果：

```text
database.md
```

改成：

```text
persistence.md
```

应同时修改：

```text
index.yaml
```

以及其他引用。

---

# 57. Context Routing

Starter 的 Context Routing 基本流程：

```text
读取 global.md
      ↓
读取 index.yaml
      ↓
理解当前 Change
      ↓
选择相关 Context
      ↓
只读取相关文件
```

不是：

```text
读取 docs/context/*
```

全部文件。

---

# 58. 外部依赖 Routing

当当前 Change 确实依赖项目边界之外的组件时：

```text
读取 external-dependency.md
      ↓
检查 index.yaml
      ↓
加载对应 Integration Context
      ↓
针对 Change 做必要调查
```

如果 index 没有相关 Context：

```text
不要 invent
```

应该调查当前真实系统。

---

# 59. UI / Brand Routing

当 Change 涉及：

```text
UI
Brand
Logo
Theme
Skin
White-label
Design Tokens
```

流程：

```text
读取 ui-frontend.md
      ↓
检查 index.yaml
      ↓
加载相关 frontend / brand Context
```

如果项目没有 Brand Context：

```text
不要凭空创造品牌事实
```

---

# 60. Context 中的未知信息

可以明确写：

```text
Unknown
```

如果它是真实状态。

例如：

```markdown
## Production CDN

NOT DOCUMENTED.

Before changing CDN behavior, inspect deployment configuration and current infrastructure.
```

这比：

```text
猜测使用 CloudFront
```

更安全。

---

# 61. 过时 Context 比没有 Context 更危险

没有 Context 时 AI 至少知道：

```text
我不知道
```

错误 Context 会让 AI 认为：

```text
错误信息是真实项目事实
```

因此 Context 必须维护。

---

# 62. 推荐定期检查

可以在：

```text
OpenSpec 升级
大型架构变更
季度技术审查
重要平台迁移
```

时检查：

```text
docs/context/
```

是否仍然准确。

---

# 63. Context 与 Doctor

当前 `doctor.sh` 会检查：

```text
docs/context/index.yaml
```

至少存在顶层：

```yaml
contexts:
```

但 Doctor 不会判断：

```text
每一条业务事实是否正确
```

这种正确性仍然需要项目维护者负责。

---

# 64. 为什么 Doctor 不自动验证所有 Context

例如 Context 写：

```text
Production uses PostgreSQL.
```

脚本无法安全地自动判断：

```text
生产环境是否真的如此
```

它最多能检查：

```text
结构
文件存在性
明显格式问题
```

事实准确性属于工程验证。

---

# 65. 新项目推荐流程

首次接入 Starter 后：

```text
Doctor
   ↓
Smoke Test
   ↓
检查项目源码和配置
   ↓
创建 tech-stack Context
   ↓
创建必要的 repository Context
   ↓
开始真实 Change
```

不需要先完成整套 Context。

---

# 66. 老项目推荐流程

已有大型项目：

```text
不要试图一次建完整百科
```

可以从：

```text
当前最频繁出错的项目事实
```

开始。

例如 AI 总是搞错：

```text
Migration 目录
身份来源
Frontend 组件库
测试命令
```

这些通常最值得优先进入 Context。

---

# 67. Context 与 README

README 通常面向：

```text
人类开发者快速理解项目
```

Project Context 主要面向：

```text
工程流程和 AI 决策
```

两者可以有重叠，但职责不同。

不要为了减少重复而让 Context 只写：

```text
See README.
```

如果关键工程事实非常重要，可以明确记录。

---

# 68. Context 与源码冲突时怎么办

如果 Context 写：

```text
Migration 在 db/migrations/
```

但真实仓库明显使用：

```text
migrations/
```

不要强行按照 Context。

应该：

```text
停止
调查
确定真实事实
修正 Context
```

Context 不是凌驾于现实之上的真理。

它是：

```text
经过维护的项目知识索引
```

---

# 69. Source of Truth

不同事实的 Source of Truth 可能不同。

例如：

```text
Runtime version
→ go.mod

Frontend dependencies
→ package.json

Deployment platform
→ infrastructure config

API contract
→ OpenAPI / official provider docs

Brand asset
→ canonical design asset
```

Context 应指向真正的 Source of Truth。

---

# 70. 不要复制整个 Source of Truth

如果：

```text
OpenAPI 文件有 5000 行
```

没必要复制进 Context。

Context 可以写：

```text
Canonical API contract:
api/openapi.yaml
```

然后在相关 Change 中针对性读取。

---

# 71. Context 的理想状态

理想 Context 应该：

```text
短
真实
稳定
有证据
可定位 Source of Truth
容易更新
按需加载
```

---

# 72. 不理想的 Context

不理想：

```text
巨大
模糊
复制粘贴
没有来源
夹杂猜测
包含秘密
包含个人路径
包含临时 Change 信息
```

---

# 73. Context 修改也应该 Review

如果团队协作，Context 修改值得 Code Review。

因为修改：

```text
“项目使用什么”
```

会直接影响 AI 之后的工程决策。

---

# 74. Context 的 Git Diff 应该可理解

例如：

```diff
- Package manager: npm
+ Package manager: pnpm
```

这种变化很清晰。

而不是：

```diff
+ 800 行自动生成机器信息
```

---

# 75. 不要自动生成大量 Context

工具可以辅助提取项目事实。

但自动生成后必须：

```text
Review
验证
精简
```

否则很容易把：

```text
暂时依赖
开发依赖
测试工具
历史残留
```

误写成长期架构事实。

---

# 76. Context 和 Generated Files

不要把 generated OpenSpec workflow 的全部内容复制到 Context。

这些行为应该：

```text
由 OpenSpec generated assets 自己表示
```

Starter 通过 Doctor 和 Smoke Test 验证它们。

---

# 77. OpenSpec 版本是否属于 Context

如果具体项目依赖固定 OpenSpec 版本，可以记录。

但 Starter 自己的 OpenSpec 基线属于：

```text
Starter compatibility information
```

不需要每个项目重复写一份。

---

# 78. Context 命名建议

推荐：

```text
tech-stack.md
repository-structure.md
database.md
authentication.md
infrastructure.md
integrations.md
frontend.md
brand.md
deployment.md
observability.md
```

不要把所有项目都强制套成这一套。

---

# 79. 一个最小项目的 Context

简单项目可能只有：

```text
docs/context/
├── index.yaml
└── tech-stack.md
```

完全正常。

---

# 80. 一个复杂项目的 Context

大型平台可能有：

```text
docs/context/
├── index.yaml
├── tech-stack.md
├── repository-structure.md
├── database.md
├── authentication.md
├── authorization-model.md
├── infrastructure.md
├── integrations.md
├── frontend.md
├── brand.md
├── deployment.md
└── observability.md
```

也正常。

重点不是数量。

重点是：

```text
真实且有用
```

---

# 81. Context Checklist

新增一个 Context 前检查：

```text
[ ] 这是项目事实，不是通用规则
[ ] 有明确证据
[ ] 不是秘密
[ ] 不是个人机器信息
[ ] 未来多个 Change 会复用
[ ] 文件路径稳定
[ ] 已登记 index.yaml
[ ] description 足够明确
[ ] 没有复制大量无关内容
```

---

# 82. 更新 Context Checklist

更新已有 Context：

```text
[ ] 确认真实 Source of Truth
[ ] 删除过时信息
[ ] 更新版本或路径
[ ] 检查 index.yaml
[ ] 检查其他 Context 是否矛盾
[ ] Git diff 是否清晰
```

---

# 83. AI 使用 Context 时应该做什么

AI 应：

```text
先判断当前 Change 需要什么事实
      ↓
读取 index.yaml
      ↓
选择相关 Context
      ↓
检查 Context 与真实代码是否明显冲突
      ↓
在有依据的情况下工作
```

---

# 84. AI 不应该做什么

AI 不应该：

```text
看到 index.yaml 就全部加载
凭 Context 名称猜内容
根据类似项目补全缺失事实
因为 Context 存在就忽略真实源码
把临时调查自动写入长期 Context
```

---

# 85. Context 与 Explore

Explore 是创建或修正 Context 的好时机。

例如：

```text
我们到底如何做身份认证？
```

可以先 Explore：

```text
配置
源码
Middleware
测试
部署环境
```

确认以后再决定是否形成：

```text
authentication.md
```

---

# 86. Context 与 Design

Design 需要引用项目事实时：

```text
应基于相关 Context
```

如果 Context 缺失：

```text
先调查
```

而不是：

```text
在 Design 中直接 invent
```

---

# 87. Context 与 Apply

Apply 时 Context 可以帮助避免：

```text
使用错误工具链
把代码放错 Domain
创建错误 Migration
绕过正确身份来源
重复已有 Infrastructure
硬编码 Brand
```

---

# 88. Context 与 Verify

Verify 阶段也应该检查：

```text
Implementation 是否符合项目真实边界
```

不仅仅是：

```text
测试有没有绿
```

---

# 89. Context 的最终目标

Project Context 的目的不是：

```text
让 AI 知道更多
```

而是：

```text
让 AI 知道正确且相关的项目事实
```

这是两个完全不同的目标。

---

# 90. 推荐的长期维护原则

保持：

```text
Rule 稳定
Context 真实
Change 聚焦
Evidence 可追踪
```

这样 Starter 才能在不同项目中长期复用。

---

# 91. 下一步

完成 Project Context 理解后，建议阅读：

```text
docs/ai-openspec/architecture.md
```

它会解释为什么 Starter 被设计成：

```text
OpenSpec workflow layer
+
generic engineering rules
+
conditional specialty rules
+
project fact layer
```

如果正在接入一个真实项目，可以现在开始创建：

```text
docs/context/tech-stack.md
```

然后在：

```text
docs/context/index.yaml
```

注册它。
