# 输出契约

一次基础下游分析最少应输出：

1. `results/01_design/`
   - metadata 快照
   - contrast 定义
   - 参数摘要
2. `results/02_differential/`
   - 全量结果表
   - 显著结果表
   - 火山图
   - 候选特征热图
3. `results/03_enrichment/`
   - ORA 或 GSEA 结果表
   - dotplot 或 barplot
4. `results/99_audit/`
   - 方法摘要 markdown
   - 阈值摘要
   - 输入文件路径

如果本次还做时序或网络分析，则继续补充对应模块的特异输出。

