# Shared helpers for Cursor hooks on Windows PowerShell 5.1 (UTF-8 stdout, no ConvertFrom-Json -Depth)

function Get-KitUtf8NoBomEncoding {
    if (-not $script:KitUtf8NoBom) {
        $script:KitUtf8NoBom = New-Object System.Text.UTF8Encoding $false
    }
    return $script:KitUtf8NoBom
}

function Read-KitUtf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    return [System.IO.File]::ReadAllText($Path, (Get-KitUtf8NoBomEncoding))
}

function Write-KitUtf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Content
    )
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, (Get-KitUtf8NoBomEncoding))
}

function Write-KitJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [int]$Depth = 5
    )
    Write-KitUtf8File -Path $Path -Content ($Object | ConvertTo-Json -Depth $Depth)
}

function Initialize-KitHookConsole {
    # Cursor reads hook stdout as UTF-8; default console on Korean Windows is often CP949.
    try {
        $utf8 = Get-KitUtf8NoBomEncoding
        [Console]::InputEncoding = $utf8
        [Console]::OutputEncoding = $utf8
        $global:OutputEncoding = $utf8
    }
    catch { }
}

function Write-HookJson {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Object
    )
    Initialize-KitHookConsole
    $json = $Object | ConvertTo-Json -Compress
    [Console]::Out.WriteLine($json)
}

function Read-HookStdinJson {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
    return ($raw | ConvertFrom-Json)
}

function Get-HookErrorText {
    param(
        [Parameter(Mandatory = $true)]
        $ErrorRecord
    )
    $msg = $ErrorRecord.Exception.Message
    if ([string]::IsNullOrWhiteSpace($msg)) { return "Unknown error in kit hook." }

    # PS 5.1 localized parameter errors (Korean) -> clear English for Cursor UI
    if ($msg -match "Depth") {
        return "PowerShell 5.1 does not support ConvertFrom-Json -Depth. Update kit-start hook scripts from cursor-workspace-kit."
    }
    if ($msg -match "매개 변수 이름 'Depth'" -or $msg -match "parameter name .Depth") {
        return "PowerShell 5.1 does not support ConvertFrom-Json -Depth. Update kit-start hook scripts from cursor-workspace-kit."
    }

    return $msg
}

function Get-KitHarnessDefaultConfig {
    return @{
        ShellGuard   = @{
            Mode         = "off"
            PatternsFile = ".cursor/hooks/guard-shell.patterns.json"
            LogPath      = ".cursor/state/shell-guard.log"
        }
        QualityGate      = @{
            Mode       = "off"
            ConfigFile = ".cursor/quality-gate.json"
            StateFile  = ".cursor/state/quality-gate-last.json"
            RunOn      = @("afterAgentResponse")
        }
        DevServerCleanup = @{
            Mode         = "off"
            RegistryFile = ".cursor/state/agent-dev-servers.json"
            KeepFile     = ".cursor/state/dev-server-keep.json"
            LogPath      = ".cursor/state/dev-server-cleanup.log"
        }
        ParseOk          = $true
        ParseMessage     = ""
    }
}

function Normalize-DevServerCleanupMode {
    param(
        [string]$Value,
        [string]$Label
    )
    $allowed = @("off", "warn", "kill")
    $m = if ($Value) { $Value.Trim().ToLowerInvariant() } else { "" }
    if ($allowed -contains $m) {
        return @{ Mode = $m; Warning = $null }
    }
    return @{
        Mode    = "off"
        Warning = "Invalid $Label '$Value'; using off."
    }
}

function Normalize-HarnessMode {
    param(
        [string]$Value,
        [string]$Label
    )
    $allowed = @("off", "warn", "block")
    $m = if ($Value) { $Value.Trim().ToLowerInvariant() } else { "" }
    if ($allowed -contains $m) {
        return @{ Mode = $m; Warning = $null }
    }
    return @{
        Mode     = "off"
        Warning  = "Invalid $Label '$Value'; using off."
    }
}

function Test-JsonPropertyPresent {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    if ($null -eq $Object) { return $false }
    foreach ($prop in $Object.PSObject.Properties) {
        if ($prop.Name -eq $Name) { return $true }
    }
    return $false
}

