# AI OpenSpec Starter 卸载指南

本文档说明如何安全地从一个项目中移除 AI OpenSpec Starter。

卸载的核心原则是：

```text
只删除 Starter 明确拥有的文件
```

而不是：

```text
删除所有看起来像 OpenSpec 的内容
```

因此 Starter 使用：

```text
.ai-openspec-starter/manifest.sha256
```

识别自己安装和管理的文件。

---

# 1. 最简单的卸载方式

进入已经安装 Starter 的目标项目：

```bash
cd /path/to/my-project
```

先预览：

```bash
./scripts/uninstall.sh
```

默认情况下：

```text
不会删除任何文件
```

脚本只会显示：

```text
哪些 Starter 文件可以删除
```

确认以后执行：

```bash
./scripts/uninstall.sh --yes
```

才会真正删除。

---

# 2. 为什么默认只预览

卸载属于破坏性操作。

即使 Manifest 能识别 Starter 文件，也不应该让：

```text
误执行一个命令
```

直接删除大量工程文件。

因此设计成：

```text
uninstall.sh
    ↓
Preview

uninstall.sh --yes
    ↓
Delete
```

---

# 3. 卸载依赖安装 Metadata

目标项目应该存在：

```text
.ai-openspec-starter/
├── manifest.sha256
├── version
└── README.txt
```

其中最重要的是：

```text
manifest.sha256
```

它记录：

```text
安装时 Hash
+
Starter 管理文件路径
```

---

# 4. 没有 Manifest 为什么不能自动卸载

如果没有 Manifest，脚本无法安全区分：

```text
Starter 文件
```

和：

```text
项目自己的文件
```

例如：

```text
docs/rules/global.md
```

可能是 Starter 创建的。

也可能是项目原本就有的。

没有明确所有权时：

```text
不要自动删除
```

---

# 5. 卸载前会重新校验 Hash

对于 Manifest 中的每个受管文件：

```text
安装时 Hash
      ↓
当前文件 Hash
```

如果一致：

```text
说明没有被项目修改
```

可以安全删除。

如果不同：

```text
说明文件已经被修改
```

卸载会停止。

---

# 6. 为什么修改过的 Starter 文件不能直接删除

例如：

```text
docs/rules/testing.md
```

最开始由 Starter 安装。

之后项目团队加入了自己的规则。

那么它已经不再是单纯的：

```text
Starter 原始文件
```

直接删除可能导致：

```text
项目自己的工程知识丢失
```

因此：

```text
modified managed file
→ stop
```

---

# 7. 卸载遇到修改文件

你可能看到：

```text
LOCALLY MODIFIED: docs/rules/testing.md
```

此时：

```text
没有任何文件会被删除
```

先检查：

```bash
git diff -- docs/rules/testing.md
```

然后决定：

```text
保留这个文件
手工迁移内容
恢复 Starter 原始版本
人工删除
```

不要为了让卸载通过而盲目覆盖。

---

# 8. MANAGED FILE MISSING

如果 Manifest 记录了某个文件，但它已经不存在，卸载也会停止。

例如：

```text
MANAGED FILE MISSING: scripts/doctor.sh
```

原因是脚本无法判断：

```text
这是项目故意删除
```

还是：

```text
安装状态已经损坏
```

因此需要人工检查。

---

# 9. 卸载会删除哪些内容

只会删除 Manifest 中记录的 Starter 受管文件。

典型包括：

```text
.agents/
.claude/
.cline/
.clinerules/
.codegraph/

docs/rules/
docs/ai-openspec/

openspec/config.yaml

Starter scripts
```

但实际删除范围以：

```text
.ai-openspec-starter/manifest.sha256
```

为准。

---

# 10. 卸载不会简单 rm -rf 整个目录

例如：

```text
docs/
```

可能同时包含：

```text
项目自己的文档
Starter 文档
项目 Context
```

因此脚本不会：

```bash
rm -rf docs
```

它只删除 Manifest 中的具体文件。

然后仅尝试：

```text
删除已经变成空目录的目录
```

---

# 11. 项目业务源码不会被删除

例如：

```text
src/
app/
internal/
cmd/
web/
backend/
frontend/
```

只要它们没有出现在 Starter Manifest 中：

```text
卸载器不会碰
```

