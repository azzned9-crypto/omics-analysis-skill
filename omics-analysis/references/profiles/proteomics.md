# 蛋白组 Profile

本 profile 用于 clean protein abundance matrix。

## 常见矩阵状态

- 常常已经做过 log2 转换
- 常常已经做过标准化
- 可能已经做过缺失值填补

除非用户明确要求，或矩阵状态本身不清楚，否则不要重复做这些步骤。

## 常见差异分析默认值

- 统计方法：`limma`
- 显著性阈值：若可用，优先 `adj.P.Val < 0.05`
- fold-change 阈值：常见可选 `|log2FC| > 0.58`、`1` 或 `1.5`，按项目严格程度确认

这些是建议默认值，不是硬性统一标准。

## 常见风险

- 忘记确认这份 clean data 是否已经做过 imputation
- 不加说明地把转录组阈值直接套到蛋白组
- 在富集分析时混用 UniProt ID、gene symbol 和 protein group label

