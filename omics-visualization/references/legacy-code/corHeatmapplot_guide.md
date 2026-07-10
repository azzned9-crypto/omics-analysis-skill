# 做相关性热图
```R
#计算相关性
cor_mat <- cor(SRSD, use = "complete.obs")
library(corrplot)
library(RColorBrewer) #调色板
my_colors <- colorRampPalette(rev(brewer.pal(n = 8, name = "Spectral")))(200)
corrplot(cor_mat,
    method = "color", #“circle”, “square”, “ellipse”, “number”, “shade”, “color”, “pie”
    type = "upper",  #上三角显示图
    col = my_colors,
    tl.cex = 1.2,  # 标签字体大小
    tl.col = "black",
    number.cex = 1.0, # 相关系数数字大小
    mar = c(0, 0, 2, 0),  # 边距
    bg = "white")
corrplot(cor_mat,
    method = "number",
    type = "lower",#下三角显示具体数值
    add = TRUE, # 关键：叠加到已有图上
    number.cex = 1.0,
    col = "black", # 数字颜色
    tl.pos = "n",  # 不重复绘制标签
    cl.pos = "n")   # 不显示颜色图例（避免重叠）
```
