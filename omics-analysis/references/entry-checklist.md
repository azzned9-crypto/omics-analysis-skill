# 入口检查清单

在开始任何下游分析前，先确认以下内容：

1. 这是什么组学：proteomics、bulk RNA-seq，还是 metabolomics？
2. 这个矩阵是否已经标准化？
3. 这个矩阵是否已经做过 log2 转换？
4. 这个矩阵是否已经做过缺失值填补？
5. 是否做过 batch correction？
6. metadata 中哪一列是主分组变量？
7. 这次需要做哪些 contrast？
8. 这是探索性分析还是正式报告分析？
9. 这次要启用哪些下游模块？

这一步至少要产出：

- matrix 路径
- metadata 路径
- 组学类型
- 矩阵状态摘要
- 分组列名
- contrast 列表
- 请求的模块列表

