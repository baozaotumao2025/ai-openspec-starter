# AI OpenSpec Starter

一个面向 AI 辅助开发的 OpenSpec 工程 Starter。

它解决的不是“怎么让 AI 多写代码”，而是：

> **怎样让 AI 在明确的需求、设计、任务、验证和工程规则下可靠地工作。**

这个 Starter 提供了一套可以复用到不同项目中的：

- OpenSpec 工作流
- AI 工程规则
- Git 工作流
- 测试与代码质量规则
- Authorization 设计规则
- Database / Migration 规则
- External Dependency 调查规则
- UI / Brand / Design Token 规则
- 项目上下文管理方式
- Verify / Archive 验证体系
- 可选 CodeGraph 集成

Starter 本身**不包含具体业务事实**。

具体项目的：

- 技术栈
- 产品信息
- 品牌信息
- 外部系统
- 基础设施
- API
- 数据库
- 部署环境

应由具体项目自己登记到：

```text
docs/context/
```

并通过：

```text
docs/context/index.yaml
```

进行管理。

---

# 适合谁

如果你希望：

- 使用 Claude / Codex / Cline 等 AI 开发工具；
- 使用 OpenSpec 管理需求和变更；
- 避免 AI 未经确认自行修改需求；
- 避免 AI 猜测不存在的项目事实；
- 建立 Proposal → Specs → Design → Tasks → Apply → Verify → Archive 流程；
- 让不同项目共享同一套工程方法；
- 让新成员快速理解 AI 开发流程；

那么这个 Starter 就是为这种工作方式准备的。

---

# 5 分钟快速开始

先取得本 Starter 仓库，然后根据目标项目选择一种方式。下面假设 Starter 位于 `/path/to/ai-openspec-starter`。

**接入已有 Git 仓库：**

```bash
/path/to/ai-openspec-starter/scripts/init.sh /path/to/existing-project
```

**从空目录创建新项目：**

```bash
/path/to/ai-openspec-starter/scripts/init.sh --new /path/to/new-project
```

第二种方式要求目标路径尚不存在。两种方式都会安装 Starter 并运行健康检查；已有仓库中的同名文件如果冲突，安装会停止。完成后先在 `docs/context/` 登记已确认的项目事实，再开始第一个 Change。更多说明见 [安装指南](docs/ai-openspec/installation.md)。

## 1. 环境要求

建议准备：

```text
Git
Bash
Python 3
OpenSpec CLI
```

当前 Starter 版本：

```text
1.0.0
```

当前已验证 OpenSpec 基线：

```text
OpenSpec 1.14.0
```

Starter 版本与 OpenSpec CLI 版本是两个独立版本。

确认 OpenSpec：

```bash
openspec --version
```

---

## 2. 安装到项目

假设：

```text
/path/to/ai-openspec-starter
```

是本 Starter。

目标项目是：

```text
/path/to/my-project
```

执行：

```bash
cd /path/to/ai-openspec-starter

./scripts/init.sh /path/to/my-project
```

安装脚本当前会：

- 不修改业务源码；
- 不修改 Git 历史；
- 不修改机器级 OpenSpec 配置；
- 不覆盖未知用户文件；
- 在复制前检测冲突；
- 安装 Starter 管理的规则、文档、脚本和 OpenSpec integration；
- 创建 `.ai-openspec-starter/manifest.sha256` 记录 Starter 管理文件；
- 当 `docs/context/index.yaml` 不存在时初始化它；
- 不把 `docs/context/index.yaml` 纳入 Starter Manifest。

安装完成后（`init.sh` 已自动运行一次诊断）：

```bash
cd /path/to/my-project
```

运行诊断：

```bash
./scripts/doctor.sh
```

---

## 3. 创建第一个 Change

例如：

```bash
openspec new change add-user-profile
```

检查状态：

```bash
openspec status --change add-user-profile
```

接下来按照 OpenSpec 工作流逐步完成：

