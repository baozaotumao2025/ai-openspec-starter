# UI 与前端视觉规则

## 适用范围

当当前 Change 涉及以下任一方面时，应读取并遵循本规则：

- UI 或前端界面设计；
- 品牌视觉；
- Logo 或品牌标识的产品内使用；
- 品牌色或视觉基线；
- Design Token；
- Theme；
- Skin；
- 白标能力；
- 组件视觉体系；
- 全局视觉一致性。

本规则定义通用的 UI 与品牌工程原则。

具体项目的：

- 品牌名称；
- Logo；
- 品牌色；
- 字体；
- 品牌性格；
- 产品视觉定位；
- 已批准的品牌资产；

不得在本通用规则中预设。

这些事实应由当前项目自己的 Context 提供。

## 品牌事实来源

涉及品牌或视觉决策时，首先读取：

`docs/context/index.yaml`

确认当前项目是否登记了相关品牌、视觉或 UI Context。

如果存在相关 Context，只加载当前 Change 实际需要的文件。

如果不存在，不得自行假设：

- 品牌名称；
- Logo 形式；
- 主品牌色；
- 辅助色；
- 字体；
- 视觉风格；
- Theme；
- 品牌语气；
- 白标策略。

不得把历史项目、参考产品、第三方组件库或外部系统的视觉设计自动视为当前项目的品牌规范。

## 品牌与 UI 解耦

品牌身份与具体业务 UI 实现必须保持解耦。

默认采用以下逻辑层次：

`Brand Token → Semantic Token → Component`

### Brand Token

Brand Token 表达项目已经确认的品牌基础事实，例如：

- 品牌主色；
- 品牌辅助色；
- 字体体系；
- Logo 相关基础属性；
- 其他稳定品牌基线。

Brand Token 的具体值必须来自当前项目正式登记的品牌 Context 或其他正式事实源。

### Semantic Token

Semantic Token 表达 UI 中的语义角色，例如：

- background；
- foreground；
- primary；
- secondary；
- muted；
- border；
- accent；
- success；
- warning；
- danger；
- focus；
- surface。

具体名称应根据当前项目已有设计系统和技术栈确定，本通用规则不固定 Token 命名。

Semantic Token 应承接 Brand Token 或 Theme 层提供的值，而不是让业务组件直接依赖品牌原始值。

### Component

业务组件应优先消费 Semantic Token 或已经建立的组件级设计契约。

不得让大量业务组件直接依赖：

- 品牌原始色值；
- 品牌字体原始定义；
- Logo 内部实现；
- Theme 的底层实现细节；
- 单个品牌 Skin 的特殊值。

目标是使品牌调整不会要求大面积修改业务页面或业务逻辑。

## 禁止硬编码品牌事实

如果当前项目已经建立 Brand Token / Semantic Token 或等价机制，业务组件不得绕过该机制直接硬编码品牌事实。

例如，不应因为某个页面当前视觉效果正确，就直接把：

- 十六进制颜色；
- RGB / HSL 品牌值；
- 品牌字体；
- 品牌资源路径；

散落到大量业务组件中。

具体技术栈如何表达 Token，应以当前项目真实配置为准。

不得在本通用规则中假设项目一定使用：

- CSS Variables；
- Tailwind；
- CSS-in-JS；
- Sass；
- 某个 UI Framework；
- 某个 Design System 工具。

## Theme、Skin 与白标

如果项目支持：

- Light / Dark Theme；
- 多品牌；
- Skin；
- 客户定制品牌；
- 白标；

应优先通过 Brand Token、Semantic Token 或项目中的等价抽象完成映射。

业务能力、业务状态和业务组件结构原则上不应因为品牌切换而产生无必要分叉。

具体 Theme 实现方式由当前项目技术栈和 Design 决定。

## 第三方 UI 与参考产品

第三方：

- UI 组件库；
- Headless Primitive；
- Design System；
- 模板；
- 参考产品；
- 外部系统；

可以作为实现或设计参考，但其默认视觉不能自动成为当前项目的品牌事实。

引入第三方 UI 能力时，应区分：

- 行为与可访问性能力；
- 组件结构；
- 默认样式；
- 当前项目品牌表达。

最终视觉应服从当前项目正式确认的品牌与 UI 规则。

## Change 与长期事实边界

当前 Change 中尚未稳定的：

- 页面视觉方案；
- Token 调整；
- 组件样式实验；
- Theme 实验；
- Logo 使用尝试；
- 新视觉方向；

应先保存在当前：

`openspec/changes/<change-id>/`

不得直接提升为项目长期品牌事实。

只有已经确认具有长期项目价值的品牌或视觉事实，才应整理到项目专属 Context，并注册到：

`docs/context/index.yaml`

## Design 要求

当 Change 涉及 UI、品牌或前端视觉体系时，Design 应根据实际范围说明：

- 使用了哪些项目品牌 / UI Context；
- Brand Token 的事实来源；
- Semantic Token 如何承接品牌事实；
- Component 如何避免直接绑定品牌原始值；
- 是否涉及 Theme、Skin 或白标；
- 是否存在第三方 UI 能力；
- 第三方视觉与当前项目品牌如何保持边界；
- 当前决策哪些属于 Change，哪些属于长期项目事实。

不得用“遵循品牌”“保持统一风格”等不可验证描述代替具体边界。

## 实现与验证

Apply 和 Verify 阶段应根据当前 Change 实际范围确认：

- 实现是否使用当前项目真实存在的 Token / Theme 机制；
- 业务组件是否绕过语义层直接绑定品牌原始值；
- 是否引入未经确认的新品牌事实；
- Theme / Skin 切换是否要求修改不相关业务逻辑；
- 第三方组件默认视觉是否意外成为事实来源；
- 实现是否与当前 Design 和项目品牌 Context 一致。

具体使用什么构建、视觉测试、组件测试或截图验证方式，由当前项目真实工具链决定，本规则不预设固定技术。
