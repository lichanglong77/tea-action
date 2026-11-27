$ErrorActionPreference = 'Continue'
Set-Location 'D:\tea-action'
$yolo = 'D:\tea-action\.venv\Scripts\yolo.exe'
$py   = 'D:\tea-action\.venv\Scripts\python.exe'
$logDir = 'D:\tea-action\research_out\logs'
function Log($m) { "$((Get-Date).ToString('HH:mm:ss'))  $m" | Tee-Object -FilePath "$logDir\baseline_cm10_progress.log" -Append }

Log 'START B_n10_s42 (yolov8n, batch16, close_mosaic=10)'
& $yolo detect train "model=yolov8n.pt" "data=training\datasets\tea_leaf_disease\data_norm.yaml" epochs=100 imgsz=640 batch=16 workers=4 device=0 seed=42 deterministic=True close_mosaic=10 cache=disk "project=D:/tea-action/research_out/runs" name=B_n10_s42 exist_ok=True *>> "$logDir\runB_n10.log"
Log ("END B_n10_s42 exit=$LASTEXITCODE")

Log 'START B_s10_s42 (yolov8s, batch8, close_mosaic=10)'
& $yolo detect train "model=yolov8s.pt" "data=training\datasets\tea_leaf_disease\data_norm.yaml" epochs=100 imgsz=640 batch=8 workers=4 device=0 seed=42 deterministic=True close_mosaic=10 cache=disk "project=D:/tea-action/research_out/runs" name=B_s10_s42 exist_ok=True *>> "$logDir\runB_s10.log"
Log ("END B_s10_s42 exit=$LASTEXITCODE")

$img = (Get-ChildItem 'training\datasets\tea_leaf_disease\tea_disease_dataset\valid\images' -File | Select-Object -First 1).FullName
Log 'START benchmark 4 models (cm10 baselines)'
& $py 'training\research\benchmark.py' --data 'training\datasets\tea_leaf_disease\data_norm.yaml' --models 'research_out\runs\B_n10_s42\weights\best.pt,research_out\runs\B_s10_s42\weights\best.pt,research_out\runs\A_s42\weights\best.pt,research_out\runs\p2_s42\weights\best.pt' --out 'research_out' --latency-image $img *>> "$logDir\runB_benchmark4_cm10.log"
Log ("END benchmark exit=$LASTEXITCODE")

Log 'ALL DONE'
