# auto-pull.ps1
#
# 后台自动同步当前仓库：周期性 git fetch + git pull --ff-only。
# 用于实现 "云端 Agent push 后，本地无感同步" 的闭环。
#
# 用法：
#   1) 双击或在 PowerShell 中运行：
#        powershell -ExecutionPolicy Bypass -File .\scripts\auto-pull.ps1
#
#   2) 自定义参数：
#        .\scripts\auto-pull.ps1 -RepoPath "C:\path\to\repo" -IntervalSec 30
#
#   3) 一次性同步（不循环），适合放进任务计划程序按分钟触发：
#        .\scripts\auto-pull.ps1 -Once
#
# 注意：
#   - 默认只在干净工作区执行 pull（有未提交改动时会跳过，不会覆盖你本地改动）。
#   - 默认使用 --ff-only，遇到分叉不会自动 merge，留给你手动处理。

[CmdletBinding()]
param(
    # 仓库路径。默认取脚本所在目录的上一级（即仓库根）。
    [string]$RepoPath = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)),

    # 轮询间隔（秒）。
    [int]$IntervalSec = 30,

    # 只跑一次，跑完就退出（用于任务计划程序）。
    [switch]$Once,

    # 是否同时拉取所有远程分支信息（fetch --all）。
    [switch]$FetchAll,

    # 日志文件路径。默认写到仓库根的 .auto-pull.log。
    [string]$LogPath
)

if (-not (Test-Path $RepoPath)) {
    Write-Error "RepoPath does not exist: $RepoPath"
    exit 1
}

if (-not $LogPath) {
    $LogPath = Join-Path $RepoPath ".auto-pull.log"
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts][$Level] $Message"
    Write-Host $line
    try {
        Add-Content -Path $LogPath -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}
}

function Invoke-GitPullOnce {
    param([string]$Repo)

    Push-Location $Repo
    try {
        # 必须是 git 仓库
        $inside = (& git rev-parse --is-inside-work-tree 2>$null)
        if ($LASTEXITCODE -ne 0 -or $inside -ne "true") {
            Write-Log "Not a git repo: $Repo" "WARN"
            return
        }

        # 当前分支
        $branch = (& git rev-parse --abbrev-ref HEAD 2>$null).Trim()
        if (-not $branch -or $branch -eq "HEAD") {
            Write-Log "Detached HEAD or unknown branch, skip pull." "WARN"
            return
        }

        # 工作区是否干净
        $dirty = (& git status --porcelain)
        if ($dirty) {
            Write-Log "Working tree dirty on '$branch', skip pull (won't overwrite local changes)." "WARN"
            # 但仍然 fetch，让你能在 IDE 里看到远端动静
            & git fetch --prune origin 2>&1 | Out-Null
            return
        }

        # fetch
        if ($FetchAll) {
            & git fetch --all --prune 2>&1 | Out-Null
        } else {
            & git fetch --prune origin 2>&1 | Out-Null
        }

        # 当前分支是否有上游
        $upstream = (& git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null)
        if ($LASTEXITCODE -ne 0 -or -not $upstream) {
            Write-Log "Branch '$branch' has no upstream, fetch only." "INFO"
            return
        }

        # 比对本地与远端
        $local  = (& git rev-parse "@" 2>$null).Trim()
        $remote = (& git rev-parse "@{u}" 2>$null).Trim()
        $base   = (& git merge-base "@" "@{u}" 2>$null).Trim()

        if ($local -eq $remote) {
            # 已是最新
            return
        }
        if ($local -eq $base) {
            # 本地落后，可以快进
            $out = & git pull --ff-only 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Fast-forward pulled on '$branch'." "OK"
            } else {
                Write-Log "git pull --ff-only failed: $out" "ERR"
            }
        } elseif ($remote -eq $base) {
            Write-Log "Local '$branch' ahead of remote, nothing to pull." "INFO"
        } else {
            Write-Log "Branches diverged on '$branch'; manual merge/rebase needed." "WARN"
        }
    } finally {
        Pop-Location
    }
}

Write-Log "auto-pull started. repo=$RepoPath interval=${IntervalSec}s once=$Once fetchAll=$FetchAll log=$LogPath" "INFO"

if ($Once) {
    Invoke-GitPullOnce -Repo $RepoPath
    exit 0
}

while ($true) {
    try {
        Invoke-GitPullOnce -Repo $RepoPath
    } catch {
        Write-Log "Unhandled error: $($_.Exception.Message)" "ERR"
    }
    Start-Sleep -Seconds $IntervalSec
}
