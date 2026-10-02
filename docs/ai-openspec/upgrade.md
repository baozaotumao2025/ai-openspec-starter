# AI OpenSpec Starter 升级指南

本文档说明如何安全升级 AI OpenSpec Starter。

升级分为两个不同场景：

```text
场景 A
目标项目升级到一个已经验证过的新版 Starter

场景 B
Starter 维护者升级 OpenSpec CLI 或重新生成 integrations
```

这两个过程不要混在一起。

对于普通项目使用者，通常只需要执行：

```text
场景 A
```

---

# 1. 升级模型

推荐架构：

```text
新版 ai-openspec-starter
        ↓
   upgrade.sh
        ↓
已有目标项目
```

也就是说：

> `upgrade.sh` 应从“新版 Starter 源目录”运行，并把经过验证的 Starter 文件部署到目标项目。

例如：

```text
/workspace/
├── ai-openspec-starter/
└── my-project/
```

进入新版 Starter：

```bash
cd /workspace/ai-openspec-starter
```

先预览：

```bash
./scripts/upgrade.sh --dry-run /workspace/my-project
```

确认没有冲突后：

```bash
./scripts/upgrade.sh /workspace/my-project
```

---

# 2. 为什么升级不是在目标项目里直接运行

目标项目中的：

```text
scripts/upgrade.sh
```

只是安装时复制进去的一个版本。

真正升级需要：

```text
新的 Starter 文件集
```

作为升级来源。

因此推荐始终从：

```text
新版 Starter checkout
```

执行升级。

这样才能明确：

```text
旧版本目标
    ↓
新版本 Starter Source
```

之间的关系。

---

# 3. 升级前必须存在安装 Metadata

目标项目必须已经通过：

```bash
./scripts/install.sh /path/to/project
```

安装过 Starter。

目标项目中应该存在：

```text
.ai-openspec-starter/
├── manifest.sha256
├── version
└── README.txt
```

如果不存在：

```text
.ai-openspec-starter/
```

则 `upgrade.sh` 会停止。

原因是没有 Manifest 时，升级器无法安全区分：

```text
Starter 原始文件
```

和：

```text
项目自己已经存在或修改的文件
```

---

# 4. Manifest 是升级安全机制

安装时：

```text
.ai-openspec-starter/manifest.sha256
```

记录 Starter 管理文件的：

```text
SHA-256
+
相对路径
```

例如概念上：

```text
HASH    docs/rules/global.md
HASH    openspec/config.yaml
HASH    scripts/doctor.sh
```

升级时，脚本会重新计算目标文件 Hash。

---

# 5. 升级前先验证本地修改

对于旧 Manifest 中的每一个受管文件：

```text
Manifest Hash
      ↓
当前 Target Hash
```

如果一致：

```text
可以安全升级
```

如果不同：

```text
用户或项目已经修改过这个文件
```

升级器会停止。

---

# 6. 为什么不自动覆盖本地修改

例如团队修改了：

```text
docs/rules/database.md
```

而新版 Starter 中也修改了这个文件。

如果升级器直接覆盖：

```text
项目定制
↓
丢失
```

这是不可接受的。

因此默认行为是：

```text
检测修改
    ↓
停止升级
    ↓
让人明确处理差异
```

而不是：

```text
--force
```

覆盖。

---

# 7. Dry Run

正式升级前推荐：

```bash
./scripts/upgrade.sh --dry-run /path/to/project
```

Dry Run 不修改目标项目。

它会显示：

```text
Source version
Target version
New managed files
Obsolete managed files
```

并执行安全检查。

---

# 8. 推荐升级顺序

完整流程：

```text
获取新版 Starter
        ↓
确认新版 Starter 自身健康
        ↓
目标项目 git status
        ↓
upgrade --dry-run
        ↓
处理冲突
        ↓
正式 upgrade
        ↓
doctor
        ↓
smoke-test
        ↓
git diff
        ↓
提交
```

---

# 9. 升级前先检查 Starter Source

在新版 Starter 源目录运行：

```bash
./scripts/doctor.sh
```

然后：

