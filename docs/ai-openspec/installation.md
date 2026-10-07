# AI OpenSpec Starter 安装与部署指南

本文档说明如何把 AI OpenSpec Starter 接入已有 Git 项目，或从空目录初始化新项目。

目标是做到：

- 安装过程可预期；
- 不覆盖未知文件；
- 不修改业务源码；
- 不修改机器级 OpenSpec 配置；
- 安装后可以立即运行诊断和 Smoke Test；
- 后续可以安全升级或卸载。

---

# 1. 安装前准备

建议目标机器具备：

```text
Git
Bash
Python 3
OpenSpec CLI
```

当前 Starter 已验证的 OpenSpec 基线版本是：

```text
1.14.0
```

确认版本：

```bash
openspec --version
```

如果输出不是 `1.14.0`，不代表一定不能使用，但建议安装完成后运行：

```bash
./scripts/doctor.sh
./scripts/smoke-test.sh
```

确认兼容性。

---

# 2. Starter 与目标项目

假设 Starter 位于：

```text
/path/to/ai-openspec-starter
```

目标项目位于：

```text
/path/to/my-project
```

目录关系不需要固定。

Starter 和目标项目可以完全分离。

---

# 3. 安装方式

进入 Starter：

```bash
cd /path/to/ai-openspec-starter
```

已有 Git 仓库（传入仓库根目录）：

```bash
./scripts/init.sh /path/to/my-project
```

创建新项目（目标路径必须尚不存在）：

```bash
./scripts/init.sh --new /path/to/new-project
```

`init.sh` 会调用安装器并运行 `doctor.sh`；新项目模式还会创建目录并执行 `git init`。健康检查失败时，已安装的文件会保留，便于根据诊断修复环境。

如果只想安装文件、不运行健康检查，可以直接运行底层安装器：

```bash
./scripts/install.sh /path/to/my-project
```

也可以使用相对路径：

```bash
./scripts/install.sh ../my-project
```

如果当前目录就是目标项目，也可以：

```bash
/path/to/ai-openspec-starter/scripts/install.sh .
```

---

# 4. 安装脚本会做什么

`install.sh` 只复制 Starter 明确管理的内容。

主要包括：

```text
.agents/
.claude/
.cline/
.clinerules/
.codegraph/

docs/rules/
docs/context/index.yaml
docs/ai-openspec/

openspec/config.yaml
openspec/changes/archive/.gitkeep
openspec/specs/.gitkeep

scripts/
```

安装完成后还会创建：

```text
.ai-openspec-starter/
```

其中包含：

```text
manifest.sha256
version
README.txt
```

这个目录用于：

- 记录 Starter 安装了哪些文件；
- 记录安装时的文件校验值；
- 检测用户是否修改过 Starter 管理文件；
- 支持安全升级；
- 支持安全卸载。

不要手工删除这个目录，除非你明确放弃 Starter 的升级和卸载保护。

---

# 5. 安装脚本不会做什么

安装脚本不会：

- 修改应用源码；
- 修改 Git 历史；
- 自动提交 Git；
- 修改机器级 OpenSpec workflow profile；
- 修改用户全局 OpenSpec 配置；
- 自动安装依赖；
- 删除已有文件；
- 静默覆盖已有 Starter 路径；
- 自动加入 Onboard workflow。

---

# 6. 为什么安装遇到冲突会停止

如果目标项目已经存在例如：

```text
docs/rules/global.md
openspec/config.yaml
.claude/commands/opsx/apply.md
```

安装器不会猜测：

```text
“这个文件是不是可以覆盖？”
```

而是直接停止。

示例：

```text
Installation stopped. Existing files would be overwritten:

  - openspec/config.yaml
  - docs/rules/global.md

No starter files were copied.
```

这是正常的安全行为。

你应该先判断这些文件属于：

```text
已有 OpenSpec 配置
已有 AI 工程规则
旧版 Starter
项目自己的同名文件
```

再决定如何合并。

不要为了让安装通过而直接：

```bash
rm -rf
```

删除未知内容。

---

# 7. 安装成功后

进入目标项目：

```bash
cd /path/to/my-project
```

首先运行：

```bash
./scripts/doctor.sh
```

Doctor 应检查：

```text
OpenSpec CLI
OpenSpec 版本
项目 Root
核心规则文件
用户文档
OpenSpec config
generated integrations
workflow 数量
Onboard 是否残留
Verify 边界
Starter scripts
```

理想结果：

```text
FAIL: 0
```

可能存在环境兼容性 `WARN`。

---

# 8. 运行 Smoke Test

Doctor 通过后执行：

```bash
./scripts/smoke-test.sh
```

Smoke Test 会创建一个临时 Change。

测试流程包括：

```text
OpenSpec root
    ↓
创建临时 Change
    ↓
Proposal rule injection
    ↓
Specs rule injection
    ↓
Design rule injection
    ↓
Tasks rule injection
    ↓
Apply guidance
    ↓
Strict validation
    ↓
Task tracking
    ↓
Archive guidance
    ↓
Native Verify boundary
    ↓
自动清理 Change
```

