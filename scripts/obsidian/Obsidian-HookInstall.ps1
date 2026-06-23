# Shared post-commit hook install/reconcile for Obsidian (PowerShell 5.1)

function Resolve-ObsidianKitRoot {
    param([Parameter(Mandatory = $true)][string]$RepoPath)

    if (Test-Path -LiteralPath (Join-Path $RepoPath "scripts\Invoke-KitStart.ps1")) {
        return (Resolve-Path -LiteralPath $RepoPath).Path
    }

    $kitPath = "vendor/cursor-workspace-kit"
    $configPath = Join-Path $RepoPath ".cursor-kit.json"
    if (Test-Path -LiteralPath $configPath) {
        try {
            $raw = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8
            if (-not [string]::IsNullOrWhiteSpace($raw)) {
                $cfg = $raw | ConvertFrom-Json
                $kp = $cfg.PSObject.Properties['kitPath']
                if ($kp -and -not [string]::IsNullOrWhiteSpace([string]$kp.Value)) { $kitPath = [string]$kp.Value }
            }
        }
        catch {
            # fail-open: default kitPath
        }
    }

    $vendorRoot = Join-Path $RepoPath $kitPath
    if (Test-Path -LiteralPath (Join-Path $vendorRoot "scripts\obsidian\install-hook.ps1")) {
        return (Resolve-Path -LiteralPath $vendorRoot).Path
    }

    if (Test-Path -LiteralPath (Join-Path $RepoPath "scripts\obsidian\install-hook.ps1")) {
        return (Resolve-Path -LiteralPath $RepoPath).Path
    }

    return $null
}

function Resolve-ObsidianInstallScript {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [string]$KitRoot = ""
    )

    $local = Join-Path $RepoPath "scripts\obsidian\install-hook.ps1"
    if (Test-Path -LiteralPath $local) { return $local }

    if ([string]::IsNullOrWhiteSpace($KitRoot)) {
        $KitRoot = Resolve-ObsidianKitRoot -RepoPath $RepoPath
    }
    if ($KitRoot) {
        $fromKit = Join-Path $KitRoot "scripts\obsidian\install-hook.ps1"
        if (Test-Path -LiteralPath $fromKit) { return $fromKit }
    }

    return $null
}

function Resolve-ObsidianScriptPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$FileName,
        [string]$KitRoot = ""
    )

    $local = Join-Path $RepoPath "scripts\obsidian\$FileName"
    if (Test-Path -LiteralPath $local) { return $local }

    if ([string]::IsNullOrWhiteSpace($KitRoot)) {
        $KitRoot = Resolve-ObsidianKitRoot -RepoPath $RepoPath
    }
    if ($KitRoot) {
        $fromKit = Join-Path $KitRoot "scripts\obsidian\$FileName"
        if (Test-Path -LiteralPath $fromKit) { return $fromKit }
    }

    return $null
}

function Get-ObsidianWantCommitJournal {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$ScriptRoot
    )

    $common = Join-Path $ScriptRoot "Obsidian-IngestCommon.ps1"
    if (-not (Test-Path -LiteralPath $common)) {
        return $false
    }

    . $common
    $ingest = Get-ObsidianIngestSettings -RepoPath $RepoPath
    return [bool]$ingest.CommitJournal
}

