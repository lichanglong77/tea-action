$ErrorActionPreference = 'Continue'
Set-Location 'D:\tea-action'
$yolo = 'D:\tea-action\.venv\Scripts\yolo.exe'
$py   = 'D:\tea-action\.venv\Scripts\python.exe'
$logDir = 'D:\tea-action\research_out\logs'
function Log($m) { "$((Get-Date).ToString('HH:mm:ss'))  $m" | Tee-Object -FilePath "$logDir\seeds_progress.log" -Append }

$runs = @(
  @{n='B_n10_s43'; m='yolov8n.pt'; b=16},
  @{n='B_n10_s44'; m='yolov8n.pt'; b=16},
  @{n='B_s10_s43'; m='yolov8s.pt'; b=8},
  @{n='B_s10_s44'; m='yolov8s.pt'; b=8}
)
foreach($r in $runs){
  $seed = $r.n.Substring($r.n.Length-2)
  Log ("START " + $r.n)
  & $yolo detect train "model=$($r.m)" "data=training\datasets\tea_leaf_disease\data_norm.yaml" epochs=100 imgsz=640 "batch=$($r.b)" workers=4 device=0 "seed=$seed" deterministic=True close_mosaic=10 cache=disk "project=D:/tea-action/research_out/runs" "name=$($r.n)" exist_ok=True *>> "$logDir\run_$($r.n).log"
  Log ("END " + $r.n + " exit=$LASTEXITCODE")
}

$img = (Get-ChildItem 'training\datasets\tea_leaf_disease\tea_disease_dataset\valid\images' -File | Select-Object -First 1).FullName
Log 'START benchmark 6 rows'
& $py 'training\research\benchmark.py' --data 'training\datasets\tea_leaf_disease\data_norm.yaml' --models 'research_out\runs\B_n10_s42\weights\best.pt,research_out\runs\B_n10_s43\weights\best.pt,research_out\runs\B_n10_s44\weights\best.pt,research_out\runs\B_s10_s42\weights\best.pt,research_out\runs\B_s10_s43\weights\best.pt,research_out\runs\B_s10_s44\weights\best.pt' --out 'research_out' --latency-image $img *>> "$logDir\run_benchmark6.log"
Log ("END benchmark exit=$LASTEXITCODE")
Log 'ALL DONE'