正常结果类似：

```text
Smoke test complete.
PASS: 28
FAIL: 0
```

Smoke Test 不应修改真实业务源码。

---

# 9. 安装后的目录结构

典型项目会增加：

```text
my-project/
├── .ai-openspec-starter/
│
├── .agents/
├── .claude/
├── .cline/
├── .clinerules/
├── .codegraph/
│
├── docs/
│   ├── ai-openspec/
│   ├── context/
│   └── rules/
│
├── openspec/
│   ├── config.yaml
│   ├── changes/
│   └── specs/
│
└── scripts/
```

业务源码结构不需要因为 Starter 改变。

---

# 10. 第一次安装后的项目 Context

Starter 默认：

```yaml
contexts: {}
```

这意味着：

> Starter 不知道当前项目使用什么技术栈、品牌、数据库、外部系统或部署环境。

这是故意的。

你应该逐步把真实项目事实登记到：

```text
docs/context/
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
    description: Runtime, frameworks, package managers and build tooling

  infrastructure:
    path: docs/context/infrastructure.md
    description: Deployment and infrastructure facts
```

详细方法见：

```text
docs/ai-openspec/project-context.md
```

---

# 11. 已经使用 OpenSpec 的项目

如果目标项目已经存在：

```text
openspec/
```

不要直接覆盖。

先检查：

```bash
find openspec -maxdepth 3 -type f -print
```

以及：

```bash
openspec list --json
```

重点确认：

```text
schema
已有 changes
已有 specs
config.yaml
workflow customizations
```

然后人工决定如何合并 Starter 的规则。

安装器默认不会替你做这个决定。

---

# 12. 已经存在 Claude / Cline / Agent 配置

同样，如果已经存在：

```text
.agents/
.claude/
.cline/
.clinerules/
```

安装器会因为冲突停止。

不要直接覆盖。

先确认里面是否包含：

```text
项目自己的 Agent Skills
自定义 Commands
已有 OpenSpec integration
其他工具配置
```

必要时应该进行人工合并。

---

# 13. Generated Integrations

Starter 当前分发：

```text
9 个 OpenSpec workflow
```

包括：

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

Starter 不分发：

```text
onboard
```

原因是当前经过审计的 Onboard 属于组合式自动流程，可能绕过 Starter 的工程治理链。

因此安装后 Doctor 会检查：

```text
Onboard workflow is not distributed
```

---

# 14. Generated 文件不要手工 Patch

以下内容主要属于 OpenSpec generated integration：

```text
.agents/
.claude/
.cline/
.clinerules/
```

原则：

```text
不要手工修改生成文件来修复治理逻辑。
```

如果 OpenSpec 升级后 generated workflow 行为变化：

```text
重新生成
    ↓
重新审计
    ↓
运行 Doctor
    ↓
运行 Smoke Test
```

详细流程见：

```text
docs/ai-openspec/upgrade.md
```

---

# 15. Verify 的重要区别

当前 OpenSpec 1.14.0 中，原生 Verify：

```text
OpenSpec native Verify
```

会读取 Apply planning context，但没有项目级 Verify guidance 注入点。

因此它不会自动加载：

```text
docs/rules/verify.md
```

Starter 不会伪装这个能力存在。

项目级完整验证通过：

```text
Archive
  ↓
docs/rules/archive.md
  ↓
docs/rules/verify.md
```

实现。

这属于项目级 prompt policy。

如果需要真正不可绕过的技术强制，应使用 CI 或外层受控流程。

---

# 16. OpenSpec 机器级配置

Starter 安装器不会执行：

```bash
openspec config
```

修改机器级 workflow profile。

原因是机器级设置可能同时影响：

```text
其他仓库
其他项目
其他用户工作流
```

Starter 只管理当前项目中的文件。

---

# 17. CodeGraph

CodeGraph 是可选能力。

如果已有 CodeGraph 并且仓库已索引，可以使用。

没有 CodeGraph 时可以继续使用：

```text
LSP
IDE References
AST
rg
Repository Search
Direct Source Inspection
```

因此：

```text
CodeGraph 不属于 Starter 的硬依赖。
```

---

# 18. Git 建议

安装前建议：

```bash
git status --short
```

最好确保已有工作已提交或备份。

安装完成后：

```bash
git status --short
```

确认新增内容。

然后：

```bash
./scripts/doctor.sh
./scripts/smoke-test.sh
```

都通过后再提交。

---

# 19. 安装完成后的第一条 Change

例如：

```bash
openspec new change add-user-profile
```

查看状态：

```bash
openspec status --change add-user-profile --json
```

然后按照：

```text
Proposal
→ Specs
→ Design
→ Tasks
→ Apply
→ Verify
→ Archive
```

工作。

完整教程见：

```text
docs/ai-openspec/getting-started.md
```

---

# 20. 下一步

安装完成后推荐依次阅读：

```text
getting-started.md
workflow-guide.md
project-context.md
```

如果安装异常：

```text
troubleshooting.md
```

如果需要升级：

```text
upgrade.md
```

如果需要删除：

```text
uninstall.md
```