function Get-KitHarnessConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,
        [string]$ConfigPath = ""
    )

    $result = Get-KitHarnessDefaultConfig
    $warnings = New-Object System.Collections.ArrayList

    try {
        $root = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
    }
    catch {
        $result.ParseOk = $false
        $result.ParseMessage = "Invalid WorkspaceRoot: $WorkspaceRoot"
        return $result
    }

    if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
        $ConfigPath = Join-Path $root ".cursor-kit.json"
    }
    elseif (-not [System.IO.Path]::IsPathRooted($ConfigPath)) {
        $ConfigPath = Join-Path $root $ConfigPath
    }

    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        return $result
    }

    $kitRepoMode = "submodule"
    $shellGuardModeSpecified = $false

    try {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        $raw = [System.IO.File]::ReadAllText($ConfigPath, $utf8NoBom)
        $cfg = $raw | ConvertFrom-Json

        if (Test-JsonPropertyPresent -Object $cfg -Name "kitRepoMode") {
            $kitRepoMode = [string]$cfg.kitRepoMode
        }

        if (Test-JsonPropertyPresent -Object $cfg -Name "harness") {
            $h = $cfg.harness

            if (Test-JsonPropertyPresent -Object $h -Name "shellGuard") {
                $sg = $h.shellGuard
                if (Test-JsonPropertyPresent -Object $sg -Name "mode") {
                    $shellGuardModeSpecified = $true
                    $norm = Normalize-HarnessMode -Value ([string]$sg.mode) -Label "harness.shellGuard.mode"
                    $result.ShellGuard.Mode = $norm.Mode
                    if ($norm.Warning) { [void]$warnings.Add($norm.Warning) }
                }
                if (Test-JsonPropertyPresent -Object $sg -Name "patternsFile") {
                    $result.ShellGuard.PatternsFile = [string]$sg.patternsFile
                }
                if (Test-JsonPropertyPresent -Object $sg -Name "logPath") {
                    $result.ShellGuard.LogPath = [string]$sg.logPath
                }
            }

            if (Test-JsonPropertyPresent -Object $h -Name "qualityGate") {
                $qg = $h.qualityGate
                if (Test-JsonPropertyPresent -Object $qg -Name "mode") {
                    $norm = Normalize-HarnessMode -Value ([string]$qg.mode) -Label "harness.qualityGate.mode"
                    $result.QualityGate.Mode = $norm.Mode
                    if ($norm.Warning) { [void]$warnings.Add($norm.Warning) }
                }
                if (Test-JsonPropertyPresent -Object $qg -Name "configFile") {
                    $result.QualityGate.ConfigFile = [string]$qg.configFile
                }
                if (Test-JsonPropertyPresent -Object $qg -Name "stateFile") {
                    $result.QualityGate.StateFile = [string]$qg.stateFile
                }
                if (Test-JsonPropertyPresent -Object $qg -Name "runOn") {
                    $runOn = New-Object System.Collections.ArrayList
                    foreach ($item in @($qg.runOn)) {
                        [void]$runOn.Add([string]$item)
                    }
                    $result.QualityGate.RunOn = @($runOn.ToArray())
                }
            }

            if (Test-JsonPropertyPresent -Object $h -Name "devServerCleanup") {
                $ds = $h.devServerCleanup
                if (Test-JsonPropertyPresent -Object $ds -Name "mode") {
                    $norm = Normalize-DevServerCleanupMode -Value ([string]$ds.mode) -Label "harness.devServerCleanup.mode"
                    $result.DevServerCleanup.Mode = $norm.Mode
                    if ($norm.Warning) { [void]$warnings.Add($norm.Warning) }
                }
                if (Test-JsonPropertyPresent -Object $ds -Name "registryFile") {
                    $result.DevServerCleanup.RegistryFile = [string]$ds.registryFile
                }
                if (Test-JsonPropertyPresent -Object $ds -Name "keepFile") {
                    $result.DevServerCleanup.KeepFile = [string]$ds.keepFile
                }
                if (Test-JsonPropertyPresent -Object $ds -Name "logPath") {
                    $result.DevServerCleanup.LogPath = [string]$ds.logPath
                }
            }
        }
    }
    catch {
        $fail = Get-KitHarnessDefaultConfig
        $fail.ParseOk = $false
        $fail.ParseMessage = "Failed to parse .cursor-kit.json: $($_.Exception.Message)"
        return $fail
    }

    if ($kitRepoMode.ToLowerInvariant() -eq "self" -and -not $shellGuardModeSpecified) {
        $result.ShellGuard.Mode = "warn"
    }

    if ($warnings.Count -gt 0) {
        $result.ParseMessage = ($warnings -join "; ")
    }

    return $result
}

