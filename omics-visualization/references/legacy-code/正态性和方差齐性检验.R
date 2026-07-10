#检查正太性
	hist(ctraits$SpO2)
	#检查正太分布
	#Shapiro - Wilk 检验
	shapiro.test(ctraits$SpO2)
	shapiro.test(subset(ttraits, AMS == "No")$HGB)
		#如果p>0.05则是正太分布
		#如果p<0.05则不是正太分布 需要用秩和检验(两组比较)
		stat_compare_means(comparisons = cp, method = "wilcox.test", label = "p", label.x = 1.5)
		#如果是多组独立样本则使用kruskal.test(多组比较)

#检查方差齐性
	#两两比较
		#提取No组的SpO2数据
		no_group <- subset(ctraits, AMS == "No")$SpO2
		# 提取Yes组的SpO2数据
		yes_group <- subset(ctraits, AMS == "Yes")$SpO2
		#进行方差齐性检验
		var_test_result <- var.test(no_group, yes_group)
		var_test_result
		#如果p >0.05则用t检验
		stat_compare_means(comparisons =cp,method = "t.test",label =  "p", label.x = 1.5)
		#如果p<0.05则用Welch's t检验
		stat_compare_means(comparisons =cp,method = "t.test",var.equal=FALSE,label =  "p", label.x = 1.5)
	#多组比较
	#正态分布,方差齐,多组比较使用ANOVA检验
