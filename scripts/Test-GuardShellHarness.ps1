# Manual verification for guard-shell.ps1 (Harness stage 2)
$ErrorActionPreference = "Stop"
$ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$KitRoot = Split-Path -Parent $ScriptsDir
$GuardScript = Join-Path $KitRoot ".cursor\hooks\guard-shell.ps1"
$PatternsSrc = Join-Path $KitRoot "shared\hooks\guard-shell.patterns.json"

if (-not (Test-Path -LiteralPath $GuardScript)) {
    Write-Error "Run sync-hooks.ps1 first. Missing $GuardScript"
    exit 1
}

. (Join-Path $ScriptsDir "Kit-HookCommon.ps1")

$failures = New-Object System.Collections.ArrayList

function Assert-Case {
    param([string]$Name, [bool]$Condition, [string]$Detail = "")
    if (-not $Condition) {
        $msg = "FAIL: $Name"
        if ($Detail) { $msg += " — $Detail" }
        [void]$failures.Add($msg)
        Write-Host $msg
    }
    else {
        Write-Host "PASS: $Name"
    }
}

function Invoke-GuardShellHook {
    param(
        [string]$WorkspaceRoot,
        [string]$StdinJson
    )

    $scriptPath = Join-Path $WorkspaceRoot ".cursor\hooks\guard-shell.ps1"
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    $psi.WorkingDirectory = $WorkspaceRoot
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $proc = [Diagnostics.Process]::Start($psi)
    $proc.StandardInput.Write($StdinJson)
    $proc.StandardInput.Close()
    $out = $proc.StandardOutput.ReadToEnd()
    $proc.WaitForExit()
    return @{
        Output   = $out
        ExitCode = $proc.ExitCode
    }
}

function New-TestWorkspace {
    param([string]$ConfigJson)

    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("kit-guard-test-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $hooksDir = Join-Path $dir ".cursor\hooks"
    $wsScriptsDir = Join-Path $dir "scripts"
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    New-Item -ItemType Directory -Path $wsScriptsDir -Force | Out-Null
    $commonSrc = Join-Path $ScriptsDir "Kit-HookCommon.ps1"
    if (-not (Test-Path -LiteralPath $commonSrc)) {
        throw "Missing $commonSrc"
    }
    Copy-Item -LiteralPath $GuardScript -Destination (Join-Path $hooksDir "guard-shell.ps1") -Force
    Copy-Item -LiteralPath $PatternsSrc -Destination (Join-Path $hooksDir "guard-shell.patterns.json") -Force
    Copy-Item -LiteralPath $commonSrc -Destination (Join-Path $wsScriptsDir "Kit-HookCommon.ps1") -Force
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Join-Path $dir ".cursor-kit.json"), $ConfigJson, $utf8NoBom)
    return $dir
}

& (Join-Path $ScriptsDir "sync-hooks.ps1") | Out-Null

$tempA = New-TestWorkspace -ConfigJson @'
{
  "kitRepoMode": "submodule",
  "harness": { "shellGuard": { "mode": "block" } }
}
'@
try {
    $rA = Invoke-GuardShellHook -WorkspaceRoot $tempA -StdinJson '{"command":"git add -A"}'
    Assert-Case -Name "A: exit 2 or deny" -Condition (($rA.ExitCode -eq 2) -or ($rA.Output -match "deny"))
}
finally {
    Remove-Item -LiteralPath $tempA -Recurse -Force -ErrorAction SilentlyContinue
}

$tempB = New-TestWorkspace -ConfigJson @'
{
  "harness": { "shellGuard": { "mode": "off" } }
}
'@
try {
    $rB = Invoke-GuardShellHook -WorkspaceRoot $tempB -StdinJson '{"command":"git add -A"}'
    Assert-Case -Name "B: allow exit 0" -Condition ($rB.ExitCode -eq 0 -and $rB.Output -match "allow")
}
finally {
    Remove-Item -LiteralPath $tempB -Recurse -Force -ErrorAction SilentlyContinue
}

$tempC = New-TestWorkspace -ConfigJson @'
{
  "harness": { "shellGuard": { "mode": "warn", "logPath": ".cursor/state/shell-guard.log" } }
}
'@
try {
    $rC = Invoke-GuardShellHook -WorkspaceRoot $tempC -StdinJson '{"command":"git add -A"}'
    Assert-Case -Name "C: warn allows" -Condition ($rC.ExitCode -eq 0 -and $rC.Output -match "allow")
    $logPath = Join-Path $tempC ".cursor\state\shell-guard.log"
    Assert-Case -Name "C: log written" -Condition (Test-Path -LiteralPath $logPath)
}
finally {
    Remove-Item -LiteralPath $tempC -Recurse -Force -ErrorAction SilentlyContinue
}

$rD = Invoke-GuardShellHook -WorkspaceRoot $KitRoot -StdinJson '{"command":"echo hello"}'
Assert-Case -Name "D: kit safe command" -Condition ($rD.ExitCode -eq 0)

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Test-GuardShellHarness: $($failures.Count) failure(s)."
    exit 1
}

Write-Host ""
Write-Host "Test-GuardShellHarness: all cases passed."
exit 0