function Resolve-HookProjectRoot {
    param([string]$HookScriptRoot = $PSScriptRoot)

    if ([string]::IsNullOrWhiteSpace($HookScriptRoot)) {
        $HookScriptRoot = $PSScriptRoot
    }
    $candidate = (Resolve-Path (Join-Path $HookScriptRoot "..\..")).Path
    if (Test-Path -LiteralPath (Join-Path $candidate "scripts\Kit-HookCommon.ps1")) {
        return $candidate
    }
    if (Test-Path -LiteralPath (Join-Path $candidate ".cursor-kit.json")) {
        return $candidate
    }
    if (Test-Path -LiteralPath (Join-Path $candidate "vendor\cursor-workspace-kit\scripts\Kit-HookCommon.ps1")) {
        return $candidate
    }
    return $candidate
}

function Resolve-KitHookCommonPath {
    param([string]$ProjectRoot)

    $candidates = @(
        (Join-Path $ProjectRoot "scripts\Kit-HookCommon.ps1"),
        (Join-Path $ProjectRoot "vendor\cursor-workspace-kit\scripts\Kit-HookCommon.ps1")
    )
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

function Write-HarnessLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,
        [Parameter(Mandatory = $true)]
        [string]$RelativeLogPath,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    try {
        $logPath = Join-Path $ProjectRoot ($RelativeLogPath -replace '/', '\')
        $dir = Split-Path -Parent $logPath
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        $ts = (Get-Date).ToString("s")
        Add-Content -LiteralPath $logPath -Value "[$ts] $Message" -Encoding UTF8
    }
    catch {
        # fail-open
    }
}

function Get-ShellCommandFromHookInput {
    param($HookInput)
    if ($null -eq $HookInput) { return "" }
    if (Test-JsonPropertyPresent -Object $HookInput -Name "command") {
        return [string]$HookInput.command
    }
    if (Test-JsonPropertyPresent -Object $HookInput -Name "tool_input") {
        $ti = $HookInput.tool_input
        if (Test-JsonPropertyPresent -Object $ti -Name "command") {
            return [string]$ti.command
        }
    }
    return ""
}

function Get-ShellGuardPatterns {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,
        [Parameter(Mandatory = $true)]
        [string]$PatternsRelativePath
    )

    $patterns = New-Object System.Collections.ArrayList
    $mainPath = Join-Path $ProjectRoot ($PatternsRelativePath -replace '/', '\')
    if (Test-Path -LiteralPath $mainPath) {
        try {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            $doc = [System.IO.File]::ReadAllText($mainPath, $utf8NoBom) | ConvertFrom-Json
            if ($null -ne $doc.patterns) {
                foreach ($p in @($doc.patterns)) {
                    [void]$patterns.Add($p)
                }
            }
        }
        catch { }
    }

    $localPath = Join-Path $ProjectRoot ".cursor\guard-shell.local.json"
    if (Test-Path -LiteralPath $localPath) {
        try {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            $local = [System.IO.File]::ReadAllText($localPath, $utf8NoBom) | ConvertFrom-Json
            if ($null -ne $local.patterns) {
                foreach ($p in @($local.patterns)) {
                    [void]$patterns.Add($p)
                }
            }
        }
        catch { }
    }

    return @($patterns.ToArray())
}

function Test-ShellGuardPatternMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        $Pattern
    )
    if ([string]::IsNullOrWhiteSpace($Command)) { return $false }
    if (-not (Test-JsonPropertyPresent -Object $Pattern -Name "regex")) { return $false }
    try {
        return ($Command -match [string]$Pattern.regex)
    }
    catch {
        return $false
    }
}

function Get-QualityGateFileConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,
        [string]$RelativeConfigPath = ".cursor/quality-gate.json"
    )

    $path = Join-Path $ProjectRoot ($RelativeConfigPath -replace '/', '\')
    if (-not (Test-Path -LiteralPath $path)) { return $null }

    try {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        return ([System.IO.File]::ReadAllText($path, $utf8NoBom) | ConvertFrom-Json)
    }
    catch {
        return $null
    }
}

