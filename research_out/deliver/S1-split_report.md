# 开放集划分报告 S1（leave-one-class-out）

- 留出类（unknown）：**Leaf rust**
- 已知类别（6）：Black rot、Brown blight、Red Spider、Tea Mosquito bug、Healthy、White spot
- 排除类别：disease（既不进 known 也不进 unknown）
- 数据根目录：`D:\tea-action\training\datasets\tea_leaf_disease`
- 验证集来源：`val` ｜ seed=42 ｜ mode=copy ｜ limit=0
- 生成时间：2026-11-23T21:08:01

## 1. 概况

| 集合 | 图像数 | 说明 |
| --- | ---: | --- |
| known/train | 5274 | 已彻底移除留出类图像 1982 张 |
| known/val | 587 | 仅含已知类 |
| unknown/val | 197 | 含留出类图像，标签统一改写为 unknown |

## 2. 每类实例数

| 类别号 | 类别 | known/train | known/val | unknown/val |
| ---: | --- | ---: | ---: | ---: |
| 0 | Black rot | 88 | 6 | 0 |
| 1 | Brown blight | 4 | 0 | 0 |
| 2 | Red Spider | 735 | 75 | 0 |
| 3 | Tea Mosquito bug | 5501 | 585 | 0 |
| 4 | Healthy | 299 | 57 | 0 |
| 5 | White spot | 240 | 39 | 0 |
| 0 | unknown | 0 | 0 | 280 |

## 3. 规则校验

- ✅ 留出类不在 known/train
- ✅ known 类别号连续无空洞
- ✅ unknown 标签全为 0

## 4. 统计与提示

- --limit 是否触发：train=False，known_val=False，unknown_val=False
- train 中因只含排除类（如 disease）被丢弃：4 张
- val 中因只含排除类被丢弃：0 张
- unknown 中同时含已知类框的图像：0 张（这些框按规则一并改写为 unknown，解读 unknown 召回时需注意）

> 说明：unknown 目录的标签全部为 class 0，评估代码不区分未知病害的具体病种；known 标签的类别号已按去掉留出类与排除类后的顺序重映射，0..nc-1 连续。