function Convert-ToRepoRootHookPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$AbsolutePath
    )

    $repoNorm = (Resolve-Path -LiteralPath $RepoPath).Path.TrimEnd('\')
    $absNorm = (Resolve-Path -LiteralPath $AbsolutePath).Path
    if ($absNorm.StartsWith($repoNorm, [StringComparison]::OrdinalIgnoreCase)) {
        $rel = $absNorm.Substring($repoNorm.Length).TrimStart('\')
        return ('"$REPO_ROOT/' + ($rel -replace '\\', '/') + '"')
    }

    return ('"' + ($absNorm -replace '\\', '/') + '"')
}

function Test-ObsidianPostCommitHookCurrent {
    param(
        [Parameter(Mandatory = $true)][string]$HookFile,
        [bool]$ExpectJournal
    )

    if (-not (Test-Path -LiteralPath $HookFile)) {
        return $false
    }

    $content = Get-Content -LiteralPath $HookFile -Raw -Encoding UTF8
    $hasSync = ($content -match 'sync-docs\.ps1')
    $hasJournal = ($content -match 'write-commit-journal')
    if (-not $hasSync) { return $false }
    if ($ExpectJournal) { return $hasJournal }
    return -not $hasJournal
}

function Invoke-ObsidianPostCommitInstall {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [string]$KitRoot = "",
        [switch]$Force
    )

    $RepoPath = (Resolve-Path -LiteralPath $RepoPath).Path
    $gitDir = Join-Path $RepoPath ".git"
    if (-not (Test-Path -LiteralPath $gitDir)) {
        return @{ Ok = $false; Skipped = $true; Reason = "not a git repo" }
    }

    if ([string]::IsNullOrWhiteSpace($KitRoot)) {
        $KitRoot = Resolve-ObsidianKitRoot -RepoPath $RepoPath
    }

    $installScript = Resolve-ObsidianInstallScript -RepoPath $RepoPath -KitRoot $KitRoot
    if (-not $installScript) {
        return @{ Ok = $false; Skipped = $true; Reason = "install-hook.ps1 not found" }
    }

    $scriptRoot = Split-Path -Parent $installScript
    $wantJournal = Get-ObsidianWantCommitJournal -RepoPath $RepoPath -ScriptRoot $scriptRoot

    $syncPath = Resolve-ObsidianScriptPath -RepoPath $RepoPath -FileName "sync-docs.ps1" -KitRoot $KitRoot
    if (-not $syncPath) {
        return @{ Ok = $false; Skipped = $true; Reason = "sync-docs.ps1 not found" }
    }

    $hookFile = Join-Path $gitDir "hooks\post-commit"
    if (-not $Force) {
        if (Test-ObsidianPostCommitHookCurrent -HookFile $hookFile -ExpectJournal $wantJournal) {
            return @{
                Ok          = $true
                Skipped     = $true
                Reason      = "hook already current"
                WantJournal = $wantJournal
            }
        }
    }

    $installArgs = @(
        "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $installScript,
        "-TargetRepo", $RepoPath
    )
    if ($KitRoot) {
        $installArgs += @("-KitRoot", $KitRoot)
    }
    if (-not $wantJournal) { $installArgs += "-NoCommitJournal" }
    else { $installArgs += "-CommitJournal" }

    & powershell @installArgs
    $exitCode = $LASTEXITCODE
    $ok = ($exitCode -eq 0) -and (Test-ObsidianPostCommitHookCurrent -HookFile $hookFile -ExpectJournal $wantJournal)

    return @{
        Ok          = $ok
        Skipped     = $false
        WantJournal = $wantJournal
        ExitCode    = $exitCode
        HookFile    = $hookFile
        Reason      = if ($ok) { "installed" } else { "install failed (exit $exitCode)" }
    }
}

function Import-ObsidianHookInstallModule {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $local = Join-Path $ProjectRoot "scripts\obsidian\Obsidian-HookInstall.ps1"
    if (Test-Path -LiteralPath $local) {
        . $local
        return $true
    }

    $kitPath = "vendor/cursor-workspace-kit"
    $configPath = Join-Path $ProjectRoot ".cursor-kit.json"
    if (Test-Path -LiteralPath $configPath) {
        try {
            $raw = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8
            if (-not [string]::IsNullOrWhiteSpace($raw)) {
                $cfg = $raw | ConvertFrom-Json
                $kp = $cfg.PSObject.Properties['kitPath']
                if ($kp -and -not [string]::IsNullOrWhiteSpace([string]$kp.Value)) { $kitPath = [string]$kp.Value }
            }
        }
        catch {
            # fail-open
        }
    }

    $fromKit = Join-Path (Join-Path $ProjectRoot $kitPath) "scripts\obsidian\Obsidian-HookInstall.ps1"
    if (Test-Path -LiteralPath $fromKit) {
        . $fromKit
        return $true
    }

    return $false
}
