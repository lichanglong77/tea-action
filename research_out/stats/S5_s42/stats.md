# 统计显著性评估（bootstrap 95% CI + McNemar）

- data.yaml：`D:\tea-action\research_out\open_set\S5\data_known.yaml`
- 划分：val ｜ 图片数：742 ｜ GT 框数：967
- 推理设置：imgsz=640，conf=0.25，IoU=0.5，device=auto
- bootstrap：1000 次，seed=42，2.5%/97.5% 分位
- 生成时间：2026-11-25T21:55:18

## 1. 主指标与 95% 置信区间（micro，逐图聚合）

| 模型 | TP | FP | FN | Precision | Recall | F1 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| best.pt | 940 | 162 | 27 | 0.853 [0.830, 0.876] | 0.972 [0.960, 0.983] | 0.909 [0.893, 0.923] |

表注：方括号内为 95% bootstrap 置信区间；F1 由 micro P/R 计算。

## 4. 结论

> best.pt 在 val 上 F1=0.9087（95% CI 0.8926–0.9235）；置信区间宽度反映样本量，区间越窄结论越稳。