```bash
./scripts/smoke-test.sh
```

推荐只有当新版 Starter 自己已经：

```text
Doctor FAIL: 0
Smoke Test FAIL: 0
```

时，才拿它升级其他项目。

---

# 10. 升级前检查目标项目 Git

进入目标项目：

```bash
cd /path/to/project
```

执行：

```bash
git status --short
```

建议先提交或备份重要工作。

升级器虽然会保护 Starter 管理文件，但 Git 仍然是最可靠的整体恢复机制。

---

# 11. 正式 Dry Run

回到新版 Starter：

```bash
cd /path/to/new-ai-openspec-starter
```

运行：

```bash
./scripts/upgrade.sh --dry-run /path/to/project
```

正常情况下不会修改任何文件。

---

# 12. Dry Run 可能显示新增文件

例如：

```text
New managed files:
  + docs/ai-openspec/new-guide.md
```

表示新版 Starter 新增了受管文件。

升级器会检查目标项目是否已经存在同名未知文件。

---

# 13. 新文件碰撞

假设新版 Starter 新增：

```text
scripts/check-context.sh
```

但目标项目已经自己创建了：

```text
scripts/check-context.sh
```

升级器不会覆盖。

它会报告：

```text
NEW FILE COLLIDES WITH EXISTING FILE
```

然后停止。

---

# 14. 为什么新文件碰撞也必须停止

因为升级器不知道：

```text
目标项目已有文件
```

是不是：

```text
同一个功能
不同实现
业务脚本
人工维护内容
```

所以不能自动决定。

---

# 15. Obsolete Managed Files

新版 Starter 可能删除旧文件。

例如旧版本存在：

```text
docs/rules/old-rule.md
```

新版已经不再分发。

如果这个文件：

```text
仍然和旧 Manifest Hash 一致
```

说明没有被项目修改。

升级时可以安全删除。

---

# 16. 被修改的旧文件不会自动删除

如果一个旧 Starter 文件：

```text
新版已经废弃
```

但项目后来修改过它：

```text
当前 Hash != Manifest Hash
```

升级器会停止。

不会自动删除。

---

# 17. 正式升级

Dry Run 没问题后执行：

```bash
./scripts/upgrade.sh /path/to/project
```

升级器会：

```text
验证旧受管文件
    ↓
检查新增文件冲突
    ↓
删除安全的 obsolete 文件
    ↓
复制新版受管文件
    ↓
重建 Manifest
    ↓
更新 Starter version metadata
```

---

# 18. 升级不会修改哪些内容

`upgrade.sh` 不会主动修改：

```text
应用业务源码
Git 历史
Git Branch
用户全局 OpenSpec 配置
机器级 OpenSpec Workflow Profile
项目自有 Context Registry
```

---

# 19. docs/context/index.yaml 的特殊所有权

这是非常重要的升级边界。

文件：

```text
docs/context/index.yaml
```

属于：

```text
目标项目
```

而不是 Starter 长期受管资产。

---

# 20. 为什么 Context Registry 必须项目所有

Starter 初始可以提供：

```yaml
contexts: {}
```

但项目随后会登记：

```text
tech-stack
database
infrastructure
brand
authentication
integrations
```

例如：

```yaml
contexts:
  tech-stack:
    path: docs/context/tech-stack.md
    description: Runtime, framework, build and test tooling
```

这些属于项目自己的长期知识。

新版 Starter 不能覆盖它。

---

# 21. Context Registry 生命周期

当前设计：

```text
安装时不存在
    ↓
Starter 初始化 contexts: {}

安装时已经存在
    ↓
原样保留

项目以后修改
    ↓
正常

Starter 升级
    ↓
保留

Starter 卸载
    ↓
保留
```

---

# 22. 旧版本 Manifest 兼容

某些旧版安装可能曾经把：

```text
docs/context/index.yaml
```

记录进 Manifest。

新版：

```text
upgrade.sh
uninstall.sh
```

会把它视为：

```text
project-owned
```

而不是继续删除或覆盖。

这样可以保护已经登记的项目 Context。

---

# 23. docs/context 下的其他项目文件

例如：

