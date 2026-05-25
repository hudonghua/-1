# install-skills-locally.ps1
#
# 把本仓库 docs/skills/ 与 docs/memory/ 内的 SKILL.md / 记忆文件，
# 安装到本地所有 Agent 的全局目录里：
#
#   - Codex CLI         : %USERPROFILE%\.codex\skills
#   - Claude Code       : %USERPROFILE%\.claude\skills
#   - Cursor 本地 Agent : %USERPROFILE%\.cursor\skills-cursor
#
# memory 文件会被同步到：
#   - Codex             : %USERPROFILE%\.codex\memory
#   - Claude Code       : %USERPROFILE%\.claude\projects\C--Users-<user>\memory
#   - Cursor            : %USERPROFILE%\.cursor\memory
#
# 设计原则（参考 skill: multi-computer-toolkit-merge）：
#   - 默认非破坏性合并：源没有的文件不动；目标已存在且不同 → 默认保留为
#     "<filename>.incoming-YYYYMMDD-HHMMSS.<ext>"，并写入 merge-report。
#   - 默认 DryRun 模式预览，加 -Apply 才真正写入。
#   - 用 -Force 才会覆盖已存在的同名文件（仍写 incoming 备份）。
#   - 永不删除本地文件；仅在缺失或显式 -Force 时写入。
#   - 合并完成后输出报告，附 added / updated / kept-local / incoming / skipped 列表。
#
# 用法：
#   # 1. 先预览（不动磁盘）
#   powershell -ExecutionPolicy Bypass -File .\scripts\install-skills-locally.ps1
#
#   # 2. 确认后真正安装
#   powershell -ExecutionPolicy Bypass -File .\scripts\install-skills-locally.ps1 -Apply
#
#   # 3. 只装某些目标
#   .\scripts\install-skills-locally.ps1 -Apply -Targets Codex,Claude
#
#   # 4. 用 -Force 覆盖同名（仍会保存 incoming 备份）
#   .\scripts\install-skills-locally.ps1 -Apply -Force

[CmdletBinding()]
param(
    # 仓库根目录。默认取脚本所在目录的上一级。
    [string]$RepoPath = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)),

    # 要安装到的目标集合。
    [ValidateSet('Codex','Claude','CursorGlobal','All')]
    [string[]]$Targets = @('All'),

    # 真正写入（默认仅 DryRun 预览）。
    [switch]$Apply,

    # 同名且内容不同时覆盖目标文件（仍写 incoming 备份）。
    [switch]$Force,

    # 跳过 memory 同步（只装 skills）。
    [switch]$SkipMemory,

    # 报告输出目录（相对 RepoPath）。
    [string]$ReportDir = "merge-reports"
)

$ErrorActionPreference = "Stop"
$ts = Get-Date -Format "yyyyMMdd-HHmmss"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "RepoPath does not exist: $RepoPath"
}

$SkillsSrc = Join-Path $RepoPath "docs\skills"
$MemorySrc = Join-Path $RepoPath "docs\memory"

if (-not (Test-Path -LiteralPath $SkillsSrc)) {
    throw "Skills source not found: $SkillsSrc"
}

$UserName  = Split-Path $env:USERPROFILE -Leaf
$ClaudeProjectDir = "C--Users-$UserName"

# 目标定义
$AllTargets = @(
    @{
        Name        = 'Codex'
        SkillsDest  = Join-Path $env:USERPROFILE ".codex\skills"
        MemoryDest  = Join-Path $env:USERPROFILE ".codex\memory"
    },
    @{
        Name        = 'Claude'
        SkillsDest  = Join-Path $env:USERPROFILE ".claude\skills"
        MemoryDest  = Join-Path $env:USERPROFILE ".claude\projects\$ClaudeProjectDir\memory"
    },
    @{
        Name        = 'CursorGlobal'
        SkillsDest  = Join-Path $env:USERPROFILE ".cursor\skills-cursor"
        MemoryDest  = Join-Path $env:USERPROFILE ".cursor\memory"
    }
)

$Selected = if ($Targets -contains 'All') { $AllTargets } else { $AllTargets | Where-Object { $Targets -contains $_.Name } }

if (-not $Selected -or $Selected.Count -eq 0) {
    throw "No valid targets selected. Use -Targets Codex|Claude|CursorGlobal or All."
}

# 报告积累器
$Report = [System.Collections.Generic.List[object]]::new()

function Get-FileHashHex {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Sync-OneFile {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$TargetName,
        [string]$Category  # 'skill' | 'memory'
    )

    $relSource = $Source.Substring($RepoPath.Length).TrimStart('\','/')
    $action = $null
    $detail = $null

    $destDir = Split-Path -Parent $Destination
    $destExists = Test-Path -LiteralPath $Destination

    if (-not $destExists) {
        $action = 'added'
        if ($Apply) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            Copy-Item -LiteralPath $Source -Destination $Destination -Force
        }
    }
    else {
        $srcHash  = Get-FileHashHex $Source
        $dstHash  = Get-FileHashHex $Destination
        if ($srcHash -eq $dstHash) {
            $action = 'unchanged'
        }
        else {
            $incomingPath = [System.IO.Path]::ChangeExtension(
                $Destination,
                ("incoming-$ts" + [System.IO.Path]::GetExtension($Destination))
            )
            if ($Force) {
                $action = 'updated'
                $detail = "incoming backup: $incomingPath"
                if ($Apply) {
                    Copy-Item -LiteralPath $Destination -Destination $incomingPath -Force
                    Copy-Item -LiteralPath $Source -Destination $Destination -Force
                }
            }
            else {
                $action = 'kept-local'
                $detail = "incoming saved at: $incomingPath"
                if ($Apply) {
                    Copy-Item -LiteralPath $Source -Destination $incomingPath -Force
                }
            }
        }
    }

    $Report.Add([pscustomobject]@{
        Target      = $TargetName
        Category    = $Category
        Source      = $relSource
        Destination = $Destination
        Action      = $action
        Detail      = $detail
    }) | Out-Null
}