Starter 安装器本身也不应该把业务源码加入 Manifest。

---

# 12. docs/context/index.yaml 不会删除

这是一个非常重要的所有权边界。

文件：

```text
docs/context/index.yaml
```

属于：

```text
目标项目
```

Starter 第一次安装时，如果它不存在，可以初始化：

```yaml
contexts: {}
```

但初始化以后：

```text
所有权属于项目
```

---

# 13. 为什么卸载还要保留 Context Registry

项目可能已经登记：

```text
tech-stack
database
authentication
infrastructure
integrations
brand
frontend
```

例如：

```yaml
contexts:
  tech-stack:
    path: docs/context/tech-stack.md
    description: Runtime, framework, build and test tooling
```

这些都是：

```text
项目工程知识
```

不是 Starter 的临时文件。

---

# 14. 其他 docs/context 文件也不会删除

例如：

```text
docs/context/tech-stack.md
docs/context/database.md
docs/context/infrastructure.md
```

本来就应该属于项目。

因此正常情况下：

```text
不会出现在 Starter Manifest
```

卸载器也不会删除。

---

# 15. 兼容旧 Manifest

某些较旧的 Starter 安装可能曾经把：

```text
docs/context/index.yaml
```

错误记录为受管文件。

当前卸载脚本会特别跳过它。

也就是说：

```text
即使旧 Manifest 记录了 index.yaml
↓
仍然保留
```

---

# 16. Git 历史不会修改

卸载脚本不会执行：

```text
git commit
git reset
git checkout
git clean
git rebase
git push
```

它只处理工作树中的 Starter 文件。

---

# 17. 卸载后 Git 会显示删除

执行：

```bash
./scripts/uninstall.sh --yes
```

之后：

```bash
git status --short
```

可能看到：

```text
D  docs/rules/global.md
D  openspec/config.yaml
D  ...
```

这是正常的。

因为：

```text
文件从工作树中删除
```

但 Git 历史仍然存在。

---

# 18. 建议卸载前检查 Git 状态

执行：

```bash
git status --short
```

最好先处理：

```text
尚未提交的重要工作
```

因为 Git 是整个项目最可靠的恢复手段。

---

# 19. 卸载前推荐备份方式

最简单：

```text
确保项目已经提交到 Git
```

或者至少：

```text
保存当前 diff
```

例如：

```bash
git diff
```

---

# 20. 机器级 OpenSpec 配置不会修改

Starter 卸载不会执行：

```bash
openspec config
```

也不会修改用户机器上的：

```text
OpenSpec profile
workflow list
delivery setting
global configuration
```

---

# 21. 为什么不修改全局 OpenSpec

机器级 OpenSpec 设置可能被：

```text
其他项目
其他仓库
其他工作流
```

使用。

项目卸载 Starter：

```text
不应该影响其他项目
```

---

# 22. Onboard 也是如此

Starter 当前不分发：

```text
onboard
```

但卸载 Starter 不会：

```text
删除机器级 Onboard 配置
```

Starter 只管理：

```text
当前项目中的分发文件
```

---

# 23. OpenSpec Changes 会不会删除

Starter 卸载器只删除：

```text
Manifest 中明确记录的文件
```

它不会扫描并删除：

```text
openspec/changes/*
```

中的真实 Change。

---

# 24. 为什么不能删除所有 openspec/

一个正在使用的项目可能已经拥有：

```text
openspec/changes/
openspec/specs/
```

真实项目数据。

如果简单执行：

```bash
rm -rf openspec
```

可能导致：

```text
Change 历史丢失
长期 Specs 丢失
```

这是不可接受的。

---

# 25. .gitkeep 的处理

Starter 可能管理：

```text
openspec/changes/archive/.gitkeep
openspec/specs/.gitkeep
```

卸载时可以删除这些受管 `.gitkeep`。

但是如果目录中已有：

```text
真实文件
```

目录本身不会被删除。

---

# 26. 空目录清理

卸载完成后，脚本会尝试删除：

```text
已经为空
```

的 Starter 目录。

例如：

```text
docs/ai-openspec/
```

如果已经没有文件，可以删除目录。

---

# 27. 非空目录不会删除

例如：

```text
docs/
```

还有：

```text
docs/context/tech-stack.md
```