```text
docs/context/tech-stack.md
docs/context/database.md
docs/context/infrastructure.md
```

本身就不是 Starter 的通用资产。

因此正常情况下：

```text
不会进入 Starter Manifest
```

升级器不会删除或覆盖这些文件。

---

# 24. Starter Rules 与 Project Context 的升级区别

Starter Rules：

```text
docs/rules/
```

属于 Starter 管理。

Project Context：

```text
docs/context/
```

属于项目管理。

可以理解成：

```text
docs/rules/
→ HOW TO WORK

docs/context/
→ WHAT IS TRUE
```

---

# 25. openspec/config.yaml

文件：

```text
openspec/config.yaml
```

属于 Starter 治理核心。

因此它是受管文件。

如果项目手工修改过：

```text
openspec/config.yaml
```

升级器会检测到本地修改并停止。

---

# 26. 为什么 config 修改不能静默覆盖

项目可能已经加入：

```text
新的 Context Routing
额外 Artifact Rule
特殊 Operation Guidance
```

直接覆盖可能破坏项目治理。

因此必须人工合并。

---

# 27. docs/rules/ 也是受管资产

Starter 的通用 Rules 默认受 Manifest 管理。

如果项目希望定制：

```text
docs/rules/*.md
```

可以修改。

但之后升级会：

```text
检测到 Local Modification
```

并停止。

这是预期行为。

---

# 28. 项目需要长期定制 Rule 怎么办

有两种思路。

第一种：

```text
把改动贡献回 Starter
```

适用于真正通用的工程规则。

第二种：

```text
项目维护自己的扩展规则
```

适用于项目专属要求。

不要把：

```text
项目事实
```

伪装成：

```text
通用 Rule
```

只为了避开 Context 机制。

---

# 29. Generated Integrations 的升级

以下目录属于 Starter 分发的 OpenSpec generated integration：

```text
.agents/
.claude/
.cline/
.clinerules/
```

目标项目升级时：

```text
upgrade.sh
```

会从新版 Starter Source 复制这些已经审计过的文件。

---

# 30. upgrade.sh 不在目标项目现场重新生成 integrations

这是故意的。

项目升级阶段的目标是：

```text
部署一个已经验证过的 Starter Release
```

而不是：

```text
在目标机器上重新生成一套未知状态的 integrations
```

---

# 31. 为什么不在目标机器自动 openspec init

因为目标机器的 OpenSpec 配置可能包含：

```text
不同 workflow profile
不同 delivery 设置
额外 workflow
Onboard
其他项目需要的全局设置
```

自动调用生成流程可能让结果依赖机器状态。

这会降低升级的可重复性。

---

# 32. 因此 Generated Assets 的责任模型

推荐：

```text
Starter Maintainer
      ↓
使用目标 OpenSpec 版本生成
      ↓
审计
      ↓
移除不分发的 Workflow
      ↓
Doctor
      ↓
Smoke Test
      ↓
发布 Starter
      ↓
Project upgrade.sh 复制发布资产
```

---

# 33. Onboard

Starter 当前不分发：

```text
onboard
```

workflow。

新版项目升级后，Doctor 仍然应该看到：

```text
Onboard workflow is not distributed
```

---

# 34. 为什么升级器不修改机器级 Onboard 配置

即使 Starter 自己不分发 Onboard，也不会运行：

```text
openspec config
```

去删除用户机器上的 Onboard。

因为这可能影响其他项目。

---

# 35. Native Verify 边界

当前经过验证的 OpenSpec 基线：

```text
1.14.0
```

Native Verify 会使用：

```text
openspec instructions apply
```

作为 planning context。

但是不会消费：

```text
operationGuidance
```

也不会自动加载：

```text
docs/rules/verify.md
```

---

# 36. 为什么升级后必须重新检查 Verify

如果未来 OpenSpec 改变 Native Verify 行为：

```text
Starter 的 config / rule routing
```

可能需要调整。

因此：

```bash
./scripts/smoke-test.sh
```

会专门检查这个边界。

---

# 37. OpenSpec CLI 升级不是普通项目升级

假设当前：

