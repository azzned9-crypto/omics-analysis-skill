library(dplyr)
library(ggplot2)
library(ggforce)#geom_arc_bar
#数据框为分组类别和每个类别所占比例，需要提前计算
	df=data.frame(group=c(1,2,3,4,5),value=c(5.35,53.57,26.79,11.6,2.68))
#比例中加上百分号
	df  <- df %>%  mutate(label = paste0(value,"%"))
#每个组别对应的颜色
	BMIcolor <- c("1" ="#ffc078","2"="#ffa94d","3"="#ff922b","4"="#fd7e14","5"="#f76707")
#设定组别顺序
	df$group <- factor(df$group, levels = c(1, 2, 3, 4, 5))
#作图并保存
	BMIdonut <- ggplot() +geom_arc_bar(data = df, stat = "pie", sep = 0,aes(x0 = 0,y0 = 0,r0 = 0.5, r = 2,amount = value,fill=group),show.legend = F)+scale_fill_manual(values = BMIcolor,name="group") +scale_color_manual(values = "black")+ coord_fixed() +  theme_void()
	ggsave("BMIdonut.pdf",BMIdonut,width=5, height=5)




df=data.frame(group=c(1,2),value=c(39.86,60.14))
#比例中加上百分号
	df  <- df %>%  mutate(label = paste0(value,"%"))
#每个组别对应的颜色
	BMIcolor <- c("1" ="#ffc078","2"="#ffa94d")
#设定组别顺序
	df$group <- factor(df$group, levels = c(1, 2))
#作图并保存
	BMIdonut <- ggplot() +geom_arc_bar(data = df, stat = "pie", sep = 0,aes(x0 = 0,y0 = 0,r0 = 0.5, r = 2,amount = value,fill=group),show.legend = F)+scale_fill_manual(values = BMIcolor,name="group") +scale_color_manual(values = "black")+ coord_fixed() +  theme_void()
	ggsave("AMSdonut.pdf",BMIdonut,width=5, height=5)



ggplot(AGE, aes(x = as.factor(V2), y = V1, fill = V2)) + geom_bar(stat = "identity", color = "black") +scale_fill_viridis_c(direction = 1) + theme(legend.position = "none")



df=data.frame(group=c(1,2,3),value=c(11.11,51.11,37.78))
#比例中加上百分号
	df  <- df %>%  mutate(label = paste0(value,"%"))
#每个组别对应的颜色
	BMIcolor <- c("1" ="#ffc078","2"="#ffa94d","3"="#ffa94d")
#设定组别顺序
	df$group <- factor(df$group, levels = c(1, 2,3))
#作图并保存
	BMIdonut <- ggplot() +geom_arc_bar(data = df, stat = "pie", sep = 0,aes(x0 = 0,y0 = 0,r0 = 0.5, r = 2,amount = value,fill=group),show.legend = F)+scale_fill_manual(values = BMIcolor,name="group") +scale_color_manual(values = "black")+ coord_fixed() +  theme_void()
	ggsave("BMIdonut.pdf",BMIdonut,width=5, height=5)




#四分均等
	df=data.frame(group=c(1,2,3,4),value=c(25,25,25,25))
	#比例中加上百分号
		df  <- df %>%  mutate(label = paste0(value,"%"))
	#每个组别对应的颜色
		BMIcolor <- c("1" ="#ffc078","2"="#ffa94d","3"="#ffa94d","4"="#ffa94d")
	#设定组别顺序
		df$group <- factor(df$group, levels = c(1, 2,3,4))
	#作图并保存
		BMIdonut <- ggplot() +geom_arc_bar(data = df, stat = "pie", sep = 0,aes(x0 = 0,y0 = 0,r0 = 0.5, r = 2,amount = value,fill=group),show.legend = F)+scale_fill_manual(values = BMIcolor,name="group") +scale_color_manual(values = "black")+ coord_fixed() +  theme_void()
		ggsave("BMIdonut.pdf",BMIdonut,width=5, height=5)
