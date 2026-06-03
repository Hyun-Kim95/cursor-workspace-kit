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

function Ensure-StartHookScript {
    param(
        [string]$Root,
        [string]$KitRoot
    )
    $destDir = Join-Path $Root ".cursor\hooks"
    $dest = Join-Path $destDir "kit-start-on-prompt.ps1"
    $hadDest = Test-Path -LiteralPath $dest

    $src = Join-Path $KitRoot ".cursor\hooks\kit-start-on-prompt.ps1"
    if (-not (Test-Path -LiteralPath $src)) {
        $src = Join-Path $KitRoot "project-kit\.cursor\hooks\kit-start-on-prompt.ps1"
    }
    if (-not (Test-Path -LiteralPath $src)) {
        throw "Hook template not found under kit at $KitRoot"
    }
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item -LiteralPath $src -Destination $dest -Force
    if ($hadDest) { return "updated" }
    return "created"
}

function Ensure-HooksJson {
    param([string]$Root)

    $hooksPath = Join-Path $Root ".cursor\hooks.json"
    $hookEntry = @{
        command = "powershell -NoProfile -ExecutionPolicy Bypass -File .cursor/hooks/kit-start-on-prompt.ps1"
        matcher = "UserPromptSubmit"
        timeout = 120
    }

    if (-not (Test-Path -LiteralPath $hooksPath)) {
        $cursorDir = Join-Path $Root ".cursor"
        if (-not (Test-Path -LiteralPath $cursorDir)) {
            New-Item -ItemType Directory -Path $cursorDir -Force | Out-Null
        }
        @{
            version = 1
            hooks   = @{
                beforeSubmitPrompt = @($hookEntry)
            }
        } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $hooksPath -Encoding UTF8
        return "created"
    }

    $raw = Get-Content -LiteralPath $hooksPath -Raw -Encoding UTF8
    if ($raw -match 'kit-start-on-prompt\.ps1') { return "exists" }

    $doc = $raw | ConvertFrom-Json
    if (-not $doc.hooks) {
        $doc | Add-Member -NotePropertyName hooks -NotePropertyValue (New-Object PSObject) -Force
    }
    $list = New-Object System.Collections.ArrayList
    $list.Add($hookEntry) | Out-Null
    if ($doc.hooks.beforeSubmitPrompt) {
        foreach ($item in @($doc.hooks.beforeSubmitPrompt)) {
            $list.Add($item) | Out-Null
        }
    }
    $doc.hooks | Add-Member -NotePropertyName beforeSubmitPrompt -NotePropertyValue @($list.ToArray()) -Force
    $doc | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $hooksPath -Encoding UTF8
    return "merged"
}

function Ensure-HarnessHookScripts {
    param(
        [string]$Root,
        [string]$KitRoot
    )

    $destDir = Join-Path $Root ".cursor\hooks"
    $srcDir = Join-Path $KitRoot "shared\hooks"
    $whitelist = @("guard-shell.ps1", "guard-shell.patterns.json", "quality-gate.ps1", "dev-server-harness.ps1")
    if (-not (Test-Path -LiteralPath $srcDir)) { return "skip (no shared/hooks)" }

    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    $n = 0
    foreach ($name in $whitelist) {
        $src = Join-Path $srcDir $name
        if (Test-Path -LiteralPath $src) {
            Copy-Item -LiteralPath $src -Destination (Join-Path $destDir $name) -Force
            $n++
        }
    }
    if ($n -eq 0) { return "skip" }
    return "copied $n harness hook file(s)"
}

