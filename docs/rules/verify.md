# Verify 阶段规则

## 阶段目标

Verify 用于证明当前实现与 OpenSpec Change 一致。

验证关注：

1. Completeness：计划是否完成；
2. Correctness：实现是否满足 Specs；
3. Coherence：实现是否遵循 Design 和项目架构约束。

Verify 不实施新需求，也不通过修改 Specs 来掩盖实现偏差。

## 验证顺序

优先按照以下顺序执行：

1. OpenSpec artifact / task 完整性；
2. 类型检查和静态检查；
3. Requirement 与实现映射；
4. Scenario 与测试覆盖；
5. 相关单元测试；
6. 必要的集成 / 契约测试；
7. Design 与代码结构一致性；
8. 高风险规则的额外验证。

先运行成本低、反馈快的检查，再进入成本更高的验证。

## Specs 可追溯性

对 ADDED 或 MODIFIED 的重要 Requirement，应建立：

`Requirement → Implementation → Test / Verification`

的可追溯关系。

不得仅因为 `tasks.md` 已勾选就认为 Requirement 已实现。

## Scenario 覆盖

针对 Specs 中实际定义的 Scenario，确认：

- 实现确实处理该条件；
- 存在对应测试或其他确定性验证；
- 测试断言验证业务结果，而不仅是代码能够执行。

不得为了追求形式上的 1:1 数量而创造无意义测试。

## 状态与不变量

涉及状态机、权限、金额、期限、幂等、并发或其他关键业务不变量时，应重点验证：

- 合法路径；
- 非法状态拒绝；
- 边界条件；
- 不变量不会被旁路；
- 失败不会留下部分写入或非法状态。

## 风险驱动验证

根据变更风险增加验证深度。

### 低风险

例如：

- 文案；
- 非行为性配置；
- 局部展示调整。

执行直接相关验证即可。

### 中风险

例如：

- 普通业务逻辑；
- Repository；
- API 契约；
- 状态变化。

应执行相关单元测试和必要的集成 / 契约测试。

### 高风险

例如：

- 权限；
- 金额；
- 高风险核心业务规则；
- 状态机；
- Migration；
- 并发；
- 数据不可逆操作。

除常规验证外，应评估是否需要：

- 更完整的边界测试；
- Migration 验证；
- 并发测试；
- 定向 Mutation Testing；
- 回滚或恢复验证。

## Spec / Design 漂移

如果实现与 Specs 或 Design 不一致：

不得默认以代码为准。

必须明确判断：

1. 实现错误；还是
2. 已确认的设计本身需要修改。

如果属于设计缺口：

- 回到对应 OpenSpec artifact 修正；
- 重新确认；
- 再修改实现并重新 Verify。

不得通过事后修改 Spec 使错误实现“看起来合规”。

## 数据库验证

涉及 Schema 或 Migration 时，应额外检查：

- Migration 是否可执行；
- 当前模型与 Migration 是否一致；
- 必要的数据转换是否明确；
- 是否意外形成跨领域 ORM 耦合；
- 是否存在数据丢失或不可逆风险。

必要时读取 `docs/rules/database.md`。

## Verification Report

验证结果应明确区分：

- CRITICAL：归档前必须解决；
- WARNING：存在明显风险或偏差；
- SUGGESTION：非阻塞改进；
- NOT VERIFIED：由于证据不足无法验证；
- NOT APPLICABLE：该检查不适用于当前 Change。

不得把“没有检查”报告为“验证通过”。

## Verify 完成条件

只有在以下内容都得到明确结果后，才能认为 Verify 完成：

1. Task 完整性；
2. Requirement 实现映射；
3. Scenario 覆盖；
4. 必要测试和静态检查；
5. Design 一致性；
6. 已知风险与未验证项已明确记录。

## 工程验证命令

如果当前 Change 涉及：

- 业务代码；
- 可执行代码；
- 依赖或构建配置；
- 类型检查；
- Lint；
- 格式化；
- 自动化测试；

则读取并遵循：

`docs/rules/engineering-workflow.md`

Verify 必须基于项目当前真实存在的工具链执行验证。

不得：

- 凭旧规则假设某个 `make` target 存在；
- 凭经验虚构 npm / pnpm / Python 命令；
- 因缺少统一入口而跳过必要验证。

如果项目尚未提供统一工程命令，应使用已经确认存在的底层工具完成验证，并在 Verification Report 中说明实际执行的命令。

## 权限验证

如果当前 Change 涉及以下任一方面：

- 身份认证或主体传递；
- 授权或访问控制；
- 角色、权限、成员关系、所有权或共享关系；
- 对受保护资源的访问或操作；
- 跨用户、组织、租户、项目、工作区或其他资源边界的访问；
- API Key、服务主体、自动化任务或代理执行；

则必须读取并遵循：

`docs/rules/authorization.md`

Verify 必须检查权限行为是否形成完整闭环：

`Requirement → Design → Authorization Enforcement → Positive / Negative Test`

至少确认：

- Specs 明确了允许与拒绝行为；
- Design 明确了 principal、action、resource 和 context；
- Design 明确了 decision point 和 enforcement point；
- 实现没有绕过已确认的授权边界；
- 正常业务主体路径没有被高权限主体替代；
- 关键允许路径存在确定性验证；
- 关键拒绝路径存在确定性验证；
- 跨主体或跨资源边界访问按实际风险进行了验证；
- 身份和授权上下文在调用链中没有丢失、替换或被意外扩大。

如果权限行为依赖项目边界之外的组件，还必须读取并遵循：

`docs/rules/external-dependency.md`

并确认相关结论是否来自足够可靠的实际证据。

结构化导航工具只用于定位和缩小调查范围。

如果 CodeGraph 已安装并完成相关仓库索引，可以使用；否则可以使用 LSP、IDE 引用搜索、`rg`、仓库搜索或直接源码分析。

不得将工具搜索结果本身当作最终事实依据。

需要运行态验证但尚未完成的内容，必须明确标记为 `NOT VERIFIED`。

存在无法解释的高风险授权缺口时，应标记为 `CRITICAL`，不得进入 Archive。

## 外部依赖 Evidence 生命周期

如果当前 Change 对项目边界之外的组件进行了新的源码、契约、配置或运行态查证，Verify 阶段必须判断这些结论是否需要长期保留。

默认情况下，调查结果保留在当前 Change 中。

只有当某项事实：

- 已经过实际验证；
- 与当前源码、正式契约、配置或确定性运行结果一致；
- 适用版本或配置范围明确；
- 适用操作、主体或资源范围明确；
- 未验证内容已经明确区分；
- 具有跨 Change 的复用价值；

才适合提升为长期项目 Context。

长期保存方式必须遵循：

`docs/rules/external-dependency.md`

并通过：

`docs/context/index.yaml`

确定当前项目是否已经登记合适的 Context 存储位置。

如果没有合适的项目 Context：

- 不自动创建固定名称的 Evidence 文件；
- 不为了完成 Verify 强制建立新的长期事实源；
- 可以继续将调查结果保留在当前 Change 中。

如果当前 Change 使用了已有长期 Evidence，Verify 还必须确认其对当前问题涉及的版本、配置、操作、主体和资源范围仍然适用。

发现已有 Evidence 已经过期、范围不足或与当前事实冲突时，应更新项目已有的权威 Context，或将差异明确记录在当前 Change 中。

不得建立多个相互独立、可能漂移的长期事实源。
