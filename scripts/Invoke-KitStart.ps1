# /start backend: git fetch/pull kit SSOT, sync into workspace .cursor/, write kit-start-last.json
# Exit 0 = success, 1 = failure (fail-closed for hooks)
# Compatible with Windows PowerShell 5.1

param(
    [Parameter(Mandatory = $false)]
    [string]$WorkspaceRoot = (Get-Location).Path,
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

$commonPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "Kit-HookCommon.ps1"
if (Test-Path -LiteralPath $commonPath) {
    . $commonPath
    Initialize-KitHookConsole
}

function Write-KitStartState {
    param(
        [string]$StatePath,
        [bool]$Ok,
        [hashtable]$Fields
    )
    $dir = Split-Path -Parent $StatePath
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $obj = @{
        ok = $Ok
        at = (Get-Date).ToString("o")
    }
    foreach ($k in $Fields.Keys) { $obj[$k] = $Fields[$k] }
    $obj | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $StatePath -Encoding UTF8
}

function Get-GitHead {
    param([string]$GitDir)
    if (-not (Test-Path -LiteralPath (Join-Path $GitDir ".git"))) { return $null }
    Push-Location $GitDir
    try {
        return (git rev-parse HEAD 2>$null).Trim()
    }
    finally { Pop-Location }
}

function Invoke-GitPullKit {
    param(
        [string]$GitDir,
        [string]$Remote,
        [string]$Branch
    )
    if (-not (Test-Path -LiteralPath (Join-Path $GitDir ".git"))) {
        throw "Not a git repository: $GitDir"
    }
    Push-Location $GitDir
    try {
        & git fetch $Remote 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "git fetch $Remote failed (exit $LASTEXITCODE)" }
        $ref = "$Remote/$Branch"
        $behindRaw = git rev-list "HEAD..$ref" --count 2>$null
        if ($LASTEXITCODE -ne 0) { throw "Cannot compare HEAD to $ref. Check branch name and remote." }
        $behind = [int]($behindRaw.Trim())
        $pulled = $false
        if ($behind -gt 0) {
            & git pull --ff-only $Remote $Branch 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                & git checkout $Branch 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    & git pull --ff-only $Remote $Branch 2>&1 | Out-Null
                }
            }
            if ($LASTEXITCODE -ne 0) {
                throw "git pull --ff-only $Remote $Branch failed (exit $LASTEXITCODE). From product root try: git submodule update --init --remote <kitPath>"
            }
            $pulled = $true
            $behindRaw2 = git rev-list "HEAD..$ref" --count 2>$null
            if ($LASTEXITCODE -eq 0) { $behind = [int]($behindRaw2.Trim()) }
        }
        return @{ Behind = $behind; Pulled = $pulled; Ref = $ref }
    }
    finally { Pop-Location }
}

