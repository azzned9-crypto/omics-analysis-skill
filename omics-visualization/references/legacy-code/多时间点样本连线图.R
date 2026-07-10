library(ggplot2)
library(ggpubr)#stat_compare_means()
#多样本时间线变化图
	TS <-read.csv("Timescale.csv",header=F)
#检查正态性
	hist(TS$V4)
	shapiro.test(TS$V4)
#添加抖动到时间点 V2，并存储在一个新的列中
	TS <- TS %>% mutate(V2_jitter = as.numeric(as.factor(V2)) + runif(n(), -0.1, 0.1))
#作图
	cp <- list(c("S0", "S24"), c("S24", "S48"),c("S48","S72"))
	ggplot(TS, aes(x = V2, y = V4, group = V1)) +geom_line(aes(group = V1), alpha = 0.8) +  geom_point(aes(x = V2_jitter, y = V4), size = 2) + scale_y_continuous(limits = c(75, 105)) +  theme_bw() + theme(panel.grid = element_blank()) +  theme(legend.position = "right") + stat_compare_means(comparisons = cp,  method = "wilcox.test",label = "p",  label.x = c(1.5, 2.5,3.5), label.y = c(101, 102,103) )
	#label.x是三个检验结果的横坐标位置
	#label.y是三个检验结果的纵坐标位置
