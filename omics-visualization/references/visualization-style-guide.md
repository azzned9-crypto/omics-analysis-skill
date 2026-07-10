# HXF的 Visualization SKILL：R 可视化合集草案

## SKILL的建立时间2026.6.30
## SKILL的修改时间2026.6.30

## 定位

这个 SKILL 是 X 项目的统一可视化入口。调用时默认使用 R 语言完成可视化，并根据数据类型自动区分不同模块：

- 1.基础数据统计可视化
- 2.组学数据可视化
- 3.统计模型数据可视化

它的目标不是生成一次性的图，而是形成一套稳定、可复用、有个人风格的科研可视化工作流。

## 总原则

- 默认使用 R。
- 默认优先使用 `ggplot2` 生态,除非指定其他特定的 R 包
- 默认加入 `theme_bw()`。
- 配色清淡、低饱和、适合论文和科研汇报。
- 图形服务于科学结论，不追求花哨。
- 不使用默认彩虹色。
- 不滥用 3D、阴影、强渐变和过度装饰。
- 代码要可复制、可复现、便于用户后续修改。
- 如果用户没有提供真实数据，先给出可替换变量名的 R 模板。

## 模块路由

调用该 SKILL 时，先判断任务属于哪一类。

### 1. 基础数据统计可视化

触发关键词:
- 柱状图
- 甜甜圈图
- 箱线图
- 云雨图
- 小提琴图
- 散点图
- 折线图
- 相关性图

使用“基础数据统计可视化模块”。

### 2. 组学数据可视化

触发关键词：

- RNA-seq
- bulk RNA-seq
- single-cell
- scRNA-seq
- ATAC-seq
- 转录组
- 蛋白组
- 代谢组
- 甲基化
- 多组学
- 差异分析
- 火山图
- 热图
- PCA
- UMAP
- TSNE
- 富集分析
- GSEA
- GO
- KEGG

使用“组学数据可视化模块”。

### 3. 统计模型数据可视化

触发关键词：

- 线性回归
- logistic 回归
- Cox 回归
- 生存分析
- Kaplan-Meier
- ROC
- AUC
- 校准曲线
- DCA
- forest plot
- nomogram
- OR
- HR
- 回归系数
- 预测模型
- 临床模型
- 混合效应模型
- 交互作用

使用“统计模型可视化模块”。


## 统一 R 风格

所有 ggplot2 图形默认加入：

```r
theme_bw()
```

推荐基础主题：

```r
x_theme <- function(base_size = 12) {
 theme_bw()+
		theme(
			plot.title = element_text(hjust = 0.5, color = "black"),
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			panel.grid = element_blank(),  # 确保所有网格线都被移除
			axis.title.x = element_text(color = "black", size = 9),
			axis.title.y = element_text(color = "black", size = 9),
			axis.text.x = element_text(color = "black", size = 7),
			axis.text.y = element_text(color = "black", size = 7),
			legend.title = element_text(),
			legend.text = element_text(),
			legend.position = "none"  # 在这里统一设置移除图例
			)
}
```

## 统一配色

### 二分类

```r
x_cols_2 <- c("#7FB3D5", "#F5B7B1")
```

### 三分类

```r
x_cols_3 <- c("#7FB3D5", "#82E0AA", "#F7DC6F")
```

### 多分类

```r
x_cols_multi <- c(
  "#7FB3D5",
  "#82E0AA",
  "#F5B7B1",
  "#C39BD3",
  "#F7DC6F",
  "#A3E4D7",
  "#D7BDE2",
  "#FAD7A0",
  "#A9CCE3",
  "#D5F5E3"
)
```

### 差异方向

```r
x_cols_diff <- c(
  "Down" = "#7FB3D5",
  "NS" = "grey80",
  "Up" = "#E59866"
)
```

### 连续变量

连续变量默认使用 `viridis` 色阶（正确拼写为 `viridis`），除非用户、期刊或既有项目规范明确指定其他颜色。该规则适用于热图、连续数值着色的散点图，以及颜色随年龄、时间、剂量、风险评分等递进变化的图。

默认加载：

```r
library(viridis)
```

点、线或文字映射连续变量时：

```r
scale_color_viridis_c(option = "viridis", direction = 1)
```

柱、面积、栅格或热图映射连续变量时：

```r
scale_fill_viridis_c(option = "viridis", direction = 1)
```

年龄等变量虽然按整数分组展示，但颜色需要体现递进关系时：

```r
scale_fill_viridis_d(option = "viridis", direction = 1)
```

此时必须先按数值顺序设置因子水平，避免颜色顺序与年龄顺序不一致：

