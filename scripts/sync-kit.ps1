# Sync all kit SSOT into .cursor/ (rules, skills, agents).

$ErrorActionPreference = "Stop"
$Scripts = Split-Path -Parent $MyInvocation.MyCommand.Path

& (Join-Path $Scripts "sync-rules.ps1")
& (Join-Path $Scripts "sync-skills.ps1")
& (Join-Path $Scripts "sync-agents.ps1")
& (Join-Path $Scripts "sync-hooks.ps1")

$kitRoot = Split-Path -Parent $Scripts
$commandsSync = Join-Path $Scripts "Sync-KitProductHooks.ps1"
if (Test-Path -LiteralPath $commandsSync) {
    $commandsDest = Join-Path $kitRoot ".cursor\commands"
    $deprecatedCommands = @(
        "kit-work-log.md"
    )
    $srcDirs = @(
        (Join-Path $kitRoot "project-kit\.cursor\commands"),
        (Join-Path $kitRoot ".cursor\commands")
    )
    $n = 0
    foreach ($srcDir in $srcDirs) {
        if (-not (Test-Path -LiteralPath $srcDir)) { continue }
        if (-not (Test-Path -LiteralPath $commandsDest)) {
            New-Item -ItemType Directory -Path $commandsDest -Force | Out-Null
        }
        Get-ChildItem -LiteralPath $srcDir -Filter "*.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = Join-Path $commandsDest $_.Name
            if (Test-Path -LiteralPath $dest) {
                $srcResolved = (Resolve-Path -LiteralPath $_.FullName).Path
                $destResolved = (Resolve-Path -LiteralPath $dest).Path
                if ($srcResolved -ieq $destResolved) { return }
            }
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
            $n++
        }
    }
    if ($n -gt 0) {
        Write-Host "sync-kit: copied $n slash command(s) to .cursor/commands"
    }
    $removed = 0
    foreach ($name in $deprecatedCommands) {
        $path = Join-Path $commandsDest $name
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Force
            $removed++
        }
    }
    if ($removed -gt 0) {
        Write-Host "sync-kit: removed $removed deprecated slash command(s)"
    }
}

Write-Host "sync-kit: done"
