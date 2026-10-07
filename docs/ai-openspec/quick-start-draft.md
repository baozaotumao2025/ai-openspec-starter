# 快速入手：从项目约定到第一个版本（README 草稿）

> 本文是供预览的草稿。文中的项目、选型和业务功能都是示例，不代表 Starter 已预设这些事实。

把 Starter 安装到项目并通过 `./scripts/doctor.sh` 后，按下面四步使用。OpenSpec 的基本单位是 **Change**：一次有边界、可验证的变更。一个版本通常包含多个 Change。

## 1. 给 AI 一个简短的项目入口

在目标项目根目录创建项目自有的 `AGENTS.md`：

```md
# 项目协作入口

- 使用简体中文沟通。
- 开始工作前阅读 `docs/rules/global.md`。
- 查看 `docs/context/index.yaml`，只读取当前任务相关的项目背景。
- 业务代码变更先建立 OpenSpec Change，再按 Specs、Design、Tasks 实施。
- 不确定项目事实时先查证，不自行假设。
```

`AGENTS.md` 只负责指路。长期工程规则放在 `docs/rules/`，已确认的项目事实放在 `docs/context/`，具体变更内容放在 `openspec/changes/<change-id>/`。不要在入口文件中再复制一份完整规则。Starter 分发的 `.agents/skills/` 是 OpenSpec 工作流文件，与项目根目录的 `AGENTS.md` 用途不同。

## 2. 用一个 Change 完成技术架构选型

假设要为一个新服务选择后端框架、数据库和部署方式。先把**真实约束**写清楚，例如团队熟悉的语言、目标运行环境、预期数据规模和运维条件；不知道的内容先调查。可以这样对 AI 说：

> 请先 Explore 这个项目的技术约束和候选架构，列出待确认信息、候选方案及取舍。暂时不要实施。

确认范围后创建 Change：

```bash
openspec new change choose-service-architecture
openspec status --change choose-service-architecture
```

继续让 AI 按 OpenSpec 完成各项产物。每行可以直接用自然语言与 AI 交互；如果习惯终端，也可以先运行右侧 CLI 命令获取该产物的项目规则和模板，再让 AI 编写文件：

| 产物 | 对 AI 说 | 获取 OpenSpec 指令 |
| --- | --- | --- |
| Proposal | “为 `choose-service-architecture` 写 Proposal，说明选型原因和范围。” | `openspec instructions proposal --change choose-service-architecture` |
| Specs | “写可观察的运行、持久化和部署约束；不要预设框架名称。” | `openspec instructions specs --change choose-service-architecture` |
| Design | “比较已调查的候选方案，记录选择依据、成本、风险和边界。” | `openspec instructions design --change choose-service-architecture` |
| Tasks | “把选定方案拆成可验证的骨架、构建、测试和部署任务。” | `openspec instructions tasks --change choose-service-architecture` |

上述 `instructions` 命令**只输出指导，不会替你生成文件**。在 AI 工具中也可以说“OpenSpec continue `choose-service-architecture`”，逐个创建下一项产物；每完成一步，用 `openspec status --change choose-service-architecture` 看哪些产物已完成、哪些已可开始。若想一次准备完整规划，可在创建 Change 之前直接对 AI 说“OpenSpec propose：为新服务做架构选型”，由该工作流创建 Change 和规划产物，再逐项审阅结果。

例如，Design 可以记录：“基于已确认的运行环境和团队能力，选择方案 A；方案 B 在当前约束下增加运维成本。”这里的 A/B 要在真实项目中调查后填写，不能由模板预设。Apply 完成、验证通过并归档后，把**已经实施且稳定**的技术栈、目录和工具链事实登记到 `docs/context/`，并在 `docs/context/index.yaml` 中索引。

如果本次只形成决策记录，没有代码或行为变更，仍应清楚说明产物和验证范围；不要虚构业务 Specs 或声称代码已经验证。

规划确认后，对 AI 说“OpenSpec apply `choose-service-architecture`，逐项实施并验证”；终端可用 `openspec instructions apply --change choose-service-architecture` 查看实施指导。完成后让 AI Verify，再按 Archive 工作流归档。只有决策文档的 Change，应如实报告未实施的部分，归档时按实际情况决定是否跳过 Specs 同步。

## 3. 用一个 Change 开发业务功能

假设要增加“用户查看自己的资料”。在目标项目中创建 Change：

```bash
openspec new change view-own-profile
openspec status --change view-own-profile
```

可以对 AI 说：