function Merge-HookEntryIntoJson {
    param(
        [string]$HooksPath,
        [string]$EventName,
        [hashtable]$NewEntry,
        [string]$ScriptMarker
    )

    if (-not (Test-Path -LiteralPath $HooksPath)) { return "no hooks.json" }

    $raw = Get-Content -LiteralPath $HooksPath -Raw -Encoding UTF8
    if ($raw -match [regex]::Escape($ScriptMarker)) { return "exists ($ScriptMarker)" }

    $doc = $raw | ConvertFrom-Json
    if (-not $doc.hooks) {
        $doc | Add-Member -NotePropertyName hooks -NotePropertyValue (New-Object PSObject) -Force
    }

    $list = New-Object System.Collections.ArrayList
    [void]$list.Add($NewEntry)
    $existingProp = $doc.hooks.PSObject.Properties | Where-Object { $_.Name -eq $EventName } | Select-Object -First 1
    if ($existingProp -and $existingProp.Value) {
        foreach ($item in @($existingProp.Value)) {
            [void]$list.Add($item)
        }
    }
    $doc.hooks | Add-Member -NotePropertyName $EventName -NotePropertyValue @($list.ToArray()) -Force
    $doc | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $HooksPath -Encoding UTF8
    return "merged ($ScriptMarker)"
}

function Ensure-HarnessHooksJson {
    param([string]$Root)

    $hooksPath = Join-Path $Root ".cursor\hooks.json"
    $shellEntry = @{
        command = "powershell -NoProfile -ExecutionPolicy Bypass -File .cursor/hooks/guard-shell.ps1"
        timeout = 10
    }
    $qgEntry = @{
        command = "powershell -NoProfile -ExecutionPolicy Bypass -File .cursor/hooks/quality-gate.ps1"
        timeout = 25
    }

    $dsShellEntry = @{
        command = "powershell -NoProfile -ExecutionPolicy Bypass -File .cursor/hooks/dev-server-harness.ps1"
        matcher = "npm run dev|pnpm dev|yarn dev|next dev|vite|uvicorn|flask run|ng serve|expo start"
        timeout = 15
    }
    $dsKeepEntry = @{
        command = "powershell -NoProfile -ExecutionPolicy Bypass -File .cursor/hooks/dev-server-harness.ps1"
        timeout = 15
    }
    $dsStopEntry = @{
        command = "powershell -NoProfile -ExecutionPolicy Bypass -File .cursor/hooks/dev-server-harness.ps1"
        timeout = 30
    }

    $r1 = Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "beforeShellExecution" -NewEntry $shellEntry -ScriptMarker "guard-shell.ps1"
    $r2 = Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "afterAgentResponse" -NewEntry $qgEntry -ScriptMarker "quality-gate.ps1"
    $r3 = Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "afterShellExecution" -NewEntry $dsShellEntry -ScriptMarker "dev-server-harness.ps1#afterShellExecution"
    $r4 = Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "afterAgentResponse" -NewEntry $dsKeepEntry -ScriptMarker "dev-server-harness.ps1#afterAgentResponse"
    $r5 = Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "stop" -NewEntry $dsStopEntry -ScriptMarker "dev-server-harness.ps1#stop"
    return "$r1; $r2; $r3; $r4; $r5"
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

    $cfgResult = Ensure-CursorKitJson -Root $WorkspaceRoot -RelativeKitPath $KitPath -ChannelName $Channel
    [void]$steps.Add(".cursor-kit.json: $cfgResult")

    $hookResult = Ensure-StartHookScript -Root $WorkspaceRoot -KitRoot $kitRoot
    [void]$steps.Add("kit-start-on-prompt.ps1: $hookResult")

    $hooksJsonResult = Ensure-HooksJson -Root $WorkspaceRoot
    [void]$steps.Add("hooks.json: $hooksJsonResult")

    $harnessScriptsResult = Ensure-HarnessHookScripts -Root $WorkspaceRoot -KitRoot $kitRoot
    [void]$steps.Add("harness hooks: $harnessScriptsResult")

    $harnessHooksJsonResult = Ensure-HarnessHooksJson -Root $WorkspaceRoot
    [void]$steps.Add("harness hooks.json: $harnessHooksJsonResult")

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
