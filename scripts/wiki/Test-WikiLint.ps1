# Deterministic kit-wiki lint for CI (PR trigger) and local runs.
# SSOT checks align with docs/wiki/README.md and shared/skills/kit-wiki/SKILL.md.
# Does not invoke LLM. Read-only on wiki files (no auto-fix in CI).
param(
    [string]$WorkspaceRoot = "",
    [string]$StatePath = "",
    [switch]$FailOnWarning
)

$ErrorActionPreference = "Stop"

$ScriptsDir = $PSScriptRoot
if (-not $ScriptsDir) { $ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$KitRoot = if ($WorkspaceRoot) { $WorkspaceRoot } else { (Resolve-Path (Join-Path $ScriptsDir "..\..")).Path }
$WikiDir = Join-Path $KitRoot "docs\wiki"
$IndexPath = Join-Path $WikiDir "index.md"

$common = Join-Path $KitRoot "scripts\Kit-HookCommon.ps1"
if (Test-Path -LiteralPath $common) { . $common }

function Read-TextFile {
    param([string]$Path)
    if (Get-Command Read-KitUtf8File -ErrorAction SilentlyContinue) {
        return Read-KitUtf8File -Path $Path
    }
    return [System.IO.File]::ReadAllText($Path, (New-Object System.Text.UTF8Encoding $false))
}

function Get-MarkdownFrontmatter {
    param([string]$Content)
    if ($Content -notmatch '(?s)\A---\r?\n(.*?)\r?\n---') { return $null }
    $block = $Matches[1]
    $fm = @{}
    foreach ($line in ($block -split '\r?\n')) {
        if ($line -match '^\s*([A-Za-z0-9_]+)\s*:\s*(.+)\s*$') {
            $fm[$Matches[1]] = $Matches[2].Trim()
        }
    }
    return $fm
}

function Get-WikiNoteFiles {
    $files = @()
    foreach ($f in (Get-ChildItem -LiteralPath $WikiDir -Filter "*.md" -File -ErrorAction SilentlyContinue)) {
        $name = $f.Name
        if ($name -eq "README.md" -or $name -eq "index.md") { continue }
        $rel = $f.FullName.Substring($WikiDir.Length + 1)
        if ($rel -like "_templates\*") { continue }
        $files += $f
    }
    return $files
}

function Get-WikiNoteSlug {
    param([string]$FileName)
    return [System.IO.Path]::GetFileNameWithoutExtension($FileName)
}

function Get-IndexLinkedSlugs {
    param([string]$IndexContent)
    $slugs = New-Object System.Collections.Generic.HashSet[string]
    foreach ($m in [regex]::Matches($IndexContent, '\[\[([^\]|#]+)(?:\|[^\]]+)?\]\]')) {
        $target = $m.Groups[1].Value.Trim()
        if ($target -notmatch '[/\\]') {
            [void]$slugs.Add($target)
        }
    }
    return $slugs
}

function Get-LocalWikilinkTargets {
    param([string]$Content)
    # Ignore [[...]] inside inline code spans (e.g. `[[링크]]` in prose)
    $scan = [regex]::Replace($Content, '`[^`]*`', '')
    $targets = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($scan, '\[\[([^\]|#]+)(?:\|[^\]]+)?\]\]')) {
        $t = $m.Groups[1].Value.Trim()
        if ($t -notmatch '[/\\]') {
            $targets.Add($t)
        }
    }
    return $targets
}

