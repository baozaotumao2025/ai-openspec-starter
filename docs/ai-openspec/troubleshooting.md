# AI OpenSpec Starter 故障排查指南

本文档用于排查 AI OpenSpec Starter 的安装、升级、卸载、OpenSpec、Doctor 和 Smoke Test 问题。

推荐始终先区分问题属于哪一层：

```text
环境问题
Starter 安装问题
OpenSpec 项目问题
Generated Integration 问题
Project Context 问题
业务项目问题
```

不要看到一个错误就直接修改 generated 文件或删除目录。

---

# 1. 第一条诊断命令

进入目标项目：

```bash
cd /path/to/project
```

运行：

```bash
./scripts/doctor.sh
```

Doctor 用于检查 Starter 的静态健康状态。

如果 Doctor 没有通过，先处理 Doctor 报告的问题，再考虑真实业务 Change。

---

# 2. 第二条诊断命令

Doctor 基本正常后运行：

```bash
./scripts/smoke-test.sh
```

Smoke Test 用于验证：

```text
Starter
↕
OpenSpec CLI
```

之间的动态契约。

它和 Doctor 的职责不同：

```text
Doctor
→ 静态结构检查

Smoke Test
→ 实际工作流行为检查
```

---

# 3. openspec: command not found

如果看到：

```text
openspec: command not found
```

说明 OpenSpec CLI：

```text
未安装
```

或者：

```text
不在当前 PATH
```

先检查：

```bash
command -v openspec
```

再检查：

```bash
openspec --version
```

如果两条都失败，应先解决 OpenSpec CLI 安装问题。

Starter 不会自动修改机器级 OpenSpec 安装。

---

# 4. OpenSpec 版本 Warning

Doctor 可能显示：

```text
Starter was validated against OpenSpec 1.14.0
```

这不代表其他版本一定不能使用。

它表示：

```text
当前 Starter 的已验证基线
=
OpenSpec 1.14.0
```

如果使用其他版本，应重点运行：

```bash
./scripts/smoke-test.sh
```

确认兼容性。

---

# 5. OpenSpec 版本变化以后 Smoke Test 失败

不要立即认为：

```text
新版 OpenSpec 有 Bug
```

也不要直接修改：

```text
.agents/
.claude/
.cline/
.clinerules/
```

先判断：

```text
OpenSpec 是否改变了合法行为？
Starter 是否仍然假设旧契约？
```

重点检查：

```text
Instruction JSON
Generated workflow
operationGuidance
Verify behavior
Archive behavior
Artifact dependencies
```

---

# 6. OpenSpec root 不正确

运行：

```bash
openspec list --json
```

检查：

```text
root.path
```

它应该指向当前项目。

如果指向父目录或另一个仓库，通常说明：

```text
当前目录位置不对
```

或者：

```text
OpenSpec 找到了更高层项目 Root
```

先确认：

```bash
pwd
```

然后检查附近目录结构。

---

# 7. Doctor: OpenSpec root mismatch

例如：

```text
[FAIL] OpenSpec root mismatch
```

不要继续运行真实 Change。

先确认：

```bash
pwd
openspec list --json
```

如果当前项目嵌套在另一个 OpenSpec 项目中，需要重新检查仓库布局。

---

# 8. schema 不是 spec-driven

Doctor 可能提示：

```text
openspec/config.yaml does not declare schema: spec-driven
```

检查：

```bash
grep '^schema:' openspec/config.yaml
```

Starter 当前设计基于：

```yaml
schema: spec-driven
```

如果项目故意使用其他 Schema，则不能直接假设 Starter 当前规则仍兼容。

---

# 9. 缺少 docs/context/index.yaml

如果 Doctor 报：

```text
Missing file: docs/context/index.yaml
```

项目至少应该拥有：

```yaml
contexts: {}
```

这个文件属于：

```text
Project-owned
```

不是长期 Starter-managed 文件。

如果确认项目从未创建过 Context Registry，可以手工初始化：

```bash
mkdir -p docs/context
printf 'contexts: {}\n' > docs/context/index.yaml
```

---

# 10. 不要覆盖已有 Context Registry

如果：

```text
docs/context/index.yaml
```

已经包含项目 Context：

```yaml
contexts:
  tech-stack:
    path: docs/context/tech-stack.md
```

不要为了“恢复默认”把它改回：

```yaml
contexts: {}
```

这会丢失项目 Context 注册信息。

---

# 11. Context Registry 结构错误

