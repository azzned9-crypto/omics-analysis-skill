# Bulk RNA-seq Profile

本 profile 用于 bulk RNA-seq 基因层矩阵。

## 常见矩阵状态

- 可能是 raw counts
- 可能是 TPM 或 FPKM
- 也可能已经做过转换

在选择方法前，必须先确认矩阵状态。

## 特殊条件追问

进入 RNA 分析前，必须先确认：

1. 建库方式是否为 polyA、ribo-depletion、total RNA、stranded、unstranded、3 prime 或 capture。
2. 项目是否属于普通 mRNA 转录组，还是全转录组项目。
3. 样本是否来自 FFPE、血液、低输入量或明显降解样本。
4. 若为血液 RNA，是否需要额外关注 globin RNA 残留。
5. 若为 FFPE 或降解样本，后续 QC 不能直接套高质量 RNA 的覆盖均匀性标准。

这些信息会影响 QC 判断、矩阵解释以及下游方法选择，因此应在第一轮问清楚。

## 常见差异分析默认值

- raw counts：`DESeq2` 或 `edgeR`
- 已转换矩阵：`limma`
- 显著性阈值：`padj < 0.05`
- fold-change 阈值：常见为 `|log2FC| > 1`

## 常见风险

- 用已转换数据去跑 count-based model
- 混用 Ensembl ID 和 gene symbol 却没有记录转换过程
- 未定义背景集就直接做富集分析
- 没有先问清楚建库方式、FFPE、血液来源或全转录组类型，就直接进入 QC 或下游分析