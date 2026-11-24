Clear-Host
while ($true) {
    Clear-Host
    Write-Host "===== 开放集拒识训练 看板 =====" -ForegroundColor Cyan
    Write-Host ("时间: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
    Write-Host ""
    Write-Host ("{0,-10} {1,10} {2,12} {3,12}" -f '运行', '轮次', 'mAP50', 'mAP50-95') -ForegroundColor Yellow
    Write-Host ("-" * 48)
    Get-ChildItem 'D:\tea-action\research_out\runs' -Directory | ForEach-Object {
        $c = Join-Path $_.FullName 'results.csv'
        if (Test-Path $c) {
            $rows = Get-Content $c
            $last = ($rows[-1] -split ',')
            $done = ($rows.Count - 1)
            $color = if ($done -ge 100) { 'Green' } else { 'White' }
            Write-Host ("{0,-10} {1,10} {2,12} {3,12}" -f $_.Name, "$done/100", $last[7], $last[8]) -ForegroundColor $color
        }
    }
    Write-Host ""
    Write-Host "===== 当前日志 =====" -ForegroundColor Cyan
    $latest = Get-ChildItem 'D:\tea-action\research_out\logs\*.log' | Where-Object { $_.Name -ne 'progress.txt' -and $_.Name -ne 'upload.txt' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) {
        Write-Host ("日志: " + $latest.Name) -ForegroundColor Gray
        Get-Content $latest.FullName -Tail 3 | Where-Object { $_ -notmatch 'it/s' } | Write-Host
    }
    Write-Host ""
    Write-Host "30 秒后刷新，关窗口不影响训练。" -ForegroundColor DarkGray
    Start-Sleep -Seconds 30
}
