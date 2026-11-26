# 训练线 C：P2 小目标检测头消融（vs 闭集基线 A）

- 生成时间：2026-11-26
- 数据：`training/datasets/tea_leaf_disease/data_norm.yaml`（8 类，train 7260 / val 784）
- 前处理：640、batch 8、100 轮、seed 42、mosaic 后 15 轮关闭、`cache=disk`
- 权重：A = `research_out/runs/A_s42/weights/best.pt`；P2 = `research_out/runs/p2_s42/weights/best.pt`

## 1. 整体指标（val 784 图 / 1042 实例）

| 模型 | 参数量(M) | GFLOPs | P | R | mAP@0.5 | mAP@0.5:0.95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A（yolov8s 基线） | 11.14 | 28.6 | **0.974** | **0.956** | 0.971 | **0.735** |
| C（yolov8s-p2） | 10.64 | 36.9 (+29%) | 0.954 | 0.940 | **0.977** | 0.731 |
| 差值 | −0.50 | +29% | −2.0pp | −1.6pp | **+0.6pp** | −0.4pp |

## 2. 逐类对比（P / R / mAP50 / mAP50-95）

| 类别 | 实例数 | A | C(P2) | 变化 |
| --- | ---: | --- | --- | --- |
| Black rot of tea | 6 | .970/1.000/.995/.746 | .940/1.000/.995/.746 | mAP50-95 持平 |
| Leaf rust of tea | 280 | .936/.938/.968/.708 | .908/.968/.949/.687 | mAP50 −1.9pp |
| Red Spider infested tea leaf | 75 | .954/.920/.974/.761 | .913/.880/.974/**.779** | mAP50-95 **+1.8pp** |
| Tea Mosquito bug infested leaf | 585 | .989/.955/.971/.639 | .986/.949/.971/**.646** | mAP50-95 **+0.7pp** |
| Tea leaf | 57 | .997/1.000/.995/.825 | .988/1.000/.995/.800 | mAP50-95 −2.5pp |
| White spot of tea | 39 | .995/.923/**.925**/.732 | .988/.846/**.975**/.727 | mAP50 **+5.0pp** |

## 3. 结论（可直接写进简历/论文）

1. P2 头把 **mAP@0.5 提升 0.6pp（0.971 → 0.977）**，但 **mAP@0.5:0.95 反而降 0.4pp**，且 P/R 双降（−2.0 / −1.6pp），整体收益不显著。
2. 增益集中在**病斑面积小、目标密集**的类别：White spot `+5.0pp mAP50`、Red Spider `+1.8pp mAP50-95`、Tea Mosquito `+0.7pp mAP50-95`——与 P2 高分辨率特征图的预期一致。
3. 代价是 Leaf rust（中大型病斑、280 实例）下降 1.9pp，说明多出的计算量没有换来稳定收益。
4. **工程决策：产品权重继续用 A（yolov8s）**；P2 作为可选高精度配置，只在需要细小白斑/螨害检测时启用。
5. 一句话总结（简历可用）：*P2 小目标头在 640/100 轮同口径下 mAP50 +0.6pp，细小白斑类 +5.0pp，但整体 mAP50-95 −0.4pp，增益与 29% 计算量不匹配，故未上线。*

## 4. 产物位置

- 训练曲线/日志：`research_out/runs/p2_s42/`、`research_out/logs/runC_p2*.log`
- 验证输出：`research_out/val_ablation/{A,P2}/`，原始日志 `research_out/logs/val_ablation.log`
- 三模型闭集对比：`research_out/benchmark.csv` / `.md`
