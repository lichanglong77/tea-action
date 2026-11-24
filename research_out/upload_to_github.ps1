$ErrorActionPreference = 'Continue'
$git = 'C:\Program Files\Git\cmd\git.exe'
$repo = 'lichanglong77/tea-action'
$tag = 'v1.1-open-set'
$root = 'D:\tea-action'
Set-Location $root
$progress = 'D:\tea-action\research_out\logs\upload.txt'
function Log($m) { Add-Content $progress "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $m" }

# ---------- 1. 汇总交付目录 ----------
$stage = Join-Path $root 'research_out\deliver'
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

foreach ($n in 'S1_s42','S1_s43','S1_s44','S5_s42','S5_s43','S5_s44') {
    $runDir = Join-Path $root "research_out\runs\$n"
    if (Test-Path (Join-Path $runDir 'weights\best.pt')) {
        Copy-Item (Join-Path $runDir 'weights\best.pt') (Join-Path $stage "$n-best.pt") -Force
        Copy-Item (Join-Path $runDir 'results.csv') (Join-Path $stage "$n-results.csv") -Force
        Copy-Item (Join-Path $runDir 'args.yaml') (Join-Path $stage "$n-args.yaml") -Force
        $last = (Import-Csv (Join-Path $runDir 'results.csv') | Select-Object -Last 1)
        $rows = (Get-Content (Join-Path $runDir 'results.csv')).Count
        Log "OK $n epochs_rows=$rows mAP50=$($last.'metrics/mAP50(B)') mAP50-95=$($last.'metrics/mAP50-95(B)')"
    } else {
        Log "MISSING $n best.pt"
    }
}

# 环境信息
$envTxt = Join-Path $stage 'env.txt'
$py = 'D:\tea-action\.venv\Scripts\python.exe'
(& $py -V) 2>&1 | Set-Content $envTxt -Encoding utf8
& $py -c "import torch,ultralytics;print('torch',torch.__version__,'cuda',torch.cuda.is_available(),torch.cuda.get_device_name(0) if torch.cuda.is_available() else '')" 2>&1 | Add-Content $envTxt -Encoding utf8
& $py -c "import ultralytics;print('ultralytics',ultralytics.__version__)" 2>&1 | Add-Content $envTxt -Encoding utf8

Copy-Item 'D:\tea-action\research_out\open_set\S1\split_report.md' (Join-Path $stage 'S1-split_report.md') -Force
Copy-Item 'D:\tea-action\research_out\open_set\S5\split_report.md' (Join-Path $stage 'S5-split_report.md') -Force
if (Test-Path 'D:\tea-action\research_out\weights_sha256.txt') {
    Copy-Item 'D:\tea-action\research_out\weights_sha256.txt' $stage -Force
}

# 汇总表
$md = Join-Path $stage 'README-交付说明.md'
$lines = @('# 开放集拒识实验 交付物', '', "生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm')", '',
  '| 运行 | 保留轮次 | mAP50 | mAP50-95 |', '|---|---|---|---|')
foreach ($csv in Get-ChildItem $stage -Filter '*-results.csv') {
    $name = $csv.Name -replace '-results.csv',''
    $rows = Get-Content $csv.FullName
    $last = (Import-Csv $csv.FullName | Select-Object -Last 1)
    $lines += "| $name | $($rows.Count - 1) | $($last.'metrics/mAP50(B)') | $($last.'metrics/mAP50-95(B)') |"
}
$lines += '', '## 未参与上传的内容', '- `research_out\open_set\` 划分副本（本地保留，可用 make_open_set_split.py 复现）', '- 原始数据集（figshare 下载，本地保留）'
Set-Content $md -Value $lines -Encoding utf8; Log "staged $((Get-ChildItem $stage).Count) files"

# ---------- 2. 提交代码与报告 ----------
# 排除大权重，只提交报告/指标/配置
$exclude = 'D:\tea-action\.git\info\exclude'
$mark = '# --- research_out exclude ---'
$block = @($mark, 'research_out/runs/', 'research_out/open_set/', 'research_out/logs/', 'research_out/smoke_train.log', 'yolov8s.pt', '*.part')
$cur = if (Test-Path $exclude) { Get-Content $exclude -Raw } else { '' }
if ($cur -notmatch [regex]::Escape($mark)) { ($block -join "`n") | Add-Content $exclude }

& $git checkout -- data/models/bandit.joblib 2>&1 | Out-Null
$br = 'research/open-set-s1-s5'
& $git checkout -B $br 2>&1 | Log 'branch'
& $git add research_out 2>&1 | Log 'add'
& $git -c user.name=lichanglong77 -c user.email=lichanglong77@users.noreply.github.com commit -m "research: 开放集 S1/S5 划分与 6 次 YOLOv8s 训练产物（不含权重，权重见 Release $tag）" 2>&1 | ForEach-Object { Log $_ }
Log 'commit done'

# ---------- 3. 推送 ----------
& $git push -f -u origin $br 2>&1 | ForEach-Object { Log $_ }
Log "push exit=$LASTEXITCODE"

# ---------- 4. Release 上传 ----------
$cred = ("protocol=https`nhost=github.com`n`n") | & $git credential fill 2>$null
$token = ($cred | Select-String -Pattern '^password=').Line -replace 'password=',''
if (-not $token) { Log 'NO TOKEN, release skipped'; exit 1 }
$h = @{ Authorization = "token $token"; 'User-Agent' = 'tea-action-agent' }

$body = @{
    tag_name = $tag; name = "开放集拒识实验 $tag"; target_commitish = $br; draft = $false; prerelease = $true
    body = "6 个 YOLOv8s 开放集权重（S1 留出 Leaf rust / S5 留出 Red Spider，各 seed 42/43/44，epochs=100, imgsz=640）。详见 README-交付说明.md 与 weights_sha256.txt。"
} | ConvertTo-Json
try {
    $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases" -Method Post -Headers $h -Body $body -ContentType 'application/json'
    Log "release created id=$($rel.id) url=$($rel.html_url)"
} catch { Log "release create failed: $($_.Exception.Message)"; exit 1 }

foreach ($f in Get-ChildItem $stage -File | Where-Object { $_.Name -notlike 'README-交付说明.md' }) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $url = "https://uploads.github.com/repos/$repo/releases/$($rel.id)/assets?name=$([uri]::EscapeDataString($f.Name))"
    try {
        $r = Invoke-RestMethod -Uri $url -Method Post -Headers $h -Body $bytes -ContentType 'application/octet-stream' -TimeoutSec 1800
        Log "uploaded $($f.Name) state=$($r.state) size=$($r.size)"
    } catch { Log "upload FAILED $($f.Name): $($_.Exception.Message)" }
}
Log 'ALL UPLOAD DONE'