Write-Host ""
Write-Host "==== install-skills-locally.ps1 ====" -ForegroundColor Cyan
Write-Host "Repo       : $RepoPath"
Write-Host "Mode       : $([string]::Empty)$(if ($Apply) {'APPLY (writing to disk)'} else {'DRY-RUN (preview only)'})" -ForegroundColor $(if ($Apply){'Yellow'}else{'Green'})
Write-Host "Targets    : $((($Selected | ForEach-Object { $_.Name }) -join ', '))"
Write-Host "Force      : $Force"
Write-Host "SkipMemory : $SkipMemory"
Write-Host ""

foreach ($t in $Selected) {
    Write-Host "[$($t.Name)]" -ForegroundColor Cyan
    Write-Host "  Skills  -> $($t.SkillsDest)"
    if (-not $SkipMemory) {
        Write-Host "  Memory  -> $($t.MemoryDest)"
    }

    # --- skills ---
    $skillFiles = Get-ChildItem -LiteralPath $SkillsSrc -Recurse -File -Filter "*.md"
    foreach ($f in $skillFiles) {
        # README.md 不算 skill 本体，留在原地，不同步
        if ($f.Name -ieq 'README.md' -and $f.Directory.FullName -eq $SkillsSrc) { continue }

        $relUnderSkills = $f.FullName.Substring($SkillsSrc.Length).TrimStart('\','/')
        $dest = Join-Path $t.SkillsDest $relUnderSkills
        Sync-OneFile -Source $f.FullName -Destination $dest -TargetName $t.Name -Category 'skill'
    }

    # --- memory ---
    if (-not $SkipMemory -and (Test-Path -LiteralPath $MemorySrc)) {
        $memoryFiles = Get-ChildItem -LiteralPath $MemorySrc -Recurse -File -Filter "*.md"
        foreach ($f in $memoryFiles) {
            if ($f.Name -ieq 'README.md' -and $f.Directory.FullName -eq $MemorySrc) { continue }

            $relUnderMemory = $f.FullName.Substring($MemorySrc.Length).TrimStart('\','/')
            $dest = Join-Path $t.MemoryDest $relUnderMemory
            Sync-OneFile -Source $f.FullName -Destination $dest -TargetName $t.Name -Category 'memory'
        }
    }
}

# 汇总打印
$grouped = $Report | Group-Object Target, Action | Sort-Object Name
Write-Host ""
Write-Host "==== Summary ====" -ForegroundColor Cyan
$Report | Group-Object Target | ForEach-Object {
    $tgt = $_.Name
    Write-Host "  [$tgt]"
    $byAct = $_.Group | Group-Object Action | Sort-Object Name
    foreach ($a in $byAct) {
        $color = switch ($a.Name) {
            'added'     { 'Green' }
            'updated'   { 'Yellow' }
            'kept-local'{ 'Yellow' }
            'unchanged' { 'DarkGray' }
            default     { 'White' }
        }
        Write-Host ("    {0,-12} {1,5}" -f $a.Name, $a.Count) -ForegroundColor $color
    }
}

# 写报告（始终写，Apply 模式写到 ReportDir；DryRun 模式打印路径到临时文件）
$reportDirAbs = Join-Path $RepoPath $ReportDir
if (-not (Test-Path -LiteralPath $reportDirAbs)) {
    if ($Apply) { New-Item -ItemType Directory -Path $reportDirAbs -Force | Out-Null }
}
$reportFile = Join-Path $reportDirAbs ("install-skills-locally-$ts" + $(if ($Apply){''}else{'.dryrun'}) + ".md")

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# install-skills-locally report")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("- Timestamp: $ts")
[void]$sb.AppendLine("- Mode     : $(if ($Apply) {'APPLY'} else {'DRY-RUN'})")
[void]$sb.AppendLine("- Repo     : $RepoPath")
[void]$sb.AppendLine("- Targets  : $((($Selected | ForEach-Object { $_.Name }) -join ', '))")
[void]$sb.AppendLine("- Force    : $Force")
[void]$sb.AppendLine("- SkipMem  : $SkipMemory")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Target | Category | Action | Source | Destination | Detail |")
[void]$sb.AppendLine("| --- | --- | --- | --- | --- | --- |")
foreach ($r in $Report) {
    [void]$sb.AppendLine("| $($r.Target) | $($r.Category) | $($r.Action) | $($r.Source) | $($r.Destination) | $($r.Detail) |")
}

if ($Apply) {
    Set-Content -LiteralPath $reportFile -Value $sb.ToString() -Encoding UTF8
    Write-Host ""
    Write-Host "Report saved: $reportFile" -ForegroundColor Cyan
}
else {
    Write-Host ""
    Write-Host "DRY-RUN: no files were written." -ForegroundColor Green
    Write-Host "Re-run with -Apply to actually install."
    Write-Host ""
    Write-Host "Preview report (not saved):" -ForegroundColor DarkGray
    Write-Host $sb.ToString()
}
