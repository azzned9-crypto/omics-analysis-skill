# 模拟临床数据字典

`assets/mock-clinical-data.csv` 包含 100 名虚拟受试者。全部数据仅用于测试作图流程，不可用于医学推断。

| 字段 | 含义 | 单位 |
|---|---|---|
| ID | 人员 ID | - |
| Sex | 性别 | Female/Male |
| Age | 年龄 | years |
| BMI | 体质指数 | kg/m2 |
| WBC | 白细胞计数 | 10^9/L |
| RBC | 红细胞计数 | 10^12/L |
| HGB | 血红蛋白 | g/L |
| HCT | 红细胞压积 | % |
| PLT | 血小板计数 | 10^9/L |
| NEUT | 中性粒细胞比例 | % |
| LYMPH | 淋巴细胞比例 | % |
| ALT | 丙氨酸氨基转移酶 | U/L |
| AST | 天门冬氨酸氨基转移酶 | U/L |
| ALP | 碱性磷酸酶 | U/L |
| GGT | γ-谷氨酰转移酶 | U/L |
| TBIL | 总胆红素 | umol/L |
| ALB | 白蛋白 | g/L |
| TP | 总蛋白 | g/L |
| GLU | 空腹血糖 | mmol/L |
| TC | 总胆固醇 | mmol/L |
| TG | 甘油三酯 | mmol/L |
| HDL | 高密度脂蛋白胆固醇 | mmol/L |
| LDL | 低密度脂蛋白胆固醇 | mmol/L |
| CREA | 肌酐 | umol/L |
| UREA | 尿素 | mmol/L |
| UA | 尿酸 | umol/L |
| CRP | C 反应蛋白 | mg/L |

建议首轮测试：

- Age counts 柱状图：测试有序递进的 `viridis` 配色。
- 23 项血液指标相关热图：测试连续色阶和变量标签。
- Age、BMI、GLU 散点图：测试连续颜色映射。
- Sex 分组箱线图：测试分类配色。
- 血液指标 Z-score 热图：测试以 0 为中心的发散色阶例外。