# Redaction: fail (block) vs warn — mirrors README table
$RedactionFailPatterns = @(
    @{ Name = "email";        Regex = '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' },
    @{ Name = "openai-key";   Regex = 'sk-[A-Za-z0-9]{20,}' },
    @{ Name = "aws-key";      Regex = 'AKIA[0-9A-Z]{16}' },
    @{ Name = "bearer";       Regex = 'Bearer\s+[A-Za-z0-9._-]+' },
    @{ Name = "credential";   Regex = '(?i)(token|secret|api[_-]?key|password)\s*[:=]\s*\S+' },
    @{ Name = "abs-path";     Regex = '([A-Za-z]:\\Users\\|/Users/|/home/)' }
)
$RedactionWarnPatterns = @(
    @{ Name = "long-hex";     Regex = '\b[0-9a-fA-F]{32,}\b' },
    @{ Name = "card-like";    Regex = '\b(?:\d[ -]?){13,16}\b' },
    @{ Name = "id-like";      Regex = '\b\d{6}[- ]?\d{7}\b' }
)

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $WikiDir)) {
    $errors.Add("docs/wiki/ directory not found at $WikiDir")
}
else {
    $indexContent = ""
    if (Test-Path -LiteralPath $IndexPath) {
        $indexContent = Read-TextFile -Path $IndexPath
        $indexFm = Get-MarkdownFrontmatter -Content $indexContent
        if (-not $indexFm -or $indexFm.type -ne "wiki-index") {
            $warnings.Add("index.md: expected frontmatter type: wiki-index")
        }
    }
    else {
        $errors.Add("docs/wiki/index.md (MOC) is missing")
    }

    $indexSlugs = if ($indexContent) { Get-IndexLinkedSlugs -IndexContent $indexContent } else { @() }
    $knownSlugs = New-Object System.Collections.Generic.HashSet[string]
    foreach ($f in (Get-WikiNoteFiles)) {
        [void]$knownSlugs.Add((Get-WikiNoteSlug -FileName $f.Name))
    }

    foreach ($file in (Get-WikiNoteFiles)) {
        $path = $file.FullName
        $rel = "docs/wiki/$($file.Name)"
        $content = Read-TextFile -Path $path
        $fm = Get-MarkdownFrontmatter -Content $content
        $slug = Get-WikiNoteSlug -FileName $file.Name

        if (-not $fm) {
            $errors.Add("$rel : missing frontmatter")
            continue
        }
        if ($fm.type -ne "wiki-note") {
            continue
        }
        if (-not $fm.updated_at) {
            $errors.Add("$rel : frontmatter missing updated_at")
        }
        if (-not $fm.review) {
            $errors.Add("$rel : frontmatter missing review (pending|done)")
        }
        elseif ($fm.review -notmatch '^(pending|done)') {
            $errors.Add("$rel : invalid review value '$($fm.review)'")
        }

        if ($indexContent -and -not $indexSlugs.Contains($slug)) {
            $warnings.Add("$rel : not linked from docs/wiki/index.md (orphan candidate)")
        }

        if ($fm.review -match '^pending' -and $content -notmatch '(?m)^##\s+검토 필요\s*$') {
            $warnings.Add("$rel : review pending but missing '## 검토 필요' section")
        }

        foreach ($pat in $RedactionFailPatterns) {
            if ([regex]::IsMatch($content, $pat.Regex)) {
                $errors.Add("$rel : redaction fail ($($pat.Name)) — possible secret/PII; see docs/wiki/README.md")
            }
        }
        foreach ($pat in $RedactionWarnPatterns) {
            if ([regex]::IsMatch($content, $pat.Regex)) {
                $warnings.Add("$rel : redaction warn ($($pat.Name)) — confirm or mask")
            }
        }

        foreach ($target in (Get-LocalWikilinkTargets -Content $content)) {
            if ($target -eq "index") { continue }
            if (-not $knownSlugs.Contains($target) -and $target -ne $slug) {
                $warnings.Add("$rel : broken local wikilink [[$target]]")
            }
        }
    }
}

$ok = ($errors.Count -eq 0)
if ($FailOnWarning -and $warnings.Count -gt 0) { $ok = $false }

$pendingNotes = @()
foreach ($file in (Get-WikiNoteFiles)) {
    $content = Read-TextFile -Path $file.FullName
    $fm = Get-MarkdownFrontmatter -Content $content
    if ($fm -and $fm.type -eq "wiki-note" -and $fm.review -match '^pending') {
        $pendingNotes += $file.Name
    }
}

$orphans = @($warnings | Where-Object { $_ -match 'orphan candidate' })

$result = @{
    ok            = $ok
    version       = 1
    checkedAt     = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    wikiDir       = "docs/wiki"
    errorCount    = $errors.Count
    warningCount  = $warnings.Count
    errors        = @($errors)
    warnings      = @($warnings)
    pendingReview = $pendingNotes
    orphanCount   = $orphans.Count
}

$stateOut = if ($StatePath) {
    $StatePath
}
else {
    Join-Path $KitRoot ".cursor\state\wiki-loop-last.json"
}

$stateDir = Split-Path -Parent $stateOut
if ($stateDir -and -not (Test-Path -LiteralPath $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}
if (Get-Command Write-KitJsonFile -ErrorAction SilentlyContinue) {
    Write-KitJsonFile -Path $stateOut -Object $result -Depth 6
}
else {
    $json = $result | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($stateOut, $json, (New-Object System.Text.UTF8Encoding $false))
}

Write-Host "kit-wiki lint (deterministic): ok=$ok errors=$($errors.Count) warnings=$($warnings.Count)"
foreach ($e in $errors) { Write-Host "ERROR: $e" }
foreach ($w in $warnings) { Write-Host "WARN:  $w" }
Write-Host "State: $stateOut"

if ($env:GITHUB_STEP_SUMMARY) {
    $summary = @"
## kit-wiki lint (PR)

| | |
|---|---|
| **Result** | $(if ($ok) { 'PASS' } else { 'FAIL' }) |
| **Errors** | $($errors.Count) |
| **Warnings** | $($warnings.Count) |
| **Pending review** | $($pendingNotes.Count) |
| **Index orphans** | $($orphans.Count) |

"@
    if ($errors.Count -gt 0) {
        $summary += "### Errors`n"
        foreach ($e in $errors) { $summary += "- $e`n" }
    }
    if ($warnings.Count -gt 0) {
        $summary += "### Warnings`n"
        foreach ($w in $warnings) { $summary += "- $w`n" }
    }
    Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value $summary -Encoding UTF8
}

if (-not $ok) { exit 1 }
exit 0
