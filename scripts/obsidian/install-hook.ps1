param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRepo,
    [string]$ScriptPath = "",
    [switch]$CommitJournal,
    [switch]$NoCommitJournal
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "Obsidian-IngestCommon.ps1")

$journalInRepo = Join-Path $TargetRepo "scripts\obsidian\write-commit-journal.ps1"
$syncInRepo = Join-Path $TargetRepo "scripts\obsidian\sync-docs.ps1"

$ingest = Get-ObsidianIngestSettings -RepoPath $TargetRepo
$enableJournal = [bool]$ingest.CommitJournal
if ($CommitJournal.IsPresent) { $enableJournal = $true }
if ($NoCommitJournal.IsPresent) { $enableJournal = $false }

if ($enableJournal) {
    if (-not [string]::IsNullOrWhiteSpace($ScriptPath)) {
        if (-not (Test-Path -LiteralPath $ScriptPath)) {
            throw "Journal script not found: $ScriptPath"
        }
    }
    elseif (-not (Test-Path -LiteralPath $journalInRepo)) {
        throw "Journal script not found in target repo (expected): $journalInRepo"
    }
}

if (-not (Test-Path -LiteralPath $syncInRepo)) {
    throw "Sync script not found in target repo (expected): $syncInRepo"
}

$hookDir = Join-Path $TargetRepo ".git\hooks"
if (-not (Test-Path -LiteralPath $hookDir)) {
    throw "Git hooks directory not found: $hookDir"
}

$hookFile = Join-Path $hookDir "post-commit"

$hookContent = @(
    "#!/bin/sh"
    "set -eu"
    'REPO_ROOT="$(git rev-parse --show-toplevel)"'
)

if ($enableJournal) {
    if (-not [string]::IsNullOrWhiteSpace($ScriptPath)) {
        $normalizedScriptPath = $ScriptPath.Replace("\", "/")
        $hookContent += ('powershell -NoProfile -ExecutionPolicy Bypass -File "{0}" -RepoRoot "$REPO_ROOT" || true' -f $normalizedScriptPath)
    }
    else {
        $hookContent += 'powershell -NoProfile -ExecutionPolicy Bypass -File "$REPO_ROOT/scripts/obsidian/write-commit-journal.ps1" -RepoRoot "$REPO_ROOT" || true'
    }
}

$hookContent += 'powershell -NoProfile -ExecutionPolicy Bypass -File "$REPO_ROOT/scripts/obsidian/sync-docs.ps1"'

Set-Content -LiteralPath $hookFile -Value ($hookContent -join "`n") -Encoding ASCII

Write-Host "Hook installed: $hookFile"
if ($enableJournal) {
    Write-Host "On each commit: commit journal (best-effort) -> vault .../journal, then sync-docs -> vault .../docs."
}
else {
    Write-Host "On each commit: sync-docs only -> vault .../docs (commitJournal disabled)."
}
