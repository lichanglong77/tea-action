# FP / FN 误差分析

- 模型：`research_out/runs/S1_s43/weights/best.pt`
- data.yaml：`research_out/open_set/S1/data_known.yaml` ｜ split=val
- 推理设置：imgsz=640，conf=0.25，IoU=0.5，device=auto
- 图片数：587 ｜ GT 框：762 ｜ 预测框：817
- 导出裁剪图：FP 60 张、FN 12 张（每种类型上限 60）
- 生成时间：2026-11-25T21:56:09 ｜ 耗时 19.8s

总计：**FP 67 个，FN 12 个**（明细见 `errors.csv`，裁剪图见 `fp/`、`fn/`）。

## 1. 按类别统计

| 类别 | FP（误报） | FN（漏检） |
| --- | ---: | ---: |
| 2 Red Spider | 21 | 0 |
| 3 Tea Mosquito bug | 46 | 12 |

## 2. 按目标尺寸（COCO 口径）

| 尺寸 | 判定条件 | FP | FN |
| --- | --- | ---: | ---: |
| small | area < 32² | 0 | 0 |
| medium | 32² ≤ area < 96² | 9 | 0 |
| large | area ≥ 96² | 58 | 12 |

## 3. 按置信度分箱

| 置信度 | FP | FN |
| --- | ---: | ---: |
| 0.25-0.40 | 30 | 0 |
| 0.40-0.60 | 15 | 0 |
| 0.60+ | 22 | 6 |
| 无重叠预测 | 0 | 6 |

表注：FN 的置信度为“与该漏检真值重叠最多的预测框”的置信度；若完全没有重叠预测则记为“无重叠预测”，说明该目标被彻底漏掉。

## 4. 误报来源（FP 压在了哪个类别的真值上）

| 预测类别 | 实际（真值）类别 | 次数 |
| --- | --- | ---: |
| Tea Mosquito bug | Tea Mosquito bug | 4 |
| Red Spider | Red Spider | 3 |
| Tea Mosquito bug | White spot | 3 |

最容易被误判成：**Tea Mosquito bug** 被预测为 **Tea Mosquito bug**（共 4 次，IoU > 0.1 的跨类重叠）。

## 5. 结论

> 共 67 个误报、12 个漏检；小目标漏检 0 个，漏检未集中在单一尺寸区间。