Doctor 当前至少检查：

```yaml
contexts:
```

顶层键存在。

如果格式更复杂后出现问题，先人工检查：

```bash
cat docs/context/index.yaml
```

不要让 AI 猜测 YAML 实际含义。

---

# 12. Context 文件登记了但不存在

例如：

```yaml
contexts:
  database:
    path: docs/context/database.md
```

但：

```text
docs/context/database.md
```

不存在。

应该：

```text
创建真实 Context
```

或者：

```text
从 index.yaml 删除无效登记
```

不要保留死链接。

---

# 13. Context 和真实源码矛盾

例如 Context 说：

```text
Migrations live in db/migrations/
```

但项目明显使用：

```text
migrations/
```

此时不要强行相信 Context。

应该：

```text
调查真实 Source of Truth
↓
确认事实
↓
修正 Context
```

过时 Context 比缺少 Context 更危险。

---

# 14. Install 报 Existing files would be overwritten

例如：

```text
Installation stopped.
Existing files would be overwritten:
```

这是安装器的安全行为，不是 Bug。

说明目标项目已经存在 Starter 想安装的同路径文件。

安装器不会猜：

```text
能不能覆盖
```

---

# 15. 安装冲突时不要直接 rm -rf

不要为了让安装通过直接：

```bash
rm -rf .claude
rm -rf openspec
rm -rf docs/rules
```

这些目录可能包含项目资产。

应该逐个确认冲突文件所有权。

---

# 16. 已有 OpenSpec 项目安装 Starter

如果目标项目已经拥有：

```text
openspec/config.yaml
openspec/changes/
openspec/specs/
```

需要人工合并治理配置。

Starter 安装器不会自动决定：

```text
现有 OpenSpec config
```

和：

```text
Starter config
```

谁应该覆盖谁。

---

# 17. Install 报 Starter metadata already exists

例如：

```text
Starter metadata already exists
```

说明目标项目已经存在：

```text
.ai-openspec-starter/
```

通常表示 Starter 已安装。

此时应该：

```text
使用 upgrade.sh
```

而不是重新 install。

---

# 18. 不要随意删除 .ai-openspec-starter

这个目录包含：

```text
manifest.sha256
version
README.txt
```

升级和卸载依赖它确定文件所有权。

直接删除后：

```text
安全升级能力丢失
安全卸载能力丢失
```

---

# 19. Upgrade 报 LOCAL MODIFICATION

例如：

```text
LOCAL MODIFICATION: docs/rules/testing.md
```

表示：

```text
当前文件 Hash
!=
上次安装 Manifest Hash
```

说明受管文件已经被修改。

这是保护机制。

---

# 20. LOCAL MODIFICATION 怎么处理

先检查 Git：

```bash
git diff -- docs/rules/testing.md
```

然后判断：

```text
修改是否应该保留？
是否应该合并新版 Starter？
是否属于项目专属规则？
是否应该提升回 Starter？
```

不要直接修改 Manifest Hash 来绕过检查。

---

# 21. Upgrade 报 MANAGED FILE MISSING

说明 Manifest 记录的文件已经不存在。

升级器无法知道：

```text
这是故意删除
```

还是：

```text
误删
```

因此停止。

先检查：

```bash
git status --short
```

以及：

```bash
git log -- <file>
```

如果该文件本应存在，可以通过 Git 恢复。

---

# 22. Upgrade 报 NEW FILE COLLIDES WITH EXISTING FILE

说明新版 Starter 新增一个文件，但目标项目已经有同名文件。

例如：

```text
NEW FILE COLLIDES WITH EXISTING FILE:
scripts/example.sh
```

需要人工判断：

```text
Starter 新文件
```

与：

```text
项目已有文件
```

是否应该合并。

---

# 23. Upgrade Dry Run

遇到不确定情况先运行：

```bash
./scripts/upgrade.sh --dry-run /path/to/project
```

Dry Run：

```text
执行检查
显示变化
不写入文件
```

---

# 24. upgrade.sh 应从哪里运行

推荐从：

```text
新版 Starter Source
```

运行：

```bash
cd /path/to/new-ai-openspec-starter
./scripts/upgrade.sh /path/to/project
```

而不是把目标项目里的旧 `upgrade.sh` 当成新版本来源。

---

# 25. 为什么 upgrade 不现场重新生成 integrations

目标机器可能拥有不同的：

```text
OpenSpec machine profile
workflow settings
delivery settings
```