那么：

```text
rmdir docs
```

会失败。

脚本会保留该目录。

这是预期行为。

---

# 28. .agents / .claude 等目录

如果这些目录中只有 Starter 文件：

```text
卸载后可能自动消失
```

如果还有项目自己的配置：

```text
目录会保留
```

---

# 29. 为什么不用 rm -rf

因为：

```text
rm -rf .claude
```

可能同时删掉：

```text
项目自己的 Claude 配置
```

所以卸载器只删除：

```text
具体受管文件
```

---

# 30. 卸载脚本本身也会删除

因为：

```text
scripts/uninstall.sh
```

本身是 Starter 管理文件。

正式卸载过程中，它最终也会被删除。

在 Unix/Linux 环境下：

```text
当前正在运行的脚本文件被删除
```

通常不会阻止已经启动的进程继续完成。

---

# 31. 卸载完成后的 Metadata

完成受管文件删除后：

```text
.ai-openspec-starter/
```

也会删除。

这表示：

```text
当前项目不再处于 Starter 管理状态
```

---

# 32. 卸载后不能直接 upgrade

因为：

```text
Manifest 已删除
```

所以：

```bash
upgrade.sh
```

不再有旧安装所有权数据。

如果以后重新使用 Starter：

```text
重新 install
```

即可。

---

# 33. 卸载后的项目 Context

卸载完成后可能仍然存在：

```text
docs/context/
```

这是正确的。

因为：

```text
项目事实
```

不应该因为工具治理层卸载而消失。

---

# 34. 卸载后的 OpenSpec Specs

真实长期 Specs 可能仍然存在：

```text
openspec/specs/
```

卸载器不会主动删除这些项目资产。

---

# 35. 卸载后的 Change

真实：

```text
openspec/changes/
```

也应继续存在，除非项目负责人明确决定删除。

---

# 36. 如果目标是彻底删除 OpenSpec

这是另一个操作。

Starter 卸载：

```text
≠
彻底删除项目所有 OpenSpec 数据
```

Starter 卸载只负责：

```text
移除 Starter 所拥有的治理层文件
```

如果你还想删除：

```text
所有 OpenSpec Specs
所有 Changes
所有归档历史
```

必须单独人工评估。

---

# 37. 为什么不提供自动“彻底清空 OpenSpec”

因为：

```text
Specs
Changes
Archive
```

可能已经成为项目正式工程资产。

自动删除风险太高。

---

# 38. Preview 示例

执行：

```bash
./scripts/uninstall.sh
```

可能看到：

```text
AI OpenSpec Starter Uninstall

The following starter-managed files are eligible for removal:

  - docs/rules/global.md
  - docs/rules/testing.md
  - openspec/config.yaml
  - scripts/doctor.sh
  ...

Preview only. Nothing was deleted.
```

---

# 39. 确认以后正式卸载

执行：

```bash
./scripts/uninstall.sh --yes
```

脚本会逐个输出：

```text
removed <file>
```

---

# 40. 卸载后检查

执行：

```bash
git status --short
```

检查删除内容是否符合预期。

---

# 41. 重点确认 Context 仍然存在

执行：

```bash
test -f docs/context/index.yaml &&
echo "project context preserved"
```

如果项目之前存在该文件，应看到：

```text
project context preserved
```

---

# 42. 重点确认业务源码还在

根据真实项目结构检查。

例如：

```bash
ls
```

或者：

```bash
git status --short
```

不应该出现：

```text
大量非 Starter 业务代码删除
```

---

# 43. 如果卸载结果不符合预期

不要继续做额外清理。

先使用：

```text
Git
```

查看：

```bash
git status --short
git diff
```

如果文件原本已经提交，可以恢复。

---

# 44. 使用 Starter Source 直接作为新项目怎么办

有一种情况：

```text
不是使用 install.sh 安装
```

而是：

```text
直接复制 / fork 整个 Starter 仓库作为项目起点
```

这种项目可能没有：

```text
.ai-openspec-starter/manifest.sha256
```

---

# 45. 没有 Manifest 的 Starter-based Project

此时：

```bash
./scripts/uninstall.sh
```

不会自动工作。

这是故意的。

因为脚本无法确定：

```text
哪些文件仍然属于 Starter
哪些文件已经演化成项目自己的文件
```