function Test-QualityGateOnlyWhen {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,
        $OnlyWhen
    )

    if ($null -eq $OnlyWhen) { return $true }

    $ralphPath = Join-Path $ProjectRoot ".cursor\state\delivery-ralph.json"
    if (Test-JsonPropertyPresent -Object $OnlyWhen -Name "deliveryLoopEnabled") {
        if ($OnlyWhen.deliveryLoopEnabled -eq $true) {
            if (-not (Test-Path -LiteralPath $ralphPath)) { return $false }
            try {
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                $ralph = [System.IO.File]::ReadAllText($ralphPath, $utf8NoBom) | ConvertFrom-Json
                if (-not (Test-JsonPropertyPresent -Object $ralph -Name "enabled") -or -not $ralph.enabled) {
                    return $false
                }
            }
            catch { return $false }
        }
    }

    if (Test-JsonPropertyPresent -Object $OnlyWhen -Name "lifecyclePhases") {
        if (-not (Test-Path -LiteralPath $ralphPath)) { return $false }
        try {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            $ralph = [System.IO.File]::ReadAllText($ralphPath, $utf8NoBom) | ConvertFrom-Json
            $phase = ""
            if (Test-JsonPropertyPresent -Object $ralph -Name "lifecyclePhase") {
                $phase = [string]$ralph.lifecyclePhase
            }
            $allowed = @($OnlyWhen.lifecyclePhases | ForEach-Object { [string]$_ })
            if ($allowed.Count -gt 0 -and $allowed -notcontains $phase) {
                return $false
            }
        }
        catch { return $false }
    }

    return $true
}

function Invoke-QualityGateCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,
        [Parameter(Mandatory = $true)]
        [string]$ShellCommand,
        [int]$MaxSeconds = 18
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    $psi.Arguments = "/c $ShellCommand"
    $psi.WorkingDirectory = $ProjectRoot
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()
    $exited = $proc.WaitForExit([Math]::Max(1000, $MaxSeconds * 1000))
    if (-not $exited) {
        try { $proc.Kill() } catch { }
        return @{
            ExitCode = -1
            Summary  = "timeout after ${MaxSeconds}s"
        }
    }

    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $tail = if ($stderr) { $stderr.Trim() } elseif ($stdout) { $stdout.Trim() } else { "exit $($proc.ExitCode)" }
    if ($tail.Length -gt 200) { $tail = $tail.Substring(0, 200) }

    return @{
        ExitCode = $proc.ExitCode
        Summary  = $tail
    }
}

function Test-WorkspaceHasKitSubmodule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)]
        [string]$KitPath
    )
    $gitmodules = Join-Path $WorkspaceRoot ".gitmodules"
    if (-not (Test-Path -LiteralPath $gitmodules)) { return $false }
    $norm = ($KitPath -replace '\\', '/').TrimEnd('/')
    $raw = Get-Content -LiteralPath $gitmodules -Raw -Encoding UTF8
    return ($raw -match [regex]::Escape($norm))
}

function Test-WorkspaceKitSubmoduleInGitIndex {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)]
        [string]$KitPath
    )
    $norm = ($KitPath -replace '\\', '/').TrimEnd('/')
    Push-Location $WorkspaceRoot
    try {
        $line = (git ls-files -s -- $norm 2>$null)
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($line)) { return $false }
        return ($line.Trim() -match '^160000 ')
    }
    finally { Pop-Location }
}

function Repair-KitSubmoduleGitIndex {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)]
        [string]$KitPath,
        [Parameter(Mandatory = $true)]
        [string]$KitRoot
    )
    if (-not (Test-WorkspaceHasKitSubmodule -WorkspaceRoot $WorkspaceRoot -KitPath $KitPath)) {
        return @{ Repaired = $false; Message = "no .gitmodules entry for $KitPath" }
    }
    if (Test-WorkspaceKitSubmoduleInGitIndex -WorkspaceRoot $WorkspaceRoot -KitPath $KitPath) {
        return @{ Repaired = $false; Message = "submodule already in git index" }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $KitRoot ".git"))) {
        return @{ Repaired = $false; Message = "kit path is not a git checkout: $KitRoot" }
    }
    Push-Location $KitRoot
    try {
        $sha = (git rev-parse HEAD 2>$null)
        if ($LASTEXITCODE -ne 0) { throw "cannot read HEAD in kit checkout" }
        $sha = $sha.Trim()
    }
    finally { Pop-Location }

    $norm = ($KitPath -replace '\\', '/').TrimEnd('/')
    Push-Location $WorkspaceRoot
    try {
        $cacheinfo = "160000,$sha,$norm"
        $exit = Invoke-GitNativeQuiet update-index --add --cacheinfo $cacheinfo
        if ($exit -ne 0) { throw "git update-index --cacheinfo failed (exit $exit)" }
        return @{ Repaired = $true; Message = "registered $norm in git index at $sha" }
    }
    finally { Pop-Location }
}

