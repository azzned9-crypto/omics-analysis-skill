install.packages("moonBook")
library(moonBook)
setwd("F:/26.HighAltitude/06.采样事宜/04.志愿者招募/04.tableone_LASSO")
#SINFO <- read.csv("Sinfo.csv")
SINFO <- read.csv("Sinfo.csv", na.strings = c("", " ", "NA", "N/A", ".", "-", "null", "NULL"))

# 使用mytable函数，以性别(sex)为分组变量
#RST <- mytable(AMS ~ ., data = SINFO)
#mycsv(RST, file = "result_moonBook.csv")
#moonBook不能自动选择检测方法




#Tableone
	library(tableone)
	#tab <- CreateTableOne(vars = c("AGE", "SEX"),strata = "AMS",data = SINFO,test = TRUE)
	#print(tab, showAllLevels = TRUE, exact = "fisher")  # 自动对小样本用 Fisher
	#分类变量
		FAC <- c("SEX", "SMK", "ALC", "OCP","AMSH","HAEH_1","HAEH_3","PC")
	#连续变量
		NUM <- c("AGE","EDU","HET","WET","BMI","SPO2","PUL","SBP","DBP","PHC","MEC","OSH","PHQ9", "GAD7","ESS")
	SINFO[FAC] <- lapply(SINFO[FAC], as.factor)
	SINFO[NUM] <- lapply(SINFO[NUM], as.numeric)

	FACRST <- CreateTableOne(vars = FAC,strata = "AMS",data = SINFO,test = TRUE)
	FACPRT <- print(FACRST, showAllLevels = TRUE, exact = "fisher")  # 自动对小样本用 Fisher
	NUMRST <- CreateTableOne(vars = NUM,strata = "AMS",data = SINFO,test = TRUE)
	NUMPRT <- print(NUMRST, showAllLevels = TRUE, exact = "fisher")  # 自动对小样本用 Fisher
	write.csv(FACPRT, "FACPRT.csv")
	write.csv(NUMPRT, "NUMPRT.csv")
	#PC批次效应
	FACRST <- CreateTableOne(vars = FAC,strata = "PC",data = SINFO,test = TRUE)
	FACPRT <- print(FACRST, showAllLevels = TRUE, exact = "fisher")

	NUMRST <- CreateTableOne(vars = NUM,strata = "PC",data = SINFO,test = TRUE)
	NUMPRT <- print(NUMRST, showAllLevels = TRUE, exact = "fisher")  # 自动对小样本用 Fisher

