# airbag installer - Windows PowerShell
# Installs into ~\.claude without overwriting anything you already have.
#   .\install.ps1              install / update
#   .\install.ps1 -Uninstall   remove airbag files
param([switch]$Uninstall)
$ErrorActionPreference = "Stop"

$RepoUrl   = "https://github.com/iqbalmbadhan/airbag.git"
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }
$SrcDir    = $PSScriptRoot
$Tmp       = $null

if (-not $SrcDir -or -not (Test-Path (Join-Path $SrcDir "claude"))) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git is required" }
    $Tmp = Join-Path ([IO.Path]::GetTempPath()) ("airbag-" + [guid]::NewGuid())
    git clone --depth 1 --quiet $RepoUrl $Tmp
    if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
    $SrcDir = $Tmp
}
$Src = Join-Path $SrcDir "claude"

$Rules    = Join-Path $ClaudeDir "rules\airbag.md"
$Skill    = Join-Path $ClaudeDir "skills\app-audit"
$Guide    = Join-Path $ClaudeDir "claude-security-guidance.md"
$Settings = Join-Path $ClaudeDir "settings.json"
$SrcGuide = Join-Path $Src "claude-security-guidance.md"

function Same($a, $b) { (Test-Path $a) -and ((Get-FileHash $a).Hash -eq (Get-FileHash $b).Hash) }

try {
    if ($Uninstall) {
        Remove-Item $Rules -ErrorAction SilentlyContinue
        if (Test-Path (Join-Path $Skill ".airbag")) { Remove-Item $Skill -Recurse -Force }
        elseif (Test-Path $Skill) { Write-Host "[i] left $Skill alone (not installed by airbag)" }
        if (Same $Guide $SrcGuide) { Remove-Item $Guide }
        Write-Host "airbag removed. Permission rules in $Settings were left in place."
        return
    }

    New-Item -ItemType Directory -Force (Join-Path $ClaudeDir "rules"), (Join-Path $ClaudeDir "skills") | Out-Null

    Copy-Item (Join-Path $Src "CLAUDE.md") $Rules -Force
    Write-Host "[ok] rules      -> $Rules"

    if ((Test-Path $Skill) -and -not (Test-Path (Join-Path $Skill ".airbag"))) {
        Rename-Item $Skill ("app-audit.backup-" + (Get-Date -Format yyyyMMddHHmmss))
        Write-Host "  (existing app-audit skill backed up)"
    }
    Remove-Item $Skill -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $Src "skills\app-audit") $Skill -Recurse
    New-Item -ItemType File (Join-Path $Skill ".airbag") | Out-Null
    Write-Host "[ok] skill      -> $Skill  (run /app-audit)"

    if ((Test-Path $Guide) -and -not (Same $Guide $SrcGuide)) {
        Write-Host "[i] kept your existing $Guide (see claude\claude-security-guidance.md to merge)"
    } else {
        Copy-Item $SrcGuide $Guide -Force
        Write-Host "[ok] guidance   -> $Guide"
    }

    $add = (Get-Content (Join-Path $Src "settings.json") -Raw -Encoding UTF8 | ConvertFrom-Json).permissions
    if (-not (Test-Path $Settings)) {
        Copy-Item (Join-Path $Src "settings.json") $Settings
        Write-Host "[ok] settings   -> $Settings"
    } else {
        $cur = Get-Content $Settings -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not ($cur.PSObject.Properties.Name -contains 'permissions')) { $cur | Add-Member -NotePropertyName permissions -NotePropertyValue ([pscustomobject]@{}) -Force }
        $changed = $false
        foreach ($key in $add.PSObject.Properties.Name) {
            $list = @(@($cur.permissions.$key) | Where-Object { $_ })
            foreach ($r in $add.$key) { if ($list -notcontains $r) { $list += $r; $changed = $true } }
            $cur.permissions | Add-Member -NotePropertyName $key -NotePropertyValue @($list) -Force
        }
        if ($changed) {
            Copy-Item $Settings ($Settings + ".backup-" + (Get-Date -Format yyyyMMddHHmmss))
            [IO.File]::WriteAllText($Settings, ($cur | ConvertTo-Json -Depth 20), (New-Object System.Text.UTF8Encoding $false))
            Write-Host "[ok] settings   -> merged permission rules (backup saved)"
        } else {
            Write-Host "[ok] settings   -> permission rules already present"
        }
    }

    Write-Host ""
    Write-Host "airbag is installed. Next:"
    Write-Host "  1. Recommended: in Claude Code run   /plugin install security-guidance@claude-plugins-official"
    Write-Host "  2. Start a new session and check     /context"
    Write-Host "  3. Audit any project with            /app-audit"
}
finally {
    if ($Tmp) { Remove-Item $Tmp -Recurse -Force -ErrorAction SilentlyContinue }
}
