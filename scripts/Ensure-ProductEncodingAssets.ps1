# Copy kit encoding templates into a product workspace (skip if file already exists).
# SSOT templates: project-kit/.editorconfig, project-kit/.gitattributes
# Called from Invoke-KitStartSetting.ps1 and sync-kit-product.ps1

param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceRoot,
    [Parameter(Mandatory = $true)]
    [string]$KitRoot
)

$ErrorActionPreference = "Stop"
$WorkspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$KitRoot = (Resolve-Path -LiteralPath $KitRoot).Path

$templates = @(
    @{ Rel = "project-kit\.editorconfig"; Name = ".editorconfig" }
    @{ Rel = "project-kit\.gitattributes"; Name = ".gitattributes" }
)

$results = New-Object System.Collections.ArrayList
foreach ($t in $templates) {
    $src = Join-Path $KitRoot $t.Rel
    $dest = Join-Path $WorkspaceRoot $t.Name
    if (-not (Test-Path -LiteralPath $src)) {
        [void]$results.Add("$($t.Name): skip (no template)")
        continue
    }
    if (Test-Path -LiteralPath $dest) {
        [void]$results.Add("$($t.Name): exists")
        continue
    }
    Copy-Item -LiteralPath $src -Destination $dest -Force
    [void]$results.Add("$($t.Name): created")
}

Write-Host ("encoding-assets: " + ($results -join "; "))