如果升级现场重新生成：

```text
结果可能依赖机器状态
```

因此目标项目升级使用：

```text
新版 Starter 中已经审计过的 generated assets
```

---

# 26. docs/context/index.yaml 升级后变化了

正常情况下：

```text
不应该
```

Starter Upgrade 应保留项目 Context Registry。

检查：

```bash
git diff -- docs/context/index.yaml
```

如果 Starter Upgrade 导致非预期修改，应停止并调查。

---

# 27. Uninstall 默认什么都没删

这是正常的。

运行：

```bash
./scripts/uninstall.sh
```

默认只是：

```text
Preview
```

真正删除需要：

```bash
./scripts/uninstall.sh --yes
```

---

# 28. Uninstall 报 LOCALLY MODIFIED

如果受管文件被项目修改，卸载器会停止。

这是为了防止：

```text
把项目自己的修改一起删掉
```

先人工迁移或确认这些内容。

---

# 29. Uninstall 报 Manifest missing

如果：

```text
.ai-openspec-starter/manifest.sha256
```

不存在，安全卸载无法继续。

不要自己随便创建一个空 Manifest。

如果项目有 Git，可以用 Git 历史判断 Starter 文件来源。

---

# 30. 直接复制 Starter 建项目时无法 uninstall

如果项目不是通过：

```text
install.sh
```

接入，而是：

```text
直接复制 / fork Starter
```

通常没有安装 Manifest。

这种情况应该使用：

```text
Git
```

判断哪些文件仍属于 Starter。

---

# 31. 卸载后 docs/context 还在

这是正确行为。

因为：

```text
docs/context/
```

属于：

```text
Project-owned
```

Starter 卸载不应该删除项目事实。

---

# 32. 卸载后 openspec/changes 还在

也是正确行为。

真实：

```text
Changes
Specs
Archive
```

属于项目工程资产。

Starter 卸载不等于：

```text
彻底删除所有 OpenSpec 数据
```

---

# 33. Doctor 报 User documentation missing

例如：

```text
Missing file:
docs/ai-openspec/upgrade.md
```

如果你正在开发 Starter 本身，而文档还没有创建：

```text
这是阶段性 FAIL
```

如果已经发布正式 Starter：

```text
则属于安装不完整
```

---

# 34. Doctor 报 Starter script missing

例如：

```text
Missing file: scripts/smoke-test.sh
```

正式 Starter 应包含：

```text
install.sh
upgrade.sh
uninstall.sh
doctor.sh
smoke-test.sh
```

缺失任何一个都应该检查安装或升级过程。

---

# 35. Doctor 报脚本不可执行

例如：

```text
scripts/doctor.sh is not executable
```

可以检查：

```bash
ls -l scripts
```

必要时：

```bash
chmod +x scripts/*.sh
```

然后重新运行 Doctor。

---

# 36. Doctor 报 workflow 数量不是 9

当前 Starter 预期：

```text
agents = 9
claude skills = 9
claude commands = 9
cline skills = 9
clinerules = 9
```

如果数量不同：

```text
可能缺文件
可能多出 Onboard
可能 OpenSpec 生成结构改变
```

不要只为了让数量变成 9 而随意删除文件。

---

# 37. Doctor 报 Onboard workflow residue detected

当前 Starter 故意不分发：

```text
onboard
```

如果检测到：

```text
*onboard*
```

首先判断它来自：

```text
旧 Starter
重新生成 OpenSpec integration
人工复制
其他工具配置
```

不要因此修改机器级 OpenSpec profile。

---

# 38. 为什么不能直接修改全局 OpenSpec Profile

因为：

```text
机器级配置
```

可能被其他项目共用。

当前项目不使用 Onboard：

```text
不代表其他项目也不使用
```

---

# 39. Proposal Rule 没有注入

执行：

```bash
openspec instructions proposal \
  --change <change> \
  --json
```

检查：

```text
rules
```

应该包含：

```text
Read and follow docs/rules/proposal.md.
```

如果不存在，检查：

```text
openspec/config.yaml
```

中的：

```yaml
rules:
  proposal:
```

---

# 40. Specs Rule 没有注入

检查：

```bash
openspec instructions specs \
  --change <change> \
  --json
```

期望：

```text
Read and follow docs/rules/specs.md.
```

---

# 41. Design Rule 没有注入

检查：

```bash
openspec instructions design \
  --change <change> \
  --json
```

期望：

```text
Read and follow docs/rules/design.md.
```

