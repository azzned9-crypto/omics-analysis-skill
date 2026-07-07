---
name: omics-qc-process
description: 面向蛋白组、bulk RNA-seq、代谢组和单细胞 RNA-seq 数据的组学 QC 分析模块。用于在进入下游分析前，先确认组学类型、矩阵状态、metadata、batch、缺失值处理和放行条件，并强制输出审计报告与参数记录。
---

# 组学 QC 分析模块

## 定位

这个 skill 负责承接组学 QC 任务入口，而不是直接展开某一个组学的全部操作细节。

## 组学分流原则

QC 不能混成一套通用模板，必须先识别 assay，再进入对应 workflow：

1. `proteomics` 使用蛋白组 QC 逻辑。
2. `bulk-rnaseq` 使用 bulk RNA-seq QC 逻辑。
3. `metabolomics` 使用代谢组 QC 逻辑。
4. `scrna` 使用单细胞 RNA-seq QC 逻辑。

scRNA 需要额外确认数据来源平台（10X Genomics 或华大 DNBelab C4），不同平台的矩阵读取方式不同（Read10X vs ReadPISA），必须在进入 workflow 前明确。

如果 assay 类型不明确，必须停止并追问，不能直接套用任一组学习惯。

## 必问项

1. 当前数据属于什么组学？
2. 当前输入是 raw、normalized、log2、imputed 还是 clean matrix？
3. 是否已有上游样本剔除结论？
4. metadata 是否完整？
5. 是否存在 batch？
6. 是否已有缺失值处理？
7. 当前任务目标是"完整 QC"还是"对既有 clean data 做放行复核"？
8. （若为 scRNA）数据来源平台是 10X Genomics 还是华大 DNBelab C4？不同平台的矩阵读取方式不同。
9. （若为 scRNA）是否已有上游 QC 指标文件（如华大 C4 的 metrics_summary.xls）？
10. （若为 scRNA）参考基因组版本是什么？物种是人还是鼠（影响线粒体 pattern）？
11. （若为 scRNA）组织类型是什么？（影响 QC 阈值调整建议）

## 必须输出

最少输出以下内容：

1. QC 审计报告。
2. 参数与决策记录报告。
3. matrix 状态说明。
4. metadata 完整性检查。
5. batch 是否存在及处理建议。
6. 风险样本清单、风险等级和触发原因。
7. 是否允许进入后续分析的结论。
8. 若不允许进入后续分析，指出卡住的原因。

## 风险样本规则

1. QC 过程中识别到的异常样本默认只做标记、统计和整理，不主动剔除。
2. 是否删除异常样本由客户或项目负责人决定，不由 AI 在未获明确授权时自动执行。
3. 最终输出的 clean data 矩阵默认保留全部样本，无论是全局 QC clean data，还是分组 QC 后 intersection 的 clean data。
4. 若用户明确要求生成"剔除异常样本版本"，也必须与"保留全部样本版本"并行保留，不得相互覆盖。

## 风险等级判定规则

1. `低风险`：质控的所有环节均未出现异常结果。
2. `中风险`：仅 1 个质控环节出现异常结果。
3. `高风险`：2 个及以上质控环节出现异常结果。
4. 风险等级用于报告和审计呈现，不等同于自动剔除样本。

## 风险样本呈现要求

风险样本的 list、原因和等级必须在以下载体中固定呈现：

1. HTML 报告中使用独立风险样本卡片展示。
2. 风险等级至少分为 `高风险`、`中风险`、`低风险`，并使用颜色标注。
3. 每个风险样本至少展示样本名、分组、风险等级、触发规则和对应指标。
4. 审计文件中必须逐条记录每个风险样本，采用一条样本一条记录的格式。
5. 若样本被标记但未删除，必须明确写明"已保留在 clean data 中，待客户决定是否剔除"。

## 停止项

遇到以下情况必须停止：

1. assay 类型不清楚。
2. matrix 状态不清楚。
3. metadata 缺失到无法完成样本映射。
4. batch、缺失值处理或样本剔除状态不清楚，且它们会影响后续方法选择。
5. （若为 scRNA）数据来源平台不明确，无法确定矩阵读取方式（Read10X 还是 ReadPISA）。

## 工作流文件

具体流程不直接堆在本文件中，而是按组学拆分到 workflow 文件：

1. `references/workflow-proteomics.md`
2. `references/workflow-bulk-rnaseq.md`
3. `references/workflow-scrna.md`
4. 后续可继续补充 `workflow-metabolomics.md`

## 参考文件

1. `references/references-proteomics.md`
2. `references/references-bulk-rna.md`
3. `references/references-scrna.md`
4. 参考代码可以放在 `references/` 下，但不在 workflow 正文中展开。

## 核心原则

这个 skill 的任务是：

- 逼迫 AI 先确认前提，而不是猜测数据状态
- 把任务导向对应组学的 workflow
- 先标记风险，再把样本去留决定交还给客户
- 给后续分析模块一个明确的放行或退回结论
