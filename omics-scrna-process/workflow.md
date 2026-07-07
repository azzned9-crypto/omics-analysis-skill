# 单细胞 RNA-seq 下游分析工作流

## 适用范围

本工作流适用于从 QC 通过的 clean rds/h5ad 文件到完整下游分析的流程。

覆盖 R/Seurat 和 Python/Scanpy 两条技术路线，默认以 R/Seurat 为主线。

## 启动前确认

开始前至少确认以下信息：

1. 所有样本的 clean rds/h5ad 文件可用且 QC 已通过。
2. 组织类型已明确（影响 marker 选择和注释策略）。
3. 物种已确认（人/鼠/其他）。
4. 是否有预期的细胞类型或 marker gene 列表。
5. 整合策略已确认（Harmony / Seurat CCA / RPCA / scVI）。
6. batch 结构已明确（哪些样本属于哪个 batch）。
7. 聚类分辨率偏好已确认或接受默认扫描。
8. 注释方式已确认（手动 / SingleR / CellTypist / Azimuth）。

## 核心流程

### 步骤 1: 数据加载与合并

1. 逐样本加载 clean rds 文件到列表中。
2. 使用 `merge()` 合并为单一 Seurat 对象。
3. 确保每个细胞的 metadata 包含 `orig.ident`（样本来源）、`group`（分组）、`time`（时间点）、`batch`（批次）等字段。
4. 检查合并后的总细胞数和样本分布。

### 步骤 2: 整合（按需）

若样本来自多个 batch，需要执行批次校正/整合。

**默认方法：Harmony**

1. 合并后先执行 `NormalizeData` → `FindVariableFeatures` → `ScaleData` → `RunPCA`。
2. 运行 `RunHarmony(group.by.vars = "batch")`。
3. 输出整合前后的 PCA 图（按 batch 着色），评估整合效果。

**备选方法：**

- Seurat CCA/RPCA 整合：适用于批次差异较大的场景，但计算量大。
- scVI：基于深度学习，适用于大规模数据集。
- 若批次差异不大，可以不整合，直接使用原始 PCA。

### 步骤 3: 聚类

1. `FindNeighbors(dims = 1:20)`（或使用 Harmony 降维后的维度）。
2. 多分辨率扫描：`resolution = 0.3, 0.5, 0.8, 1.0`，分别生成聚类结果。
3. `RunUMAP(dims = 1:20)`（或使用 Harmony 降维后的维度）。
4. 输出不同分辨率的 UMAP 对比图，辅助选择最优分辨率。
5. 最终分辨率由用户确认或选择默认 0.5。

### 步骤 4: Marker Gene 识别

1. `FindAllMarkers(only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)`。
2. 输出每个 cluster 的 top marker gene 列表。
3. 输出 marker gene 的 dotplot 和 heatmap。

### 步骤 5: 细胞类型注释

1. **手动注释**：基于用户提供的 marker gene 和组织背景，结合 top marker 进行注释。
2. **自动注释（可选）**：
   - SingleR：使用参考数据集（如 Blueprint/ENCODE、HumanPrimaryCellAtlas）进行注释。
   - CellTypist：使用预训练模型（需指定模型名称）。
   - Azimuth：使用 Seurat 官方参考数据集（如 pbmcref、bonemarrowref）。
3. 注释结果必须与 marker 表达模式交叉验证。若自动注释与手动 marker 不一致，以 marker 验证为准，并记录差异。
4. 输出注释后的 UMAP（按 cell type 着色）、marker dotplot/heatmap、featureplot。

### 步骤 6: 差异表达分析（按需）

1. **Cluster 间差异**：已由步骤 4 的 `FindAllMarkers` 完成。
2. **条件间差异（within cell type）**：
   - 按细胞类型子集化数据。
   - 在每个 cell type 内做条件间 DEG。
   - 方法：Wilcoxon rank-sum test（Seurat 默认）或 DESeq2/edgeR（需转为 pseudo-bulk）。
3. 输出火山图、热图。

### 步骤 7: 拟时序分析（按需）

若用户需要拟时序/轨迹分析：

1. **Monocle3**：
   - 将 Seurat 对象转为 cell_data_set。
   - 选择 root cells（基于已知分化方向或 marker）。
   - 学习轨迹图（learn_graph）。
   - 计算拟时序（order_cells）。
2. **CellRank 2**：
   - 适用于 Python/Scanpy 流程。
   - 支持多种 kernel（PAGA, VIA, RealTime）。
   - 可结合 RNA velocity（需 scVelo）。

### 步骤 8: 细胞通讯分析（按需）

若用户需要细胞通讯分析：

1. 使用 **CellChat**。
2. 计算 ligand-receptor 交互强度。
3. 识别信号通路和通讯模式。
4. 输出交互网络图、信号通路热图、circos 图。

### 步骤 9: 干性/分化潜能预测（按需）

若用户需要干性/分化潜能分析：

1. 使用 **CytoTRACE2**。
2. 预测每个细胞的干性评分（stemness score）和分化状态。
3. 在 UMAP 上可视化干性评分分布。
4. 比较不同 cluster / cell type 间的干性水平。
5. 结合拟时序分析，构建分化轨迹与干性变化的关联。

### 步骤 10: 结果保存

1. 保存注释后的完整 Seurat 对象（rds）。
2. 导出 metadata（CSV）。
3. 导出 marker gene 列表（CSV）。
4. 导出 DEG 结果表（CSV，若适用）。
5. 保存关键图表（PDF/PNG）。

## 默认参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| PCA dims | 1:20 | 降维维度 |
| UMAP dims | 1:20 | UMAP 输入维度 |
| 聚类 resolution | 0.5 | 默认值，建议扫描 0.3-1.0 |
| FindAllMarkers only.pos | TRUE | 仅保留正向 marker |
| FindAllMarkers min.pct | 0.25 | 基因在 cluster 中表达的最低细胞比例 |
| FindAllMarkers logfc.threshold | 0.25 | log2FC 阈值 |
| Harmony theta | 2 | Harmony 弹性参数 |
| Harmony max_iter_harmony | 20 | Harmony 最大迭代次数 |
| CellChat min.population | 10 | 最小细胞群大小 |
| CytoTRACE2 | 默认参数 | 干性预测使用包默认参数 |

## 必做图表

1. 整合前后 PCA 图（按 batch 着色）。
2. UMAP 图（分别按 cluster、cell type、sample、batch 着色）。
3. Marker gene dotplot。
4. Marker gene heatmap。
5. 已知 marker 在 UMAP 上的 featureplot。
6. 差异分析火山图和热图（若适用）。
7. 每样本细胞类型比例柱状图。
8. 拟时序轨迹图（若适用）。
9. CellChat 交互网络图（若适用）。
10. CytoTRACE2 干性评分 UMAP（若适用）。

## 交付要求

1. 注释后的 Seurat/AnnData 对象（rds/h5ad）。
2. Marker gene 列表（CSV）。
3. 细胞类型注释表（CSV）。
4. DEG 结果表（CSV，若适用）。
5. 关键图表（PDF/PNG）。
6. 参数与决策记录。

## 不在本文件要求的内容

1. QC 流程（见 `omics-qc-process` 模块）。
2. HTML 报告。
3. 具体计算代码。
4. 参考文献见 `references.md`。
