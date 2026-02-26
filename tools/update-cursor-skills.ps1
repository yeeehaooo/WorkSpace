param (
  [string]$WorkspaceRoot = (Resolve-Path "$PSScriptRoot\..").Path
)

$ProjectsRoot = Join-Path $WorkspaceRoot "Projects"
$SkillsRoot = Join-Path $WorkspaceRoot "skills"
$AgentRoot = Join-Path $WorkspaceRoot "agent"

Write-Host "Workspace Root: $WorkspaceRoot"
Write-Host ""

# ------------------------------------------
# Get Project Folders
# ------------------------------------------
function Get-ProjectFolders {
  if (!(Test-Path $ProjectsRoot)) {
    Write-Warning "Projects folder not found."
    return @()
  }

  return Get-ChildItem $ProjectsRoot -Directory
}

# ------------------------------------------
# Read Project Profile (with migration)
# ------------------------------------------
function Get-ProjectProfile($projectPath) {

  $profilePath = Join-Path $projectPath ".ai\project-profile.json"

  if (!(Test-Path $profilePath)) {
    Write-Warning "No project-profile.json in $projectPath"
    Write-Warning "Creating default profile for migration..."

    $default = @{
      governance = "v1"
      skills     = @("_shared/core")
    } | ConvertTo-Json -Depth 5

    $profileDir = Split-Path $profilePath -Parent
    if (!(Test-Path $profileDir)) {
      New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    }

    Set-Content -Path $profilePath -Value $default -Encoding UTF8
    Write-Host "Created default profile: $profilePath"
  }

  try {
    return Get-Content $profilePath -Raw | ConvertFrom-Json
  }
  catch {
    Write-Error "Invalid JSON in $profilePath"
    return $null
  }
}

# ------------------------------------------
# Validate Skill Path
# ------------------------------------------
function Validate-SkillPath($skillPath) {

  $fullPath = Join-Path $SkillsRoot $skillPath

  if (!(Test-Path $fullPath)) {
    Write-Warning "Skill path not found: skills/$skillPath"
    return $false
  }

  # Check if it's a directory or file
  $item = Get-Item $fullPath
  if ($item.PSIsContainer) {
    # Directory: Check for skill file (new format SKILL.md or old format skill.mdc)
    $skillMdPath = Join-Path $fullPath "SKILL.md"
    $skillMdcPath = Join-Path $fullPath "skill.mdc"
    $skillMdPathAlt = Join-Path $fullPath "skill.md"

    # For _shared, also check for any .md files in the directory
    $hasSkillFile = (Test-Path $skillMdPath) -or (Test-Path $skillMdcPath) -or (Test-Path $skillMdPathAlt)

    if (!$hasSkillFile) {
      # Check for any .md files in directory (for _shared skills)
      $mdFiles = Get-ChildItem -Path $fullPath -Filter "*.md" -File
      if ($mdFiles.Count -eq 0) {
        Write-Warning "Skill file not found in: skills/$skillPath (looking for SKILL.md, skill.mdc, skill.md, or any .md file)"
        return $false
      }
    }
  }
  else {
    # It's a file, check if it's .md
    if ($item.Extension -ne ".md") {
      Write-Warning "Skill file is not .md: skills/$skillPath"
      return $false
    }
  }

  return $true
}

# ------------------------------------------
# Validate Governance
# ------------------------------------------
function Validate-Governance($gov) {

  $fullPath = Join-Path $AgentRoot $gov

  if (!(Test-Path $fullPath)) {
    Write-Error "Governance not found: agent/$gov"
    return $false
  }

  return $true
}