#LASSO
	#数据处理
		#计算数据缺失比例
			na_prop <- colSums(is.na(SINFO)) / nrow(SINFO)
			na_pct <- round(na_prop * 100, 2)
			na_pct
		#计算数据稀疏性
			dominant_prop <- sapply(SINFO, function(x) {
				tbl <- sort(table(x, useNA = "no"), decreasing = TRUE)
				if (length(tbl) == 0) return(NA)
				max_freq <- as.numeric(tbl[1])
				max_freq / sum(!is.na(x))
					})
			round(dominant_prop * 100, 2)
		#删除不相关的列
			SINFO$VID <- NULL
			SINFO$HET <- NULL
			SINFO$WET <- NULL
			SINFO$PC <- NULL
			SINFO$FMS <- NULL #自觉高稀疏
			SINFO$PMS <- NULL #自觉高稀疏
			SINFO$TRS <- NULL #自觉高稀疏
			SINFO$ALS <- NULL #自觉高稀疏
			SINFO$MET <- NULL #自觉高稀疏
			SINFO$SUS <- NULL
		#删除数据缺失>30%的列
			SINFO$WET <- NULL
			SINFO$HAEH_7 <- NULL
			SINFO$HAEH_13 <- NULL
			SINFO$OSH <- NULL
		#删除高稀疏数据>95%
			SINFO$ETH <- NULL
			SINFO$HAEH_13 <- NULL
	#生成哑变量
	#分离特征和目标变量
	#先分离，再填充避免数据泄露
		features <- SINFO[, colnames(SINFO) != "AMS"]
		target <- as.factor(SINFO$AMS)
		features$SEX <- ifelse(features$SEX=="0","Female","Male")
		features$SEX <- factor(features$SEX, levels = c("Female", "Male"))
	#使用mice进行数据填充
		library(mice)
		#对数据类型进行分类
		BCAT <- c("SEX", "AMSH")
		MCAT <- c("SMK", "ALC", "OCP","HAEH_1","HAEH_3")
		CONT <- c("AGE", "EDU", "BMI","SPO2","PUL","SBP","DBP","PHC","MEC","PHQ9", "GAD7","ESS")
	#初始化方法向量（基于当前数据）
		meth <- make.method(features)
	#一次性指定多个变量的方法
		meth[CONT]  <- "pmm"      # 连续变量：预测均值匹配
		meth[BCAT]  <- "logreg"   # 二分类：逻辑回归
		meth[MCAT]  <- "polyreg"  # 多分类：多项逻辑回归
	#插补
		IMP <- mice(features, method = meth, m = 1, printFlag = FALSE)
		featuresV2 <- complete(IMP)

	#glmnet 只接受数值矩阵，且需要正确编码分类变量(哑变量)
		x <- model.matrix(~ . , data = featuresV2)
		x <-x[,-1] #删除截距列
	#对连续变量做数据标准化
		#检查x的列是否在原始 NUM 中
		CONT2 <- colnames(x)[colnames(x) %in% CONT]
		#标准化这些连续变量
		x[, CONT2] <- scale(x[, CONT2])
	#LASSO模型筛选特征
		library(glmnet)
		#不做交叉验证作图
			NonlassoModel <- glmnet(x, y = target, alpha = 1, family = "binomial")
			plot(NonlassoModel, xvar="lambda",label=TRUE, lwd=2)

		#交叉验证
			set.seed(369)
			cv_lasso <- cv.glmnet(x , y = target, alpha = 1, family = "binomial")
			#获取最优的 lambda 值
			best_lambda_min <- cv_lasso$lambda.min
			print(best_lambda_min)
			best_lambda_1se <- cv_lasso$lambda.1se
			print(best_lambda_1se)
			#绘制交叉验证结果图
				plot(cv_lasso, main = "Cross-Validation for LASSO")
				#添加最优 lambda 值的垂直线
				abline(v = -log(best_lambda_min), col = "red", lty = 2)
				abline(v = -log(best_lambda_1se), col = "blue", lty = 2)
				#添加文本标注
				text(log(best_lambda_min), max(cv_lasso$cvm), paste("λ_min =", round(best_lambda_min, 3)), pos = 4, col = "red")
				text(log(best_lambda_1se), max(cv_lasso$cvm), paste("λ_1se =", round(best_lambda_1se, 3)), pos = 4, col = "blue")
				#显示图例
				legend("topright", legend = c("CV Error", "λ_min", "λ_1se"), col = c("black", "red", "blue"), lty = c(1, 2, 2))
		#查看最佳 lambda 下的变量（非零系数）
		#用lambda_min(#最小CV)误差或lambda_1se(更简洁模型)
		coef_min <- coef(cv_lasso, s = "lambda.min")
		#提取非零系数及其变量名
		nonzero_idx <- which(coef_min[, 1] != 0) # 找非零行索引
		nonzero_coef <- coef_min[nonzero_idx, 1, drop = TRUE] #转为普通numeric
		print(nonzero_coef)


#逻辑回归+ROC曲线
	library(dplyr)
	library(pROC)
	#避免数据泄露
	NEW <- cbind(target,featuresV2)
	NEW$target<-ifelse(NEW$target=="YES",1,0)
	model <- glm(target ~ MEC + SEX+AGE+EDU+BMI, data = NEW, family = binomial)
	summary(model)
	#计算预测概率
	NEW$PP <- predict(model, type="response")
	roc_curve <- roc(NEW$target, NEW$PP)
	#作图
	plot(roc_curve)
	auc(roc_curve)



	library(broom)