try {
    $WorkspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
    $ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
        $ConfigPath = Join-Path $WorkspaceRoot ".cursor-kit.json"
    }
    elseif (-not [System.IO.Path]::IsPathRooted($ConfigPath)) {
        $ConfigPath = Join-Path $WorkspaceRoot $ConfigPath
    }

    $statePath = Join-Path $WorkspaceRoot ".cursor\state\kit-start-last.json"

    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Missing config: $ConfigPath (copy from .cursor-kit.json.example or project-kit/.cursor-kit.json.example)"
    }

    $cfg = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $mode = if ($cfg.kitRepoMode) { [string]$cfg.kitRepoMode } else { "submodule" }
    $kitPath = if ($cfg.kitPath) { [string]$cfg.kitPath } else { "vendor/cursor-workspace-kit" }
    $remote = if ($cfg.remote) { [string]$cfg.remote } else { "origin" }
    $branch = if ($cfg.branch) { [string]$cfg.branch } else { "main" }
    $channel = if ($cfg.channel) { [string]$cfg.channel } else { "B" }

    $gitDir = $WorkspaceRoot
    $kitRoot = $WorkspaceRoot

    switch ($mode.ToLowerInvariant()) {
        "self" {
            $kitRoot = $WorkspaceRoot
            $gitDir = $WorkspaceRoot
        }
        "submodule" {
            $kitRoot = Join-Path $WorkspaceRoot $kitPath
            $gitDir = $kitRoot
        }
        "embedded" {
            $kitRoot = $WorkspaceRoot
            $gitDir = $WorkspaceRoot
            if (-not (Test-Path -LiteralPath (Join-Path $kitRoot "shared"))) {
                throw "embedded mode requires shared/ at workspace root"
            }
        }
        default { throw "Unknown kitRepoMode: $mode" }
    }

    $submoduleRemoteSync = $null
    if ($mode -eq "submodule") {
        $hasSubmodule = Test-WorkspaceHasKitSubmodule -WorkspaceRoot $WorkspaceRoot -KitPath $kitPath
        $runRemoteUpdate = $false
        if ($hasSubmodule) {
            if (-not (Test-Path -LiteralPath $kitRoot) -or -not (Test-Path -LiteralPath (Join-Path $kitRoot "scripts\Invoke-KitStart.ps1"))) {
                $runRemoteUpdate = $true
            }
            else {
                $need = Get-KitSubmoduleSyncNeed -KitRoot $kitRoot -Remote $remote -Branch $branch
                $runRemoteUpdate = $need.Needs
            }
        }
        if ($runRemoteUpdate) {
            $submoduleRemoteSync = Invoke-WorkspaceKitSubmoduleRemoteUpdate -WorkspaceRoot $WorkspaceRoot -KitPath $kitPath
            if (-not $submoduleRemoteSync.Ok -and -not $submoduleRemoteSync.Skipped) {
                throw $submoduleRemoteSync.Message
            }
        }
        if (-not (Test-Path -LiteralPath $kitRoot)) {
            throw "Kit submodule path not found: $kitRoot. Run: git submodule update --init or /start-setting"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $kitRoot "scripts\Invoke-KitStart.ps1"))) {
            throw "Kit scripts missing under $kitRoot. Run: git submodule update --init --remote $kitPath"
        }
    }

    $beforeSha = Get-GitHead -GitDir $gitDir
    $pullResult = Invoke-GitPullKit -GitDir $gitDir -Remote $remote -Branch $branch
    $afterSha = Get-GitHead -GitDir $gitDir

    $syncOk = $false
    $syncMessage = ""

    if ($mode -eq "self") {
        $syncScript = Join-Path $ScriptsDir "sync-kit.ps1"
        if (-not (Test-Path -LiteralPath $syncScript)) {
            throw "sync-kit.ps1 not found at $syncScript"
        }
        & powershell -NoProfile -ExecutionPolicy Bypass -File $syncScript
        if ($LASTEXITCODE -ne 0) { throw "sync-kit.ps1 failed (exit $LASTEXITCODE)" }
        $syncOk = $true
        $syncMessage = "sync-kit completed (kit repo self mode)"
    }
    else {
        $syncProduct = Join-Path $ScriptsDir "sync-kit-product.ps1"
        if (-not (Test-Path -LiteralPath $syncProduct)) {
            throw "sync-kit-product.ps1 not found at $syncProduct"
        }
        & powershell -NoProfile -ExecutionPolicy Bypass -File $syncProduct `
            -WorkspaceRoot $WorkspaceRoot -KitRoot $kitRoot -Channel $channel
        if ($LASTEXITCODE -ne 0) { throw "sync-kit-product.ps1 failed (exit $LASTEXITCODE)" }
        $syncOk = $true
        $syncMessage = "sync-kit-product channel $channel completed"
    }

    $summary = @(
        "Kit start OK ($mode)."
        "Behind $($pullResult.Behind) commit(s) on $($pullResult.Ref)."
    )
    if ($pullResult.Pulled) { $summary += "Pulled latest." } else { $summary += "Already up to date." }
    if ($null -ne $submoduleRemoteSync -and $submoduleRemoteSync.Ok) {
        $summary += "Submodule remote sync applied."
    }
    $summary += $syncMessage

    $stateFields = @{
        kitRepoMode = $mode
        channel     = $channel
        kitPath     = $kitPath
        remote      = $remote
        branch      = $branch
        beforeSha   = $beforeSha
        afterSha    = $afterSha
        wasBehind   = ($pullResult.Behind -gt 0)
        pulled      = $pullResult.Pulled
        syncOk      = $syncOk
        message     = ($summary -join " ")
    }
    if ($null -ne $submoduleRemoteSync) {
        $stateFields.submoduleRemoteSync = $submoduleRemoteSync.Ok
        if ($submoduleRemoteSync.Message) { $stateFields.submoduleRemoteSyncMessage = $submoduleRemoteSync.Message }
    }
    Write-KitStartState -StatePath $statePath -Ok $true -Fields $stateFields

    Write-Host ($summary -join " ")
    exit 0
}
catch {
    $msg = $_.Exception.Message
    $root = if ($WorkspaceRoot) { $WorkspaceRoot } else { (Get-Location).Path }
    $statePath = Join-Path $root ".cursor\state\kit-start-last.json"
    Write-KitStartState -StatePath $statePath -Ok $false -Fields @{
        message = $msg
        syncOk  = $false
    }
    Write-Error $msg
    exit 1
}
