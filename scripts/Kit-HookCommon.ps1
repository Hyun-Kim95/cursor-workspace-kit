# Shared helpers for Cursor hooks on Windows PowerShell 5.1 (UTF-8 stdout, no ConvertFrom-Json -Depth)

function Initialize-KitHookConsole {
    # Cursor reads hook stdout as UTF-8; default console on Korean Windows is often CP949.
    try {
        $utf8 = New-Object System.Text.UTF8Encoding $false
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
        QualityGate  = @{
            Mode       = "off"
            ConfigFile = ".cursor/quality-gate.json"
            StateFile  = ".cursor/state/quality-gate-last.json"
            RunOn      = @("afterAgentResponse")
        }
        ParseOk      = $true
        ParseMessage = ""
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
