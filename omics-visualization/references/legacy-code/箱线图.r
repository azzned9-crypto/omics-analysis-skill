library(ggplot2)
library(ggpubr)#stat_compare_means检验
#单因素检验
	HAI3$AMS <- ifelse(HAI3$AMS=="1","YES","NO")
	cp =list(c("YES","NO"))
	ggplot(HAI3, aes(x = AMS, y= SPO2, fill=AMS,color = AMS)) +
	geom_boxplot(aes())+
	theme_bw()+
	theme(panel.grid = element_blank(),axis.text.x = element_blank())+geom_jitter(size=1)+
	stat_compare_means(comparisons =cp,method = "t.test",label =  "p", label.x = 1.5)+
	scale_color_manual(values = c("NO" = "black", "YES" = "black"))+
	scale_fill_manual(values = c("NO" = "#4a4b9d", "YES" = "#a72126"))+
	theme(
		    plot.title = element_text(hjust = 0.5, color = "black"),
		    legend.position = "none",
		    panel.grid.major = element_blank(), # 删除主要网格线
		    panel.grid.minor = element_blank(), # 删除次要网格线
		    axis.title.x = element_text(color = "black",size=9), # X轴标题颜色
		    axis.title.y = element_text(color = "black",size=9), # Y轴标题颜色
		    axis.text.x = element_text(color = "black",size=7), # X轴文本颜色
		    axis.text.y = element_text(color = "black",size=7), # Y轴文本颜色
		    legend.title = element_text(color = "black",size=9), # 图例标题颜色
		    legend.text = element_text(color = "black",size=7) # 图例文本颜色
		  )
		ggsave("LINE.pdf", p, width = 40, height = 60, units = "mm", dpi = 300)
	#method可以改成wilcox.test
	#geom_jitter() 改为 geom_point()，并设置 position = "jitter" 的替代方式或直接固定位置
	#geom_point(position = position_jitter(width = 0.1, seed = 223), size = 1)
	#stat_compare_means( label.x = 1.5,label.y设置统计值的位置，具体值根据纵坐标的值定）
	#+xlab("")+ylab("") 删除X轴Y轴标题
