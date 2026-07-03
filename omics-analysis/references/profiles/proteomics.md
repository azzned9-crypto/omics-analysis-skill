# 蛋白组 Profile

本 profile 用于 clean protein abundance matrix。

## 常见矩阵状态

- 常常已经做过 log2 转换
- 常常已经做过标准化
- 可能已经做过缺失值填补

除非用户明确要求，或矩阵状态本身不清楚，否则不要重复做这些步骤。

## 特殊条件追问

进入蛋白组分析前，必须先确认：

1. 样本类型是否为血浆、血清、尿液、CSF、唾液或其他体液。
2. 平台类型是否为 DIA、DDA、TMT、label-free。
3. 若为血浆或血清，不能默认混用同一套污染判定逻辑。
4. 若为 DDA，不能用 DIA 的缺失模式预期去要求矩阵。
5. 若为 TMT/iTRAQ，后续 QC 应额外关注通道平衡、串扰和 ratio compression。

这些信息会影响 QC、差异分析解释和可视化口径，因此应在第一轮问清楚。

## 常见差异分析默认值

- 统计方法：`limma`
- 显著性阈值：若可用，优先 `adj.P.Val < 0.05`
- fold-change 阈值：常见可选 `|log2FC| > 0.58`、`1` 或 `1.5`，按项目严格程度确认

这些是建议默认值，不是硬性统一标准。

## 常见风险

- 忘记确认这份 clean data 是否已经做过 imputation
- 不加说明地把转录组阈值直接套到蛋白组
- 在富集分析时混用 UniProt ID、gene symbol 和 protein group label
- 没有先问清楚样本类型和平台类型，就直接进入 QC 或下游分析