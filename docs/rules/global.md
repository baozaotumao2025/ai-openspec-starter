# OpenSpec 全局开发原则

## OpenSpec 主导开发

- OpenSpec 是项目开发流程的主控制层。
- 任何业务代码修改，包括 Bugfix、依赖升级和小型修改，都必须属于一个明确的 OpenSpec Change。
- 不允许绕过 OpenSpec 直接进入业务代码实现。

## Change 生命周期

- 每个 Change 使用独立 Git 分支：`change/<change-id>`。
- Change 的 proposal、specs、design、tasks、implementation、验证与 archive 属于同一生命周期。
- 当前 Change 的临时信息只保存在 `openspec/changes/<change-id>/`。
- 已确认的长期系统行为保存在 `openspec/specs/`。

## 上下文原则

- 项目背景位于 `docs/context/`。
- 首先读取 `docs/context/index.yaml`。
- 只加载当前任务需要的上下文，不默认加载全部背景资料。
- 不把任务临时信息写入项目级长期规则。

## 沟通

- 始终使用简体中文。
- 沟通和方案说明遵循金字塔原则：先结论后论据，先整体后细节，避免重复和结构跳跃。

## 上下文生命周期与防污染

项目上下文按生命周期分层管理。

### 项目级：稳定基线

项目级内容包括：

- `docs/rules/` 中的长期工程规则；
- `docs/context/` 中的稳定项目背景；
- `docs/context/index.yaml` 中的上下文路由信息。

项目级文件不得记录：

- 当前 Change 的临时决策；
- 临时排错过程；
- 单次任务进度；
- 仅属于某一个 Domain 的局部细节。

### 领域级：长期领域知识

已经确认的长期系统行为属于：

`openspec/specs/<domain>/`

如果某个 Domain 存在长期但不属于行为规范的背景、约束或外部依赖相关知识，应放入独立的 `docs/context/` 文件，并注册到：

`docs/context/index.yaml`

只有当前 Change 涉及该领域时才加载。

### Change 级：瞬态上下文

当前任务的：

- proposal；
- specs delta；
- design；
- tasks；
- handoff；
- 临时实施决策；

保存在：

`openspec/changes/<change-id>/`

这些信息只服务于当前 Change，并随 Change 归档。

### 防向上污染

仅适用于当前 Change 或单个 Domain 的信息，不得写入：

- `docs/rules/global.md`；
- `openspec/config.yaml` 的全局 context；
- 其他项目级长期规则。

如果局部信息长期有效，应下沉到对应 Domain 的 Spec 或 Context，而不是提升为全局规则。

### 防向下污染

真正适用于整个项目的规则，应在项目级维护唯一来源。

不得在不同 Domain、Change 或局部说明文件中复制并形成不同版本。

### 渐进披露

默认只加载：

1. 全局规则；
2. `docs/context/index.yaml`；
3. 当前阶段规则；
4. 当前任务实际需要的领域和专项上下文。

不得为了“可能有用”提前加载所有项目、领域或历史 Change 内容。

## Git 工作流按需加载

当执行以下操作时，必须读取并遵循：

`docs/rules/git-workflow.md`

适用场景包括：

- 创建或开始一个新的 OpenSpec Change；
- 恢复一个未完成的 Change；
- 进入 Apply；
- 创建提交；
- 合并、变基或处理 Git 冲突；
- Archive 后准备合流；
- 任何可能修改 Git 历史或分支状态的操作。

仅进行纯探索、纯阅读或不涉及仓库状态变更时，无需加载 Git 工作流规则。


## 代码导航

需要定位或理解代码时，应优先使用当前项目已经可用的结构化导航能力，例如：

- CodeGraph；
- LSP；
- IDE symbol / reference search；
- AST 或调用图工具；
- 仓库级代码搜索。

如果 CodeGraph 已安装并完成当前仓库索引，可以优先用于：

- 符号定义；
- 引用关系；
- 调用链；
- 依赖关系；
- 状态读写关系。

如果 CodeGraph 不可用、未初始化或无法覆盖目标内容，则使用当前环境实际可用的替代方式。

`grep` / `rg` 适合用于：

- 精确文本或字面量搜索；
- 配置、文档及非代码文件；
- 结构化导航工具未覆盖的内容；
- 验证其他导航工具返回的结果；
- 当前工具无法直接回答的问题。

不得因为缺少某一种特定导航工具而阻塞代码调查。

所有导航工具都只用于定位和缩小范围。

最终判断仍应以当前实际源码、正式契约、配置或确定性运行结果为准。
