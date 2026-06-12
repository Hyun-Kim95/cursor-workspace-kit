# One-shot product onboarding: submodule, .cursor-kit.json, /start hook, first sync
# Exit 0 = success, 1 = failure
# PS 5.1 compatible. Run manually or via /start-setting hook.

param(
    [Parameter(Mandatory = $false)]
    [string]$WorkspaceRoot = (Get-Location).Path,
    [Parameter(Mandatory = $false)]
    [string]$KitPath = "vendor/cursor-workspace-kit",
    [Parameter(Mandatory = $false)]
    [string]$KitRepoUrl = "https://github.com/Hyun-Kim95/cursor-workspace-kit.git",
    [Parameter(Mandatory = $false)]
    [string]$Channel = "A",
    [Parameter(Mandatory = $false)]
    [string]$BootstrapKitPath = ""
)

$ErrorActionPreference = "Stop"

$commonPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "Kit-HookCommon.ps1"
if (Test-Path -LiteralPath $commonPath) {
    . $commonPath
    Initialize-KitHookConsole
}

function Write-SettingState {
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
    if (Get-Command Write-KitJsonFile -ErrorAction SilentlyContinue) {
        Write-KitJsonFile -Path $StatePath -Object $obj -Depth 6
    }
    else {
        $obj | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $StatePath -Encoding UTF8
    }
}

function Test-KitRootReady {
    param([string]$Root)
    Test-Path -LiteralPath (Join-Path $Root "scripts\Invoke-KitStart.ps1")
}

function Ensure-GitRepo {
    param([string]$Root)
    if (-not (Test-Path -LiteralPath (Join-Path $Root ".git"))) {
        throw "Not a git repository: $Root. Initialize git first (git init)."
    }
}

function Ensure-KitSubmodule {
    param(
        [string]$Root,
        [string]$RelativeKitPath,
        [string]$RepoUrl,
        [string]$BootstrapPath
    )

    $kitRoot = Join-Path $Root $RelativeKitPath
    if (Test-KitRootReady -Root $kitRoot) {
        return $kitRoot
    }

    Ensure-GitRepo -Root $Root
    Push-Location $Root
    try {
        if (Test-Path -LiteralPath ".gitmodules") {
            $subPath = $RelativeKitPath -replace '/', '\'
            if ((Invoke-GitNativeQuiet submodule update --init --recursive $subPath) -ne 0) {
                Invoke-GitNativeQuiet submodule update --init --recursive | Out-Null
            }
        }
        if (-not (Test-KitRootReady -Root $kitRoot)) {
            if (Test-Path -LiteralPath $RelativeKitPath) {
                throw "Path exists but kit scripts missing: $kitRoot. Remove the folder or fix submodule, then retry."
            }
            $addExit = Invoke-GitNativeQuiet submodule add $RepoUrl $RelativeKitPath
            if ($addExit -ne 0) {
                throw "git submodule add failed (exit $addExit). Commit or stash changes, then retry."
            }
        }
    }
    finally { Pop-Location }

    if (-not (Test-KitRootReady -Root $kitRoot)) {
        if (-not [string]::IsNullOrWhiteSpace($BootstrapPath) -and (Test-KitRootReady -Root $BootstrapPath)) {
            throw "Submodule not ready at $kitRoot. Run: git submodule update --init"
        }
        throw "Kit not available at $kitRoot after submodule step."
    }
    return $kitRoot
}

