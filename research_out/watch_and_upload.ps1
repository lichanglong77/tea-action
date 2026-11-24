$progress = 'D:\tea-action\research_out\logs\progress.txt'
while ($true) {
    if ((Test-Path $progress) -and (Get-Content $progress -Raw) -match 'ALL DONE') { break }
    Start-Sleep -Seconds 300
}
Add-Content $progress "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] watcher: 训练全部结束，开始上传 GitHub"
& pwsh -NoProfile -ExecutionPolicy Bypass -File 'D:\tea-action\research_out\upload_to_github.ps1'
