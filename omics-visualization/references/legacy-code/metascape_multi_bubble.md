# 多基因集metascape富集结果热图（通用模板）
------------------------------------------------
> 创建日期 2025-12-15
> 用途 记录利用metascpe的多基因集富集结果重新做热图展示
> 创建人何雪飞
> 更新日期 2025-12-15
------------------------------------------------

## 1.数据输入
数据来源于metascape对于多基因集的富集分析结果
结果路径位于 metascape_results/Enrichment_heatmap/HeatmapSelectedGO.csv
原图如下：

![HAPE模块富集分析](https://github.com/azzned9-crypto/md.image/blob/main/HeatmapSelectedGO.png?raw=true)

## 2.加载包处理数据
```R
rm(list=ls())
library(reshape2) # melt
library(ggplot2) # ggplot2
setwd("F:/26.HighAltitude/17.HAPE_TE/06.NewResults/results/wgcna/enrichment/allgenes.in.modules/Enrichment_heatmap")
heat <- read.csv("HeatmapSelectedGO.csv")
heat$Pathway <- paste(heat$GO, heat$Description,sep=':') # 处理文件，合并GO号码列和描述列
heat <-heat[,-(1:2)] # 删除头两列（原来的GO号码列和描述列）
heat2 <-heat[,c(5,1:4)] # 重新排列
names(heat2) <-c("Pathway","BM","DTM","MNM","RM") # 重新命名
# 此时文件是矩阵格式
heat2 <-melt(heat2) #转为长格式
order <- unique(heat$Pathway)
heat2$Pathway <- factor(heat2$Pathway, levels = order, ordered = TRUE) # 按原来的pathway排序

```

## 3. 气泡图
```R
ggplot(heat2, aes(x = variable, y = Pathway, size = abs(value))) +
  geom_point(color = "steelblue", alpha = 0.7) +  # 统一颜色，半透明
  scale_size_area(max_size =10) + # 气泡大小与 |value| 成正比
  theme_bw() + # 黑框+网格背景
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 9),
    panel.grid = element_blank() # 移除网格线
  ) +
  labs(
    x = "Modules",
    y = "GO Terms",
    size = "-logP",
    title = "GO Enrichment Plot"
  )
```
