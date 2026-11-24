$ErrorActionPreference = 'Continue'
$yolo = 'D:\tea-action\.venv\Scripts\yolo.exe'
Set-Location 'D:\tea-action'
$logDir = 'D:\tea-action\research_out\logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$progress = Join-Path $logDir 'progress.txt'

$jobs = @(
    @{ s = 'S1'; seed = 42 },
    @{ s = 'S1'; seed = 43 },
    @{ s = 'S1'; seed = 44 },
    @{ s = 'S5'; seed = 42 },
    @{ s = 'S5'; seed = 43 },
    @{ s = 'S5'; seed = 44 }
)

foreach ($j in $jobs) {
    $name = "$($j.s)_s$($j.seed)"
    $log = Join-Path $logDir "$name.log"
    $data = "D:/tea-action/research_out/open_set/$($j.s)/data_known.yaml"
    Add-Content $progress "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] START $name (seed=$($j.seed), data=$data)"
    & $yolo detect train model=yolov8s.pt data="$data" epochs=100 imgsz=640 batch=16 workers=2 seed=$($j.seed) project=D:/tea-action/research_out/runs name=$name device=0 *> $log
    $code = $LASTEXITCODE
    Add-Content $progress "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] END $name exit=$code"
}

# SHA256 归档
$sha = 'D:\tea-action\research_out\weights_sha256.txt'
Get-ChildItem 'D:\tea-action\research_out\runs\*\weights\best.pt' |
    ForEach-Object { (Get-FileHash $_.FullName -Algorithm SHA256).Hash + '  ' + $_.FullName } |
    Set-Content $sha -Encoding utf8
Add-Content $progress "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ALL DONE, sha256 -> $sha"
