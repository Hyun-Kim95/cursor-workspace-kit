# Quick check for rule-mine cooldown helpers
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "RuleSignalCommon.ps1")

$root = $script:RuleSignalKitRoot

$c1 = Get-RuleMineCooldownCheck -WorkspaceRoot $root -Prompt "/kit-rule-mine"
$c2 = Get-RuleMineCooldownCheck -WorkspaceRoot $root -Prompt "/kit-rule-mine force"

Write-Host "normal: Proceed=$($c1.Proceed) DaysSince=$($c1.DaysSince) Cooldown=$($c1.CooldownDays)"
Write-Host "force:  Proceed=$($c2.Proceed)"

if (-not $c2.Proceed) { throw "force should always proceed" }
if ($c1.DaysSince -ge 0 -and $c1.DaysSince -lt $c1.CooldownDays -and $c1.Proceed) {
    throw "expected cooldown block when last run within window"
}
Write-Host "OK"
