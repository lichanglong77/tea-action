import json, glob, os, statistics

rows = []
for f in sorted(glob.glob(r'D:\tea-action\research_out\eval\*\metrics.json')):
    d = json.load(open(f, encoding='utf-8'))
    name = os.path.basename(os.path.dirname(f))
    rows.append({
        'name': name,
        'auroc': {k: v['auroc'] for k, v in d['rq2'].items()},
        'fpr95': {k: v.get('fpr_at_95tpr') for k, v in d['rq2'].items()},
        'map50': d['known_map']['map50'],
        'misdiag': d['rq1']['closed_set_misdiagnosis_rate'],
        'protocol': d['protocol'],
        'primary': d['primary_scorer'],
    })

hdr = ['run', 'fusion', 'mahalanobis', 'entropy', 'msp', 'energy', 'proto', 'mAP50', '误诊率']
print(' | '.join(hdr))
for r in rows:
    a = r['auroc']
    print(' | '.join([r['name']] + [f'{a.get(k, float("nan")):.4f}' for k in ['fusion', 'mahalanobis', 'entropy', 'msp', 'energy', 'proto']] + [f'{r["map50"]:.4f}', f'{r["misdiag"]:.4f}']))

print()
for key in ['fusion', 'mahalanobis', 'entropy', 'msp', 'energy', 'proto']:
    for grp in ['S1', 'S5']:
        vals = [r['auroc'][key] for r in rows if r['name'].startswith(grp)]
        if vals:
            print(f'{key:12s} {grp}: mean={statistics.mean(vals):.4f} std={statistics.pstdev(vals):.4f} n={len(vals)}')

print()
d = json.load(open(r'D:\tea-action\research_out\eval\S1_s42\metrics.json', encoding='utf-8'))
print('protocol S1_s42:', d['protocol'])
print('primary_scorer:', d['primary_scorer'])
