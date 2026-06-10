param(
    [string]$VaultRoot = "D:\Obsidian\projects",
    [switch]$WhatIf,
    [switch]$RemoveEmptyJournalDirs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $VaultRoot)) {
    throw "Vault root not found: $VaultRoot"
}

$removedFiles = 0
$removedDirs = 0
$projects = @()

Get-ChildItem -LiteralPath $VaultRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne '.obsidian' } |
    ForEach-Object {
        $journalDir = Join-Path $_.FullName "journal"
        if (-not (Test-Path -LiteralPath $journalDir)) {
            return
        }

        $files = @(Get-ChildItem -LiteralPath $journalDir -File -ErrorAction SilentlyContinue)
        if ($files.Count -eq 0) {
            return
        }

        $projects += $_.Name
        foreach ($file in $files) {
            if ($WhatIf) {
                Write-Host "[WhatIf] Remove: $($file.FullName)"
            }
            else {
                Remove-Item -LiteralPath $file.FullName -Force
            }
            $removedFiles++
        }

        if ($RemoveEmptyJournalDirs) {
            $remaining = @(Get-ChildItem -LiteralPath $journalDir -Force -ErrorAction SilentlyContinue)
            if ($remaining.Count -eq 0) {
                if ($WhatIf) {
                    Write-Host "[WhatIf] Remove directory: $journalDir"
                }
                else {
                    Remove-Item -LiteralPath $journalDir -Force -Recurse -ErrorAction SilentlyContinue
                }
                $removedDirs++
            }
        }
    }

Write-Host "Vault: $VaultRoot"
Write-Host "Projects with journal files: $($projects.Count) ($($projects -join ', '))"
Write-Host "Journal files removed: $removedFiles$(if ($WhatIf) { ' (WhatIf)' })"
if ($RemoveEmptyJournalDirs) {
    Write-Host "Empty journal directories removed: $removedDirs$(if ($WhatIf) { ' (WhatIf)' })"
}
