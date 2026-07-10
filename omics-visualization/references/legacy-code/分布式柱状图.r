
library(ggplot2)
#年龄分布柱状图
ggplot(AGE,aes(x=V2,y=V1,fill=V2))+geom_bar(position="dodge",stat="identity")+scale_fill_viridis_c(option = "viridis")+theme_bw() + theme(panel.grid = element_blank())
