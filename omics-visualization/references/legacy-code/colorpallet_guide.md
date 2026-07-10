```R
#使用RColorBrewer调色板，有固定的颜色主题使用
library(RColorBrewer)
# 查看所有调色板预览
display.brewer.all()
# 按类型查看
display.brewer.all(type = "seq")   # 连续型
display.brewer.all(type = "div")   # 发散型
display.brewer.all(type = "qual")  # 定性型
# 查看某个调色板（如 RdYlBu，取11色）
display.brewer.pal(n = 11, name = "RdYlBu")
```