---

# 46. 这种情况应该使用 Git

如果项目直接基于 Starter 建立，建议通过：

```text
Git diff
Git history
```

判断哪些治理文件需要删除。

不要人工伪造 Manifest 后直接卸载。

---

# 47. 卸载和升级的所有权模型相同

两者都遵守：

```text
Manifest
      ↓
确定 Starter 所有权
      ↓
Hash
      ↓
确认文件未被修改
```

---

# 48. Starter Managed

典型：

```text
docs/rules/
docs/ai-openspec/
openspec/config.yaml
generated integrations
Starter scripts
```

---

# 49. Project Owned

典型：

```text
业务源码
docs/context/
OpenSpec real Changes
OpenSpec long-term Specs
Git history
项目自己的配置和文档
```

---

# 50. Machine Owned

例如：

```text
用户机器级 OpenSpec Config
全局工具设置
```

Starter 不应该管理。

---

# 51. 三种所有权必须区分

可以记成：

```text
Starter-owned
Project-owned
Machine-owned
```

卸载只处理：

```text
Starter-owned
```

---

# 52. 为什么这是最重要的卸载原则

如果所有权边界不清楚：

```text
安装容易
升级危险
卸载更危险
```

只有明确记录：

```text
谁拥有哪个文件
```

才能安全维护。

---

# 53. 不推荐的卸载方式

不要：

```bash
rm -rf .agents
rm -rf .claude
rm -rf .cline
rm -rf .clinerules
rm -rf docs/rules
rm -rf openspec
```

除非你已经逐项确认这些目录完全没有项目资产。

---

# 54. 也不要直接删除 Metadata

不要第一步：

```bash
rm -rf .ai-openspec-starter
```

因为一旦删掉 Manifest：

```text
安全卸载器失去所有权信息
```

---

# 55. 推荐卸载顺序

完整流程：

```text
检查 Git 状态
    ↓
运行 uninstall preview
    ↓
确认没有 modified conflict
    ↓
人工检查删除列表
    ↓
运行 --yes
    ↓
git status
    ↓
确认 Context 保留
    ↓
确认业务代码保留
    ↓
提交卸载变化
```

---

# 56. 最简操作

日常只需要记：

```bash
cd /path/to/project

git status --short

./scripts/uninstall.sh

./scripts/uninstall.sh --yes

git status --short
```

---

# 57. 卸载验收标准

可以认为卸载正确完成，当：

```text
.ai-openspec-starter/ 已删除

Starter 受管文件已删除

docs/context/index.yaml 仍保留

项目自己的 Context 仍保留

业务源码仍保留

真实 OpenSpec Change / Specs 未被误删

机器级 OpenSpec 配置未改变

Git 历史未改变
```

---

# 58. 如果只是暂时不用 Starter

不一定需要卸载。

你也可以只是：

```text
停止使用相关 Workflow
```

保留规则和历史。

卸载适用于：

```text
明确决定项目不再使用 Starter 治理层
```

的场景。

---

# 59. 如果准备换另一套治理工具

建议先：

```text
导出或保留项目 Context
```

因为：

```text
docs/context/
```

中的很多信息依然是有价值的项目知识。

---

# 60. 项目 Context 可以独立于 Starter 存在

这也是为什么它属于：

```text
Project-owned
```

而不是：

```text
Starter-owned
```

即使未来不用 Starter：

```text
tech-stack
repository structure
database facts
infrastructure facts
```

仍然可以继续作为项目文档使用。

---

# 61. 最终原则

卸载机制可以浓缩为：

```text
不知道是不是我的
→ 不删

用户改过
→ 不删

项目 Context
→ 不删

业务源码
→ 不删

真实 Specs / Changes
→ 不删

机器级 OpenSpec Config
→ 不改

只有 Manifest 明确拥有且仍未修改的文件
→ 才删除
```

---

# 62. 下一步

如果卸载过程中出现：

```text
LOCALLY MODIFIED
MANAGED FILE MISSING
Manifest missing
```

阅读：

```text
docs/ai-openspec/troubleshooting.md
```

如果之后希望重新安装：

```text
docs/ai-openspec/installation.md
```

如果只是升级而不是删除：

```text
docs/ai-openspec/upgrade.md
```
