# Archive 阶段规则

## 阶段目标

Archive 用于结束一个已经实施并完成验证的 OpenSpec Change。

归档不是补做实现或修改需求的阶段。

## 归档前验证

归档前必须读取并遵循：

`docs/rules/verify.md`

如果当前 Change 在最后一次代码修改之后尚未完成项目级验证，应先按照该规则完成验证并报告结果。

## 归档准入标准

项目级归档决策应先依据 Verification Report 判断当前 Change 是否适合归档。

以下情况属于项目级阻塞问题，应停止正常归档流程，报告问题并优先完成修复和重新验证：

- Verification Report 存在 CRITICAL；
- 存在已知 Spec / Design 漂移并影响当前 Change 的正确性；
- 关键数据库 Migration 尚未验证；
- 高风险行为存在明确但尚未处理的正确性问题。

未完成 Task 应结合其对当前 Change 验收结果的影响判断；
OpenSpec 原生 Archive 对不完整 Task / Artifact 的提示和用户确认仍按其内建流程处理，
不得把这些确认误述为项目级验证已经通过。

WARNING、SUGGESTION 或 NOT VERIFIED 不得被隐藏，应在归档决定前明确报告。
如果 NOT VERIFIED 涉及验收标准、关键业务不变量、权限边界、关键 Migration
或其他高风险行为，应明确报告其阻塞风险。

本规则属于项目级 prompt policy，不是 CLI 强制锁。
OpenSpec 自带 Archive workflow 的内建检查、用户确认和 CLI 控制值仍然有效。
如果项目需要不可绕过的归档或发布 Gate，应由项目外层自动化、CI 或明确的受控入口实现，
不得声称仅凭 OpenSpec operation guidance 已形成技术强制。

## Specs 同步

存在 delta specs 时：

- 按 OpenSpec Archive workflow 判断是否需要同步至主 `openspec/specs/`；
- 不手工复制或覆盖主 Specs；
- 同步完成后确认主 Specs 与 Change 的最终行为一致。

## 归档内容

归档后应确保：

- Change artifacts 被完整保留；
- 已确认的长期系统行为进入主 Specs；
- Change 临时信息不被误写入项目级长期规则；
- 未解决但允许归档的问题已经明确记录。

## 归档总结

归档结果至少说明：

1. Change；
2. 验证状态；
3. Specs 是否同步；
4. 是否存在 WARNING / NOT VERIFIED；
5. 归档位置。


## 外部依赖 Evidence 归档检查

如果当前 Change 对项目边界之外的组件进行了源码、契约、配置或运行态查证，Archive 前必须确认 Evidence 生命周期已经正确处理。

检查：

- Verify 已判断本次调查结果是否具有跨 Change 复用价值；
- 需要长期保留的稳定事实已经写入当前项目已登记的合适 Context；
- 不满足长期保留条件的调查过程、临时判断和未确认假设仍只保留在当前 Change；
- 没有把当前 Change 特有的设计取舍写成项目级长期事实；
- 已有长期 Evidence 如果已经过期、范围不足或与当前事实冲突，已经得到修正或明确记录；
- 没有建立多个相互独立、可能漂移的长期事实源。

长期 Evidence 的处理必须遵循：

`docs/rules/external-dependency.md`

并通过：

`docs/context/index.yaml`

确定当前项目实际登记的 Context。

如果当前项目没有合适的长期 Context：

- 不自动创建固定名称的 Evidence 文件；
- 不因为 Archive 而强制建立新的 Context；
- 可以继续将调查结果保留在当前 Change 中。

不得因为当前 Change 使用了外部依赖，就强制创建长期 Evidence。

Archive 只确认 Evidence 生命周期已经正确收口，不在此阶段重新开展新的外部依赖调查。
