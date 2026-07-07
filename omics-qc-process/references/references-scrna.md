# 单细胞 RNA-seq QC 参考文献

1. Hao Y, Hao S, Andersen-Nissen E, et al. Integrated analysis of multimodal single-cell data. Cell, 2021. 作为 Seurat v4 标准流程参考（CreateSeuratObject、NormalizeData、FindVariableFeatures、ScaleData、RunPCA、FindNeighbors、FindClusters 等核心函数）。

2. Stuart T, Butler A, Hoffman P, et al. Comprehensive Integration of Single-Cell Data. Cell, 2019. 作为 Seurat 整合流程与 SCTransform 标准化方法参考。

3. McGinnis CS, Murrow LM, Gartner ZJ. DoubletFinder: Doublet Detection in Single-Cell RNA Sequencing Data Using Artificial Nearest Neighbors. Cell Systems, 2019. 作为 DoubletFinder 双细胞检测流程参考（paramSweep、find.pK、doubletFinder、modelHomotypic、formation_rate 设定）。

4. Wolf FA, Angerer P, Theis FJ. SCANPY: large-scale single-cell gene expression data analysis. Genome Biology, 2018. 作为 Scanpy Python 流程参考（QC、normalize、PCA、UMAP、Leiden 聚类、marker gene 识别）。

5. Korsunsky I, Millard N, Fan J, et al. Fast, sensitive and accurate integration of single-cell data with Harmony. Nature Methods, 2019. 作为批次校正与整合方法参考。

6. Luecken MD, Theis FJ. Current best practices in single-cell RNA-seq analysis: a tutorial. Molecular Systems Biology, 2019. 作为 scRNA-seq 分析最佳实践综合参考（QC 阈值建议、流程设计原则、常见陷阱）。

7. Hafemeister C, Satija R. Normalization and variance stabilization of single-cell RNA-seq data using regularized negative binomial regression. Genome Biology, 2019. 作为 SCTransform 标准化方法参考。

8. Lun ATL, Bach K, Marioni JC. EmptyDrops: distinguishing cells from empty droplets in droplet-based single-cell RNA sequencing data. Genome Biology, 2019. 作为空滴检测与细胞鉴定参考。

9. MGI-tech-bioinformatics. DNBelab C Series HT scRNA-analysis-software documentation. GitHub, 2024. 作为华大 C4 平台 DNBC4tools 上游分析流程、输出文件格式与 QC 阈值标准参考。

10. Zheng GXY, Terry JM, Belgrader P, et al. Massively parallel digital transcriptional profiling of single cells. Nature Communications, 2017. 作为 10X Genomics 单细胞平台技术背景与数据格式参考。

说明：workflow 主文只保留执行规则；文献说明统一放在本文件维护。
