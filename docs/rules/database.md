# 数据库设计规则

## 适用范围

当 Change 涉及以下内容时使用本规则：

- 数据库表或字段；
- ORM Model；
- Repository；
- 数据迁移；
- 跨领域数据引用；
- 查询模型与读模型；
- 数据库 Schema 变更。

## 领域是数据边界

数据库的数据边界按业务 Domain / Module 划分，而不是按单个功能 Slice 划分。

例如：

- `auth`
- `billing`
- `case`
- `knowledge`

多个属于同一领域的功能 Slice，可以共享该领域的核心持久化模型。

不得为了每个操作 Slice 单独创建一套私有数据表。

## 持久化模型归属

业务表定义属于对应领域模块。

推荐：

`features/<domain>/models.*`

全局数据库基础设施只负责：

- 数据库连接；
- Session / Client；
- ORM Base / Metadata；
- 事务基础设施。

不得在全局 `models/` 中集中存放全部业务实体。

## Write Model 与 Read Model

### Write Model

领域核心状态由该领域自己的持久化模型维护。

只有所属领域可以修改自己的核心数据。

### Read Model

面向具体查询、页面或聚合需求时，应优先定义专门的只读 DTO / Projection。

不得为了查询方便，把其他领域的完整 ORM Model 传播到当前领域。

## 跨领域数据关系

跨领域关联优先使用稳定标识符，例如：

`user_id`

而不是 ORM 导航关系。

默认规则：

- 禁止跨领域 ORM `relationship()`；
- 禁止通过 ORM 实体进行跨领域级联写入；
- 禁止直接修改其他领域的数据；
- 跨领域协作通过 ID、DTO、Port、领域事件或明确查询契约完成。

## 数据对象分层

至少区分：

### ORM Model

负责：

- 数据库映射；
- 持久化约束；
- 领域内部事务。

不得直接作为 API Response 或跨领域契约。

### DTO / Schema

负责：

- 输入校验；
- 输出契约；
- 跨边界数据传递。

DTO 应使用明确语义命名，例如：

- `CreateXInput`
- `UpdateXInput`
- `XResponse`

### Read DTO / Projection

负责具体查询场景所需的数据投影。

只读取当前使用场景所需字段，避免加载无关完整实体。

## Migration

采用：

**分散模型定义，集中 Migration 管理。**

业务模型保存在对应 Domain 内。

Migration 文件统一保存在项目级迁移目录，例如：

`migrations/`

数据库 Schema 变更必须通过 Migration 完成，不允许直接手工修改生产数据库结构。

## Schema 事实来源

项目形成稳定数据库结构后，应维护机器可读的当前 Schema 快照，例如：

- `schema.sql`
- ORM metadata 导出文件
- 数据库 Schema 描述文件

Agent 分析当前数据库结构时，应优先使用该快照与当前 Migration 作为事实来源。

不得仅凭代码中的历史假设推断当前数据库结构。

## Design 阶段要求

涉及数据库的 Design 必须明确：

1. 数据属于哪个 Domain；
2. 新增或修改哪些持久化模型；
3. 写入责任属于哪个领域；
4. 是否存在跨领域数据引用；
5. 使用物理关系还是逻辑 ID 引用；
6. 是否需要 Read DTO / Projection；
7. Migration 策略；
8. 向后兼容与数据迁移风险。
