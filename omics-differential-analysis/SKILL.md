---
name: omics-differential-analysis
description: 面向 clean omics matrix 的差异分析模块 skill。用于在 assay 类型、矩阵状态、metadata 和 contrast 已明确的前提下，计算或审查 DEG、DEP、DEM 结果、阈值、火山图、热图和显著特征结果表。
---

# 组学差异分析模块

## 前置条件

必须先明确：

1. assay 类型
2. 矩阵状态
3. 分组变量
4. 精确 contrast
5. 阈值策略

缺少任一项时都应停止。

## 最低流程

1. 根据 assay 和矩阵状态选择合适的统计方法。
2. 先构建全量结果表，而不是只保留显著项。
3. 再按阈值生成显著结果子集。
4. 输出火山图和热图。
5. 记录本次真实使用的全部阈值。

## 不要硬编码

不要给所有组学写一个通用的 `log2FC` 阈值。

阈值只能作为默认建议，再由本次项目确认或覆盖。