#逻辑回归(连续变量,非校正)
	#循环函数
		#提取需要做的变量参数
		NUM2 <- c("AGE","EDU","BMI","SPO2","PUL","SBP","DBP","PHC","MEC","PHQ9", "GAD7","ESS")
		predictors <- NUM2
		#创建一个空的数据框，用于存储结果
			LRresults <- data.frame(
				VAR = character(),
				AIC = numeric(),
				conf.low = numeric(),
				conf.high = numeric(),
				OR = numeric(),
				Pvalue = numeric(),
				stringsAsFactors = FALSE
					)
		#遍历每个因变量，拟合线性模型并提取参数
			for (response in predictors) {
				formula <- as.formula(paste("target ~", response))
				model <- glm(formula, data = NEW, family = binomial)
				#使用 broom::tidy 提取 exponentiated 系数 + 95% CI
				tidy_res <- tidy(model, exponentiate = TRUE, conf.int = TRUE)
				#提取非截距行（即预测变量那一行）
				pred_row <- tidy_res[tidy_res$term != "(Intercept)", ]
				#将结果添加到数据框中
				LRresults <- rbind(LRresults, data.frame(
				VAR = response,
				OR = pred_row$estimate,
				conf.low = pred_row$conf.low,
				conf.high = pred_row$conf.high,
				Pvalue = pred_row$p.value,
				AIC = AIC(model),
				stringsAsFactors = FALSE
				))
				}
		#保存数据
		write.csv(LRresults,"LRresults_NUM.csv")
#逻辑回归（分类变量，哑变量）
		SUF <- as.data.frame(x)
		SUF2 <- cbind(target,SUF)
		#提取需要做的变量参数
		FAC2 <-c("SEXMale", "AMSHYES","SMK1", "SMK2","SMK3","ALC1","ALC2", "OCP1","OCP2","OCP4","HAEH_11","HAEH_12")
		predictors <- FAC2
		#创建一个空的数据框，用于存储结果
			LRresults <- data.frame(
				VAR = character(),
				AIC = numeric(),
				conf.low = numeric(),
				conf.high = numeric(),
				OR = numeric(),
				Pvalue = numeric(),
				stringsAsFactors = FALSE
					)
		#遍历每个因变量，拟合线性模型并提取参数
			for (response in predictors) {
				formula <- as.formula(paste("target ~", response))
				model <- glm(formula, data = SUF2, family = binomial)
				#使用 broom::tidy 提取 exponentiated 系数 + 95% CI
				tidy_res <- tidy(model, exponentiate = TRUE, conf.int = TRUE)
				#提取非截距行（即预测变量那一行）
				pred_row <- tidy_res[tidy_res$term != "(Intercept)", ]
				#将结果添加到数据框中
				LRresults <- rbind(LRresults, data.frame(
				VAR = response,
				OR = pred_row$estimate,
				conf.low = pred_row$conf.low,
				conf.high = pred_row$conf.high,
				Pvalue = pred_row$p.value,
				AIC = AIC(model),
				stringsAsFactors = FALSE
				))
				}
		#保存数据
		write.csv(LRresults,"LRresults_FAC.csv")
#Forest Plot
	#本身不支持原点
	install.packages("forestplot")
	library(forestplot)
	#按OR值排序（如有需要）
		#LRresults <- LRresults[order(LRresults$OR), ]
	#创建标签文本
		labeltext <- cbind(
			Variable = LRresults$VAR,
			OR = sprintf("%.2f", LRresults$OR),
			CI = sprintf("[%.2f, %.2f]", LRresults$conf.low, LRresults$conf.high),
			P = sprintf("p = %.2f", LRresults$Pvalue) #控制pvalue在小数点后两位
			)
	#作图
		forestplot(
		  labeltext = labeltext,
		  mean = LRresults$OR,
		  lower = LRresults$conf.low,
		  upper = LRresults$conf.high,
		  boxsize = 0.3,
		  col = fpColors(box = "firebrick", line = "firebrick", zero = "gray60"), #颜色设置
		  xlab = "Odds Ratio (95% CI)",
		  zero = 1,
		  lwd.zero = 1.5,          # 无效线加粗
		  clip = c(-0.5, 8),       # 限制 x 轴范围（避免极端值拉宽）
		  xticks = c(0,  2,4,6,8),  # 自定义刻度
		  graph.pos = 2, #图形放在第2列（左侧是文字，右侧是P值
		  txt_gp = fpTxtGp(label = gpar(fontfamily = "sans")),#sans使用无衬线字体
		  line.margin = 0.1        # 行间距
		)
