#火山图
	library(ggplot2)
	library(dplyr)
	library(ggrepel)
	#处理数据,添加显著性信息
	res_plot <- res_annotated %>% dplyr::mutate(group = case_when(padj < 0.05 & abs(log2FoldChange) > 1 ~ ifelse(log2FoldChange > 0, "Up", "Down"),TRUE ~ "NS")) %>% dplyr::mutate(label = ifelse(padj < 0.05 & abs(log2FoldChange) > 1.5, gene_symbols, NA))
	#作图
	ggplot(res_plot, aes(x = log2FoldChange, y = -log10(padj))) + geom_point(aes(color = group), size = 2) +
		#设置颜色
		scale_color_manual(
			values = c("Up" = "#ed6d3d", "Down" = "#757cbb", "NS" = "gray50"),
			limits = c("Up", "Down", "NS") #控制图例顺序
			) +
		#设置基因标签
		geom_text_repel(aes(label = label),size = 3,force = 0.5,show.legend = FALSE,na.rm = TRUE) +
		#添加阈值线
		geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "gray") +
		geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "gray")+
		#主题
		theme_bw() +
		labs(title = "",x = "logFC",y = "-log10(adj_p)",color = "Group") +
		theme(
		    plot.title = element_text(hjust = 0.5, color = "black"),
		    legend.position = "top",
		    panel.grid.major = element_blank(), # 删除主要网格线
		    panel.grid.minor = element_blank(), # 删除次要网格线
		    axis.title.x = element_text(color = "black",size=16), # X轴标题颜色
		    axis.title.y = element_text(color = "black",size=16), # Y轴标题颜色
		    axis.text.x = element_text(color = "black",size=14), # X轴文本颜色
		    axis.text.y = element_text(color = "black",size=14), # Y轴文本颜色
		    legend.title = element_text(color = "black",size=16), # 图例标题颜色
		    legend.text = element_text(color = "black",size=14) # 图例文本颜色
		  )
