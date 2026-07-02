# 模块关系图

## 主次关系

主体：

- `omics-downstream-analysis`

模块：

- `omics-qc-process`
- `omics-differential-analysis`
- `omics-enrichment-analysis`
- `omics-time-series-analysis`
- `omics-network-analysis`
- `omics-visualization`

## 关系说明

主体不是重复做模块的事，而是做以下三件事：

1. 判断现在该调用哪个模块。
2. 在调用模块前补齐必问项。
3. 在模块完成后统一审计和收口。

## 调用顺序示例

### 例 1：普通蛋白组差异分析

`omics-downstream-analysis`

-> `omics-qc-process`

-> `omics-differential-analysis`

-> `omics-visualization`

### 例 2：差异分析后做富集

`omics-downstream-analysis`

-> `omics-differential-analysis`

-> `omics-enrichment-analysis`

-> `omics-visualization`

### 例 3：WGCNA

`omics-downstream-analysis`

-> `omics-qc-process`

-> `omics-network-analysis`

-> `omics-visualization`

## 何时可直接调用模块

仅当以下信息已经非常明确时，才适合直接调用模块：

- assay 类型
- matrix 状态
- contrast 或 trait
- 阈值策略
- 输入对象

否则优先回到主体。

