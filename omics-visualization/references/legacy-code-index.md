# 历史代码索引

这些文件来自用户曾经使用的代码。按任务类型选择性读取，不要一次加载全部文件。

## 基础统计图

- 柱状图：`legacy-code/柱状图.r`
- 分布式柱状图：`legacy-code/分布式柱状图.r`
- 双向柱状图：`legacy-code/双向柱状图.R`
- 箱线图：`legacy-code/箱线图.r`
- 甜甜圈图：`legacy-code/甜甜圈图.R`
- 多时间点样本连线图：`legacy-code/多时间点样本连线图.R`
- 散点图参考：`legacy-code/ggplot_point_guide.md`
- 配色参考：`legacy-code/colorpallet_guide.md`

## 组学图

- 火山图：`legacy-code/火山图.R`
- 热图：`legacy-code/热图.r`
- 相关性热图：`legacy-code/corHeatmapplot_guide.md`
- 富集分析：`legacy-code/富集分析.r`
- 多组富集气泡图：`legacy-code/metascape_multi_bubble.md`
- PLS-DA：`legacy-code/PLS-DA分析.r`
- UpSet 图：`legacy-code/upsetR.r`
- 韦恩图：`legacy-code/韦恩图.r`
- 桑基图：`legacy-code/桑基图.R`
- 基因组轨迹图：源 HXF-vis 索引提到 legacy-code/Gviz.r，但当前源目录未提供该文件，暂不作为可用模板。

## 统计模型与表格

- 逻辑回归和线性回归：`legacy-code/逻辑回归及线性回归.r`
- TableOne、LASSO 和森林图：`legacy-code/tableone_LASSO_ForestPlotTurtal.r`
- 正态性和方差齐性检验：`legacy-code/正态性和方差齐性检验.R`

## 改造要求

1. 不直接沿用绝对路径和工作目录。
2. 不默认信任历史代码中的统计阈值或变量编码。
3. 将数据、分组、标签、颜色、尺寸和输出目录参数化。
4. 按当前风格规范补充 `theme_bw()`、`viridis` 连续色阶以及 PDF/PNG 双格式导出。
5. 保留用户原有视觉偏好，但发现统计或表达问题时明确指出并修正。

未纳入本 SKILL：

- `194个R语言可视化代码.zip`：约 400 MB，待后续解包筛选。
- Shell、生信预处理、集群配置及非可视化脚本：与当前 SKILL 的调用范围不一致。
