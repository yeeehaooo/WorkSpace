param (
    [string]$WorkspaceRoot = (Resolve-Path "$PSScriptRoot\..").Path
)

$SkillsRoot = Join-Path $WorkspaceRoot "skills"
$RulesPath = Join-Path $WorkspaceRoot ".cursor\rules"

# ------------------------------------------
# Get skill metadata
# ------------------------------------------
function Get-SkillMetadata($skillPath) {
    $fullPath = Join-Path $SkillsRoot $skillPath

    # Try new format first, then old format
    $skillMdPath = Join-Path $fullPath "SKILL.md"
    $skillMdcPath = Join-Path $fullPath "skill.mdc"
    $skillMdPathAlt = Join-Path $fullPath "skill.md"

    $skillFile = $null
    if (Test-Path $skillMdPath) {
        $skillFile = Get-Item $skillMdPath
    }
    elseif (Test-Path $skillMdcPath) {
        $skillFile = Get-Item $skillMdcPath
    }
    elseif (Test-Path $skillMdPathAlt) {
        $skillFile = Get-Item $skillMdPathAlt
    }

    if (-not $skillFile) {
        return $null
    }

    $content = Get-Content $skillFile.FullName -Raw
    $frontmatterMatch = $content -match '(?s)^---\s+(.*?)\s+---'

    if (-not $frontmatterMatch) {
        return $null
    }

    $yamlContent = $matches[1]
    $metadata = @{
        Path = $skillPath
        File = $skillFile.Name
    }

    # Extract name
    if ($yamlContent -match 'name\s*:\s*(.+)') {
        $metadata.Name = $matches[1].Trim()
    }

    # Extract description (handle multi-line)
    if ($yamlContent -match '(?s)description\s*:\s*\|\s*\n(.*?)(?=\n\w+\s*:|$)') {
        $metadata.Description = $matches[1].Trim()
    }
    elseif ($yamlContent -match 'description\s*:\s*(.+)') {
        $metadata.Description = $matches[1].Trim()
    }

    # Extract type
    if ($yamlContent -match 'type\s*:\s*(.+)') {
        $metadata.Type = $matches[1].Trim()
    }

    # Extract version
    if ($yamlContent -match 'version\s*:\s*(.+)') {
        $metadata.Version = $matches[1].Trim()
    }

    # Extract tags
    $tags = @()
    if ($yamlContent -match '(?s)tags\s*:\s*\n((?:\s*-\s*.+\n?)+)') {
        $tagsContent = $matches[1]
        $tagsMatches = [regex]::Matches($tagsContent, '^\s*-\s*(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
        foreach ($match in $tagsMatches) {
            $tags += $match.Groups[1].Value.Trim()
        }
    }
    $metadata.Tags = $tags

    return $metadata
}

# ------------------------------------------
# Generate metadata registry
# ------------------------------------------
function Generate-MetadataRegistry($activeSkills) {
    $registry = @"
# Active Skills Metadata

This file is auto-generated. DO NOT EDIT MANUALLY.

## Skills

"@

    foreach ($skillPath in $activeSkills) {
        $metadata = Get-SkillMetadata $skillPath

        if ($metadata) {
            $registry += "### $($metadata.Name)`n`n"
            $registry += "- **Path**: `/skills/$skillPath`\n"
            $registry += "- **Type**: $($metadata.Type)\n"
            $registry += "- **Version**: $($metadata.Version)\n"

            if ($metadata.Tags.Count -gt 0) {
                $registry += "- **Tags**: $($metadata.Tags -join ', ')\n"
            }

            $registry += "- **Description**:\n"
            $descLines = $metadata.Description -split "`n"
            foreach ($line in $descLines) {
                $registry += "  $line`n"
            }

            $registry += "`n"
        }
    }

    return $registry
}

# ------------------------------------------
# Main Execution
# ------------------------------------------

Write-Host "Extracting skill metadata..." -ForegroundColor Cyan

# This would normally read from project-profile.json
# For now, we'll scan all skills
$allSkills = @()

Get-ChildItem -Path $SkillsRoot -Recurse -Directory | ForEach-Object {
    $skillPath = $_.FullName.Replace($SkillsRoot, "").TrimStart("\")

    # Check if it's a skill directory (has skill file)
    $skillMdPath = Join-Path $_.FullName "SKILL.md"
    $skillMdcPath = Join-Path $_.FullName "skill.mdc"
    $skillMdPathAlt = Join-Path $_.FullName "skill.md"

    if ((Test-Path $skillMdPath) -or (Test-Path $skillMdcPath) -or (Test-Path $skillMdPathAlt)) {
        $allSkills += $skillPath
    }
}

Write-Host "Found $($allSkills.Count) skills" -ForegroundColor Gray

# Generate registry (for now, using all skills - in production, use active skills from project-profile.json)
$registry = Generate-MetadataRegistry $allSkills

# Write to file (this would be integrated into update-cursor-skills.ps1)
Write-Host "Metadata extraction completed" -ForegroundColor Green
