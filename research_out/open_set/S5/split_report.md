# 开放集划分报告 S5（leave-one-class-out）

- 留出类（unknown）：**Red Spider**
- 已知类别（6）：Black rot、Brown blight、Leaf rust、Tea Mosquito bug、Healthy、White spot
- 排除类别：disease（既不进 known 也不进 unknown）
- 数据根目录：`D:\tea-action\training\datasets\tea_leaf_disease`
- 验证集来源：`val` ｜ seed=42 ｜ mode=copy ｜ limit=0
- 生成时间：2026-11-25T21:12:24

## 1. 概况

| 集合 | 图像数 | 说明 |
| --- | ---: | --- |
| known/train | 6821 | 已彻底移除留出类图像 435 张 |
| known/val | 742 | 仅含已知类 |
| unknown/val | 605 | 含留出类图像，标签统一改写为 unknown |

- unknown 来源：--unknown-scope=all；分片明细 val 42 图/75 框、train 435 图/735 框、test 128 图/212 框
- unknown 去重跳过（同一图像出现在多个分片）：0 张

## 2. 每类实例数

| 类别号 | 类别 | known/train | known/val | unknown/val |
| ---: | --- | ---: | ---: | ---: |
| 0 | Black rot | 92 | 6 | 0 |
| 1 | Brown blight | 4 | 0 | 0 |
| 2 | Leaf rust | 2749 | 280 | 0 |
| 3 | Tea Mosquito bug | 5501 | 585 | 0 |
| 4 | Healthy | 299 | 57 | 0 |
| 5 | White spot | 240 | 39 | 0 |
| 0 | unknown | 0 | 0 | 1022 |

## 3. 规则校验

- ✅ 留出类不在 known/train
- ✅ known 类别号连续无空洞
- ✅ unknown 标签全为 0
- ✅ unknown 与 known 类别不相交

## 4. 统计与提示

- --limit 是否触发：train=False，known_val=False，unknown_val=False
- train 中因只含排除类（如 disease）被丢弃：4 张
- val 中因只含排除类被丢弃：0 张
- unknown 中同时含其他类别框的混合图：0 张（策略 exclude：已整图排除，不纳入 unknown 评估；实际排除 0 张）

## 5. calib / eval 拆分（阈值校准与指标上报隔离）

- --val-split=0.50：calib 371 图 / 488 实例；eval 371 图 / 479 实例
- 清单：`known/eval_split/calib.txt`、`known/eval_split/eval.txt`（每行一个相对 split 根目录的图像路径，如 `known/images/val/xxx.jpg`）
- `data_known.yaml` 的 `val:` 仍指向 `known/images/val`（训练期使用），不因拆分改变
- 评估协议：阈值校准、Mahalanobis 均值/协方差、原型统计只在 calib 上拟合；AUROC/AUPR/FPR@95TPR/AURC/E-AURC/coverage@risk/代价曲线/已知类 mAP 只在 eval 上计算

> 说明：unknown 目录的标签全部为 class 0，评估代码不区分未知病害的具体病种；known 标签的类别号已按去掉留出类与排除类后的顺序重映射，0..nc-1 连续。
