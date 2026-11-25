# FP / FN 误差分析

- 模型：`research_out/runs/S5_s43/weights/best.pt`
- data.yaml：`research_out/open_set/S5/data_known.yaml` ｜ split=val
- 推理设置：imgsz=640，conf=0.25，IoU=0.5，device=auto
- 图片数：742 ｜ GT 框：967 ｜ 预测框：1088
- 导出裁剪图：FP 60 张、FN 27 张（每种类型上限 60）
- 生成时间：2026-11-25T21:57:20 ｜ 耗时 24.3s

总计：**FP 148 个，FN 27 个**（明细见 `errors.csv`，裁剪图见 `fp/`、`fn/`）。

## 1. 按类别统计

| 类别 | FP（误报） | FN（漏检） |
| --- | ---: | ---: |
| 2 Leaf rust | 81 | 6 |
| 3 Tea Mosquito bug | 58 | 15 |
| 4 Healthy | 6 | 0 |
| 5 White spot | 3 | 6 |

## 2. 按目标尺寸（COCO 口径）

| 尺寸 | 判定条件 | FP | FN |
| --- | --- | ---: | ---: |
| small | area < 32² | 0 | 0 |
| medium | 32² ≤ area < 96² | 24 | 0 |
| large | area ≥ 96² | 124 | 27 |

## 3. 按置信度分箱

| 置信度 | FP | FN |
| --- | ---: | ---: |
| 0.25-0.40 | 39 | 0 |
| 0.40-0.60 | 36 | 0 |
| 0.60+ | 73 | 18 |
| 无重叠预测 | 0 | 9 |

表注：FN 的置信度为“与该漏检真值重叠最多的预测框”的置信度；若完全没有重叠预测则记为“无重叠预测”，说明该目标被彻底漏掉。

## 4. 误报来源（FP 压在了哪个类别的真值上）

| 预测类别 | 实际（真值）类别 | 次数 |
| --- | --- | ---: |
| Tea Mosquito bug | Tea Mosquito bug | 13 |
| Leaf rust | White spot | 6 |
| Leaf rust | Leaf rust | 3 |
| Leaf rust | Tea Mosquito bug | 3 |

最容易被误判成：**Tea Mosquito bug** 被预测为 **Tea Mosquito bug**（共 13 次，IoU > 0.1 的跨类重叠）。

## 5. 结论

> 共 148 个误报、27 个漏检；小目标漏检 0 个，漏检未集中在单一尺寸区间。
