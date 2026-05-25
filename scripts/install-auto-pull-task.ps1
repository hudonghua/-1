# install-auto-pull-task.ps1
#
# 把 auto-pull.ps1 注册成 Windows 任务计划程序：
#   - 登录时自动启动
#   - 每 1 分钟触发一次（脚本内部仍会用 -Once 跑一次）
#   - 静默后台运行，不弹窗
#
# 用法（请用管理员 PowerShell 运行）：
#   powershell -ExecutionPolicy Bypass -File .\scripts\install-auto-pull-task.ps1
#
# 卸载：
#   .\scripts\install-auto-pull-task.ps1 -Uninstall

[CmdletBinding()]
param(
    [string]$TaskName  = "CursorRepoAutoPull",
    [string]$RepoPath  = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)),
    [int]$IntervalMin  = 1,
    [switch]$Uninstall
)

function Test-Admin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Warning "建议使用『管理员 PowerShell』运行本脚本，否则可能注册失败。"
}

if ($Uninstall) {
    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
        Write-Host "已卸载任务: $TaskName"
    } catch {
        Write-Warning "卸载失败或任务不存在: $($_.Exception.Message)"
    }
    exit 0
}

$scriptPath = Join-Path $RepoPath "scripts\auto-pull.ps1"
if (-not (Test-Path $scriptPath)) {
    Write-Error "未找到 $scriptPath，请确认仓库路径是否正确：-RepoPath <path>"
    exit 1
}

$argument = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" -Once -RepoPath `"$RepoPath`""

$action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $argument

$trigLogon = New-ScheduledTaskTrigger -AtLogOn
$trigEvery = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMin) `
    -RepetitionDuration ([TimeSpan]::FromDays(3650))

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

try {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }
    Register-ScheduledTask `
        -TaskName  $TaskName `
        -Action    $action `
        -Trigger   @($trigLogon, $trigEvery) `
        -Settings  $settings `
        -Principal $principal `
        -Description "Auto git pull for Cursor cloud-agent workflow ($RepoPath)" | Out-Null

    Write-Host "已注册任务: $TaskName"
    Write-Host "  仓库路径 : $RepoPath"
    Write-Host "  触发频率 : 登录时 + 每 $IntervalMin 分钟"
    Write-Host "  日志文件 : $(Join-Path $RepoPath '.auto-pull.log')"
    Write-Host ""
    Write-Host "立即试跑一次："
    Write-Host "  powershell -ExecutionPolicy Bypass -File `"$scriptPath`" -Once"
} catch {
    Write-Error "注册任务失败: $($_.Exception.Message)"
    exit 1
}
