# 统计显著性评估（bootstrap 95% CI + McNemar）

- data.yaml：`D:\tea-action\research_out\open_set\S1\data_known.yaml`
- 划分：val ｜ 图片数：587 ｜ GT 框数：762
- 推理设置：imgsz=640，conf=0.25，IoU=0.5，device=auto
- bootstrap：1000 次，seed=42，2.5%/97.5% 分位
- 生成时间：2026-11-25T21:53:04

## 1. 主指标与 95% 置信区间（micro，逐图聚合）

| 模型 | TP | FP | FN | Precision | Recall | F1 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| best.pt | 750 | 91 | 12 | 0.892 [0.869, 0.914] | 0.984 [0.976, 0.992] | 0.936 [0.922, 0.949] |

表注：方括号内为 95% bootstrap 置信区间；F1 由 micro P/R 计算。

## 4. 结论

> best.pt 在 val 上 F1=0.9357（95% CI 0.9221–0.9492）；置信区间宽度反映样本量，区间越窄结论越稳。