---

# 42. Tasks Rule 没有注入

检查：

```bash
openspec instructions tasks \
  --change <change> \
  --json
```

期望：

```text
Read and follow docs/rules/tasks.md.
```

---

# 43. Apply Guidance 没有注入

执行：

```bash
openspec instructions apply \
  --change <change> \
  --json
```

检查：

```text
operationGuidance
```

当前 Starter 期望：

```text
When implementing tasks, read and follow docs/rules/apply.md.
```

---

# 44. Archive Guidance 没有注入

执行：

```bash
openspec instructions archive \
  --change <change> \
  --json
```

检查：

```text
operationGuidance
```

当前期望：

```text
Read and follow docs/rules/archive.md before archiving a change.
```

---

# 45. Verify 没有读取 docs/rules/verify.md

在当前验证基线：

```text
OpenSpec 1.14.0
```

这是预期行为。

不要把它当作 Bug。

---

# 46. Native Verify 当前边界

当前 generated Verify 使用：

```text
openspec instructions apply
```

获取 planning context。

但：

```text
不会消费 operationGuidance
```

也没有：

```text
项目级 verify guidance injection
```

---

# 47. docs/rules/verify.md 怎么生效

Starter 的项目级链路是：

```text
Archive
   ↓
docs/rules/archive.md
   ↓
docs/rules/verify.md
```

因此项目级 Verify Rule 仍然存在，只是不是 Native Verify 自动注入。

---

# 48. 不要手工 Patch Native Verify

不要为了让 Native Verify 读取：

```text
docs/rules/verify.md
```

而直接修改：

```text
.agents/skills/openspec-verify-change/SKILL.md
```

这会让 generated integration 进入手工漂移状态。

---

# 49. Smoke Test 在 Verify boundary 失败

如果看到：

```text
Native Verify no longer uses apply instructions
```

或者：

```text
Native Verify unexpectedly consumes operationGuidance
```

首先确认：

```bash
openspec --version
```

如果 OpenSpec 已升级：

```text
重新审计新版 Verify
```

而不是直接修改 Smoke Test 让它变绿。

---

# 50. Smoke Test 创建 Change 后失败

脚本使用：

```text
trap cleanup
```

正常情况下失败后也会尝试删除临时 Change。

检查：

```bash
openspec list --json
```

是否仍然存在：

```text
starter-smoke-test-*
```

---

# 51. 临时 Smoke Change 残留

如果脚本意外被强制终止，可能残留：

```text
openspec/changes/starter-smoke-test-12345
```

先确认它确实是 Smoke Test 产生的临时 Change。

然后可以删除对应临时目录。

不要删除名称不确定的真实 Change。

---

# 52. Smoke Test 不会真正 Archive

这是故意设计。

真正 Archive 可能：

```text
同步 Smoke Spec
写入 Archive
污染长期 Specs
```

所以 Smoke Test 只验证 Archive Guidance。

---

# 53. openspec validate --strict 失败

先直接运行：

```bash
openspec validate <change> --strict
```

查看 OpenSpec 的真实错误。

常见问题：

```text
Spec 格式不正确
Requirement 缺 Scenario
Capability 路径错误
Artifact 未完成
```

不要只根据 Smoke Test 最后一行猜问题。

---

# 54. Change 状态不符合预期

执行：

```bash
openspec status --change <change> --json
```

观察：

```text
proposal
specs
design
tasks
```

的：

```text
ready
blocked
done
```

不要根据流程记忆直接创建后续 Artifact。

---

# 55. Proposal 写了但仍然不是 done

检查：

```text
proposal.md
```

是否符合当前 OpenSpec Template 和结构要求。

必要时重新运行：

```bash
openspec instructions proposal \
  --change <change> \
  --json
```

以当前 CLI 返回模板为准。

---

# 56. Specs / Design 没有解锁

通常说明：

```text
Proposal 还没有被 OpenSpec 识别为完成
```

先检查：

```bash
openspec status --change <change> --json
```

不要绕过依赖关系直接假设后续已 ready。

---

# 57. Tasks 没有解锁

通常意味着：

```text
Specs
或
Design
```

尚未完成。

再次运行：

```bash
openspec status --change <change> --json
```

查看实际状态。

---

# 58. Apply state 不是 ready

执行：

```bash
openspec instructions apply \
  --change <change> \
  --json
```

查看：

```text
state
progress
tasks
```

可能原因：

