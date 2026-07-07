# 单细胞 RNA-seq Assay Profile

## 常见矩阵状态

1. **上游软件直接输出**：raw_matrix / filter_matrix 目录（10X mtx 格式：barcodes.tsv.gz, features.tsv.gz, matrix.mtx.gz）。华大 C4 还会输出 filter_feature.h5ad 和 metrics_summary.xls。
2. **QC 后 clean data**：每样本独立保存的 Seurat rds 文件（已移除低质量细胞和 doublet）。
3. **已整合对象**：多样本合并并完成批次校正的 Seurat 对象。

## 特殊条件追问

1. 数据来源平台是什么？10X Genomics 还是华大 DNBelab C4？不同平台的矩阵读取方式不同（Read10X vs ReadPISA）。
2. 组织类型是什么？PBMC、肿瘤组织、脑组织、肠组织、肝组织、肺组织等。不同组织的细胞类型组成和 marker 完全不同，影响注释策略。
3. 物种是什么？人还是鼠？影响线粒体 pattern（^MT- vs ^mt-）、参考数据集选择和注释工具。
4. 是否来自多个 batch？是否需要整合？多 batch 不整合会导致聚类被批次效应主导。
5. 是否为核测序（snRNA-seq）？snRNA-seq 的内含子 reads 比例高，QC 阈值需调整。
6. 是否为低输入量或降解样本？可能需要更宽松的 QC 阈值。
7. 是否已有上游 QC 指标文件？可用于复核数据质量。

## 常见下游分析默认值

| 项目 | 默认值 | 说明 |
|------|--------|------|
| 整合方法 | Harmony | 快速、适用性广；备选 Seurat CCA/RPCA、scVI |
| 聚类分辨率 | 0.5 | 建议扫描 0.3-1.0 |
| 注释策略 | 手动 + SingleR | 手动 marker 验证为主，SingleR 自动注释为辅 |
| PCA dims | 1:20 | 降维维度 |
| HVGs | 2000 | 高变基因数量 |
| 线粒体阈值 | <10% | 可按组织类型调整 |
| DoubletFinder formation_rate | 0.05 | 5% 双细胞形成率 |

## 常见风险

1. **平台读取错误**：华大 C4 数据用 Read10X 读取可能失败或丢失信息，必须确认平台后选择正确函数。
2. **过度校正**：Harmony 或 CCA 整合过度时，可能抹去真实的生物学差异。需要检查整合前后 PCA 变化。
3. **注释与 marker 不一致**：自动注释（SingleR/CellTypist）结果可能与已知 marker 不符，以 marker 验证为准。
4. **分辨率不当**：分辨率过高导致过度细分，过低导致细胞类型混合。需多分辨率扫描比较。
5. **细胞数不足**：某些 cell type 细胞数过少时，DEG 结果不可靠。
6. **批次效应未处理**：多 batch 数据不整合直接聚类，结果被批次效应主导。
7. **线粒体 pattern 错误**：人用 ^MT-，鼠用 ^mt-，混用会导致 percent.mt 计算错误。