$script:KitProductCapabilityMarkers = @(
    "shared\skills\kit-work-log\SKILL.md",
    "scripts\Sync-KitProductHooks.ps1"
)

function Get-KitRootMissingCapabilityMarkers {
    param(
        [Parameter(Mandatory = $true)]
        [string]$KitRoot
    )
    $missing = New-Object System.Collections.ArrayList
    foreach ($rel in $script:KitProductCapabilityMarkers) {
        if (-not (Test-Path -LiteralPath (Join-Path $KitRoot $rel))) {
            [void]$missing.Add(($rel -replace '\\', '/'))
        }
    }
    return @($missing.ToArray())
}

function Test-KitProductSyncResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)]
        [string]$KitRoot
    )
    $missingKit = Get-KitRootMissingCapabilityMarkers -KitRoot $KitRoot
    $missingProduct = New-Object System.Collections.ArrayList
    $productChecks = @(
        ".cursor\skills\kit-work-log\SKILL.md",
        ".cursor\skills\kit-start\SKILL.md",
        ".cursor\hooks\work-log-on-prompt.ps1",
        ".cursor\hooks\kit-start-on-prompt.ps1",
        ".cursor\commands\kit-start.md"
    )
    foreach ($rel in $productChecks) {
        if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceRoot $rel))) {
            [void]$missingProduct.Add(($rel -replace '\\', '/'))
        }
    }
    return @{
        Ok                  = ($missingKit.Count -eq 0 -and $missingProduct.Count -eq 0)
        MissingKitMarkers   = $missingKit
        MissingProductPaths = @($missingProduct.ToArray())
    }
}

function Invoke-GitNativeQuiet {
    <#
    Run git without treating stderr progress (e.g. "From https://...") as a terminating
    error when $ErrorActionPreference is Stop (PowerShell 5.1 + native commands).
    Returns git exit code; stdout/stderr are discarded.
    #>
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$GitArgs
    )
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        if ($GitArgs.Count -eq 0) {
            & git 2>&1 | Out-Null
        }
        else {
            & git @GitArgs 2>&1 | Out-Null
        }
        return $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $prevEap
    }
}

function Get-KitSubmoduleSyncNeed {
    param(
        [Parameter(Mandatory = $true)]
        [string]$KitRoot,
        [string]$Remote = "origin",
        [string]$Branch = "main"
    )
    if (-not (Test-Path -LiteralPath (Join-Path $KitRoot ".git"))) {
        return @{ Needs = $true; Reason = "missing-git-dir" }
    }

    Push-Location $KitRoot
    try {
        if ((Invoke-GitNativeQuiet fetch $Remote) -ne 0) {
            return @{ Needs = $true; Reason = "fetch-failed" }
        }

        $ref = "$Remote/$Branch"
        $behindRaw = git rev-list "HEAD..$ref" --count 2>$null
        if ($LASTEXITCODE -ne 0) {
            return @{ Needs = $true; Reason = "cannot-compare-to-remote" }
        }
        $behind = [int]($behindRaw.Trim())
        if ($behind -gt 0) {
            return @{ Needs = $true; Reason = "behind-remote"; Behind = $behind }
        }

        $syncScript = Join-Path $KitRoot "scripts\sync-kit-product.ps1"
        if (Test-Path -LiteralPath $syncScript) {
            $text = Get-Content -LiteralPath $syncScript -Raw -Encoding UTF8
            if ($text -notmatch 'sharedSkills') {
                return @{ Needs = $true; Reason = "stale-sync-script" }
            }
        }

        $missingMarkers = Get-KitRootMissingCapabilityMarkers -KitRoot $KitRoot
        if ($missingMarkers.Count -gt 0) {
            return @{
                Needs   = $true
                Reason  = "missing-kit-capability-markers"
                Missing = $missingMarkers
            }
        }

        return @{ Needs = $false; Reason = "up-to-date" }
    }
    finally { Pop-Location }
}

