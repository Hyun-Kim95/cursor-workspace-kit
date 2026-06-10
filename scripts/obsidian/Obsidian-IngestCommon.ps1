# Shared .obsidian-ingest.json readers for Obsidian scripts (PowerShell 5.1)

function Get-ObsidianIngestPath {
    param([Parameter(Mandatory = $true)][string]$RepoPath)
    return Join-Path $RepoPath ".obsidian-ingest.json"
}

function Get-ObsidianIngestSettings {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [string]$DefaultVaultRoot = "D:\Obsidian\projects"
    )

    $ingestPath = Get-ObsidianIngestPath -RepoPath $RepoPath
    $folderSlug = Split-Path -Path $RepoPath -Leaf

    $settings = [ordered]@{
        Slug          = $folderSlug
        VaultRoot     = $DefaultVaultRoot
        DocsPaths     = @("docs")
        SyncMode      = "safe"
        LockSlug      = $false
        DisplayName   = ""
        HubFileStem   = ""
        CommitJournal = $false
        IngestPath    = $ingestPath
        HasConfigFile = $false
    }

    if (-not (Test-Path -LiteralPath $ingestPath)) {
        return $settings
    }

    try {
        $raw = Get-Content -LiteralPath $ingestPath -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($raw)) {
            return $settings
        }
        $cfg = $raw | ConvertFrom-Json
        $settings.HasConfigFile = $true

        if (-not [string]::IsNullOrWhiteSpace([string]$cfg.slug)) {
            $settings.Slug = [string]$cfg.slug
        }
        if (-not [string]::IsNullOrWhiteSpace([string]$cfg.vaultRoot)) {
            $settings.VaultRoot = [string]$cfg.vaultRoot
        }
        if ($cfg.docsPaths -and @($cfg.docsPaths).Count -gt 0) {
            $settings.DocsPaths = @($cfg.docsPaths | ForEach-Object { [string]$_ })
        }
        $syncProp = $cfg.PSObject.Properties['syncMode']
        if ($null -ne $syncProp -and -not [string]::IsNullOrWhiteSpace([string]$syncProp.Value)) {
            $settings.SyncMode = [string]$syncProp.Value
        }
        $lockProp = $cfg.PSObject.Properties['lockSlug']
        if ($null -ne $lockProp -and $null -ne $lockProp.Value) {
            $settings.LockSlug = [bool]$lockProp.Value
        }
        $dnProp = $cfg.PSObject.Properties['displayName']
        if ($null -ne $dnProp -and -not [string]::IsNullOrWhiteSpace([string]$dnProp.Value)) {
            $settings.DisplayName = [string]$dnProp.Value
        }
        $hfProp = $cfg.PSObject.Properties['hubFileStem']
        if ($null -ne $hfProp -and -not [string]::IsNullOrWhiteSpace([string]$hfProp.Value)) {
            $settings.HubFileStem = [string]$hfProp.Value
        }
        $cjProp = $cfg.PSObject.Properties['commitJournal']
        if ($null -ne $cjProp -and $null -ne $cjProp.Value) {
            $settings.CommitJournal = [bool]$cjProp.Value
        }
    }
    catch {
        # fail-open: defaults above
    }

    return $settings
}
