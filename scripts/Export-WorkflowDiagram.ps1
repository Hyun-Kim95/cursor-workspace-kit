# Export polished workflow diagram (SVG SSOT -> PNG).
# Topology matches cursor-workflow-detailed.html; visuals are infographic-style SVG.
# AI-generated PNG is NOT used (arrow placement unreliable).

param(
    [string]$WorkspaceRoot = "",
    [string]$OutPath = "",
    [int]$ViewportWidth = 3200,
    [int]$ViewportHeight = 1960,
    [int]$WaitMs = 1500
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

$buildScript = Join-Path $WorkspaceRoot "scripts\build-workflow-svg.py"
$svgFile = Join-Path $WorkspaceRoot "assets\ai-development-workflow.svg"
if (-not (Test-Path -LiteralPath $buildScript)) {
    throw "Build script not found: $buildScript"
}

if ([string]::IsNullOrWhiteSpace($OutPath)) {
    $OutPath = Join-Path $WorkspaceRoot "assets\ai-development-workflow.png"
}

$outDir = Split-Path -Parent $OutPath
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

Write-Host "Build SVG (infographic)"
& python $buildScript
if ($LASTEXITCODE -ne 0) {
    throw "build-workflow-svg.py failed (exit $LASTEXITCODE)"
}
if (-not (Test-Path -LiteralPath $svgFile)) {
    throw "SVG was not created: $svgFile"
}

$resolvedSvg = (Resolve-Path -LiteralPath $svgFile).Path
$fileUri = ([System.Uri]::new($resolvedSvg)).AbsoluteUri

Write-Host "Export PNG"
Write-Host "  Source: $fileUri"
Write-Host "  Output: $OutPath"

$playwrightArgs = @(
    "playwright", "screenshot",
    "--viewport-size=$ViewportWidth,$ViewportHeight",
    "--wait-for-timeout=$WaitMs",
    $fileUri,
    $OutPath
)

Push-Location $WorkspaceRoot
try {
    & npx --yes @playwrightArgs
    if ($LASTEXITCODE -ne 0) {
        throw "playwright screenshot failed (exit $LASTEXITCODE)"
    }
}
finally {
    Pop-Location
}

if (-not (Test-Path -LiteralPath $OutPath)) {
    throw "PNG was not created: $OutPath"
}

Write-Host "Done: $OutPath"
