---
name: omics-visualization
description: 面向组学分析结果和临床表型关联结果的可视化模块。用于在差异分析、富集分析、时序分析、网络分析或临床指标相关性分析后，按 HXF 统一 R 作图风格生成火山图、热图、富集图、趋势图、网络图、散点相关图和模型结果图，并强制记录图形对应的数据层级、筛选规则、统计方法和阈值。
---

# 组学与临床表型可视化模块

## 定位

本 skill 负责统一结果展示，不替代统计分析模块。调用本 skill 时默认使用 R 完成可视化，优先使用 `ggplot2`；只有当前环境缺少必要 R 包且无法安装时，才允许用 base R 复刻同一风格，并在结果说明中写明原因。

适用图形包括：火山图、热图、富集图、时序趋势图、网络图、PCA/UMAP/tSNE、散点图、相关性图、森林图、ROC、KM 曲线、校准曲线、DCA 等。

## HXF-vis 同步资源

本 skill 已同步 HXF-vis 的通用规范与历史代码资源。需要复现或改造用户既有风格时，优先读取：

- `references/visualization-style-guide.md`：HXF 通用 R 可视化风格、模块路由、配色、导出和质量检查。
- `references/legacy-code-index.md`：历史代码路由索引，按图形类型选择性读取。
- `references/legacy-code/`：火山图、热图、富集图、相关性热图、PLS-DA、UpSet、韦恩图、桑基图、森林图和模型图等参考代码。
- `assets/mock-clinical-data.csv`、`references/mock-data-dictionary.md` 和 `scripts/generate_mock_clinical_data.*`：仅用于最小测试和临床表型相关图示例，不作为组学分析默认输入。

历史代码仅作为风格、参数和实现思路参考。执行前必须检查硬编码路径、变量名、包依赖、统计方法和导出方式，并将数据、分组、标签、颜色、尺寸和输出目录参数化。

## 图形路由关键词

当用户意图不够明确时，按关键词选择最窄图形路线：

- 组学图：RNA-seq、bulk RNA-seq、single-cell、scRNA-seq、ATAC-seq、转录组、蛋白组、代谢组、甲基化、多组学、差异分析、火山图、热图、PCA、UMAP、tSNE、富集分析、GSEA、GO、KEGG。
- 统计模型图：线性回归、logistic 回归、Cox 回归、生存分析、Kaplan-Meier、ROC、AUC、校准曲线、DCA、forest plot、nomogram、OR、HR、回归系数、预测模型、临床模型、混合效应模型、交互作用。
- 基础统计图：柱状图、甜甜圈图、箱线图、云雨图、小提琴图、散点图、折线图、相关性图。

如果任务只是修图、出图或统一风格，直接进入本 skill；如果还需要重新计算统计结果，先回到对应分析 skill 完成统计分析，再交给本 skill 出图。

## 作图前必须记录

每张图都必须记录以下信息：

1. 图对应的分析步骤或结果表。
2. 输入数据层级，例如 clean clinical matrix、clean omics matrix、DEG/DEP/DEM result、enrichment result。
3. 样本筛选规则和纳入人数。
4. 阈值或统计方法，例如 p < 0.05、FDR < 0.05、Pearson/Spearman、linear model、log2FC cutoff。
5. 图的用途：探索性图、正式报告图、论文图或 PPT 图。

## 统一 R 风格

默认优先使用 `ggplot2` 生成图形。所有 ggplot2 图形默认加入：

```r
theme_bw()
```

推荐统一主题：

```r
x_theme <- function(base_size = 12) {
  theme_bw(base_size = base_size) +
    theme(
      plot.title = element_text(hjust = 0.5, color = "black"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid = element_blank(),
      axis.title.x = element_text(color = "black", size = 9),
      axis.title.y = element_text(color = "black", size = 9),
      axis.text.x = element_text(color = "black", size = 7),
      axis.text.y = element_text(color = "black", size = 7),
      legend.title = element_text(),
      legend.text = element_text(),
      legend.position = "none"
    )
}
```

通用原则：

- 默认使用 R。
- 默认优先使用 `ggplot2`，除非指定其他 R 包或当前环境不可用。
- 配色清淡、低饱和，适合论文和科研汇报。
- 图形服务于科学结论，不追求花哨。
- 不使用默认彩虹色。
- 不使用 3D、阴影、强渐变和过度装饰。
- 代码要可复制、可复现、便于后续修改。
- 如果用户没有提供真实数据，先给出可替换变量名的 R 模板。

## 统一配色

二分类：

