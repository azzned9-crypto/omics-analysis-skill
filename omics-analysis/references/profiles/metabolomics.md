# 代谢组 Profile

本 profile 用于 metabolite intensity matrix。

## 常见矩阵状态

- 常常已经做过标准化和转换
- 特征注释有时不完整

## 常见差异分析默认值

- 统计方法：根据设计选择 `limma` 或非参数检验
- 显著性阈值：`p < 0.05`，或在多重检验稳定时使用校正阈值
- fold-change 阈值：按平台和项目确认
- 某些项目会加入 `VIP` 等 OPLS-DA 指标，但除非用户明确要求，否则不能把它当成唯一证据

## 常见风险

- 特征注释不稳定
- 富集分析时混用不同 compound ID
- 在没有结合平台方差的情况下过度解释小 fold change