```text
Tasks 不完整
Change artifact 不完整
所有 Task 已完成
```

---

# 59. Apply state = all_done

这只表示：

```text
Task checkbox 全部完成
```

不表示：

```text
功能已经通过项目级 Verification
```

仍需要验证 Requirements、实现和证据。

---

# 60. Task 打勾但功能不正确

这是为什么 Starter 强调：

```text
Task completion
≠
Verification
```

应回到：

```text
Requirement
Scenario
Implementation
Test
Runtime Evidence
```

进行追踪。

---

# 61. Archive 能继续但项目 Verification 有问题

OpenSpec Native Archive 和 Starter 项目级 Prompt Policy 是两个层次。

如果：

```text
OpenSpec 允许用户确认后继续
```

不代表：

```text
Starter Verification 已通过
```

两者不要混淆。

---

# 62. 真正不可绕过的 Gate

如果项目要求：

```text
测试失败绝对不能发布
```

不能只依赖 Prompt Rule。

应该使用：

```text
CI
Branch Protection
Release Pipeline
Deployment Gate
```

---

# 63. CodeGraph 不可用

Starter 不要求 CodeGraph 必须存在。

可以使用：

```text
LSP
IDE References
AST
rg
Repository Search
Direct Source Inspection
```

替代。

不要因为 CodeGraph 不可用而停止所有工程工作。

---

# 64. AI 一直猜技术栈

通常说明：

```text
Project Context 不够
```

建议创建：

```text
docs/context/tech-stack.md
```

并注册：

```text
docs/context/index.yaml
```

---

# 65. AI 总把文件放错目录

考虑增加：

```text
docs/context/repository-structure.md
```

明确：

```text
Domain Boundary
Adapter Location
Migration Location
Frontend Location
Generated Code Location
```

---

# 66. AI 总猜外部 API 行为

确认当前 Change 是否真正依赖该系统。

如果是：

```text
读取 external-dependency.md
```

然后查：

```text
正式契约
源码
SDK
配置
真实测试
```

不要把猜测升级成长期 Context。

---

# 67. AI 总创造品牌色

如果项目有真实品牌规范：

```text
建立 brand Context
```

如果没有：

```text
不要让 AI invent
```

Starter 的 UI Rule 已经明确要求如此。

---

# 68. AI 每次加载所有 Context

这是不符合 Starter 设计的。

正确逻辑：

```text
Current Change
↓
index.yaml
↓
选择相关 Context
```

不是：

```text
读取 docs/context/*
```

全部文件。

---

# 69. Project Context 太大

如果一个 Context 文件已经变成：

```text
数千行混杂内容
```

建议按稳定领域拆分，例如：

```text
tech-stack.md
database.md
infrastructure.md
brand.md
```

但不要拆成每个事实一个文件。

---

# 70. 文档和脚本行为不一致

以：

```text
实际脚本行为
```

和：

```text
实际 Smoke Test
```

为优先调查对象。

然后更新文档。

不要为了让文档显得正确而忽略真实行为。

---

# 71. README 和详细文档重复

这是允许的。

职责不同：

```text
README
→ 快速入口

getting-started
→ 教学

workflow-guide
→ 工作流机制

architecture
→ Starter 内部设计

installation / upgrade / uninstall
→ 生命周期管理
```

但不要让同一关键事实出现相互矛盾的版本。

---

# 72. Doctor 本身报假 FAIL

如果某个文件明明存在，但 Doctor 报缺失：

先确认：

```bash
find <path> -type f -print
```

然后检查 Doctor 是否错误推导 generated 文件名。

Generated workflow 的 canonical 文件名不一定全部使用：

```text
*-change
```

后缀。

---

# 73. Doctor 只能证明它检查到的东西

Doctor：

```text
不是 Formal Verification
```

它不会自动证明：

```text
每条 Project Context 事实正确
每条业务 Requirement 正确
所有 generated 文件内容完全一致
```

所以仍需要：

```text
Smoke Test
人工审计
业务测试
```

---

# 74. Smoke Test PASS 也不证明业务正确

Smoke Test 验证：

```text
Starter/OpenSpec compatibility
```

不是：

```text
目标项目业务功能
```

业务功能仍然需要项目自己的 Tests 和 Verification。

---

# 75. Git 是最终安全网

任何安装、升级、卸载前都推荐：

```bash
git status --short
```

重要操作后：

```bash
git diff
```

如果出现异常：

```text
先检查 Git
```

不要继续执行更多破坏性命令。

