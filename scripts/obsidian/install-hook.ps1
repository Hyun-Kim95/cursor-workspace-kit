param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRepo,
    [string]$ScriptPath = "",
    [string]$KitRoot = "",
    [switch]$CommitJournal,
    [switch]$NoCommitJournal
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "Obsidian-IngestCommon.ps1")
. (Join-Path $PSScriptRoot "Obsidian-HookInstall.ps1")

$TargetRepo = (Resolve-Path -LiteralPath $TargetRepo).Path
if ([string]::IsNullOrWhiteSpace($KitRoot)) {
    $KitRoot = Resolve-ObsidianKitRoot -RepoPath $TargetRepo
}

$ingest = Get-ObsidianIngestSettings -RepoPath $TargetRepo
$enableJournal = [bool]$ingest.CommitJournal
if ($CommitJournal.IsPresent) { $enableJournal = $true }
if ($NoCommitJournal.IsPresent) { $enableJournal = $false }

$syncPath = Resolve-ObsidianScriptPath -RepoPath $TargetRepo -FileName "sync-docs.ps1" -KitRoot $KitRoot
if (-not $syncPath) {
    throw "Sync script not found for repo (expected under scripts/obsidian or kit submodule): $TargetRepo"
}

$journalPath = Resolve-ObsidianScriptPath -RepoPath $TargetRepo -FileName "write-commit-journal.ps1" -KitRoot $KitRoot

if ($enableJournal) {
    if (-not [string]::IsNullOrWhiteSpace($ScriptPath)) {
        if (-not (Test-Path -LiteralPath $ScriptPath)) {
            throw "Journal script not found: $ScriptPath"
        }
        $journalPath = $ScriptPath
    }
    elseif (-not $journalPath) {
        throw "Journal script not found for repo (expected under scripts/obsidian or kit submodule): $TargetRepo"
    }
}

$hookDir = Join-Path $TargetRepo ".git\hooks"
if (-not (Test-Path -LiteralPath $hookDir)) {
    throw "Git hooks directory not found: $hookDir"
}

$hookFile = Join-Path $hookDir "post-commit"
$syncHookPath = Convert-ToRepoRootHookPath -RepoPath $TargetRepo -AbsolutePath $syncPath

$hookContent = @(
    "#!/bin/sh"
    "set -eu"
    'REPO_ROOT="$(git rev-parse --show-toplevel)"'
)

if ($enableJournal) {
    $journalHookPath = if ([string]::IsNullOrWhiteSpace($ScriptPath)) {
        Convert-ToRepoRootHookPath -RepoPath $TargetRepo -AbsolutePath $journalPath
    }
    else {
        '"' + ($ScriptPath.Replace('\', '/')) + '"'
    }
    $hookContent += ('powershell -NoProfile -ExecutionPolicy Bypass -File {0} -RepoRoot "$REPO_ROOT" || true' -f $journalHookPath)
}

$hookContent += ('powershell -NoProfile -ExecutionPolicy Bypass -File {0}' -f $syncHookPath)

Set-Content -LiteralPath $hookFile -Value ($hookContent -join "`n") -Encoding ASCII

Write-Host "Hook installed: $hookFile"
if ($enableJournal) {
    Write-Host "On each commit: commit journal (best-effort) -> vault .../journal, then sync-docs -> vault .../docs."
}
else {
    Write-Host "On each commit: sync-docs only -> vault .../docs (commitJournal disabled)."
}
