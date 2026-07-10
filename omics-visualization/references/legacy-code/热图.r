
#Heatmap
	#简单粗暴，可以聚类
	#需要melt
	#组间差异体现
	library(ComplexHeatmap)
	Heatmap(EXP4,name = "Z-score",col = colorRampPalette(c("#fde725","#5dc863","#21908c","#3b528b", "#440154"))(100),cluster_rows = TRUE,cluster_columns = FALSE,show_row_names = FALSE,show_column_names = TRUE,rect_gp = gpar(col = "black", lwd = 0.5),row_names_gp = gpar(fontsize = 8),column_names_gp = gpar(fontsize = 8),heatmap_legend_param = list(title = "Z-score"))


#ggplot
	#需要melt
	#相关性体现
	library(ggplot2)
	ggplot(data, aes(x = Row, y = Column, fill = Correlation)) + geom_tile(color = "black", size = 0.1) +geom_text(aes(label = ifelse(Significance != "", Significance, "")),vjust = 0.8, size = 4, color = "black")  + theme( axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.8), legend.position = "right", panel.background = element_blank(),plot.background = element_blank(),panel.border = element_rect(color = "black", fill = NA, size = 1)  ) +labs( title = "Correlation and Significance Heatmap",  x = "Variables (HUBEXP)",y = "Variables (DETC)")+scale_fill_viridis_c( option = "viridis",  limits = c(-0.73, 0.4312), direction = 1, name = "Correlation",alpha = 0.7)


#pheatmap
	library(pheatmap)
	#基本热图
	pheatmap(ExpCorDetc,
         color = colorRampPalette(c("#46337e", "#277f8e", "#4ac16d","#f5d134"))(100), # 蓝-白-红的颜色梯度
         show_rownames = TRUE, # 显示TE名
         show_colnames = FALSE, # 不显示2000个基因名，太密了
         cluster_rows = TRUE, # 对TE进行聚类
         cluster_cols = TRUE, # 对基因进行聚类
         main = "")