function Invoke-WorkspaceKitSubmoduleRemoteUpdate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)]
        [string]$KitPath
    )
    if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceRoot ".git"))) {
        throw "Workspace is not a git repository: $WorkspaceRoot"
    }
    if (-not (Test-WorkspaceHasKitSubmodule -WorkspaceRoot $WorkspaceRoot -KitPath $KitPath)) {
        return @{ Ok = $false; Skipped = $true; Message = "Kit path is not a registered submodule; skipped submodule update --remote." }
    }

    if (-not (Test-WorkspaceKitSubmoduleInGitIndex -WorkspaceRoot $WorkspaceRoot -KitPath $KitPath)) {
        return @{
            Ok      = $false
            Skipped = $true
            Message = "Submodule listed in .gitmodules but missing from git index; skipped submodule update --remote (vendor git pull will run)."
        }
    }

    Push-Location $WorkspaceRoot
    try {
        $exit = Invoke-GitNativeQuiet submodule update --init --remote $KitPath
        if ($exit -ne 0) {
            return @{
                Ok      = $false
                Skipped = $true
                Message = "git submodule update --init --remote $KitPath failed (exit $exit); vendor git pull will run."
            }
        }
        return @{ Ok = $true; Skipped = $false; Message = "submodule update --init --remote $KitPath" }
    }
    finally { Pop-Location }
}

function Test-DevServerShellCommand {
    param([Parameter(Mandatory = $true)][string]$Command)
    if ([string]::IsNullOrWhiteSpace($Command)) { return $false }
    $patterns = @(
        'npm\s+run\s+dev\b',
        'pnpm\s+(run\s+)?dev\b',
        'yarn\s+dev\b',
        'bun\s+run\s+dev\b',
        'next\s+dev\b',
        '\bvite\b',
        'nuxt\s+dev\b',
        'astro\s+dev\b',
        'uvicorn\b',
        'flask\s+run\b',
        'rails\s+s\b',
        'dotnet\s+run\b',
        'ng\s+serve\b',
        'expo\s+start\b'
    )
    foreach ($rx in $patterns) {
        if ($Command -match $rx) { return $true }
    }
    return $false
}

function Get-DevServerPortsFromText {
    param([string]$Text)
    $ports = New-Object System.Collections.Generic.HashSet[int]
    if ([string]::IsNullOrWhiteSpace($Text)) { return @() }

    $rxList = @(
        '(?i)(?:localhost|127\.0\.0\.1):(\d{2,5})',
        '(?i)--port[=\s]+(\d{2,5})',
        '(?i)(?:^|\s)-p\s+(\d{2,5})(?:\s|$)',
        '(?i)port\s+(\d{2,5})\b',
        '(?i)PORT=(\d{2,5})'
    )
    foreach ($rx in $rxList) {
        [regex]::Matches($Text, $rx) | ForEach-Object {
            $n = 0
            if ([int]::TryParse($_.Groups[1].Value, [ref]$n) -and $n -ge 1024 -and $n -le 65535) {
                [void]$ports.Add($n)
            }
        }
    }
    return @($ports | Sort-Object)
}

function Get-DevServerRegistryPath {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][hashtable]$DevServerConfig
    )
    return Join-Path $ProjectRoot ($DevServerConfig.RegistryFile -replace '/', '\')
}

function Get-DevServerKeepPath {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][hashtable]$DevServerConfig
    )
    return Join-Path $ProjectRoot ($DevServerConfig.KeepFile -replace '/', '\')
}

function Read-DevServerRegistry {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return @{ version = 1; servers = @() }
    }
    try {
        $doc = Read-KitUtf8File -Path $Path | ConvertFrom-Json
        $list = New-Object System.Collections.ArrayList
        if ($null -ne $doc.servers) {
            foreach ($s in @($doc.servers)) { [void]$list.Add($s) }
        }
        return @{ version = 1; servers = @($list.ToArray()) }
    }
    catch {
        return @{ version = 1; servers = @() }
    }
}

function Write-DevServerRegistry {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][array]$Servers
    )
    Write-KitJsonFile -Path $Path -Object @{ version = 1; servers = $Servers } -Depth 6
}