> 请按 OpenSpec 为 `view-own-profile` 完成 Proposal、Specs、Design 和 Tasks。先查证现有身份、用户数据和 API 结构；每个 Task 写明如何验证。完成规划后再开始 Apply。

也可以逐项推进；每个 CLI 命令只返回当前项目的指导，由 AI 或开发者依据指导写入文件：

| 阶段 | 对 AI 说 | 终端命令 |
| --- | --- | --- |
| Proposal | “OpenSpec continue `view-own-profile`：先写为什么做及影响范围。” | `openspec instructions proposal --change view-own-profile` |
| Specs | “继续写用户能查看什么，以及未登录时如何拒绝。” | `openspec instructions specs --change view-own-profile` |
| Design | “继续设计身份、授权和资料读取边界。” | `openspec instructions design --change view-own-profile` |
| Tasks | “继续拆分实现任务，每项说明验证方式。” | `openspec instructions tasks --change view-own-profile` |

写完每项后运行 `openspec status --change view-own-profile` 查看进度。若希望 AI 一次生成规划，可以在运行 `openspec new change` 之前对 AI 说“OpenSpec propose：增加查看本人资料功能”，让该工作流创建 Change 和规划产物，再逐项审阅结果。

最小的 Specs 场景可以是：

```md
### Requirement: 用户查看自己的资料
系统 SHALL 允许已登录用户查看自己的资料。

#### Scenario: 查看本人资料
- **WHEN** 已登录用户请求自己的资料
- **THEN** 系统返回其允许查看的资料字段

#### Scenario: 未登录访问
- **WHEN** 未登录请求访问资料
- **THEN** 系统拒绝访问
```

随后按顺序完成：

1. **Design**：明确资料属于哪个领域、身份从哪里来、在哪里执行资源级授权、数据如何读取。
2. **Tasks**：拆成可验证的实施步骤，包括允许和拒绝场景。
3. **Apply**：依据规划修改代码、运行相关验证、更新 `tasks.md`。任务全部勾选只代表任务记录完成。
4. **Verify**：让 AI 执行 OpenSpec Verify，并按 `docs/rules/verify.md` 做项目级验证；检查 Requirement → 实现 → 测试、Design 一致性和权限负向场景。对缺少证据的项目标记 `NOT VERIFIED`。
5. **Archive**：先查看验证报告并处理阻塞问题，再让 AI 按 Archive 工作流归档。归档时核对 delta Specs 是否同步到主 `openspec/specs/`。

实施、验证和归档也有对应入口：

| 阶段 | 对 AI 说 | 终端命令 |
| --- | --- | --- |
| Apply | “OpenSpec apply `view-own-profile`，逐项实施并报告验证结果。” | `openspec instructions apply --change view-own-profile` 查看指导；`openspec status --change view-own-profile` 查看产物状态。 |
| Verify | “OpenSpec verify `view-own-profile`，同时遵循 `docs/rules/verify.md`，列出未验证项和阻塞问题。” | `openspec validate view-own-profile --strict` 检查规范格式；完整 Verify 需由 AI 工作流结合代码和测试执行。 |
| Archive | “按项目 Archive 规则检查 `view-own-profile`；满足条件后归档，报告 Specs 同步结果和归档位置。” | 先运行 `openspec instructions archive --change view-own-profile` 查看指导；确认验证结果后运行 `openspec archive view-own-profile`。 |

例如，终端检查可以这样运行：

```bash
openspec status --change view-own-profile
openspec validate view-own-profile --strict
```

当前验证基线 OpenSpec 1.14.0 的**原生 Verify 工作流不会自动读取** `docs/rules/verify.md`。项目级 Verify 要显式要求 AI 遵循该文件；Archive 的配置会提示读取 `docs/rules/archive.md`，后者要求归档前执行项目级验证。这些是 AI 工作流指导，不是不可绕过的 CLI 门禁。

**不要把** `openspec validate` **当成完整 Verify**：它检查 OpenSpec 产物的有效性，不会证明功能实现正确。当前 CLI 也没有与 AI Verify 工作流等价的 `openspec verify` 子命令。

## 4. 已有 PRD：从文档生成 Change

假设产品团队已将 PRD 放在 `docs/prd/profile/`，其中有 `overview.md`、流程图和验收说明。PRD 可以不完整，但要把**已确认需求、待确认问题和方案设想**区分开。OpenSpec 1.14.0 没有“导入 PRD 并自动生成 Change”的独立 CLI 命令；最短路径是在 AI 工具中明确指定 PRD 路径和 OpenSpec 工作流。

