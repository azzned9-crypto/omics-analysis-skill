# 单细胞 RNA-seq QC 工作流

## 适用范围

本工作流适用于 scRNA-seq 数据在进入下游分析（整合、聚类、注释、差异表达）前的细胞级 QC 执行或 QC 放行复核。

覆盖 10X Genomics 和华大 DNBelab C4 两种数据来源平台。

本流程仅做数据质量评估与双细胞检测，不做主要聚类分析或细胞类型注释。DoubletFinder 需要 PCA 和初步聚类作为前置步骤，但这些步骤仅为 doublet detection 服务，不属于主要聚类分析。

## 启动前确认

开始前至少确认以下信息：

1. 数据来源平台：10X Genomics、华大 DNBelab C4 还是其他平台？不同平台的矩阵读取方式不同。
2. 输入矩阵是什么格式？是上游软件直接输出的 raw_matrix / filter_matrix（10X 格式 mtx），还是已处理的 rds / h5ad？
3. 参考基因组版本是什么？（如 GRCh38.115、GRCm39 等）
4. 是否有上游 QC 指标文件？（如华大 C4 的 metrics_summary.xls）
5. 样本数量多少？是否有分组、时间点和 batch 信息？
6. 是否已经做过任何细胞过滤？
7. 当前 QC 目标是首次 QC，还是仅对既有 clean data 做可用性复核？
8. 物种是什么？人还是鼠？（影响线粒体基因 pattern）
9. 组织类型是什么？（影响 QC 阈值调整建议）

## 核心原则

1. 质控负责识别风险和记录验证，不主动删除样本。
2. 双细胞移除属于 QC 范畴，移除后的 Singlet 保留为 clean data。
3. 最终 clean data 默认保留全部样本，样本去留由客户决定。
4. workflow 只约束 QC 必做内容、关键图表和中间矩阵。
5. 不同平台读取方式不同，必须先确认平台再选择读取函数。
6. 必须保留每个处理环节产生的矩阵文件，不得只保留最终 rds。

## 默认参数与默认行为

除非用户明确指定其他方案，否则按以下默认规则执行，并在参数与决策记录报告中写明实际采用值。

### 通用默认参数

1. `min.cells = 3`（CreateSeuratObject 中基因过滤）
2. `min.features = 200`（CreateSeuratObject 中细胞过滤）
3. 细胞过滤：`nFeature_RNA > 200 & nFeature_RNA < 6000`
4. 细胞过滤：`nCount_RNA >= 1000 & nCount_RNA <= 25000`
5. 细胞过滤：`percent.mt < 10`
6. `selection.method = "vst"`, `nfeatures = 2000`（FindVariableFeatures）
7. `dims = 1:20`（PCA / FindNeighbors）
8. `resolution = 0.5`（FindClusters，仅为 DoubletFinder 准备，非主要聚类）
9. `formation_rate = 0.05`（DoubletFinder 双细胞形成率，根据文献设定为 5%）
10. `pN = 0.25`（DoubletFinder，官方推荐默认值）
11. `pK = auto`（DoubletFinder，通过 find.pK 自动选择最优 pK）
12. `PCs = 1:20`, `sct = FALSE`（DoubletFinder）
13. 线粒体 pattern：`"^MT-"`（人）/ `"^mt-"`（鼠）

### 默认预处理行为

1. 10X 平台使用 `Read10X()` 读取矩阵；华大 C4 平台使用 `ReadPISA()` 读取，若已转为 10X 格式也可用 `Read10X()`。
2. 每个样本独立处理，使用 `RenameCells(add.cell.id = sample_name)` 给 barcode 添加标签，防止后期整合时 barcode 重复。
3. 添加 `percent.mt` 列（`PercentageFeatureSet(pattern = "^MT-")`）。
4. 细胞过滤后执行 `NormalizeData` → `FindVariableFeatures` → `ScaleData` → `RunPCA`。
5. `FindNeighbors(dims = 1:20)` + `FindClusters(resolution = 0.5)` 仅为 DoubletFinder 提供聚类输入。
6. DoubletFinder 流程：`paramSweep` → `summarizeSweep` → `find.pK` → `modelHomotypic` → `doubletFinder`。
7. 移除双细胞（`subset(doublet_info == "Singlet")`），保留 Singlet。
8. 清理非必要数据（`scale.data` 层、`reductions`、`commands`）以大幅减少内存占用。
9. 逐样本保存 clean rds 文件。
10. 统计每样本细胞数并输出 CSV 文件。

### 上游 QC 指标默认阈值（华大 C4 平台）

以下阈值适用于华大 C4 平台上游输出文件的复核：

| 指标 | 推荐 | 可接受 | 需优化 |
|------|------|--------|--------|
| 有效条形码比例 (Valid barcodes) | >=80% | 70-80% | <70% |
| Q30 碱基质量 (barcode/UMI 区域) | >=85% | 75-85% | <75% |
| 转录组置信比对率 (Reads mapped to transcriptome) | >=50% | 30-50% | <30% |
| 细胞内 reads 比例 (Fraction reads in cells) | >=60% | 30-60% | <30% |
| Mean reads per cell | >=30,000 | 15,000-30,000 | <15,000 |
| Median genes per cell | >=1,000 | 500-1,000 | <500 |
| Sequencing saturation | >=40% | 20-40% | <20% |
| 基因组比对率 (Reads mapped to genome) | >=80% | 50-80% | <50% |

