# Bulk RNA-seq Profile

本 profile 用于 bulk RNA-seq 基因层矩阵。

## 常见矩阵状态

- 可能是 raw counts
- 可能是 TPM 或 FPKM
- 也可能已经做过转换

在选择方法前，必须先确认矩阵状态。

## 常见差异分析默认值

- raw counts：`DESeq2` 或 `edgeR`
- 已转换矩阵：`limma`
- 显著性阈值：`padj < 0.05`
- fold-change 阈值：常见为 `|log2FC| > 1`

## 常见风险

- 用已转换数据去跑 count-based model
- 混用 Ensembl ID 和 gene symbol 却没有记录转换过程
- 未定义背景集就直接做富集分析