```text
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

不要直接从“想法”跳到“实现”。

---

# 日常工作方式

## Explore

用于：

- 调查问题；
- 阅读代码；
- 梳理需求；
- 比较方案；
- 分析架构；
- 找出未知项。

Explore 的目标是**理解问题**，不是直接实施。

---

## Proposal

回答：

```text
为什么做？
要改变什么？
会影响哪些能力？
```

Proposal 重点描述：

```text
WHY
+
WHAT
```

而不是实现细节。

---

## Specs

Specs 描述系统应该表现出的：

```text
可观察行为
```

例如：

```text
输入
输出
错误
权限
约束
场景
```

Specs 是行为契约，不是代码计划。

---

## Design

Design 描述：

```text
HOW
```

例如：

```text
模块边界
架构决策
数据流
授权位置
Migration
外部依赖
技术取舍
风险
```

---

## Tasks

把 Design 转换成可执行任务。

标准格式：

```markdown
- [ ] 1.1 Implement something and verify ...
```

每个 Task 都应该说明：

```text
怎么证明它完成了
```

而不是只有：

```text
“实现 XXX”
```

---

## Apply

Apply 才进入实际实施阶段。

实施时：

```text
Specs
+
Design
+
Tasks
+
Project Context
+
Engineering Rules
```

共同约束实现。

不要为了让测试通过而偷偷改变 Specs。

---

# Verify

Starter 中存在两种需要区分的 Verify。

## OpenSpec 原生 Verify

OpenSpec 自带：

```text
verify
```

workflow。

它用于检查：

```text
Change
Implementation
Artifacts
```

之间的一致性。

但是在当前 OpenSpec 1.14.0 中：

> 原生 Verify 没有项目级自定义 Verify guidance 注入点。

因此 Starter **不会声称**：

```text
OpenSpec Verify
    ↓
自动加载 docs/rules/verify.md
```

这不是当前版本的真实能力。

---

## 项目级 Verify

Starter 自己的完整验证规范位于：

```text
docs/rules/verify.md
```

项目级验证重点检查：

```text
Requirement
    ↓
Implementation
    ↓
Test / Verification
```

以及：

```text
Completeness
Correctness
Coherence
```

它由 Archive 阶段的项目规则链读取。

因此整体关系是：

```text
OpenSpec native Verify
        │
        └── 辅助一致性检查

Archive
   ↓
docs/rules/archive.md
   ↓
docs/rules/verify.md
   ↓
