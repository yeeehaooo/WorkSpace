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
# Write 90-active-skills.mdc
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

# Governance
- /agent/$governance

# Active Skills
Use the following skill packs as reference:
"@

  foreach ($skill in $skills) {
    $content += "`n- /skills/$skill"
  }

  $content += @"
`n
Notes:
- This file is auto-generated.
- DO NOT EDIT MANUALLY.
"@

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
