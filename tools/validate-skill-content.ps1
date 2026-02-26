param (
    [Parameter(Mandatory=$false)]
    [string]$SkillPath,

    [Parameter(Mandatory=$false)]
    [switch]$AllSkills,

    [string]$WorkspaceRoot = (Resolve-Path "$PSScriptRoot\..").Path
)

$SkillsRoot = Join-Path $WorkspaceRoot "skills"
$ErrorActionPreference = "Continue"

$validationResults = @()

# ------------------------------------------
# Get all skill files
# ------------------------------------------
function Get-SkillFiles {
    if ($AllSkills) {
        $skillFiles = @()
        $skillFiles += Get-ChildItem -Path $SkillsRoot -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue
        $skillFiles += Get-ChildItem -Path $SkillsRoot -Recurse -Filter "skill.mdc" -ErrorAction SilentlyContinue
        return $skillFiles
    }
    elseif ($SkillPath) {
        $fullPath = Join-Path $SkillsRoot $SkillPath
        $skillMdPath = Join-Path $fullPath "SKILL.md"
        $skillMdcPath = Join-Path $fullPath "skill.mdc"

        if (Test-Path $skillMdPath) {
            return @(Get-Item $skillMdPath)
        }
        elseif (Test-Path $skillMdcPath) {
            return @(Get-Item $skillMdcPath)
        }
        else {
            Write-Error "Skill file not found: $fullPath"
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
        return $matches[1]
    }

    return $null
}

# ------------------------------------------
# Validate skill file
# ------------------------------------------
function Validate-Skill($skillFile) {
    $results = @{
        File = $skillFile.FullName
        IsNewFormat = $skillFile.Name -eq "SKILL.md"
        Errors = @()
        Warnings = @()
        Passed = @()
    }

    Write-Host ""
    Write-Host "Validating: $($skillFile.FullName)" -ForegroundColor Cyan

    # Check file name
    if ($skillFile.Name -eq "SKILL.md") {
        $results.Passed += "File name is SKILL.md"
    }
    elseif ($skillFile.Name -eq "skill.mdc") {
        $results.Warnings += "File is still using old format (skill.mdc), should be SKILL.md"
    }
    else {
        $results.Errors += "File name should be SKILL.md or skill.mdc"
    }

    # Parse frontmatter
    $frontmatterYaml = Get-Frontmatter $skillFile.FullName
    if (-not $frontmatterYaml) {
        $results.Errors += "Frontmatter not found or invalid"
        $validationResults += $results
        return
    }

    # Check required fields
    $requiredFields = @("name", "description", "type", "version")
    foreach ($field in $requiredFields) {
        if ($frontmatterYaml -match "$field\s*:") {
            $results.Passed += "Field '$field' exists"
        }
        else {
            $results.Errors += "Required field '$field' is missing"
        }
    }

    # Check description format
    if ($frontmatterYaml -match "description\s*:\s*\|") {
        $results.Passed += "Description uses multi-line format"

        # Check for "Use when"
        $content = Get-Content $skillFile.FullName -Raw
        if ($content -match "Use when:") {
            $results.Passed += "Description contains 'Use when'"
        }
        else {
            $results.Warnings += "Description should contain 'Use when' section"
        }

        # Check for "Triggers"
        if ($content -match "Triggers:") {
            $results.Passed += "Description contains 'Triggers'"
        }
        else {
            $results.Warnings += "Description should contain 'Triggers' section"
        }
    }
    else {
        $results.Warnings += "Description should use multi-line format (|) for better formatting"
    }

    # Check tags
    if ($frontmatterYaml -match "tags\s*:") {
        $results.Passed += "Tags field exists"

        # Count tags
        $tagMatches = [regex]::Matches($frontmatterYaml, "^\s*-\s+(\w+)", [System.Text.RegularExpressions.RegexOptions]::Multiline)
        if ($tagMatches.Count -ge 3) {
            $results.Passed += "Has at least 3 tags ($($tagMatches.Count) tags)"
        }
        else {
            $results.Warnings += "Should have at least 3 tags (currently $($tagMatches.Count))"
        }
    }
    else {
        $results.Warnings += "Tags field is missing (should have at least 3 tags)"
    }

    # Check content structure
    $content = Get-Content $skillFile.FullName -Raw

    $requiredSections = @("Purpose", "Scope", "Rules", "Anti-Patterns", "Examples")
    foreach ($section in $requiredSections) {
        if ($content -match "##\s+$section") {
            $results.Passed += "Section '$section' exists"
        }
        else {
            $results.Warnings += "Section '$section' is missing or not properly formatted"
        }
    }

    # Check content length
    $wordCount = ($content -split '\s+').Count
    if ($wordCount -lt 5000) {
        $results.Passed += "Content length is acceptable ($wordCount words)"
    }
    else {
        $results.Warnings += "Content is too long ($wordCount words, should be < 5000). Consider splitting to references/"
    }

    # Check for code examples
    if ($content -match '```(csharp|cs|powershell|bash|python)') {
        $results.Passed += "Contains code examples"
    }
    else {
        $results.Warnings += "Should contain code examples"
    }

    # Display results
    if ($results.Errors.Count -eq 0 -and $results.Warnings.Count -eq 0) {
        Write-Host "  ✓ All validations passed" -ForegroundColor Green
    }
    else {
        if ($results.Errors.Count -gt 0) {
            Write-Host "  ✗ Errors:" -ForegroundColor Red
            foreach ($error in $results.Errors) {
                Write-Host "    - $error" -ForegroundColor Red
            }
        }
        if ($results.Warnings.Count -gt 0) {
            Write-Host "  ⚠ Warnings:" -ForegroundColor Yellow
            foreach ($warning in $results.Warnings) {
                Write-Host "    - $warning" -ForegroundColor Yellow
            }
        }
    }

    $validationResults += $results
}

# ------------------------------------------
# Main Execution
# ------------------------------------------

Write-Host "Skill Content Validation Tool" -ForegroundColor Cyan
Write-Host "Workspace Root: $WorkspaceRoot" -ForegroundColor Gray
Write-Host ""

$skillFiles = Get-SkillFiles

if ($skillFiles.Count -eq 0) {
    Write-Warning "No skill files found to validate"
    exit 0
}

Write-Host "Found $($skillFiles.Count) skill file(s) to validate" -ForegroundColor Cyan

foreach ($skillFile in $skillFiles) {
    try {
        Validate-Skill $skillFile
    }
    catch {
        Write-Error "Failed to validate $($skillFile.FullName): $_"
    }
}

# Summary
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Validation Summary" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

$totalFiles = $validationResults.Count
$filesWithErrors = ($validationResults | Where-Object { $_.Errors.Count -gt 0 }).Count
$filesWithWarnings = ($validationResults | Where-Object { $_.Warnings.Count -gt 0 }).Count
$filesPassed = ($validationResults | Where-Object { $_.Errors.Count -eq 0 -and $_.Warnings.Count -eq 0 }).Count

Write-Host "Total files: $totalFiles" -ForegroundColor Gray
Write-Host "Passed: $filesPassed" -ForegroundColor Green
Write-Host "With warnings: $filesWithWarnings" -ForegroundColor Yellow
Write-Host "With errors: $filesWithErrors" -ForegroundColor Red

if ($filesWithErrors -gt 0) {
    Write-Host ""
    Write-Host "Files with errors:" -ForegroundColor Red
    foreach ($result in $validationResults | Where-Object { $_.Errors.Count -gt 0 }) {
        Write-Host "  - $($result.File)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Validation completed!" -ForegroundColor Green