```r
x_cols_2 <- c("#7FB3D5", "#F5B7B1")
```

三分类：

```r
x_cols_3 <- c("#7FB3D5", "#82E0AA", "#F7DC6F")
```

多分类：

```r
x_cols_multi <- c(
  "#7FB3D5", "#82E0AA", "#F5B7B1", "#C39BD3", "#F7DC6F",
  "#A3E4D7", "#D7BDE2", "#FAD7A0", "#A9CCE3", "#D5F5E3"
)
```

差异方向：

```r
x_cols_diff <- c(
  "Down" = "#7FB3D5",
  "NS" = "grey80",
  "Up" = "#E59866"
)
```

连续变量默认使用 `viridis` 色阶，除非用户、期刊或既有项目规范明确指定其他颜色。该规则适用于热图、连续数值着色的散点图，以及颜色随年龄、时间、剂量、风险评分等递进变化的图。

```r
library(viridis)
scale_color_viridis_c(option = "viridis", direction = 1)
scale_fill_viridis_c(option = "viridis", direction = 1)
```

如果年龄等变量按整数或分组展示，但颜色需要体现递进关系，应先按数值顺序设置因子水平，再用离散 viridis：

```r
df <- df |>
  mutate(age_group = factor(age_group, levels = sort(unique(age_group))))

scale_fill_viridis_d(option = "viridis", direction = 1)
```

当连续变量以 0 为中心且正负方向具有相反含义，例如 z-score、相关系数或 log2 fold change，优先使用以 0 为中心的发散色阶：

```r
scale_fill_gradient2(
  low = "#7FB3D5",
  mid = "white",
  high = "#E59866",
  midpoint = 0
)
```

## 相关性图规范

相关性图、线性回归散点图默认使用如下风格：

```r
p <- ggplot(df, aes(x = X, y = Y, color = X)) +
  geom_point(size = 3, alpha = 0.7, shape = 16, stroke = 0) +
  geom_smooth(method = "lm", se = TRUE, color = "#a72126") +
  labs(title = "Linear Regression", x = "X", y = "Y") +
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    legend.position = "none",
    aspect.ratio = 1
  ) +
  scale_color_viridis_c(option = "viridis", direction = 1) +
  scale_fill_viridis_c(option = "viridis", direction = 1) +
  guides(color = "none")
```

强制规则：

- 点大小默认 `size = 3`，透明度默认 `alpha = 0.7`，点形状默认 `shape = 16`，`stroke = 0`。
- 连续型横轴变量映射到点颜色时，默认使用 `scale_color_viridis_c()`。
- 线性拟合线默认使用 `geom_smooth(method = "lm", se = TRUE, color = "#a72126")`。
- 默认白底、无网格线、隐藏颜色图例。
- 必须标注或另存 Pearson/Spearman 相关系数、P 值、样本量和缺失样本数。
- 相关性图的“绘图区/图形区域”必须为 1:1 正方形；这是图形区域比例，不要求整个导出画布为正方形。ggplot2 中使用 `theme(aspect.ratio = 1)`；base R 中使用 `par(pty = "s")` 或等效方式保证 plotting region 为正方形。
- 默认同时导出 PDF 和 PNG。若用于论文或截图，可按需要导出单图 `width = 3, height = 5`，但绘图区仍必须保持 1:1。


## 默认 R 包

默认加载：

```r
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(ggrepel)
```

组学图按需使用：

```r
library(pheatmap)
library(ComplexHeatmap)
library(clusterProfiler)
library(enrichplot)
library(Seurat)
library(patchwork)
library(UpSetR)
```

统计模型图按需使用：

```r
library(broom)
library(forcats)
library(survival)
library(survminer)
library(pROC)
library(rms)
library(gtsummary)
library(broom.helpers)
```

缺包时先报告缺失包和可替代方案；只有当前环境无法安装且用户接受时，才使用 base R 或更轻量依赖复刻同一风格。

## 组学图规范

火山图：

- 上调、下调、非显著使用固定颜色。
- 只标注与故事线相关的核心分子。
- 不在图上堆满标签。
- 横轴使用 `log2FoldChange` 或等价指标。
- 纵轴使用 `-log10(padj)` 或 `-log10(P value)`。

```r
ggplot(deg, aes(x = log2FoldChange, y = -log10(padj), color = change)) +
  geom_point(size = 1.5, alpha = 0.75) +
  scale_color_manual(values = x_cols_diff) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "grey60") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey60") +
  x_theme()
```

热图：