项目级最终验证
```

---

# Archive

Archive 用于结束一个已经完成实施和验证的 Change。

Starter 会通过：

```text
docs/rules/archive.md
```

定义项目级归档准入标准。

需要注意：

> OpenSpec `operationGuidance` 属于 prompt policy，而不是不可绕过的 CLI 强制锁。

如果项目需要真正不可绕过的：

```text
Release Gate
Merge Gate
Archive Gate
```

应使用：

```text
CI
GitHub Actions
GitLab CI
受控发布流程
外层自动化
```

进行技术强制。

---

# 项目 Context

Starter 不应该猜项目事实。

项目事实统一通过：

```text
docs/context/index.yaml
```

登记。

Starter 默认：

```yaml
contexts: {}
```

`docs/context/index.yaml` 属于目标项目，而不是 Starter 的长期受管文件。

它的生命周期是：

```text
安装时缺失 → Starter 初始化 contexts: {}
安装时已有 → 原样保留
项目后续修改 → 正常
Starter 升级 → 保留，不覆盖
Starter 卸载 → 保留，不删除
```

因此 `docs/context/index.yaml` 不会进入 `.ai-openspec-starter/manifest.sha256`。

项目自己创建的 `docs/context/*.md` 同样属于 Project-owned 资产。

例如一个真实项目以后可以登记：

```yaml
contexts:
  tech-stack:
    path: docs/context/tech-stack.md
    description: Project technology stack and runtime constraints

  infrastructure:
    path: docs/context/infrastructure.md
    description: Deployment and infrastructure facts

  brand:
    path: docs/context/brand.md
    description: Brand tokens and visual identity
```

AI 只应该加载：

```text
当前 Change 真正需要的 Context
```

而不是默认把整个项目知识库全部塞进上下文。

详细说明：

```text
docs/ai-openspec/project-context.md
```

---

# External Dependency

Starter 不假设项目一定存在外部系统。

只有当当前 Change 依赖：

```text
第三方 API
另一个仓库
SDK
服务
平台
基础设施
模型服务
外部数据库
```

时，才加载：

```text
docs/rules/external-dependency.md
```

调查结论必须尽可能来自：

```text
源码
正式契约
配置
确定性运行结果
```

而不是 AI 猜测。

长期稳定事实可以进入项目 Context。

临时调查结果应留在当前 Change。

---

# Authorization

Starter 使用通用授权模型：

```text
principal
action
resource
context
identity source
decision point
enforcement point
```

不绑定：

```text
Tenant
Workspace
Knowledge Base
Organization
```

等特定业务概念。

这些具体概念应该由实际项目定义。

---

# Database

Starter 保留：

```text
Vertical Slice
Domain Boundary
Ports & Adapters
Persistence Ownership
Centralized Migration
```

等工程原则。

核心思想是：

> Domain 拥有自己的业务行为和持久化责任，但数据库 Schema Migration 应有明确、统一的管理入口。

---

# UI / Frontend / Brand

UI 和品牌规则采用：

```text
Brand Token
    ↓
Semantic Token
    ↓
Component
```

Starter 不预设：

```text
React
Vue
Tailwind
CSS Variables
Sass
Material UI
```

也不会预设：

```text
品牌名
Logo
颜色
字体
Theme
```

这些都属于具体项目 Context。

---

# CodeGraph

CodeGraph 是可选能力。

如果：

```text
CodeGraph 已安装
+
当前仓库已建立索引
```

可以优先用于代码导航。

否则可以使用：

```text
LSP
IDE References
AST
Repository Search
rg
Direct Source Inspection
```

Starter 不依赖 CodeGraph 才能正常工作。

---

# OpenSpec Workflows

当前 Starter 分发 9 个 workflow：

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

Starter **故意不分发**：

```text
onboard
```

原因是 Onboard 属于组合式自动流程，在当前版本中可能绕过 Starter 自己的工程治理链。

因此：

> 不要为了“看起来完整”而重新加入 Onboard。

除非未来重新审计其行为并确认符合 Starter 的治理模型。

---

# Generated Files

以下目录主要包含 OpenSpec 生成的 integration：

```text
.agents/
.claude/
.cline/
.clinerules/
```

原则：

> 不要手工 patch generated workflow。

升级 OpenSpec 后，应使用 Starter 的升级流程重新生成和验证这些 integration。

详见：

```text
docs/ai-openspec/upgrade.md
```

---

# 安装

完整安装文档：

```text
docs/ai-openspec/installation.md
```

快速方式：

```bash
./scripts/install.sh /path/to/project
```

---

# 升级

升级应该从新版 Starter Source 执行。

先做 Dry Run：

```bash
cd /path/to/new-ai-openspec-starter
./scripts/upgrade.sh --dry-run /path/to/project
```

确认没有冲突后正式升级：

```bash
./scripts/upgrade.sh /path/to/project
```

升级器会使用 `.ai-openspec-starter/manifest.sha256` 检测 Starter 管理文件是否被项目修改。

如果发现本地修改或文件冲突，升级会停止，而不是静默覆盖。

升级不会修改：

```text
业务源码
Git 历史
机器级 OpenSpec 配置
docs/context/index.yaml
项目自己的 docs/context/*
```

详细说明：

```text
docs/ai-openspec/upgrade.md
```

---

# 健康检查

运行：

```bash
./scripts/doctor.sh
```

用于检查：

```text
OpenSpec CLI
版本
项目 root
config.yaml
rules
contexts
generated integrations
workflow 数量
Onboard 残留
路径引用
基本配置
```

---

# Smoke Test

修改 Starter 或升级 OpenSpec 后：

```bash
./scripts/smoke-test.sh
```

Smoke Test 会使用临时 Change 验证：

```text
OpenSpec root
Schema
Proposal rules
Specs rules
Design rules
Tasks rules
Apply guidance
Task tracking
Strict validation
Archive guidance
Verify boundary
Cleanup
```

Smoke Test 不应该修改真实业务代码。

---

# 卸载


默认运行：

```bash
./scripts/uninstall.sh
```

只进行 Preview，不删除任何文件。

确认删除列表正确后执行：

```bash
./scripts/uninstall.sh --yes
```

正式卸载只删除 Manifest 中记录、并且当前 Hash 仍与安装记录一致的 Starter 管理文件。

如果 Starter 管理文件已经被项目修改，卸载会停止，而不是强制删除。

它不会：

```text
删除业务源码
删除 Git 历史
修改机器级 OpenSpec 配置
删除 docs/context/index.yaml
删除项目自己的 docs/context/*
删除真实 OpenSpec Changes / Specs
```

完整说明：

```text
docs/ai-openspec/uninstall.md
```

---

# 文档导航

第一次使用：

```text
docs/ai-openspec/getting-started.md
```

安装部署：

```text
docs/ai-openspec/installation.md
```

完整开发流程：

```text
docs/ai-openspec/workflow-guide.md
```

项目 Context：

```text
docs/ai-openspec/project-context.md
```

架构：

```text
docs/ai-openspec/architecture.md
```

升级：

```text
docs/ai-openspec/upgrade.md
```

卸载：

```text
docs/ai-openspec/uninstall.md
```

问题排查：

```text
docs/ai-openspec/troubleshooting.md
```

---

# Starter 目录结构

```text
ai-openspec-starter/
├── README.md
├── .gitignore
│
├── .agents/
├── .claude/
├── .cline/
├── .clinerules/
│
├── .codegraph/
│
├── docs/
│   ├── ai-openspec/
│   │   ├── installation.md
│   │   ├── getting-started.md
│   │   ├── workflow-guide.md
│   │   ├── project-context.md
│   │   ├── architecture.md
│   │   ├── upgrade.md
│   │   ├── uninstall.md
│   │   └── troubleshooting.md
│   │
│   ├── context/
│   │   └── index.yaml
│   │
│   └── rules/
│       ├── global.md
│       ├── git-workflow.md
│       ├── engineering-workflow.md
│       ├── proposal.md
│       ├── specs.md
│       ├── design.md
│       ├── tasks.md
│       ├── apply.md
│       ├── verify.md
│       ├── archive.md
│       ├── testing.md
│       ├── code-quality.md
│       ├── database.md
│       ├── authorization.md
│       ├── external-dependency.md
│       ├── ui-frontend.md
│       └── session-continuity.md
│
├── openspec/
│   ├── config.yaml
│   ├── changes/
│   └── specs/
│
└── scripts/
    ├── install.sh
    ├── init.sh
    ├── upgrade.sh
    ├── uninstall.sh
    ├── doctor.sh
    └── smoke-test.sh
```

---

# 核心原则

这个 Starter 最重要的不是文件数量，而是下面这些原则：

```text
不要猜项目事实。
不要绕过 Specs。
不要把 Task checkbox 当成完成证明。
不要把搜索结果当成最终事实。
不要让 generated workflow 成为手工维护代码。
不要让 Change 临时信息污染长期项目 Context。
不要把 prompt policy 冒充成技术强制。
```

开发过程应该形成：

```text
Intent
  ↓
Proposal
  ↓
Specs
  ↓
Design
  ↓
Tasks
  ↓
Implementation
  ↓
Verification
  ↓
Archive
  ↓
Durable Project Knowledge
```

AI 是执行者和分析者。

Specs、代码、测试、验证证据和明确的项目事实，才是工程判断的基础。

---

# 下一步

第一次使用建议阅读：

```text
docs/ai-openspec/getting-started.md
```

如果你正在把 Starter 接入已有项目：

```text
docs/ai-openspec/installation.md
```

如果刚升级 OpenSpec：

```text
docs/ai-openspec/upgrade.md
```

如果不知道哪里出了问题：

```bash
./scripts/doctor.sh
```

然后查看：

```text
docs/ai-openspec/troubleshooting.md
```
