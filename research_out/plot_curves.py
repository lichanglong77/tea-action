import csv, glob, os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

runs_dir = r"D:\tea-action\research_out\runs"
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))
plots = [("metrics/mAP50(B)", "mAP50", axes[0]), ("metrics/mAP50-95(B)", "mAP50-95", axes[1])]
colors = {"S1_s42": "#1f77b4", "S1_s43": "#4fa3d1", "S1_s44": "#8ec3e8", "S5_s42": "#d62728", "S5_s43": "#e8736f", "S5_s44": "#f2a6a3"}
for key, label, ax in plots:
    for csv_path in sorted(glob.glob(os.path.join(runs_dir, "*", "results.csv"))):
        name = os.path.basename(os.path.dirname(csv_path))
        xs, ys = [], []
        with open(csv_path, encoding="utf-8") as f:
            for i, row in enumerate(csv.DictReader(f), 1):
                k = key
                if k not in row:
                    k = [c for c in row if c.strip() == key][0]
                v = row[k]
                if v and v.strip():
                    xs.append(i)
                    ys.append(float(v))
        if xs:
            ax.plot(xs, ys, linewidth=1.4, color=colors.get(name, None), label=f"{name} ({ys[-1]:.3f})")
    ax.set_title(label, fontsize=12)
    ax.set_xlabel("epoch")
    ax.grid(alpha=0.3)
    ax.set_xlim(0, 100)
    ax.legend(fontsize=8, loc="lower right")

fig.suptitle("Open-set training curves (known 6 classes, S1 hold Leaf rust / S5 hold Red Spider)", fontsize=12)
fig.tight_layout()
out = r"D:\tea-action\research_out\training_curves.png"
fig.savefig(out, dpi=130)
print("saved", out)