- 优先展示核心基因或核心特征，不直接展示全部差异特征。
- 行列注释要清楚。
- 非中心化连续数值默认使用 `viridis`。
- z-score、相关系数等有正负方向的数据，使用以 0 为中心的发散色阶。
- 样本很多时隐藏列名。

富集图：

- 只展示最重要的 10-20 个条目。
- 通路名称过长时换行。
- 气泡大小表示 gene count 或 gene ratio。
- 颜色表示显著性、NES 或其他连续统计量。


单细胞图：

- UMAP/tSNE 点不要太大，避免高密度区域糊成色块。
- 细胞类型超过 10 类时，优先使用清淡多分类色，并保证同一项目颜色含义一致。
- 标签避免遮挡主要细胞群；必要时使用 `ggrepel` 或单独图例。
- 展示组间差异时优先分面，避免把组别、细胞类型和表达量全部压在一张图里。
- marker gene 图要控制颜色上限，避免少数极端值支配图形。

UpSet/韦恩/桑基图：

- 用于展示差异分子、通路或细胞群交集与流向。
- 交集过多时优先 UpSet，少量集合才使用韦恩图。
- 桑基图必须明确节点层级和流量含义，不用装饰性渐变掩盖数量差异。

## 模型结果图规范

森林图：

- 变量按效应大小或临床逻辑排序。
- 使用点和横线表示效应值与 95% CI。
- 加入无效线：OR/HR 为 1，beta 为 0。
- 不只展示 P 值，要突出效应方向和不确定性。

```r
ggplot(model_df, aes(x = estimate, y = fct_rev(term))) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey60") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.18, color = "grey35") +
  geom_point(size = 2.4, color = "#21618C") +
  scale_x_log10() +
  labs(x = "Effect size", y = NULL) +
  x_theme()
```

KM、ROC、校准曲线和 DCA 图必须保留关键参考线或风险表，不得通过截断坐标轴夸大模型表现。

Kaplan-Meier 曲线：

- 曲线颜色使用清淡二分类或三分类配色。
- 显示风险表时保持整洁。
- P 值可以显示，但不能让 P 值成为唯一结论。
- 图题或图注要说明分组变量和结局。

ROC 曲线：

- AUC 标注简洁，多模型比较时颜色保持低饱和。
- 不要把过多曲线堆在一张图上；必要时拆成分面或补充表格。
- 必要时补充置信区间。

校准曲线：

- 必须保留理想参考线。
- 横轴为预测风险，纵轴为观察风险。
- 标题或说明中明确建模人群、验证集或重采样方式。

DCA 曲线：

- 必须包含 treat all 和 treat none 参考线。
- 阈值概率范围要合理。
- 如果模型净获益很弱，要如实展示，不通过截断坐标轴夸大效果。

## 输出规范

每张最终图必须同时保留：

- PDF 矢量图：用于论文排版、后期编辑和无损缩放。
- PNG 位图：用于快速预览、PPT 和日常沟通。

默认导出：

```r
ggsave("figure.pdf", width = 6, height = 4, device = cairo_pdf)
ggsave("figure.png", width = 6, height = 4, dpi = 300)
```

投稿级输出可增加 TIFF：

```r
ggsave("figure.tiff", width = 6, height = 4, dpi = 600, compression = "lzw")
```

除非目标绘图设备不支持矢量输出，否则不得只交付 PNG、JPEG 或 TIFF。PDF 与位图必须使用相同的宽度、高度、字体和图形对象。


## 每次作图前的最小问题

如果用户没有提供足够信息，优先只问会影响图形正确性的最少问题：

- 这是组学结果、统计模型结果，还是普通数据？
- 这张图用于论文、PPT、内部探索，还是宣传展示？
- 分组变量、对比组和参考组是什么？
- 主要想突出什么结论？
- 是否有目标期刊、画布尺寸或导出格式要求？

如果用户已经给出明确数据和目标，不要过度追问，直接给出 R 代码或执行绘图。

## 图形质量检查清单

输出前逐项检查：

- 结论是否一眼能看出。
- 颜色是否清淡且有区分度。
- 连续变量和递进颜色是否默认使用 `viridis`，且色阶方向与数值顺序一致。
- 是否使用 `theme_bw()` 或 `x_theme()`。
- 坐标轴是否完整。
- 图例是否必要；不必要时隐藏。
- 字号是否适合论文或 PPT。
- 统计量、P 值、CI、AUC 等是否标注或另存正确。
- 是否存在样本点重叠严重。
- 是否存在标题过长。
- 颜色含义是否前后一致。
- 图形是否夸大了不确定结果。
- 是否同时保留 PDF 矢量图和所需位图格式。
