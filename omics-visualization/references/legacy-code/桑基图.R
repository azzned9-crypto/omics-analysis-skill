
if (!require("networkD3")) install.packages("networkD3")
library(networkD3)

# 定义节点（按顺序ABCD）
nodes <- data.frame(name = c("2023A", "2023B", "2024A", "2024B"))

node_weights <- c(
  "2023A" = 83,  # A的初始样本量
  "2023B" = 662,   # B的初始样本量
  "2024A" = 475,   # C的初始样本量
  "2024B" = 520    # D的初始样本量
)



#创建连接数据（按顺序连接）
links <- data.frame(
  source = c(0, 1, 2),    # 源节点索引（从0开始）
  target = c(1, 2, 3),    # 目标节点索引
  value = c(43, 188, 278)     # 流量值（可自定义）
)



#使用在线网页
	https://app.flourish.studio/projects