```text
OpenSpec 1.14.0
```

未来升级到：

```text
OpenSpec 1.x / 2.x / newer
```

不能只做：

```text
换一个版本号
```

然后宣布兼容。

---

# 38. OpenSpec 升级可能改变什么

包括：

```text
Generated workflow 文件路径
Generated workflow 内容
Instruction JSON
Artifact dependency
operationGuidance 行为
Archive 行为
Verify 行为
Config schema
CLI command
```

因此它属于：

```text
Starter compatibility change
```

---

# 39. Starter Maintainer 升级 OpenSpec 的推荐流程

推荐：

```text
确认新的 OpenSpec 版本
        ↓
阅读版本变化
        ↓
重新生成 integrations
        ↓
比较 generated diff
        ↓
检查 9 个 workflow
        ↓
确认 Onboard 分发策略
        ↓
检查 config capability
        ↓
运行 Doctor
        ↓
运行 Smoke Test
        ↓
更新文档
        ↓
发布新的 Starter Version
```

---

# 40. Generated Files 不要手工 Patch

如果新版 OpenSpec 的 generated Verify 有变化：

不要第一反应：

```text
直接 patch .agents/skills/...
```

因为同一个 workflow 还存在：

```text
Claude
Cline
Commands
Cline Rules
```

多个分发目标。

手工 patch 很容易造成不一致。

---

# 41. 应先调查新版真实行为

需要确认：

```text
CLI 真实输出
Generated 文件
Official behavior
Smoke Test
```

再决定 Starter 是否需要调整。

---

# 42. OpenSpec 升级后的 Smoke Test

运行：

```bash
./scripts/smoke-test.sh
```

它会验证：

```text
Root
Change creation
Proposal rule
Specs rule
Design rule
Tasks rule
Apply guidance
Strict validation
Archive guidance
Native Verify boundary
Cleanup
```

---

# 43. Smoke Test 失败不一定代表新版 OpenSpec 有 Bug

它表示：

```text
新版行为
```

与：

```text
Starter 当前验证契约
```

不一致。

需要人工判断：

```text
OpenSpec 出错？
还是 OpenSpec 合法改变了行为？
Starter 是否应该升级契约？
```

---

# 44. Doctor 与 Smoke Test 的角色

Doctor：

```text
静态结构检查
```

Smoke Test：

```text
动态行为检查
```

升级完成后应该两个都运行。

---

# 45. 升级后第一步

进入目标项目：

```bash
cd /path/to/project
```

运行：

```bash
./scripts/doctor.sh
```

期望：

```text
FAIL: 0
```

---

# 46. 升级后第二步

运行：

```bash
./scripts/smoke-test.sh
```

当前验证基线的正常结果：

```text
PASS: 28
FAIL: 0
```

未来 Smoke Test 增加检查后，PASS 数量可能变化。

真正关键的是：

```text
FAIL: 0
```

---

# 47. 升级后检查 Git Diff

运行：

```bash
git status --short
```

以及：

```bash
git diff
```

确认：

```text
只有预期 Starter 文件发生变化
Project Context 没被覆盖
业务源码没被修改
```

---

# 48. 为什么仍然需要人工看 Git Diff

即使脚本通过：

```text
自动化只能检查已编码的安全条件
```

人仍应该确认：

```text
这次升级的实际变化
```

符合项目预期。

---

# 49. 升级失败：LOCAL MODIFICATION

可能看到：

```text
LOCAL MODIFICATION: docs/rules/testing.md
```

说明：

```text
目标当前文件 Hash
!=
安装时 Manifest Hash
```

---

# 50. 如何处理本地修改

不要直接删除。

先比较：

```bash
git diff -- docs/rules/testing.md
```

并和新版 Starter 对比。

需要明确决定：

```text
保留项目修改
采用新版 Starter
人工合并两者
把通用改动提升回 Starter
```

---

# 51. 升级失败：MANAGED FILE MISSING

可能看到：

```text
MANAGED FILE MISSING
```

表示安装后某个 Starter 文件被删除。

升级器无法知道：

```text
这是故意删除
还是误删
```

