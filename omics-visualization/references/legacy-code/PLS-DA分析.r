#PLS-DA
library(mixOmics)
library(ggplot2)
#准备数据
X <- t(cpm(y, log = TRUE))  #数据需要归一化后的样本，rownames是样本，colnames是基因
group <- factor(c("H","H","H","H","H","H","N","N","N","N","N","N"), levels = c("N", "H"))
Y <- group  #分组向量
#执行PLS-DA
	plsda_result <- plsda(X, Y, ncomp = 2)
#获取得分
	plsda_df <- data.frame(Comp1 = plsda_result$variates$X[, 1],Comp2 = plsda_result$variates$X[, 2],group = Y,sample = rownames(X))
# 计算解释方差
	explained_var <- plsda_result$prop_expl_var$X

# 绘图
	ggplot(plsda_df, aes(x = Comp1, y = Comp2, fill = group)) +
		geom_point(shape = 21, size = 3, color = "black") +
		scale_fill_manual(values = colors) +
		stat_ellipse(aes(color = group), level = 0.95) +  # 添加置信椭圆
		labs(x = paste0("Component 1 (", round(explained_var[1]*100, 1), "%)"),y = paste0("Component 2 (", round(explained_var[2]*100, 1), "%)"))+
		theme_bw()+theme(
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
