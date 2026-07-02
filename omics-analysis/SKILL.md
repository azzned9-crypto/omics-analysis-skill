---
name: omics-analysis
description: 面向 bulk RNA-seq、蛋白组和代谢组 clean matrix 的跨组学分析总入口 skill。用于在开展 QC、下游分析和结果可视化前，统一确认组学类型、矩阵状态、contrast、batch、阈值策略、模块选择和审计要求，并把 AI 引导到预设模块中执行，而不是直接猜测方案。
---

# 组学分析总入口

## 这个主体的作用

这个 skill 不是为了和模块抢工作，而是为了做总调度。

当 `/omics-*` 同时显示多个 skill 时，模块负责具体方法，主体负责：

1. 收口任务入口。
2. 强制 AI 不要直接猜 assay 和矩阵状态。
3. 强制 AI 把任务分发到正确模块。
4. 在模块运行前补齐必须确认的信息。
5. 统一记录默认值、覆盖值和审计信息。

所以：

- 模块是“怎么做某一步”。
- 主体是“现在该做哪一步、在做之前必须问什么”。

如果直接调用模块也可以工作，但前提是上下文已经清楚。
如果上下文还不清楚，主体就有意义。

## 什么时候优先调用主体

以下情况优先从本 skill 进入：

- 用户说“做组学分析”
- 用户说“做下游分析”
- 用户只给了 clean matrix 和 metadata
- 用户没有说清楚 assay 类型、contrast、batch、阈值
- 用户要做多个模块组合任务

## 当前挂载的模块

读取 [references/module-map.md](references/module-map.md)。

当前主体下挂模块：

- `omics-qc-process`
- `omics-differential-analysis`
- `omics-enrichment-analysis`
- `omics-time-series-analysis`
- `omics-network-analysis`
- `omics-visualization`

## 必需输入

正式分析前，尽量补齐：

1. clean matrix
2. metadata
3. assay 类型
4. 分析目标

如果这四项中有缺失，主体必须先触发追问，而不是直接进入方法模块。

## 主体工作流

1. 读取 [references/entry-checklist.md](references/entry-checklist.md)。
2. 读取 assay profile：
   - [proteomics](references/profiles/proteomics.md)
   - [bulk-rnaseq](references/profiles/bulk-rnaseq.md)
   - [metabolomics](references/profiles/metabolomics.md)
3. 读取 [references/parameter-policy.md](references/parameter-policy.md)。
4. 读取 [references/question-policy.md](references/question-policy.md)。
5. 判断当前任务属于哪个模块或哪些模块组合。
6. 只有在必需信息补齐后，才把任务分发到模块。
7. 统一按 [references/output-contract.md](references/output-contract.md) 输出。

## 必问项

以下问题属于“必须问清楚，否则容易方法错”的问题：

1. 这是什么组学？
2. 这个矩阵是否已经 log2？
3. 这个矩阵是否已经标准化？
4. 这个矩阵是否已经做过 imputation？
5. contrast 是什么？
6. metadata 中是否有 batch？若有，是否纳入设计矩阵？
7. 如果做富集，ID 类型是什么？
8. 如果做 Mfuzz，时间顺序是什么？
9. 如果做 WGCNA，要关联哪些 trait？

## 默认建议项

以下问题可以先给建议，再让用户确认：

1. 差异分析阈值。
2. 富集分析是用 ORA 还是 GSEA。
3. 是否先做 QC 流程复核再进入下游。
4. 是否先输出基础图，再输出高级图。
5. WGCNA soft-threshold 是自动扫描还是手动指定。

## 停止项

遇到以下情况要停止，而不是继续猜：

1. 不知道 assay 类型。
2. 不知道矩阵状态。
3. 不知道 contrast。
4. 不知道富集输入 ID 类型。
5. 不知道 WGCNA 关联哪个 trait。
6. 不知道时间序列顺序。

## 审计项

主体必须逼 AI 在结果里留下这些信息：

1. assay 类型
2. matrix 状态
3. contrast
4. batch 是否纳入
5. 阈值是默认值还是用户覆盖值
6. 进入了哪些模块
7. 每个模块用的关键方法

## 核心原则

主体 skill 的任务不是把所有方法写死，而是：

- 框定 AI 的办事方式
- 暴露动态决策点
- 提醒用户补齐容易忘的细节
- 把分析经验变成流程护栏