function Read-DevServerKeepRegistry {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return @{ version = 1; keeps = @() }
    }
    try {
        $doc = Read-KitUtf8File -Path $Path | ConvertFrom-Json
        $list = New-Object System.Collections.ArrayList
        if ($null -ne $doc.keeps) {
            foreach ($k in @($doc.keeps)) { [void]$list.Add($k) }
        }
        return @{ version = 1; keeps = @($list.ToArray()) }
    }
    catch {
        return @{ version = 1; keeps = @() }
    }
}

function Write-DevServerKeepRegistry {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][array]$Keeps
    )
    Write-KitJsonFile -Path $Path -Object @{ version = 1; keeps = $Keeps } -Depth 6
}

function Get-HookConversationId {
    param($HookInput)
    if ($null -eq $HookInput) { return "" }
    if (Test-JsonPropertyPresent -Object $HookInput -Name "conversation_id") {
        return [string]$HookInput.conversation_id
    }
    return ""
}

function Register-DevServerFromShellHook {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][hashtable]$DevServerConfig,
        $HookInput
    )
    $command = Get-ShellCommandFromHookInput -HookInput $HookInput
    if (-not (Test-DevServerShellCommand -Command $command)) { return }

    $output = ""
    if (Test-JsonPropertyPresent -Object $HookInput -Name "output") {
        $output = [string]$HookInput.output
    }
    $ports = Get-DevServerPortsFromText -Text "$command`n$output"
    if ($ports.Count -eq 0) { return }

    $convId = Get-HookConversationId -HookInput $HookInput
    $cwd = ""
    if (Test-JsonPropertyPresent -Object $HookInput -Name "cwd") { $cwd = [string]$HookInput.cwd }

    $regPath = Get-DevServerRegistryPath -ProjectRoot $ProjectRoot -DevServerConfig $DevServerConfig
    $doc = Read-DevServerRegistry -Path $regPath
    $servers = New-Object System.Collections.ArrayList
    foreach ($s in @($doc.servers)) {
        $drop = $false
        if ($convId -and (Test-JsonPropertyPresent -Object $s -Name "conversationId") -and ([string]$s.conversationId -eq $convId)) {
            $existingPort = 0
            if (Test-JsonPropertyPresent -Object $s -Name "port") { $existingPort = [int]$s.port }
            if ($ports -contains $existingPort) { $drop = $true }
        }
        if (-not $drop) { [void]$servers.Add($s) }
    }
    $ts = (Get-Date).ToString("o")
    foreach ($port in $ports) {
        [void]$servers.Add(@{
            conversationId = $convId
            port           = $port
            command        = $command
            cwd            = $cwd
            registeredAt   = $ts
        })
    }
    Write-DevServerRegistry -Path $regPath -Servers @($servers.ToArray())
}

function Add-DevServerKeepFromAgentText {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][hashtable]$DevServerConfig,
        [Parameter(Mandatory = $true)][string]$ConversationId,
        [Parameter(Mandatory = $true)][string]$Text
    )
    if ([string]::IsNullOrWhiteSpace($Text)) { return @() }

    $found = New-Object System.Collections.ArrayList
    # ASCII-only patterns (PS 5.1 + UTF-8 no BOM safe). Korean alias in dev-server-cleanup-global.mdc.
    $patterns = @(
        '(?im)dev-server-keep:\s*(\d{2,5})\s*[^\d\r\n]+\s*(.+?)(?:\r?\n|$)'
    )
    foreach ($rx in $patterns) {
        [regex]::Matches($Text, $rx) | ForEach-Object {
            $port = [int]$_.Groups[1].Value
            $reason = $_.Groups[2].Value.Trim()
            if ($port -lt 1024 -or $port -gt 65535) { return }
            if ([string]::IsNullOrWhiteSpace($reason)) { return }
            [void]$found.Add(@{ port = $port; reason = $reason })
        }
    }
    if ($found.Count -eq 0) { return @() }

    $keepPath = Get-DevServerKeepPath -ProjectRoot $ProjectRoot -DevServerConfig $DevServerConfig
    $doc = Read-DevServerKeepRegistry -Path $keepPath
    $keeps = New-Object System.Collections.ArrayList
    foreach ($k in @($doc.keeps)) {
        if ($ConversationId -and (Test-JsonPropertyPresent -Object $k -Name "conversationId") -and ([string]$k.conversationId -eq $ConversationId)) {
            $existingPort = 0
            if (Test-JsonPropertyPresent -Object $k -Name "port") { $existingPort = [int]$k.port }
            $dup = $false
            foreach ($f in @($found)) {
                if ($f.port -eq $existingPort) { $dup = $true; break }
            }
            if ($dup) { continue }
        }
        [void]$keeps.Add($k)
    }
    $ts = (Get-Date).ToString("o")
    foreach ($f in @($found)) {
        [void]$keeps.Add(@{
            conversationId = $ConversationId
            port           = $f.port
            reason         = $f.reason
            recordedAt     = $ts
        })
    }
    Write-DevServerKeepRegistry -Path $keepPath -Keeps @($keeps.ToArray())
    return @($found)
}

