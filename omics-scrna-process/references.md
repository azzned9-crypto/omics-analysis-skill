# 单细胞 RNA-seq 下游分析参考文献

1. Hao Y, Hao S, Andersen-Nissen E, et al. Integrated analysis of multimodal single-cell data. Cell, 2021. 作为 Seurat v4/v5 整合、聚类、注释核心流程参考（FindIntegrationAnchors、FindNeighbors、FindClusters、FindAllMarkers 等）。

2. Korsunsky I, Millard N, Fan J, et al. Fast, sensitive and accurate integration of single-cell data with Harmony. Nature Methods, 2019. 作为 Harmony 批次校正与整合方法参考（RunHarmony、theta 参数、迭代策略）。

3. Wolf FA, Angerer P, Theis FJ. SCANPY: large-scale single-cell gene expression data analysis. Genome Biology, 2018. 作为 Scanpy Python 流程参考（normalize、PCA、UMAP、Leiden 聚类、rank_genes_groups）。

4. Traag VA, Waltman L, van Eck NJ. From Louvain to Leiden: guaranteeing well-connected communities. Scientific Reports, 2019. 作为 Leiden 聚类算法原理参考。

5. Aran D, Looney AP, Liu L, et al. Reference-based annotation of single-cell transcriptomes identifies a profibrotic macrophage niche after tissue injury. Nature Immunology, 2019. 作为 SingleR 自动细胞类型注释方法参考。

6. Domínguez Conde C, Xu C, Jarvis LB, et al. Cross-tissue immune cell analysis reveals tissue-specific features in humans. Science, 2022. 作为 CellTypist 自动注释方法与预训练模型参考。

7. Hao Y, Stuart T, Kowalski MH, et al. Dictionary learning for integrative, multimodal and scalable single-cell analysis. Nature Biotechnology, 2024. 作为 Azimuth 参考数据集映射注释与 Seurat v5 WNN 分析参考。

8. Cao J, Spielmann M, Qiu X, et al. The single-cell transcriptional landscape of mammalian organogenesis. Nature, 2019. 作为 Monocle3 拟时序分析流程参考（learn_graph、order_cells）。

9. Lange M, Bergen V, Klein M, et al. CellRank 2: unified statistics with transition models across scales. Nature Methods, 2022. 作为 CellRank 2 轨迹分析方法参考（多种 kernel、fate probability、driver gene）。

10. Jin S, Guerrero-Juarez CF, Zhang L, et al. Inference and analysis of cell-cell communication using CellChat. Nature Communications, 2021. 作为 CellChat 细胞通讯分析方法参考（ligand-receptor 交互、信号通路、通讯网络）。

11. Gao T, Soldatov R, Sarkar A, et al. CytoTRACE 2: accurate and coherent single-cell developmental potential inference. Nature, 2024. 作为 CytoTRACE2 干性/分化潜能预测方法参考（stemness score、分化状态分类）。

12. Luecken MD, Theis FJ. Current best practices in single-cell RNA-seq analysis: a tutorial. Molecular Systems Biology, 2019. 作为 scRNA-seq 分析综合最佳实践参考（整合策略、聚类分辨率选择、注释验证原则）。

说明：workflow 主文只保留执行规则；文献说明统一放在本文件维护。