## 核心检查顺序

1. 确认数据来源平台，选择对应读取函数（Read10X 或 ReadPISA）。
2. 检查上游 QC 指标文件（若存在），复核各项阈值是否达标。
3. 读取矩阵，检查矩阵维度和基本结构（细胞数、基因数）。
4. 创建 Seurat 对象（`CreateSeuratObject(counts, min.cells = 3, min.features = 200)`）。
5. 计算线粒体百分比（`PercentageFeatureSet(pattern = "^MT-")`）。
6. 输出 QC 前 `nFeature_RNA`、`nCount_RNA`、`percent.mt` 小提琴图。
7. 执行细胞过滤（nFeature_RNA、nCount_RNA、percent.mt 阈值）。
8. `NormalizeData` 标准化。
9. `FindVariableFeatures(selection.method = "vst", nfeatures = 2000)` 寻找高变基因。
10. `ScaleData` + `RunPCA`（为 DoubletFinder 准备降维空间）。
11. `FindNeighbors(dims = 1:20)` + `FindClusters(resolution = 0.5)`（仅为 DoubletFinder 提供聚类输入）。
12. 运行 DoubletFinder：`paramSweep(PCs = 1:20, sct = FALSE)` → `summarizeSweep` → `find.pK` → `modelHomotypic` → `doubletFinder`。
13. 移除双细胞，保留 Singlet。
14. 清理非必要数据（scale.data、reductions、commands），保存 clean rds。
15. 统计每样本过滤前、过滤后、移除 doublet 后的细胞数。
16. 汇总风险样本名单、风险等级和触发原因，但默认不剔除。

## 风险样本规则

1. 上游 QC 指标低于可接受阈值（如有效条形码 <70%、Q30 <75%）。
2. 过滤后细胞数过低（影响下游分析统计效力，具体阈值取决于组织类型和实验设计）。
3. 双细胞比例异常偏高（远超 5% 形成率预期，可能提示样本质量问题）。
4. median genes per cell 过低（<500），可能提示测序深度不足或样本质量差。
5. percent.mt 分布异常（中位数 >10% 或存在极端高值），可能提示细胞凋亡或应激状态。
6. 样本间细胞数差异极大（可能提示样本质量不均一或技术批次效应）。
7. 风险等级判定以模块 `SKILL.md` 的统一规则为准。

## 必须关注的内容

1. 上游 QC 指标是否达标，是否有需要补测的样本。
2. 细胞过滤阈值是否适合当前组织类型（不同组织 nFeature 和 percent.mt 范围可能不同）。
3. 每样本双细胞检出率和移除后的细胞数。
4. 平台读取方式是否正确（10X 使用 Read10X，华大 C4 使用 ReadPISA）。
5. percent.mt 阈值是否需要按组织类型调整（如肿瘤组织可能需要更宽松的阈值）。
6. 过滤前后细胞数变化幅度，是否过度过滤。
7. 是否存在明显的批次效应（通过过滤后的 PCA 初步判断）。
8. 最终 clean rds 是否保留了全部样本。
9. 每样本细胞数是否足够支撑下游分析。
10. 参考基因组版本是否正确，线粒体 pattern 是否匹配物种。

## 必做图表与中间矩阵

1. QC 前 `nFeature_RNA`、`nCount_RNA`、`percent.mt` 小提琴图。
2. QC 后 `nFeature_RNA`、`nCount_RNA`、`percent.mt` 小提琴图。
3. DoubletFinder pK 选择图（BCmetric vs pK）。
4. 每样本 doublet 比例柱状图。
5. 每样本细胞数统计表（过滤前 / 过滤后 / 移除 doublet 后）。
6. 过滤前后 PCA 图（按样本着色，初步判断批次效应）。
7. 上游 QC 指标汇总表（若有 metrics_summary.xls）。
8. 过滤前的 Seurat 对象 rds 文件。
9. 过滤后的 Seurat 对象 rds 文件。
10. 移除 doublet 后的 clean rds 文件。
11. 细胞数统计 CSV（`sample_cell_counts.csv`）。
12. 风险样本清单矩阵或表格。

## 放行结论

1. 可以直接进入下游分析。
2. 可以进入下游分析，但需要记录限制条件（如某样本细胞数偏少、某指标处于可接受范围下限）。
3. 不建议继续，必须回退到上游重新处理或补测。

## 交付要求

1. QC 前后及各处理中间环节的 rds 文件。
2. 细胞数统计结果（CSV）。
3. 风险样本清单、风险等级和触发原因。
4. 关键图表或其说明。
5. 参数与决策记录摘要。
6. 放行结论及理由。

## 不在本文件要求的内容

1. HTML 报告。
2. 审计报告。
3. 具体计算代码与代码归档。
4. 参考文献详见 `references/references-scrna.md`。
5. 下游整合、聚类、注释、差异分析等流程不在本文件范围，详见 `omics-scrna-process` 模块。