因此停止。

---

# 52. 升级失败：NEW FILE COLLIDES

表示新版 Starter 新增文件，但目标项目已经存在同路径文件。

必须人工判断所有权。

---

# 53. 不推荐通过手工修改 Manifest 绕过冲突

理论上可以修改：

```text
.ai-openspec-starter/manifest.sha256
```

但通常不应该。

因为这等于关闭：

```text
升级安全边界
```

---

# 54. Manifest 不应该成为普通编辑文件

建议：

```text
由 install.sh / upgrade.sh 自动维护
```

不要人工编辑。

---

# 55. 升级中断怎么办

升级脚本的设计原则是：

```text
冲突检查
发生在修改之前
```

因此大部分冲突会在：

```text
任何文件改变之前
```

被发现。

---

# 56. 仍然推荐 Git 作为最终恢复机制

文件系统错误、磁盘问题或人为中断仍可能发生。

所以正式升级前：

```text
确保 Git 状态可恢复
```

仍然是最佳实践。

---

# 57. Starter Version

如果 Starter Source 存在：

```text
VERSION
```

安装和升级会记录：

```text
.ai-openspec-starter/version
```

如果没有 VERSION：

```text
dev
```

会作为开发状态版本。

---

# 58. Starter Version 与 OpenSpec Version

它们必须分开理解。

例如：

```text
Starter Version: 1.0.0
OpenSpec Version: 1.14.0
```

Starter 发布版本代表：

```text
Starter 文件和治理规则版本
```

OpenSpec Version 代表：

```text
底层 CLI / generated workflow capability
```

---

# 59. 版本升级建议

Starter 自己可以采用：

```text
Semantic Versioning
```

例如：

```text
1.0.0
1.1.0
1.1.1
2.0.0
```

具体版本政策由维护者决定。

---

# 60. 哪些变化可能属于 Major

例如：

```text
改变受管文件所有权
改变 Context 模型
改变 Workflow 分发集合
改变 Artifact 治理模型
不兼容的 Rule 重构
要求新的 OpenSpec Major Version
```

---

# 61. 哪些变化可能属于 Minor

例如：

```text
新增通用 Rule
新增文档
新增安全诊断
增加 Doctor 检查
增加 Smoke Test Coverage
```

前提是不破坏现有使用方式。

---

# 62. 哪些变化可能属于 Patch

例如：

```text
修正文档错误
修复脚本 Bug
改善错误提示
修复安全检查
```

---

# 63. 项目自身升级 OpenSpec CLI

目标项目可能自行升级：

```text
openspec
```

CLI。

这不会自动升级：

```text
Starter Generated Integrations
```

也不会自动证明兼容。

---

# 64. CLI 与 Generated Assets 版本漂移

可能出现：

```text
新 OpenSpec CLI
+
旧 Starter generated workflows
```

这时 Doctor 可能提示版本 Warning。

Smoke Test 才能进一步验证行为。

---

# 65. 不要只看版本号

版本号不同不代表一定坏。

版本号相同也不能代替：

```text
实际 Smoke Test
```

---

# 66. 目标项目升级后的最低验收标准

至少：

```text
upgrade 成功
doctor FAIL: 0
smoke-test FAIL: 0
git diff 已审查
Project Context 完整
业务源码未被非预期修改
```

---

# 67. 如果项目有 CI

推荐将：

```bash
./scripts/doctor.sh
```

加入基础配置检查。

是否加入：

```bash
./scripts/smoke-test.sh
```

取决于 CI 是否允许创建和清理临时 OpenSpec Change。

---

# 68. CI 中运行 Smoke Test

Smoke Test 会：

```text
创建临时 openspec/changes/<id>
执行验证
删除临时 Change
```

它不会 Archive 临时 Change。

因此不会故意把 smoke capability 同步到主 Specs。

---

# 69. 为什么不在 Smoke Test 中真正 Archive

Archive 可能：

```text
写入 archive
同步 specs
改变长期 OpenSpec 状态
```

Smoke Test 的目标只是验证 Starter 契约。

所以它检查：

```text
Archive Guidance
```

