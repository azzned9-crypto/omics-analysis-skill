
```R
PCS2$Group <-factor(c(rep("H",6),rep("N",6)), levels = c("N", "H"))
ggplot(PCS2, aes(x = PC1, y = PC2, fill = Group)) +
    geom_point(size=3,shape=21)+
    #stat_ellipse(aes(color = Group), level = 0.95, type = "t", size = 0.75)+ #这个是95%置信区间
	geom_encircle(aes(group = Group,fill=Group),expand=0,spread=0.5,s_shape=1,size=3,linetype = 1,alpha=0.2)+ #这个是分组圈
    scale_fill_manual(values = c("H" = "#46337e", "N" = "#f5d134"))+
    scale_color_manual(values = c("H" = "#46337e", "N" = "#f5d134")) +
    theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, color = "black"),
    panel.grid.major = element_blank(), # 删除主要网格线
    panel.grid.minor = element_blank(), # 删除次要网格线
    axis.title.x = element_text(color = "black",size=16),
    axis.title.y = element_text(color = "black",size=16),
    axis.text.x = element_blank(),
    axis.text.y = element_text(color = "black",size=14))
```
