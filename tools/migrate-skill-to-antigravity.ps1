param (
    [Parameter(Mandatory=$false)]
    [string]$SkillPath,

    [Parameter(Mandatory=$false)]
    [switch]$AllSkills,

    [Parameter(Mandatory=$false)]
    [switch]$EnhanceDescription,

    [string]$WorkspaceRoot = (Resolve-Path "$PSScriptRoot\..").Path
)

$SkillsRoot = Join-Path $WorkspaceRoot "skills"
$ErrorActionPreference = "Stop"

# ------------------------------------------
# Get all skill files
# ------------------------------------------
function Get-SkillFiles {
    if ($AllSkills) {
        $skillFiles = Get-ChildItem -Path $SkillsRoot -Recurse -Filter "skill.mdc"
        return $skillFiles
    }
    elseif ($SkillPath) {
        $fullPath = Join-Path $SkillsRoot $SkillPath
        $skillFile = Join-Path $fullPath "skill.mdc"
        if (Test-Path $skillFile) {
            return @(Get-Item $skillFile)
        }
        else {
            Write-Error "Skill file not found: $skillFile"
            return @()
        }
    }
    else {
        Write-Error "Either -SkillPath or -AllSkills must be specified"
        return @()
    }
}

# ------------------------------------------
# Parse frontmatter
# ------------------------------------------
function Get-Frontmatter($filePath) {
    $content = Get-Content $filePath -Raw
    $frontmatterMatch = $content -match '(?s)^---\s+(.*?)\s+---'

    if ($frontmatterMatch) {
        $yamlContent = $matches[1]
        $frontmatter = @{}

        # Simple YAML parsing (basic implementation)
        $yamlContent -split "`n" | ForEach-Object {
            $line = $_.Trim()
            if ($line -and $line -notmatch '^#') {
                if ($line -match '^(\w+):\s*(.+)$') {
                    $key = $matches[1]
                    $value = $matches[2].Trim()

                    # Handle multi-line values
                    if ($value -eq '|') {
                        $frontmatter[$key] = "|"
                    }
                    else {
                        $frontmatter[$key] = $value
                    }
                }
            }
        }

        return $frontmatter
    }

    return $null
}

# ------------------------------------------
# Enhance description
# ------------------------------------------
function Enhance-Description($frontmatter, $skillType) {
    $currentDesc = $frontmatter["description"]

    if ($currentDesc -and $currentDesc.Length -gt 50 -and -not $EnhanceDescription) {
        # Description already seems complete
        return $currentDesc
    }

    # Basic enhancement based on type
    $enhanced = switch ($skillType) {
        "pattern" {
            "$currentDesc`n`nUse when:`n- Implementing {pattern-name} pattern`n- {Scenario 2}`n- {Scenario 3}`n`nTriggers: `"{pattern-name}`", `"{related-keyword}`""
        }
        "structure" {
            "$currentDesc`n`nUse when:`n- Creating new {structure-type} projects`n- {Scenario 2}`n- {Scenario 3}`n`nTriggers: `"{structure-name}`", `"{architecture-type}`""
        }
        "generator" {
            "$currentDesc`n`nUse when:`n- Generating {generated-item}`n- {Scenario 2}`n- {Scenario 3}`n`nTriggers: `"create {item}`", `"generate {item}`", `"scaffold {item}`""
        }
        "template" {
            "$currentDesc`n`nUse when:`n- Creating {template-type}`n- {Scenario 2}`n- {Scenario 3}`n`nTriggers: `"{template-type}`", `"create {item}`""
        }
        default {
            "$currentDesc`n`nUse when:`n- {Scenario 1}`n- {Scenario 2}`n- {Scenario 3}`n`nTriggers: `"{keyword1}`", `"{keyword2}`""
        }
    }

    Write-Warning "Description enhanced (manual review required): $enhanced"
    return $enhanced
}

# ------------------------------------------
# Generate tags based on type
# ------------------------------------------
function Get-DefaultTags($skillType, $name) {
    $tags = @("dotnet")

    switch ($skillType) {
        "pattern" {
            $tags += @("pattern", "clean-architecture")
            if ($name) {
                $tags += $name
            }
        }
        "structure" {
            $tags += @("structure", "architecture")
            if ($name) {
                $tags += $name
            }
        }
        "generator" {
            $tags += @("generator", "scaffolding")
        }
        "template" {
            $tags += @("template", "boilerplate")
        }
    }

    return $tags
}