function Ensure-CursorKitJson {
    param(
        [string]$Root,
        [string]$RelativeKitPath,
        [string]$ChannelName
    )
    $configPath = Join-Path $Root ".cursor-kit.json"
    if (Test-Path -LiteralPath $configPath) { return "exists" }

    $example = Join-Path $Root (Join-Path $RelativeKitPath "project-kit\.cursor-kit.json.example")
    if (Test-Path -LiteralPath $example) {
        Copy-Item -LiteralPath $example -Destination $configPath -Force
    }
    else {
        @{
            kitPath     = $RelativeKitPath.Replace('\', '/')
            kitRepoMode = "submodule"
            remote      = "origin"
            branch      = "main"
            channel     = $ChannelName
        } | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding UTF8
    }
    return "created"
}

function Get-ConfigChannel {
    param([string]$Root, [string]$Default)
    $configPath = Join-Path $Root ".cursor-kit.json"
    if (-not (Test-Path -LiteralPath $configPath)) { return $Default }
    try {
        $cfg = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($cfg.channel) { return [string]$cfg.channel }
    }
    catch { }
    return $Default
}
$steps = New-Object System.Collections.ArrayList

try {
    $WorkspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
    $statePath = Join-Path $WorkspaceRoot ".cursor\state\kit-start-setting-last.json"

    $bootstrap = $BootstrapKitPath
    if ([string]::IsNullOrWhiteSpace($bootstrap)) {
        $scriptKitRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
        if (Test-KitRootReady -Root $scriptKitRoot) {
            $bootstrap = $scriptKitRoot
        }
    }

    $kitRoot = Ensure-KitSubmodule -Root $WorkspaceRoot -RelativeKitPath $KitPath -RepoUrl $KitRepoUrl -BootstrapPath $bootstrap
    [void]$steps.Add("submodule: OK ($KitPath)")

    if (Get-Command Repair-KitSubmoduleGitIndex -ErrorAction SilentlyContinue) {
        $indexRepair = Repair-KitSubmoduleGitIndex -WorkspaceRoot $WorkspaceRoot -KitPath $KitPath -KitRoot $kitRoot
        if ($indexRepair.Repaired) {
            [void]$steps.Add("submodule index: repaired ($($indexRepair.Message))")
        }
    }

    $cfgResult = Ensure-CursorKitJson -Root $WorkspaceRoot -RelativeKitPath $KitPath -ChannelName $Channel
    [void]$steps.Add(".cursor-kit.json: $cfgResult")

    $hooksSyncScript = Join-Path $kitRoot "scripts\Sync-KitProductHooks.ps1"
    if (-not (Test-Path -LiteralPath $hooksSyncScript)) {
        throw "Sync-KitProductHooks.ps1 not found under kit: $kitRoot"
    }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $hooksSyncScript `
        -WorkspaceRoot $WorkspaceRoot -KitRoot $kitRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Sync-KitProductHooks.ps1 failed (exit $LASTEXITCODE)"
    }
    [void]$steps.Add("product hooks: OK (Sync-KitProductHooks)")

    $startScript = Join-Path $kitRoot "scripts\Invoke-KitStart.ps1"
    & powershell -NoProfile -ExecutionPolicy Bypass -File $startScript -WorkspaceRoot $WorkspaceRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Invoke-KitStart.ps1 failed (exit $LASTEXITCODE). See .cursor/state/kit-start-last.json"
    }
    [void]$steps.Add("sync: OK (channel $(Get-ConfigChannel -Root $WorkspaceRoot -Default $Channel))")

    $encodingScript = Join-Path $kitRoot "scripts\Ensure-ProductEncodingAssets.ps1"
    if (Test-Path -LiteralPath $encodingScript) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $encodingScript -WorkspaceRoot $WorkspaceRoot -KitRoot $kitRoot
        if ($LASTEXITCODE -ne 0) {
            throw "Ensure-ProductEncodingAssets.ps1 failed (exit $LASTEXITCODE)"
        }
        [void]$steps.Add("encoding-assets: OK")
    }

    $summary = "Kit start-setting OK. " + ($steps -join "; ") + " Next: use /start <task> daily."
    Write-SettingState -StatePath $statePath -Ok $true -Fields @{
        kitPath  = $KitPath
        channel  = (Get-ConfigChannel -Root $WorkspaceRoot -Default $Channel)
        steps    = @($steps)
        message  = $summary
    }
    Write-Host $summary
    exit 0
}
catch {
    $msg = $_.Exception.Message
    $root = if ($WorkspaceRoot) { $WorkspaceRoot } else { (Get-Location).Path }
    $statePath = Join-Path $root ".cursor\state\kit-start-setting-last.json"
    Write-SettingState -StatePath $statePath -Ok $false -Fields @{
        message = $msg
        steps   = @($steps)
    }
    Write-Error $msg
    exit 1
}