# ------------------------------------------
# Get Skill Metadata
# ------------------------------------------
function Get-SkillMetadata($skillPath) {
  $fullPath = Join-Path $SkillsRoot $skillPath

  # Check if it's a directory or file
  $item = Get-Item $fullPath
  $skillFile = $null

  if ($item.PSIsContainer) {
    # Directory: Try new format first, then old format
    $skillMdPath = Join-Path $fullPath "SKILL.md"
    $skillMdcPath = Join-Path $fullPath "skill.mdc"
    $skillMdPathAlt = Join-Path $fullPath "skill.md"

    if (Test-Path $skillMdPath) {
      $skillFile = Get-Item $skillMdPath
    }
    elseif (Test-Path $skillMdcPath) {
      $skillFile = Get-Item $skillMdcPath
    }
    elseif (Test-Path $skillMdPathAlt) {
      $skillFile = Get-Item $skillMdPathAlt
    }
    else {
      # For _shared, check for any .md files in the directory
      $mdFiles = Get-ChildItem -Path $fullPath -Filter "*.md" -File
      if ($mdFiles.Count -gt 0) {
        $skillFile = $mdFiles[0]  # Use first .md file found
      }
    }
  }
  else {
    # It's a file, use it directly if it's .md
    if ($item.Extension -eq ".md") {
      $skillFile = $item
    }
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
  }

  # Extract name
  if ($yamlContent -match 'name\s*:\s*(.+)') {
    $metadata.Name = $matches[1].Trim()
  }

  # Extract description (handle multi-line, get first line only for brevity)
  if ($yamlContent -match '(?s)description\s*:\s*\|\s*\n(.*?)(?=\n\w+\s*:|$)') {
    $fullDesc = $matches[1].Trim()
    # Get first meaningful line (skip empty lines)
    $descLines = $fullDesc -split "`n" | Where-Object { $_.Trim() -ne "" }
    $metadata.Description = if ($descLines.Count -gt 0) { $descLines[0].Trim() } else { "" }
  }
  elseif ($yamlContent -match 'description\s*:\s*(.+)') {
    $metadata.Description = $matches[1].Trim()
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
# Write 90-active-skills.mdc (Metadata Only)
# ------------------------------------------
function Write-90-Simple($projectPath, $governance, $skills) {

  $rulesPath = Join-Path $projectPath ".cursor\rules"

  if (!(Test-Path $rulesPath)) {
    New-Item -ItemType Directory -Force -Path $rulesPath | Out-Null
  }

  $filePath = Join-Path $rulesPath "90-active-skills.mdc"

  $content = @"
---
alwaysApply: true
---

# Active Skills (Metadata Only)

CRITICAL: This file contains ONLY metadata. DO NOT load full SKILL.md files.
Paths are NOT included to prevent auto-loading. Use skill names only for discovery.

## Governance
- /agent/$governance

## Available Skills

The following skills are available. Load full SKILL.md ONLY when explicitly triggered by user request.

"@

  foreach ($skill in $skills) {
    $metadata = Get-SkillMetadata $skill

    if ($metadata) {
      $tagsStr = if ($metadata.Tags -and $metadata.Tags.Count -gt 0) { " | Tags: $($metadata.Tags -join ', ')" } else { "" }
      if ($metadata.Description) {
        $desc = if ($metadata.Description.Length -gt 100) {
          $metadata.Description.Substring(0, 100) + "..."
        } else {
          $metadata.Description
        }
      } else {
        $desc = "No description"
      }

      $skillName = if ($metadata.Name) { $metadata.Name } else { $skill }
      # Remove path to prevent auto-loading - only include name and description
      $content += "`n- $skillName - $desc$tagsStr"
    }
    else {
      # Fallback if metadata extraction fails - use skill name only, no path
      $skillName = $skill -replace '.*/', ''
      $content += "`n- $skillName"
    }
  }

  $content += "`n`n## Usage Rules`n`n"
  $content += "1. Metadata Only: This file provides lightweight metadata (~100 tokens/skill)`n"
  $content += "2. Triggered Load: Load full SKILL.md only when skill matches user request`n"
  $content += "3. No Auto-Load: DO NOT automatically load all SKILL.md files listed here`n"
  $content += "4. Progressive Disclosure: Use metadata for discovery, load body only when needed`n`n"
  $content += "## Notes`n`n"
  $content += "- This file is auto-generated. DO NOT EDIT MANUALLY.`n"
  $content += "- Paths are intentionally omitted to prevent auto-loading`n"
  $content += "- To load a skill, search for skill name in /skills/ directory`n"

  Set-Content -Path $filePath -Value $content -Encoding UTF8

  Write-Host "Generated: $filePath"
}

# ------------------------------------------
# Main Execution
# ------------------------------------------

$projects = Get-ProjectFolders

foreach ($project in $projects) {

  Write-Host ""
  Write-Host "Processing project: $($project.Name)"

  $projectProfile = Get-ProjectProfile $project.FullName

  if ($null -eq $projectProfile) {
    continue
  }

  if (-not $projectProfile.governance) {
    Write-Error "Missing governance in project-profile.json"
    continue
  }

  if (-not (Validate-Governance $projectProfile.governance)) {
    continue
  }

  $validSkills = @()

  foreach ($skill in $projectProfile.skills) {
    if (Validate-SkillPath $skill) {
      $validSkills += $skill
    }
  }

  Write-90-Simple $project.FullName $projectProfile.governance $validSkills
}

Write-Host ""
Write-Host "Done."
