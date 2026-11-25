# 统计显著性评估（bootstrap 95% CI + McNemar）

- data.yaml：`D:\tea-action\research_out\open_set\S5\data_known.yaml`
- 划分：val ｜ 图片数：742 ｜ GT 框数：967
- 推理设置：imgsz=640，conf=0.25，IoU=0.5，device=auto
- bootstrap：1000 次，seed=42，2.5%/97.5% 分位
- 生成时间：2026-11-25T21:56:06

## 1. 主指标与 95% 置信区间（micro，逐图聚合）

| 模型 | TP | FP | FN | Precision | Recall | F1 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| best.pt | 940 | 148 | 27 | 0.864 [0.840, 0.889] | 0.972 [0.961, 0.983] | 0.915 [0.899, 0.930] |

表注：方括号内为 95% bootstrap 置信区间；F1 由 micro P/R 计算。

## 4. 结论

> best.pt 在 val 上 F1=0.9148（95% CI 0.8993–0.9304）；置信区间宽度反映样本量，区间越窄结论越稳。
