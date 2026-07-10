library(VennDiagram)
library(grid)

# 创建 venn_list，按照固定的顺序：A2023, B2023, A2024, B2024
venn_list <- list(
  A2023 = A2023$V1,
  B2023 = B2023$V1,
  A2024 = A2024$V1,
  B2024 = B2024$V1
)

# 定义颜色，确保与顺序一致
colors <- c(
  rgb(t(col2rgb('#b7cc64')) / 255, alpha = 0.7), # A2023 的颜色
  rgb(t(col2rgb('#dfa978')) / 255, alpha = 0.7), # B2023 的颜色
  rgb(t(col2rgb('#dfa978')) / 255, alpha = 0.7), # A2024 的颜色
  rgb(t(col2rgb('#dfa978')) / 255, alpha = 0.7)  # B2024 的颜色
)

# 绘制 Venn 图
p <- venn.diagram(
  venn_list,
  filename = NULL,
  fill = colors, # 使用定义的颜色
  category = c("A2023", "B2023", "A2024", "B2024"), # 按照固定顺序设置类别名称
  cat.col = c("black", "black", "black", "black"), # 类别标签颜色
  cat.cex = 1.5, # 类别标签字体大小
  cat.fontfamily = 'serif', # 类别标签字体
  col = c("black", "black", "black", "black"), # 边框颜色
  cex = 1.5, # 文本字体大小
  fontfamily = 'serif' # 文本字体
)

# 保存为 PDF 文件
pdf("NamelistVenn.pdf", width = 7, height = 7)
grid.draw(p)
dev.off()
