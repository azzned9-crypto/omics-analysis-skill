
#排序柱状图
	COUNTS <- read.csv("03.COR/TEcorGENE_counts.csv",header=F)
	#柱状图
	COUNTS <- COUNTS[order(COUNTS$V2, decreasing = FALSE),]
	COUNTS$V1 <- factor(COUNTS$V1, levels = unique(COUNTS$V1))
	ggplot(COUNTS, aes(x = V1, y = V2, fill = V1, color = V1)) +
		geom_bar(stat = "identity", position = "dodge") +labs(x = "TE_Family", y = "Counts") +
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
			)+
		coord_flip()

#堆叠柱状图展示每个样本每个class的比例
	CLSp$Sample <- rownames(CLSp)
	mCLSp <- melt(CLSp, id.vars = "Sample",  variable.name = "TE_Type",value.name = "Proportion")
	p<- ggplot(mCLSp, aes(x = Sample, y = Proportion, fill = TE_Type)) +
		geom_col(position = "stack", width = 0.7) +
		labs(title = "",x = "",y = "", fill = "") +
		theme_bw()+
		theme(
			plot.title = element_text(hjust = 0.5, color = "black"),
			legend.position = "top",
			panel.grid.major = element_blank(), # 删除主要网格线
			panel.grid.minor = element_blank(), # 删除次要网格线
			axis.title.x = element_text(color = "black",size=9), # X轴标题颜色
			axis.title.y = element_text(color = "black",size=9), # Y轴标题颜色
			axis.text.x = element_text(color = "black",size=7), # X轴文本颜色
			axis.text.y = element_text(color = "black",size=7), # Y轴文本颜色
			legend.title = element_text(color = "black",size=9), # 图例标题颜色
			legend.text = element_text(color = "black",size=7) # 图例文本颜色
			 )
	ggsave("TEclassPercentage.pdf", p, width = 50, height = 50, units = "mm", dpi = 300)


#柱状图连续变色（年龄分布统计）
	ggplot(COUNTS, aes(x = AGE, y = DIS, fill = AGE, color = AGE)) +geom_bar(stat = "identity", position = "dodge") +labs(x = "Days", y = "Counts") +theme_bw() +scale_fill_viridis_d(direction = 1) + scale_color_viridis_d(direction = 1)+theme_bw()+
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
