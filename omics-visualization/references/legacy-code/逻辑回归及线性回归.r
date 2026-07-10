#逻辑回归(连续变量,非校正)
		model <- glm(AMS ~ SPO2, data = HAI1, family = binomial)
		summary(model)
		#循环函数
			#提取需要做的变量参数
				predictors <- colnames(HAI1)[c(5:9,12,13)]
			#创建一个空的数据框，用于存储结果
				LRresults <- data.frame(
					VAR = character(),
					AIC = numeric(),
					OR = numeric(),
					Pvalue = numeric(),
					stringsAsFactors = FALSE
				)
			#遍历每个因变量，拟合线性模型并提取参数
				for (response in predictors) {
					formula <- as.formula(paste("AMS ~", response))
					model <- glm(formula, data = HAI1, family = binomial)
					res <-summary(model)
					#提取关键参数
					aic <- res$aic
					coef_matrix <- res$coefficients
					non_intercept_rows <- rownames(coef_matrix) != "(Intercept)"
					#假设只有一个预测变量，取第一个非截距行
					target_row <- rownames(coef_matrix)[non_intercept_rows][1]
					or <- exp(coef_matrix[target_row, "Estimate"])
					pvalue <- coef_matrix[target_row, "Pr(>|z|)"]
				#将结果添加到数据框中
				LRresults <- rbind(LRresults, data.frame(
					VAR = response,
					AIC =aic,
					OR = or,
					Pvalue = pvalue
				  ))
				}
			#保存数据
				write.csv(LRresults,"LRresults_8H_H0607V2.csv")
#逻辑回归(连续变量，校正)
	model <- glm(AMS ~ SPO2+SEX+AGE+BMI, data = HAI1, family = binomial)
	summary(model)
	#提取需要做的变量参数
		predictors <- colnames(HAI1)[c(5:9,12,13)]
	#创建一个空的数据框，用于存储结果
		MLRresults <- data.frame(
			VAR = character(),
			AIC = numeric(),
			OR = numeric(),
			Pvalue = numeric(),
			stringsAsFactors = FALSE
			)
	#遍历每个因变量，拟合线性模型并提取参数
		for (response in predictors) {
			formula <- as.formula(paste("AMS ~", response,"+SEX+AGE+BMI"))
			model <- glm(formula, data = HAI1, family = binomial)
			res <-summary(model)
			#提取关键参数
			aic <- res$aic
			coef_matrix <- res$coefficients
			if (response %in% rownames(coef_matrix)) {
			#如果存在，直接使用 response 作为行索引
			or <- exp(coef_matrix[response, "Estimate"])
			pvalue <- coef_matrix[response, "Pr(>|z|)"]
			} else {
			# 处理异常情况：如果变量不在模型中（例如，因为共线性被自动剔除）
			warning(paste("Variable", response, "was not found in the model coefficients. It might have been dropped due to collinearity or other issues."))
			or <- pvalue <- NA
			# AIC 仍然有效，因为模型拟合了
			}
			#将结果添加到数据框中
			MLRresults <- rbind(MLRresults, data.frame(
					VAR = response,
					AIC =aic,
					OR = or,
					Pvalue = pvalue
				  ))
				}
			#保存数据
				write.csv(MLRresults,"MLRresults_8H_H0607v2.csv")
#线性回归（COR）
	#非校正
		model <- lm(AMSS ~ SPO2, data = HAI1)
		summary(model)
		#循环函数
			#提取因变量列名
			#提取需要做的变量参数
				predictors <- colnames(HAI1)[c(5:8,10,12,13)]

			#创建一个空的数据框，用于存储结果
				results <- data.frame(
				  Response = character(),   # 因变量名称
				  P_Value = numeric(),      # 自变量（DAY）的 P 值
				  Adj_P_Value = numeric(),  # BH 校正后的 P 值
				  R_Squared = numeric(),    # 决定系数 R²
				  R = numeric(), #相关系数R
				  Intercept = numeric(),    # 截距
				  Slope = numeric(),        # 斜率
				  stringsAsFactors = FALSE
				)

			#遍历每个因变量，拟合线性模型并提取参数
				for (response in predictors) {
				  # 构建公式：因变量 ~ AMSS
				  formula <- as.formula(paste(response, "~ AMSS"))
				  #formula <- as.formula(paste(response, "~ AMSS + SEX+AGE+BMI"))
				  # 拟合线性模型
				  model <- lm(formula, data = HAI1)

				  # 提取模型摘要
				  summary_model <- summary(model)

				  # 提取关键参数
				  p_value <- summary_model$coefficients[2, 4]  # 自变量（DAY）的 P 值
				  Adj_P_Value = NA # 占位符，稍后填充
				  r_squared <- summary_model$r.squared          # 决定系数 R²
				  intercept <- summary_model$coefficients[1, 1] # 截距
				  slope <- summary_model$coefficients[2, 1]     # 斜率
				  r_value <- sign(slope) * sqrt(r_squared) #计算R，保留斜率符号
				  # 将结果添加到数据框中
				  results <- rbind(results, data.frame(
				    Response = response,
				    P_Value = p_value,
				    R_Squared = r_squared,
				    R = r_value,
				    Intercept = intercept,
				    Slope = slope
				  ))
				}
				print(results)
		#保存结果
			write.csv(results, "LiRresults_COR_H0607v2.csv", row.names = FALSE)
	#校正
		model <- lm(AMSS ~ SPO2 + SEX+AGE+BMI, data = HAI1)
		summary(model)
		#循环函数
			#提取因变量列名
			#提取需要做的变量参数
				predictors <- colnames(HAI1)[c(5:8,10,12,13)]

			#创建一个空的数据框，用于存储结果
				results <- data.frame(
				  Response = character(),   # 因变量名称
				  P_Value = numeric(),      # 自变量（DAY）的 P 值
				  Adj_P_Value = numeric(),  # BH 校正后的 P 值
				  R_Squared = numeric(),    # 决定系数 R²
				  R = numeric(), #相关系数R
				  Intercept = numeric(),    # 截距
				  Slope = numeric(),        # 斜率
				  stringsAsFactors = FALSE
				)

			#遍历每个因变量，拟合线性模型并提取参数
				for (response in predictors) {
				  # 构建公式：因变量 ~ AMSS+ SEX+AGE+BMI
				  formula <- as.formula(paste(response, "~ AMSS + SEX+AGE+BMI"))
				  # 拟合线性模型
				  model <- lm(formula, data = HAI1)

				  # 提取模型摘要
				  summary_model <- summary(model)

				  # 提取关键参数
				  p_value <- summary_model$coefficients[2, 4]  # 自变量（DAY）的 P 值
				  Adj_P_Value = NA # 占位符，稍后填充
				  r_squared <- summary_model$r.squared          # 决定系数 R²
				  intercept <- summary_model$coefficients[1, 1] # 截距
				  slope <- summary_model$coefficients[2, 1]     # 斜率
				  r_value <- sign(slope) * sqrt(r_squared) #计算R，保留斜率符号
				  # 将结果添加到数据框中
				  results <- rbind(results, data.frame(
				    Response = response,
				    P_Value = p_value,
				    R_Squared = r_squared,
				    R = r_value,
				    Intercept = intercept,
				    Slope = slope
				  ))
				}
				print(results)
		#保存结果
			write.csv(results, "MLiRresults_COR_H0607v2.csv", row.names = FALSE)
