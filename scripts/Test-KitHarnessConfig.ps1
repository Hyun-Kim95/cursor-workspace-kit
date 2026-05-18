# Manual verification for Get-KitHarnessConfig (Harness stage 1)
# Exit 0 = all cases passed, 1 = failure

$ErrorActionPreference = "Stop"
$ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$KitRoot = Split-Path -Parent $ScriptsDir

. (Join-Path $ScriptsDir "Kit-HookCommon.ps1")

$failures = New-Object System.Collections.ArrayList

function Assert-Case {
    param(
        [string]$Name,
        [bool]$Condition,
        [string]$Detail = ""
    )
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

# Case A: kit repo root (.cursor-kit.json with harness shellGuard warn)
$cfgA = Get-KitHarnessConfig -WorkspaceRoot $KitRoot
Assert-Case -Name "A: ParseOk" -Condition ($cfgA.ParseOk -eq $true) -Detail $cfgA.ParseMessage
Assert-Case -Name "A: ShellGuard.Mode warn" -Condition ($cfgA.ShellGuard.Mode -eq "warn")
Assert-Case -Name "A: QualityGate.Mode off" -Condition ($cfgA.QualityGate.Mode -eq "off")

# Case B: temp dir + empty config {}
$tempB = Join-Path ([System.IO.Path]::GetTempPath()) ("kit-harness-test-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempB -Force | Out-Null
try {
    Set-Content -LiteralPath (Join-Path $tempB ".cursor-kit.json") -Value "{}" -Encoding UTF8
    $cfgB = Get-KitHarnessConfig -WorkspaceRoot $tempB
    Assert-Case -Name "B: ParseOk" -Condition ($cfgB.ParseOk -eq $true)
    Assert-Case -Name "B: ShellGuard.Mode off" -Condition ($cfgB.ShellGuard.Mode -eq "off")
    Assert-Case -Name "B: QualityGate.Mode off" -Condition ($cfgB.QualityGate.Mode -eq "off")
}
finally {
    Remove-Item -LiteralPath $tempB -Recurse -Force -ErrorAction SilentlyContinue
}

# Case C: invalid JSON
$tempC = Join-Path ([System.IO.Path]::GetTempPath()) ("kit-harness-test-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempC -Force | Out-Null
try {
    Set-Content -LiteralPath (Join-Path $tempC ".cursor-kit.json") -Value "{ not json" -Encoding UTF8
    $cfgC = Get-KitHarnessConfig -WorkspaceRoot $tempC
    Assert-Case -Name "C: ParseOk false" -Condition ($cfgC.ParseOk -eq $false)
    Assert-Case -Name "C: ShellGuard.Mode off" -Condition ($cfgC.ShellGuard.Mode -eq "off")
    Assert-Case -Name "C: ParseMessage set" -Condition (-not [string]::IsNullOrWhiteSpace($cfgC.ParseMessage))
}
finally {
    Remove-Item -LiteralPath $tempC -Recurse -Force -ErrorAction SilentlyContinue
}

# Case D: harness.shellGuard.mode block
$tempD = Join-Path ([System.IO.Path]::GetTempPath()) ("kit-harness-test-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempD -Force | Out-Null
try {
    @'
{
  "kitRepoMode": "submodule",
  "harness": {
    "shellGuard": { "mode": "block" }
  }
}
'@ | Set-Content -LiteralPath (Join-Path $tempD ".cursor-kit.json") -Encoding UTF8
    $cfgD = Get-KitHarnessConfig -WorkspaceRoot $tempD
    Assert-Case -Name "D: ParseOk" -Condition ($cfgD.ParseOk -eq $true)
    Assert-Case -Name "D: ShellGuard.Mode block" -Condition ($cfgD.ShellGuard.Mode -eq "block")
}
finally {
    Remove-Item -LiteralPath $tempD -Recurse -Force -ErrorAction SilentlyContinue
}

# Case E (bonus): self without harness.shellGuard.mode -> warn
$tempE = Join-Path ([System.IO.Path]::GetTempPath()) ("kit-harness-test-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempE -Force | Out-Null
try {
    @'
{
  "kitRepoMode": "self"
}
'@ | Set-Content -LiteralPath (Join-Path $tempE ".cursor-kit.json") -Encoding UTF8
    $cfgE = Get-KitHarnessConfig -WorkspaceRoot $tempE
    Assert-Case -Name "E: self default ShellGuard warn" -Condition ($cfgE.ShellGuard.Mode -eq "warn")
}
finally {
    Remove-Item -LiteralPath $tempE -Recurse -Force -ErrorAction SilentlyContinue
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Test-KitHarnessConfig: $($failures.Count) failure(s)."
    exit 1
}

Write-Host ""
Write-Host "Test-KitHarnessConfig: all cases passed."
exit 0