```r
df <- df |>
  mutate(age_group = factor(age_group, levels = sort(unique(age_group))))
```

默认使用原版 `"viridis"`；需要在相邻颜色间获得更明显区分时，可改用 `"plasma"`、`"magma"` 或 `"cividis"`，但同一组图中保持一致。不要把连续变量切成无科学依据的分类，仅为了套用离散配色。

当连续变量以 0 为中心且正负方向具有明确相反含义时，例如标准化表达量、相关系数或 log2 fold change，优先使用以 0 为中点的发散色阶，避免 `viridis` 单向色阶掩盖方向：

```r
scale_fill_gradient2(
  low = "#7FB3D5",
  mid = "white",
  high = "#E59866",
  midpoint = 0
)
```

## 组学数据可视化模块

### 目标

把组学结果画成能支撑论文故事线的图，而不是只展示软件默认输出。

### 常见输入

- 表达矩阵
- 差异分析结果表
- 富集分析结果表
- 单细胞对象或降维坐标
- 细胞类型注释
- 蛋白、代谢物或甲基化位点结果
- 临床表型关联结果

### 常用图形

- PCA 图：展示组间分离、批次效应、异常样本。
- 火山图：展示差异分子整体分布，并标注关键分子。
- 热图：展示核心基因集、样本聚类和分组关系。
- 富集气泡图：展示 GO、KEGG、Reactome 或 GSEA 结果。
- UMAP/tSNE：展示单细胞群体结构。
- DotPlot：展示 marker gene 或通路特征。
- 细胞比例图：展示不同组别细胞组成变化。
- 相关性热图：展示分子与临床指标关系。
- UpSet 图：展示多组差异分子交集。

### 默认包

```r
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(ggrepel)
```

按需使用：

```r
library(pheatmap)
library(ComplexHeatmap)
library(clusterProfiler)
library(enrichplot)
library(Seurat)
library(patchwork)
library(UpSetR)
```

### 火山图规范

- 上调、下调、非显著使用固定颜色。
- 只标注与故事线相关的基因。
- 不在图上堆满标签。
- 横轴使用 `log2FoldChange` 或等价指标。
- 纵轴使用 `-log10(padj)` 或 `-log10(P value)`。

模板：

```r
ggplot(deg, aes(x = log2FoldChange, y = -log10(padj), color = change)) +
  geom_point(size = 1.5, alpha = 0.75) +
  scale_color_manual(values = x_cols_diff) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "grey60") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey60") +
  x_theme()
```

### 热图规范

- 优先展示核心基因，不直接展示全部差异基因。
- 行列注释要清楚。
- 非中心化的连续数值默认使用 `viridis` 色阶。
- 标准化表达量、Z-score、相关系数等具有正负方向的数据，色阶要以 0 为中心，使用发散色阶避免误导方向。
- 样本很多时隐藏列名。

非中心化连续值推荐色阶：

```r
heat_cols <- viridis::viridis(100, option = "viridis")
```

中心化连续值推荐色阶：

```r
heat_cols <- colorRampPalette(c("#21618C", "white", "#B03A2E"))(100)
```

### 富集图规范

- 只展示最重要的 10-20 个条目。
- 通路名称过长时换行。
- 气泡大小表示 gene count 或 gene ratio。
- 颜色表示显著性或 NES。

### 单细胞图规范

- UMAP 点不要太大。
- 细胞类型超过 10 类时，优先使用清淡多分类色。
- 标签避免遮挡主要细胞群。
- 需要展示组间差异时，优先分面。
- marker gene 图要控制颜色上限，避免少数极端值支配图形。

## 统计模型可视化模块

### 目标

把统计模型结果画成临床和科研读者能快速理解的图，重点展示效应大小、不确定性、模型性能和临床解释。

### 常见输入

- 回归模型结果表
- OR、HR、beta、95% CI、P value
- 生存数据
- ROC 或预测概率
- 校准曲线数据
- DCA 决策曲线数据
- 分组比较结果
- 交互作用或亚组分析结果

### 常用图形

- 森林图：展示 OR、HR、beta 及置信区间。
- Kaplan-Meier 曲线：展示生存或无事件结局。
- ROC 曲线：展示模型区分能力。
- 校准曲线：展示预测概率与实际风险一致性。
- DCA 曲线：展示临床净获益。
- 回归系数图：展示变量方向和强度。
- 边际效应图：展示连续变量或交互作用。
- 亚组森林图：展示不同人群中的效应一致性。

### 默认包

```r
library(ggplot2)
library(dplyr)
library(broom)
library(forcats)
library(survival)
library(survminer)
```

