# 统计显著性评估（bootstrap 95% CI + McNemar）

- data.yaml：`D:\tea-action\research_out\open_set\S1\data_known.yaml`
- 划分：val ｜ 图片数：587 ｜ GT 框数：762
- 推理设置：imgsz=640，conf=0.25，IoU=0.5，device=auto
- bootstrap：1000 次，seed=42，2.5%/97.5% 分位
- 生成时间：2026-11-25T21:53:48

## 1. 主指标与 95% 置信区间（micro，逐图聚合）

| 模型 | TP | FP | FN | Precision | Recall | F1 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| best.pt | 750 | 67 | 12 | 0.918 [0.900, 0.936] | 0.984 [0.973, 0.995] | 0.950 [0.939, 0.961] |

表注：方括号内为 95% bootstrap 置信区间；F1 由 micro P/R 计算。

## 4. 结论

> best.pt 在 val 上 F1=0.9500（95% CI 0.9390–0.9606）；置信区间宽度反映样本量，区间越窄结论越稳。
