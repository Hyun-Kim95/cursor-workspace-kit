# Product: copy to .cursor/hooks/ — or re-run /start-setting to refresh from kit submodule.
# Full hook lives in kit at .cursor/hooks/kit-start-on-prompt.ps1 after submodule add.

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

$kitPath = "vendor/cursor-workspace-kit"
$configPath = Join-Path $projectRoot ".cursor-kit.json"
if (Test-Path -LiteralPath $configPath) {
    $cfg = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($cfg.kitPath) { $kitPath = [string]$cfg.kitPath }
}

$delegated = Join-Path $projectRoot (Join-Path $kitPath ".cursor\hooks\kit-start-on-prompt.ps1")
if (Test-Path -LiteralPath $delegated) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $delegated
    exit $LASTEXITCODE
}

[Console]::Out.WriteLine('{"continue":false,"user_message":"Kit hook missing. Run: powershell -File vendor/cursor-workspace-kit/scripts/Invoke-KitStartSetting.ps1 -WorkspaceRoot ."}')
exit 2
