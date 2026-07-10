library(tidyr)
library(ggplot2)
#双向柱状图统计上下调基因个数
		#建立数据框
		#each是指两个方向
		#Times是指4个组
        gene_data <- data.frame( Group = rep(c("2023A", "2023B", "2024A","2024B"), each = 2),  Direction = rep(c("Male", "Female"), times = 4),Count = c(69, -14, 603, -59, 426, -49,464,-56) )
        #重塑数据，使每个组的上调和下调基因在同一行
        reshaped_data <- gene_data %>%  pivot_wider(names_from = Direction, values_from = Count, values_fill = 0) %>%  mutate(Total = Male + Female)
        reshaped_data$Group <- factor(reshaped_data$Group, levels = c("2024B", "2024A", "2023B","2023A"))
        #绘制柱状图
        C <-ggplot(reshaped_data, aes(x = Group)) +geom_bar(aes(y = Male, fill = "Male"), stat = "identity", position = position_stack(), width = 0.8, color="black", size=0.3) + geom_bar(aes(y = Female, fill = "Female"), stat = "identity", position = position_stack(), width = 0.8,color="black", size=0.3) + scale_fill_manual(values = c("Male" = "#ff8235", "Female" = "#30e8bf")) +coord_flip() +labs(x = "Groups", y = "Number of Genes") +theme_bw()
        ggsave("C.pdf",C,width=5,height=2)







        gene_data <- data.frame( Group = rep(c("P506", "P507", "P517","P508","P518","P509"), each = 2),  Direction = rep(c("NON", "AMS"), times = 6),Count = c(-8, 12, -11, 11, -8, 19,-12,15,-6,15,-10,11) )
        #重塑数据，使每个组的上调和下调基因在同一行
        reshaped_data <- gene_data %>%  pivot_wider(names_from = Direction, values_from = Count, values_fill = 0) %>%  mutate(Total = NON + AMS)
        reshaped_data$Group <- factor(reshaped_data$Group, levels = c("P509", "P518", "P508","P517","P507","P506"))
        #绘制柱状图
        C <-ggplot(reshaped_data, aes(x = Group)) +geom_bar(aes(y = NON, fill = "NON"), stat = "identity", position = position_stack(), width = 0.8, color="black", size=0.3) + geom_bar(aes(y = AMS, fill = "AMS"), stat = "identity", position = position_stack(), width = 0.8,color="black", size=0.3) + scale_fill_manual(values = c("NON" = "#ff8235", "AMS" = "#30e8bf")) +coord_flip() +labs(x = "Groups", y = "Number of Genes") +theme_bw()
        ggsave("C.pdf",C,width=5,height=2)
