---
name: omics-time-series-analysis
description: 面向组学项目的时序分析模块 skill。用于在 clean matrix 和 metadata 已准备好的前提下，分析有序时间点数据，尤其适合 Mfuzz 类软聚类任务，并强制确认时间顺序、重复结构和时序解释边界。
---

# 组学时序分析模块

## 前置条件

必须先明确：

1. 时间顺序
2. 重复样本结构
3. 矩阵是否适合时序分析

## 核心规则

1. 未经确认，不得仅凭样本名推断时间顺序。
2. 必须区分“聚类分析”和“差异检验”。
3. 必须记录进入 Mfuzz 或其他时序聚类前的特征过滤规则。
4. 若使用 Mfuzz，必须记录 cluster 数量或 fuzzification 相关设置。