# ------------------------------------------
# Migrate skill file
# ------------------------------------------
function Migrate-Skill($skillFile) {
    $skillDir = $skillFile.DirectoryName
    $skillMdcPath = $skillFile.FullName
    $skillMdPath = Join-Path $skillDir "SKILL.md"

    Write-Host ""
    Write-Host "Migrating: $skillMdcPath" -ForegroundColor Cyan

    # Read existing content
    $content = Get-Content $skillMdcPath -Raw

    # Parse frontmatter
    $frontmatter = Get-Frontmatter $skillMdcPath
    if (-not $frontmatter) {
        Write-Warning "Could not parse frontmatter, skipping: $skillMdcPath"
        return
    }

    # Enhance description if needed
    $skillType = $frontmatter["type"]
    $skillName = $frontmatter["name"]

    if ($EnhanceDescription -or -not $frontmatter["description"] -or $frontmatter["description"].Length -lt 50) {
        $frontmatter["description"] = Enhance-Description $frontmatter $skillType
    }

    # Add tags if missing
    if (-not $frontmatter["tags"]) {
        $frontmatter["tags"] = Get-DefaultTags $skillType $skillName
    }

    # Build new frontmatter
    $newFrontmatter = "---`n"
    $newFrontmatter += "name: $($frontmatter['name'])`n"
    $newFrontmatter += "description: |`n"

    # Format description with proper indentation
    $descLines = $frontmatter["description"] -split "`n"
    foreach ($line in $descLines) {
        $newFrontmatter += "  $line`n"
    }

    $newFrontmatter += "type: $($frontmatter['type'])`n"
    $newFrontmatter += "version: $($frontmatter['version'])`n"

    # Format tags
    if ($frontmatter["tags"] -is [array]) {
        $newFrontmatter += "tags:`n"
        foreach ($tag in $frontmatter["tags"]) {
            $newFrontmatter += "  - $tag`n"
        }
    }
    else {
        $newFrontmatter += "tags:`n"
        $newFrontmatter += "  - $($frontmatter['tags'])`n"
    }

    $newFrontmatter += "---`n`n"

    # Extract body (content after frontmatter)
    $bodyMatch = $content -match '(?s)^---\s+.*?---\s+(.*)$'
    $body = if ($bodyMatch) { $matches[1] } else { $content }

    # Write new SKILL.md
    $newContent = $newFrontmatter + $body
    Set-Content -Path $skillMdPath -Value $newContent -Encoding UTF8

    Write-Host "  ✓ Created: $skillMdPath" -ForegroundColor Green

    # Create optional directories
    $scriptsDir = Join-Path $skillDir "scripts"
    $referencesDir = Join-Path $skillDir "references"
    $assetsDir = Join-Path $skillDir "assets"

    if (-not (Test-Path $scriptsDir)) {
        New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
        Write-Host "  ✓ Created: $scriptsDir" -ForegroundColor Green
    }

    if (-not (Test-Path $referencesDir)) {
        New-Item -ItemType Directory -Path $referencesDir -Force | Out-Null
        Write-Host "  ✓ Created: $referencesDir" -ForegroundColor Green
    }

    if (-not (Test-Path $assetsDir)) {
        New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
        Write-Host "  ✓ Created: $assetsDir" -ForegroundColor Green
    }

    # Backup old file (rename with .backup)
    $backupPath = $skillMdcPath + ".backup"
    Copy-Item -Path $skillMdcPath -Destination $backupPath -Force
    Write-Host "  ✓ Backed up: $backupPath" -ForegroundColor Yellow

    Write-Host "  ⚠ Manual review required for description and tags" -ForegroundColor Yellow
}

# ------------------------------------------
# Main Execution
# ------------------------------------------

Write-Host "Skill Migration Tool" -ForegroundColor Cyan
Write-Host "Workspace Root: $WorkspaceRoot" -ForegroundColor Gray
Write-Host ""

$skillFiles = Get-SkillFiles

if ($skillFiles.Count -eq 0) {
    Write-Warning "No skill files found to migrate"
    exit 0
}

Write-Host "Found $($skillFiles.Count) skill file(s) to migrate" -ForegroundColor Cyan
Write-Host ""

foreach ($skillFile in $skillFiles) {
    try {
        Migrate-Skill $skillFile
    }
    catch {
        Write-Error "Failed to migrate $($skillFile.FullName): $_"
    }
}

Write-Host ""
Write-Host "Migration completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review and enhance descriptions manually" -ForegroundColor Gray
Write-Host "2. Verify tags are appropriate" -ForegroundColor Gray
Write-Host "3. Test SKILL.md files" -ForegroundColor Gray
Write-Host "4. Remove .backup files after verification" -ForegroundColor Gray