按需使用：

```r
library(pROC)
library(rms)
library(gtsummary)
library(broom.helpers)
library(patchwork)
```

### 森林图规范

- 变量按效应大小或临床逻辑排序。
- 使用点和横线表示效应值与 95% CI。
- 加入无效线：OR/HR 为 1，beta 为 0。
- 不只展示 p 值，要突出效应方向和不确定性。

模板：

```r
ggplot(model_df, aes(x = estimate, y = fct_rev(term))) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey60") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.18, color = "grey35") +
  geom_point(size = 2.4, color = "#21618C") +
  scale_x_log10() +
  labs(x = "Effect size", y = NULL) +
  x_theme()
```

### Kaplan-Meier 曲线规范

- 曲线颜色使用清淡二分类或三分类配色。
- 显示风险表时保持整洁。
- p 值可以显示，但不要让 p 值成为唯一结论。
- 图题要说明分组变量和结局。

### ROC 曲线规范

- AUC 标注简洁。
- 多模型比较时颜色保持低饱和。
- 不要用过多曲线堆在一张图上。
- 必要时补充置信区间。

### 校准曲线规范

- 必须保留理想参考线。
- 横轴为预测风险，纵轴为观察风险。
- 标题或说明中明确建模人群或验证集。

### DCA 曲线规范

- 必须包含 treat all 和 treat none 参考线。
- 阈值概率范围要合理。
- 如果模型净获益很弱，要如实展示，不通过截断坐标轴夸大效果。

## 输出规范

每张最终图片必须同时保留：

- PDF 矢量图：用于论文排版、后期编辑和无损缩放。
- PNG 位图：用于快速预览、PPT 和日常沟通。

默认导出：

```r
ggsave("figure.pdf", width = 6, height = 4, device = cairo_pdf)
ggsave("figure.png", width = 6, height = 4, dpi = 300)
```

除非目标绘图设备本身不支持矢量输出，否则不得只交付 PNG、JPEG 或 TIFF。PDF 与位图必须使用相同的宽度、高度、字体和图形对象。

投稿级输出：

```r
ggsave("figure.pdf", width = 6, height = 4, device = cairo_pdf)
ggsave("figure.tiff", width = 6, height = 4, dpi = 600, compression = "lzw")
```

## 每次作图前的最小问题

如果用户没有提供足够信息，优先询问：

- 这是组学结果、统计模型结果，还是普通数据？
- 这张图用于论文、PPT、内部探索，还是宣传展示？
- 分组变量是什么？
- 主要想突出什么结论？
- 是否有目标期刊或尺寸要求？

如果用户已经给出明确数据和目标，不要过度追问，直接给出 R 代码。

## 图形质量检查清单

每张图输出前检查：

- 结论是否一眼能看出来。
- 颜色是否清淡且有区分度。
- 连续变量和递进颜色是否默认使用了 `viridis`，且色阶方向与数值顺序一致。
- 是否使用了 `theme_bw()` 或 `x_theme()`。
- 坐标轴是否完整。
- 图例是否必要。
- 字号是否适合论文或 PPT。
- 统计量、P 值、CI、AUC 等是否标注正确。
- 是否存在样本点重叠严重。
- 是否存在标题过长。
- 颜色含义是否前后一致。
- 图形是否夸大了不确定结果。
- 是否同时保留了 PDF 矢量图和所需的位图格式。

## 未来正式 SKILL 结构建议

后续如果要把这个文件转换成正式可调用的合集型 SKILL，建议使用以下结构：

```text
visualization/
├── SKILL.md
├── references/
│   ├── omics-visualization.md
│   ├── statistical-model-visualization.md
│   └── style-guide.md
└── scripts/
    ├── x_theme.R
    ├── x_palette.R
    ├── plot_volcano.R
    ├── plot_forest.R
    └── export_figure.R
```

其中：

- `SKILL.md` 只放入口路由、统一原则和何时读取哪个 reference。
- `omics-visualization.md` 放组学图规范和模板。
- `statistical-model-visualization.md` 放模型图规范和模板。
- `style-guide.md` 放配色、字体、导出、图形检查清单。
- `scripts/` 放真正可重复调用的 R 函数。

## 后续待完善

- 将 `x_theme()` 和配色表拆成 R 脚本。
- 增加火山图、富集图、热图、UMAP 的函数模板。
- 增加森林图、KM 曲线、ROC、校准曲线、DCA 的函数模板。
- 增加论文图和 PPT 图不同尺寸标准。
- 增加 X项目专属图形示例库。