但不真正归档。

---

# 70. 升级后的 Project Context 检查

特别检查：

```bash
git diff -- docs/context/index.yaml
```

正常 Starter 升级不应该覆盖这个文件。

如果它发生非预期变化，应停止检查。

---

# 71. 升级后的 Onboard 检查

Doctor 应显示：

```text
Onboard workflow is not distributed
```

如果出现 Onboard 文件：

```text
检查 generated integration 来源
```

不要立即修改机器级 Profile。

---

# 72. 升级后的 Verify 检查

当前基线应看到：

```text
Native Verify uses apply instructions
Native Verify does not claim custom verify.md injection
Native Verify does not consume operationGuidance
```

如果未来这些检查失败：

```text
重新审计 OpenSpec Verify behavior
```

---

# 73. 项目 Rule 定制与升级的长期策略

如果团队频繁修改：

```text
docs/rules/
```

每次升级都会发生冲突。

这通常意味着需要重新判断：

```text
哪些是真正通用 Starter Rule
哪些是项目专属 Policy
```

---

# 74. 不要用 Context 保存工作方法

例如：

```text
所有 PR 必须先跑 Integration Test
```

如果这是工程工作政策，应进入：

```text
Rule / CI
```

而不是：

```text
Project Context
```

---

# 75. 不要用 Rule 保存环境事实

例如：

```text
Production runs Kubernetes 1.xx
```

属于：

```text
Project Context
```

而不是 Starter Rule。

---

# 76. 升级的本质

Starter Upgrade 不是：

```text
复制一堆新文件
```

而是：

```text
更新工程治理层
同时保护项目事实和项目源码
```

---

# 77. 普通使用者最简升级流程

实际使用时可以只记住：

```bash
cd /path/to/new-ai-openspec-starter

./scripts/doctor.sh
./scripts/smoke-test.sh

./scripts/upgrade.sh --dry-run /path/to/project
./scripts/upgrade.sh /path/to/project

cd /path/to/project
./scripts/doctor.sh
./scripts/smoke-test.sh

git status --short
git diff
```

---

# 78. 不要做的事

升级时不要直接：

```text
cp -rf new-starter/* project/
```

不要直接：

```text
rm -rf .agents .claude .cline .clinerules
```

不要直接：

```text
删除 .ai-openspec-starter/
```

也不要为了消除冲突直接修改 Manifest。

---

# 79. Starter 维护者发布前检查

发布新版 Starter 前至少检查：

```text
[ ] openspec/config.yaml 正确
[ ] docs/rules/ 无项目残留
[ ] docs/context/index.yaml 仍是通用默认
[ ] 9 个 workflow 一致
[ ] Onboard 未分发
[ ] Generated assets 已审计
[ ] Doctor FAIL: 0
[ ] Smoke Test FAIL: 0
[ ] Install script 语法通过
[ ] Upgrade script 语法通过
[ ] Uninstall script 语法通过
[ ] 文档与实际行为一致
```

---

# 80. 发布后项目升级检查

目标项目升级后：

```text
[ ] Project Context 未被覆盖
[ ] Business Source 未被覆盖
[ ] Machine OpenSpec Config 未被修改
[ ] Manifest 已更新
[ ] Doctor 通过
[ ] Smoke Test 通过
[ ] Git Diff 已人工审查
```

---

# 81. 最终原则

整个升级机制遵守：

```text
不知道所有权
→ 不覆盖

检测到本地修改
→ 不覆盖

项目 Context
→ 永远由项目拥有

机器级 OpenSpec 配置
→ 不自动修改

Generated Integration
→ 从经过验证的 Starter Source 发布

升级完成
→ Doctor + Smoke Test 验证
```

这比：

```text
自动覆盖一切
```

更保守。

但对于一个希望长期复用的工程 Starter 来说，也更安全。

---

# 82. 下一步

如果需要删除 Starter：

```text
docs/ai-openspec/uninstall.md
```

如果升级遇到冲突：

```text
docs/ai-openspec/troubleshooting.md
```

如果要理解整体所有权模型：

```text
docs/ai-openspec/architecture.md
```
