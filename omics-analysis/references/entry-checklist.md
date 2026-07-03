# 入口检查清单

在开始任何 QC、下游分析或结果可视化前，先确认以下内容：

1. 这是什么组学：`proteomics`、`bulk RNA-seq`，还是 `metabolomics`？
2. 这是什么样本类型：例如血浆、血清、尿液、CSF、组织、细胞、血液 RNA、FFPE？
3. 这是什么平台或建库方式：
   - 蛋白组：DIA、DDA、TMT、label-free。
   - RNA：polyA、ribo-depletion、total RNA、stranded、unstranded、3 prime、capture。
4. 这个矩阵是否已经标准化？
5. 这个矩阵是否已经做过 log2 转换？
6. 这个矩阵是否已经做过缺失值填补或其他关键预处理？
7. 是否做过 batch correction？
8. metadata 中哪一列是主分组变量？
9. 这次需要做哪些 contrast？
10. 这是探索性分析还是正式报告分析？
11. 这次要启用哪些下游模块？
12. 是否命中特殊条件：
   - 蛋白组体液样本
   - 蛋白组特殊平台
   - RNA 特殊建库方式
   - RNA 的 FFPE、血液、低输入量、全转录组等项目

这一至少要产出：

- matrix 路径
- metadata 路径
- 组学类型
- 样本类型
- 平台类型或建库方式
- 矩阵状态摘要
- 分组列名
- contrast 列表
- 请求的模块列表
- 是否命中特殊条件分支