function Stop-DevServerListeningPort {
    param([Parameter(Mandatory = $true)][int]$Port)
    $pids = New-Object System.Collections.Generic.HashSet[int]
    try {
        Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
            ForEach-Object { [void]$pids.Add([int]$_.OwningProcess) }
    }
    catch { }
    if ($pids.Count -eq 0) {
        $lines = netstat -ano -p tcp 2>$null | Where-Object { $_ -match ":\s*$Port\s+" }
        foreach ($line in $lines) {
            if ($line -match '\s+(\d+)\s*$') {
                [void]$pids.Add([int]$Matches[1])
            }
        }
    }
    foreach ($procId in $pids) {
        if ($procId -le 0) { continue }
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-DevServerCleanup {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][hashtable]$DevServerConfig,
        [Parameter(Mandatory = $true)][string]$Mode,
        [string]$ConversationId = ""
    )
    if ($Mode -eq "off") { return @() }

    $regPath = Get-DevServerRegistryPath -ProjectRoot $ProjectRoot -DevServerConfig $DevServerConfig
    $keepPath = Get-DevServerKeepPath -ProjectRoot $ProjectRoot -DevServerConfig $DevServerConfig
    $doc = Read-DevServerRegistry -Path $regPath
    $keepDoc = Read-DevServerKeepRegistry -Path $keepPath

    $keepPorts = New-Object System.Collections.Generic.HashSet[int]
    foreach ($k in @($keepDoc.keeps)) {
        $keepConv = ""
        if (Test-JsonPropertyPresent -Object $k -Name "conversationId") {
            $keepConv = [string]$k.conversationId
        }
        if ($keepConv -and $ConversationId -and ($keepConv -ne $ConversationId)) { continue }
        if ($keepConv -and -not $ConversationId) { continue }
        if (Test-JsonPropertyPresent -Object $k -Name "port") {
            [void]$keepPorts.Add([int]$k.port)
        }
    }

    $actions = New-Object System.Collections.ArrayList
    $remaining = New-Object System.Collections.ArrayList
    foreach ($s in @($doc.servers)) {
        $matchConv = $true
        if ($ConversationId) {
            $matchConv = $false
            if (Test-JsonPropertyPresent -Object $s -Name "conversationId") {
                $matchConv = ([string]$s.conversationId -eq $ConversationId)
            }
        }
        if (-not $matchConv) {
            [void]$remaining.Add($s)
            continue
        }
        $port = 0
        if (Test-JsonPropertyPresent -Object $s -Name "port") { $port = [int]$s.port }
        if ($port -le 0) {
            [void]$remaining.Add($s)
            continue
        }
        if ($keepPorts.Contains($port)) {
            $reason = ""
            foreach ($k in @($keepDoc.keeps)) {
                if (([int]$k.port) -eq $port) {
                    if (Test-JsonPropertyPresent -Object $k -Name "reason") { $reason = [string]$k.reason }
                    break
                }
            }
            [void]$actions.Add("keep port $port ($reason)")
            [void]$remaining.Add($s)
            continue
        }
        if ($Mode -eq "warn") {
            [void]$actions.Add("would kill port $port")
            [void]$remaining.Add($s)
            continue
        }
        Stop-DevServerListeningPort -Port $port
        [void]$actions.Add("killed port $port")
    }

    Write-DevServerRegistry -Path $regPath -Servers @($remaining.ToArray())
    if ($actions.Count -gt 0) {
        Write-HarnessLog -ProjectRoot $ProjectRoot -RelativeLogPath $DevServerConfig.LogPath -Message ($actions -join "; ")
    }
    return @($actions)
}