### 快速生成规划

直接对 AI 说：

> 请阅读 `docs/prd/profile/` 下与“查看本人资料”有关的文件，使用 OpenSpec propose 创建一个范围明确的 Change。先列出 PRD 中已经确认的需求、歧义、缺失的验收条件和互相冲突的内容；有关键缺口先向我确认，不要自行补成事实。根据已确认内容生成 Proposal、Specs、Design 和可验证的 Tasks，并标明每项需求在 PRD 中的来源。

`propose` 工作流会创建 Change 并编写规划产物。不要在调用它之前再运行 `openspec new change` 创建同名 Change。若 PRD 覆盖多个独立功能，先让 AI 建议拆成多个 Change，确认边界后分别规划。

### 想逐步审阅时

也可以先让 AI Explore PRD，确认范围后从终端创建一个空 Change，再逐项推进：

```bash
openspec new change view-own-profile-from-prd
openspec status --change view-own-profile-from-prd
openspec instructions proposal --change view-own-profile-from-prd
```

然后对 AI 说：

> 请以 `docs/prd/profile/` 为输入，OpenSpec continue `view-own-profile-from-prd`。一次只完成当前可创建的产物；标出 PRD 来源、缺失信息和待确认决策，完成后等我审阅。

审阅一个产物后，再运行 `openspec status --change view-own-profile-from-prd`，按需将下一项的名称（`specs`、`design` 或 `tasks`）填入 `openspec instructions <artifact> --change view-own-profile-from-prd`，并让 AI 继续。`instructions` 只输出规则和模板；**PRD 的读取、判断和产物编写由 AI 或开发者完成**。

### 从 PRD 到归档的完整生命周期

| 阶段 | 本例要做什么 | 可用指令 |
| --- | --- | --- |
| Explore | 阅读 PRD、现有代码和项目 Context；指出歧义、冲突与范围。 | 对 AI 说“OpenSpec explore `docs/prd/profile/`”。 |
| Proposal | 明确为什么做、做哪些能力，以及 PRD 哪些内容进入本 Change。 | `openspec instructions proposal --change view-own-profile-from-prd` |
| Specs | 把已确认需求写成可观察的 Requirement 和 Scenario；缺少验收条件时先确认。 | `openspec instructions specs --change view-own-profile-from-prd` |
| Design | 基于真实技术栈确定身份、授权、数据和接口边界；PRD 的技术设想需要查证。 | `openspec instructions design --change view-own-profile-from-prd` |
| Tasks | 拆成可验证的实施步骤。 | `openspec instructions tasks --change view-own-profile-from-prd` |
| Apply | 实施并验证任务，更新 `tasks.md`。 | 对 AI 说“OpenSpec apply `view-own-profile-from-prd`”；可用 `openspec instructions apply --change view-own-profile-from-prd` 查看指导。 |
| Verify | 对照 **已确认的 Specs** 检查实现与测试，同时回看 PRD 来源，报告遗漏和未验证项。 | 对 AI 说“OpenSpec verify `view-own-profile-from-prd`，并遵循 `docs/rules/verify.md`”；`openspec validate view-own-profile-from-prd --strict` 仅检查规范有效性。 |
| Archive | 处理阻塞问题后归档，并检查主 Specs 同步结果。 | 先查看 `openspec instructions archive --change view-own-profile-from-prd`；确认后由 AI 工作流归档，或执行 `openspec archive view-own-profile-from-prd`。 |

**PRD 是需求输入，已确认的 Specs 是该 Change 的行为契约。**如果 PRD 在实施中发生变化，先更新 OpenSpec 产物并重新确认，再继续 Apply 和 Verify。归档保存 Change 历史及长期 Specs；原始 PRD 是否继续作为产品文档保留，由项目自己的文档管理方式决定。

## 5. 一个版本在哪里结束？

**每个 Change 在 Archive 结束；版本发布在 OpenSpec 之外完成。**例如版本 `1.0.0` 包含架构初始化、用户资料和登录三个 Change。每个 Change 完成验证与归档后，主 `openspec/specs/` 表达当前确认的系统行为，归档目录保留变更历史。

发布版本时，再由项目自己的发布流程完成构建、集成测试、Git tag、部署和回滚准备。不要把“已 Archive”直接等同于“已发布”。如果需要不可绕过的合并或发布门禁，应在项目 CI 或受控发布流程中设置。

更完整的逐步说明见 `docs/ai-openspec/getting-started.md`；安装、升级与冲突处理见 `docs/ai-openspec/installation.md`。
