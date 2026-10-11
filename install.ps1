# Flow Driven Development installer for Windows PowerShell 5.1+ / PowerShell 7+
# Usage: .\install.ps1 -Project 'C:\src\my-project' -Agent Both [-DryRun]
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Project = '.',
    [ValidateSet('Both', 'Claude', 'Codex')]
    [string]$Agent = 'Both',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$kit = $PSScriptRoot
$projectPath = (Resolve-Path -LiteralPath $Project).ProviderPath
if (-not (Test-Path -LiteralPath $projectPath -PathType Container)) {
    throw "Project directory does not exist: $projectPath"
}

$writes = New-Object 'System.Collections.Generic.List[object]'
$skipped = New-Object 'System.Collections.Generic.List[string]'
$conflicts = New-Object 'System.Collections.Generic.List[string]'
$utf8 = [System.Text.UTF8Encoding]::new($false)
$start = '<!-- FDD:START -->'
$end = '<!-- FDD:END -->'

function Plan-Copy {
    param([string]$Source, [string]$Relative, [switch]$KeepExisting)
    $destination = Join-Path $projectPath $Relative
    if (Test-Path -LiteralPath $destination) {
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
            $conflicts.Add("Not a regular file: $Relative")
        } elseif ($KeepExisting) {
            $skipped.Add("Preserved $Relative")
        } elseif ((Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash -eq
                  (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash) {
            $skipped.Add("Unchanged $Relative")
        } else {
            $conflicts.Add("Different existing file: $Relative")
        }
    } else {
        $writes.Add([pscustomobject]@{ Target = $destination; Source = $Source; Text = $null })
    }
}

function Merge-Policy {
    param([string]$Existing, [string]$Block, [string]$Name)
    $startMatches = [regex]::Matches($Existing, [regex]::Escape($start))
    $endMatches = [regex]::Matches($Existing, [regex]::Escape($end))
    if ($startMatches.Count -ne $endMatches.Count -or $startMatches.Count -gt 1) {
        throw "Invalid or duplicate FDD markers in $Name"
    }
    $newline = if ($Existing.Contains("`r`n")) { "`r`n" } else { "`n" }
    $snippet = [regex]::Replace($Block.Trim([char[]]"`r`n"), '\r\n|\r|\n', $newline)
    if ($startMatches.Count -eq 0) {
        if ($Existing.Length -eq 0) { return $snippet + $newline }
        $separator = if ($Existing.EndsWith("`n")) { $newline } else { $newline + $newline }
        return $Existing + $separator + $snippet + $newline
    }
    $startAt = $startMatches[0].Index
    $endAt = $endMatches[0].Index
    if ($endAt -lt $startAt) { throw "Reversed FDD markers in $Name" }
    return $Existing.Substring(0, $startAt) + $snippet + $Existing.Substring($endAt + $end.Length)
}

function Plan-Policy {
    param([string]$Name, [string]$Template)
    $destination = Join-Path $projectPath $Name
    if ((Test-Path -LiteralPath $destination) -and
        -not (Test-Path -LiteralPath $destination -PathType Leaf)) {
        $conflicts.Add("Not a regular file: $Name")
        return
    }
    $existing = if (Test-Path -LiteralPath $destination) {
        [System.IO.File]::ReadAllText($destination, [System.Text.Encoding]::UTF8)
    } else { '' }
    try {
        $block = [System.IO.File]::ReadAllText($Template, [System.Text.Encoding]::UTF8)
        $merged = Merge-Policy -Existing $existing -Block $block -Name $Name
        if ($merged -ceq $existing) {
            $skipped.Add("Unchanged $Name")
        } else {
            $writes.Add([pscustomobject]@{ Target = $destination; Source = $null; Text = $merged })
        }
    } catch {
        $conflicts.Add($_.Exception.Message)
    }
}

foreach ($name in @('index.md', '_template.md')) {
    Plan-Copy -Source (Join-Path $kit "templates/flows/$name") -Relative "docs/flows/$name" -KeepExisting
}

$providers = if ($Agent -eq 'Both') { @('Claude', 'Codex') } else { @($Agent) }
foreach ($provider in $providers) {
    $base = if ($provider -eq 'Claude') { '.claude/skills' } else { '.agents/skills' }
    foreach ($skill in @('flow-bootstrap', 'flow-develop', 'flow-verify')) {
        Plan-Copy -Source (Join-Path $kit "skills/$skill/SKILL.md") -Relative "$base/$skill/SKILL.md"
    }
    if ($provider -eq 'Claude') {
        Plan-Policy -Name 'CLAUDE.md' -Template (Join-Path $kit 'templates/policies/CLAUDE.block.md')
    } else {
        Plan-Policy -Name 'AGENTS.md' -Template (Join-Path $kit 'templates/policies/AGENTS.block.md')
    }
}

if ($conflicts.Count -gt 0) {
    throw "Installation cancelled; no files written. Conflicts:`n - $($conflicts -join "`n - ")"
}

foreach ($write in $writes) {
    $relative = $write.Target.Substring($projectPath.TrimEnd([char[]]@('\', '/')).Length).TrimStart([char[]]@('\', '/'))
    if ($DryRun) {
        Write-Output "Would write $relative"
        continue
    }
    $directory = Split-Path -Parent $write.Target
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    if ($null -ne $write.Source) {
        Copy-Item -LiteralPath $write.Source -Destination $write.Target
    } else {
        [System.IO.File]::WriteAllText($write.Target, $write.Text, $utf8)
    }
    Write-Output "Wrote $relative"
}
foreach ($item in $skipped) { Write-Output $item }
$verb = if ($DryRun) { 'Planned' } else { 'Installed' }
Write-Output "${verb}: $($writes.Count) files; $($skipped.Count) preserved/unchanged."