---

# 76. 不要用 git clean -fd 作为故障修复

当 Starter 有未跟踪文件时：

```bash
git clean -fd
```

可能一次删除：

```text
所有未跟踪项目文件
```

风险很高。

不要把它当成通用清理手段。

---

# 77. 不要用 git reset --hard 作为默认修复

除非明确知道会丢失什么。

Starter 的工具和文档不会要求你为了修复普通配置问题强制重置整个仓库。

---

# 78. Manifest 不应该进故障“修复脚本”

不要随意写自动脚本：

```text
重新计算所有 Hash
```

来让 Upgrade / Uninstall 通过。

这会把：

```text
真实本地修改
```

错误标记成：

```text
Starter 原始状态
```

从而破坏安全机制。

---

# 79. Starter Source 自己怎么检查

在 Starter 源仓库执行：

```bash
./scripts/doctor.sh
```

然后：

```bash
./scripts/smoke-test.sh
```

正式发布前应该：

```text
FAIL: 0
```

---

# 80. Lifecycle Script 语法检查

可以运行：

```bash
bash -n scripts/install.sh
bash -n scripts/upgrade.sh
bash -n scripts/uninstall.sh
bash -n scripts/doctor.sh
bash -n scripts/smoke-test.sh
```

没有输出表示语法通过。

---

# 81. 脚本语法通过但运行失败

`bash -n` 只能验证：

```text
Shell Syntax
```

不能验证：

```text
业务逻辑
路径逻辑
Manifest 生命周期
真实复制和删除行为
```

所以还必须进行实际生命周期测试。

---

# 82. 推荐最终 Lifecycle Test

Starter 发布前应使用临时 Git 项目测试：

```text
Install
↓
Doctor
↓
Smoke Test
↓
修改 Project Context
↓
Upgrade Dry Run
↓
Upgrade
↓
确认 Context 保留
↓
Uninstall Preview
↓
Uninstall
↓
确认 Context 保留
```

这是 Starter 发布前非常重要的一次完整验证。

---

# 83. Install 成功但 Doctor FAIL

不要直接认为 Install 失败。

先看具体 FAIL 类型。

例如：

```text
缺文档
缺脚本
workflow 数量错误
OpenSpec Root 错误
```

它们代表不同问题。

---

# 84. Warning 是否必须修

不一定。

例如版本 Warning：

```text
当前 OpenSpec 不是验证基线
```

可能只是：

```text
兼容性尚未正式确认
```

但：

```text
FAIL
```

通常应该在发布前清零。

---

# 85. 最终排查顺序

遇到问题时推荐：

```text
1. 不做破坏性操作
2. git status --short
3. ./scripts/doctor.sh
4. openspec --version
5. openspec list --json
6. 查看具体文件
7. 必要时运行 smoke-test
8. 确认是 Starter / OpenSpec / Project 哪一层
9. 修正真正的 Source of Truth
10. 再重新验证
```

---

# 86. 最重要的故障排查原则

可以浓缩成：

```text
不知道原因
→ 不删除

不知道所有权
→ 不覆盖

Context 与源码冲突
→ 调查真实事实

Generated Workflow 异常
→ 先审计生成行为

升级冲突
→ 不绕过 Manifest

Task 完成
→ 不等于验证通过

Prompt Guidance
→ 不等于技术 Gate

Doctor PASS
→ 不等于业务正确

Smoke PASS
→ 不等于业务正确
```

---

# 87. 仍然无法定位问题时

收集以下信息：

```text
openspec --version
pwd
git status --short
openspec list --json
./scripts/doctor.sh 输出
./scripts/smoke-test.sh 输出
具体失败文件路径
```

然后基于这些实际证据调查。

不要只描述：

```text
“OpenSpec 好像坏了”
```

越具体的证据，越容易定位真实问题。

---

# 88. 文档导航

安装：

```text
docs/ai-openspec/installation.md
```

第一次使用：

```text
docs/ai-openspec/getting-started.md
```

工作流：

```text
docs/ai-openspec/workflow-guide.md
```

Project Context：

```text
docs/ai-openspec/project-context.md
```

Starter 架构：

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

---

# 89. 最终目标

故障排查的目标不是：

```text
让命令变绿
```

而是：

```text
确认真实问题
保护项目资产
恢复明确的所有权边界
恢复可验证的 Starter/OpenSpec 行为
```

只有理解原因以后再修复，Starter 才能长期稳定使用。
