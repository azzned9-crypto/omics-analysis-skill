---
name: omics-downstream-analysis
description: 面向 bulk RNA-seq、蛋白组和代谢组 clean matrix 的跨组学下游分析主入口 skill。用于在开展组间比较、差异分析、富集分析、时序聚类或网络分析前，强制确认组学类型、矩阵状态、对比设计、阈值记录和可复现输出要求。
---

# 组学下游分析主入口

## 将本 Skill 作为总入口

当任务还比较宽泛，或用户表达类似以下意图时，优先从本 skill 进入：

- 做下游分析
- 做疾病组和对照组比较
- 分析 clean omics data
- 做 DEG、DEP 或 DEM
- 做富集分析
- 做 Mfuzz 或 WGCNA

在没有确认组学类型、矩阵状态、metadata 和 contrast 之前，不要直接跳入某个具体方法。

## 必需输入

正式分析前必须具备：

1. 特征在行、样本在列的 clean matrix。
2. 带样本 ID 且至少包含一个分组变量的 metadata 表。
3. 明确的组学类型：`proteomics`、`bulk-rnaseq` 或 `metabolomics`。
4. 明确的分析目标：`differential`、`enrichment`、`time-series`、`network` 或它们的组合。

如果矩阵状态不清楚，必须停止。不要默认猜测这个矩阵是否已经 raw、normalized、log2、batch-corrected 或 imputed。

## 入口流程

1. 读取 [references/entry-checklist.md](references/entry-checklist.md)。
2. 加载对应的组学 profile：
   - [proteomics](references/profiles/proteomics.md)
   - [bulk-rnaseq](references/profiles/bulk-rnaseq.md)
   - [metabolomics](references/profiles/metabolomics.md)
3. 读取 [references/parameter-policy.md](references/parameter-policy.md)。
4. 确认 contrast 和模型设计。
5. 决定需要调用哪个模块 skill：
   - `omics-differential-analysis`
   - `omics-enrichment-analysis`
   - `omics-time-series-analysis`
   - `omics-network-analysis`
6. 按 [references/output-contract.md](references/output-contract.md) 约束输出。

## 模块调用规则

主 skill 负责总入口和流程控制。

只有在主 skill 已经明确以下信息后，才进入模块 skill：

- 组学类型
- 矩阵状态
- 样本 metadata
- 分组变量
- contrast
- 阈值策略

如果用户请求本身就很窄，也可以直接进入某个模块，但仍然要先补齐并核对这些上下文。

## 核心规则

1. 区分“默认阈值”和“本次真实使用阈值”。
2. 所有阈值都必须写入结果和审计说明。
3. 区分探索性阈值和正式报告阈值。
4. fold-change 阈值必须考虑 assay 差异；未经说明，不得把某一种组学的默认阈值直接套用到另一种组学。
5. 富集分析前必须确认 ID 类型。
6. Mfuzz 前必须确认时间顺序。
7. WGCNA 前必须确认 trait 表和样本量检查。
8. `SKILL.md` 保持简洁，方法细节放入 references，不把所有实现细节塞进主文件。

