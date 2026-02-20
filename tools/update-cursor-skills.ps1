param(
  [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

# Root-level excludes (top folder name)
$excludeTopDirs = @(".git", "node_modules", "bin", "obj", ".vs", ".idea")

$toolsDir = Join-Path $Root "tools"
$cachePath = Join-Path $toolsDir ".skill-cache.json"
$logPath = Join-Path $toolsDir "skill-detection.log"

$workspaceOutPath = Join-Path $Root ".cursor/rules/90-active-skills.mdc"
$projectsRoot = Join-Path $Root "Projects"

# ------------------------
# Utilities
# ------------------------
function Ensure-Dir([string]$path) {
  if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
}

Ensure-Dir $toolsDir
Ensure-Dir (Join-Path $Root ".cursor/rules")

# optional log rotation (keep last 2MB)
if (Test-Path $logPath) {
  $len = (Get-Item $logPath).Length
  if ($len -gt 2MB) {
    Move-Item $logPath ($logPath + "." + (Get-Date -Format "yyyyMMddHHmmss") + ".bak") -Force
  }
}

function NowIso() { (Get-Date).ToString("o") }

function Write-Log([string]$level, [string]$msg) {
  $line = "[{0}] [{1}] {2}" -f (NowIso), $level.ToUpperInvariant(), $msg
  Add-Content -Path $logPath -Value $line -Encoding UTF8
  if ($level -in @("WARN", "ERROR")) { Write-Warning $msg } else { Write-Host $msg }
}

function Normalize-Skill([string]$s) {
  if (-not $s) { return $null }
  $x = $s.Trim()
  $x = $x.TrimStart("/") # store without leading slash
  return $x
}

function Skill-ToLine([string]$s) {
  # output always with leading slash
  return "- /$s"
}

function Load-JsonSafe([string]$path) {
  try { return (Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json) }
  catch { return $null }
}

function Get-OverrideFilesUnder([string]$baseDir) {
  if (-not (Test-Path $baseDir)) { return @() }
  return Get-ChildItem -Path $baseDir -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -match "\\.ai\\skills\.json$" }
}

function Get-ProjectFolders {
  if (-not (Test-Path $projectsRoot)) { return @() }

  # Only first-level folders under Projects
  return Get-ChildItem -Path $projectsRoot -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -ne ".gitkeep" }
}

function Find-AnyUnder([string]$baseDir, [string[]]$patterns) {
  if (-not (Test-Path $baseDir)) { return $false }

  foreach ($p in $patterns) {
    $hit = Get-ChildItem -Path $baseDir -Recurse -File -Filter $p -ErrorAction SilentlyContinue |
    Where-Object {
      $_.FullName -notmatch "\\bin\\" -and
      $_.FullName -notmatch "\\obj\\" -and
      $_.FullName -notmatch "\\node_modules\\"
    } | Select-Object -First 1
    if ($hit) { return $true }
  }
  return $false
}

function Detect-Tech([string]$baseDir) {
  $tech = [ordered]@{
    dotnet   = (Find-AnyUnder $baseDir @("*.sln", "*.slnx", "*.csproj", "Directory.Build.props", "global.json"))
    frontend = (Find-AnyUnder $baseDir @("package.json", "pnpm-lock.yaml", "yarn.lock"))
    java     = (Find-AnyUnder $baseDir @("pom.xml", "build.gradle", "settings.gradle"))
  }
  return $tech
}

function Skills-FromTech($tech) {
  $skills = New-Object System.Collections.Generic.List[string]
  $skills.Add("skills/_shared") # always

  if ($tech.dotnet) { $skills.Add("skills/dotnet") }
  if ($tech.frontend) { $skills.Add("skills/frontend") }
  if ($tech.java) { $skills.Add("skills/java") }

  return $skills
}

function Apply-Overrides([System.Collections.Generic.List[string]]$skills, [string[]]$overrideFiles, [string]$scopeName) {
  # Returns: @{
  #   skills = List[string]
  #   report = [ordered]@{ added = []; removed = []; blocked = []; files = [] }
  # }
  $report = [ordered]@{
    scope   = $scopeName
    files   = @()
    added   = @()
    removed = @()
    blocked = @()
  }

  foreach ($file in $overrideFiles) {
    $report.files += $file
    $json = Load-JsonSafe $file
    if (-not $json) {
      $report.blocked += ("Invalid JSON: " + $file)
      continue
    }

    if ($json.add) {
      foreach ($a in $json.add) {
        $n = Normalize-Skill $a
        if (-not $n) { continue }
        if (-not $skills.Contains($n)) {
          $skills.Add($n)
          $report.added += $n
        }
      }
    }

    if ($json.remove) {
      foreach ($r in $json.remove) {
        $n = Normalize-Skill $r
        if (-not $n) { continue }

        # Hard block: cannot remove shared
        if ($n -eq "skills/_shared") {
          $report.blocked += ("Blocked remove (hard): " + $n + " via " + $file)
          continue
        }

        if ($skills.Contains($n)) {
          [void]$skills.Remove($n)
          $report.removed += $n
        }
      }
    }
  }

  return @{ skills = $skills; report = $report }
}

function Write-90([string]$path, [System.Collections.Generic.List[string]]$skills, [string]$generatedBy) {
  $dir = Split-Path $path -Parent
  Ensure-Dir $dir

  $lines = @()
  $lines += "alwaysApply: true"
  $lines += ""
  $lines += "# Active Skills (auto-generated)"
  $lines += "Use the following skill packs as the first reference:"
  foreach ($s in $skills) { $lines += (Skill-ToLine $s) }
  $lines += ""
  $lines += "Notes:"
  $lines += "- Governance rules under /agent have higher priority than skills."
  $lines += "- This file is generated by $generatedBy."
  $lines += "- DO NOT EDIT MANUALLY."

  $lines -join "`n" | Set-Content -Path $path -Encoding UTF8
}

# ------------------------
# Cache signature
# ------------------------
function Get-WorkspaceSignature {
  # signature: tech signals (limited) + any override files + workspace configs
  $patterns = @(
    "*.sln", "*.slnx", "*.csproj", "Directory.Build.props", "global.json",
    "package.json", "pnpm-lock.yaml", "yarn.lock",
    "pom.xml", "build.gradle", "settings.gradle"
  )

  $items = @()

  # workspace scan (excluding huge dirs)
  foreach ($p in $patterns) {
    $found = Get-ChildItem -Path $Root -Recurse -File -Filter $p -ErrorAction SilentlyContinue |
    Where-Object {
      $rel = $_.FullName.Replace($Root, "").TrimStart("\", "/")
      $top = $rel.Split([IO.Path]::DirectorySeparatorChar)[0]
      ($excludeTopDirs -notcontains $top)
    } | Select-Object -First 50
    if ($found) { $items += $found }
  }

  # overrides anywhere under Projects/*/.ai/skills.json
  $overrideFiles = Get-OverrideFilesUnder $projectsRoot
  if ($overrideFiles) { $items += $overrideFiles }

  # workspace configs that affect behavior
  $workspaceConfigs = @(
    (Join-Path $Root "agent/meta/version.md"),
    (Join-Path $Root "adapters/cursor/skill-detection.md")
  )
  foreach ($cfg in $workspaceConfigs) {
    if (Test-Path $cfg) { $items += (Get-Item $cfg) }
  }

  if (-not $items) { return @{ count = 0; maxWrite = "" } }

  $maxWrite = ($items | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1).LastWriteTimeUtc.ToString("o")
  return @{ count = $items.Count; maxWrite = $maxWrite }
}

function Load-Cache {
  if (Test-Path $cachePath) {
    try { return Get-Content $cachePath -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { return $null }
  }
  return $null
}

function Save-Cache($obj) {
  $obj | ConvertTo-Json -Depth 20 | Set-Content -Path $cachePath -Encoding UTF8
}

# ------------------------
# Main
# ------------------------
Write-Log "INFO" "=== Skill Detection v1.2 start ==="
Write-Log "INFO" ("Root: " + $Root)

$signature = Get-WorkspaceSignature
$cache = Load-Cache

$useCache = $false
if ($cache -and $cache.signature.count -eq $signature.count -and $cache.signature.maxWrite -eq $signature.maxWrite) {
  $useCache = $true
  Write-Log "INFO" "No changes detected. Using cached results."
}
else {
  Write-Log "INFO" "Changes detected. Recomputing results."
}

# ------------------------
# Compute results (or load cached)
# ------------------------
$workspaceSkills = $null
$projectResults = @()  # array of @{ name; path; tech; skills; report; outPath }

if ($useCache) {
  $workspaceSkills = [System.Collections.Generic.List[string]]@($cache.workspace.skills)

  foreach ($p in $cache.projects) {
    $projectResults += @{
      name    = $p.name
      path    = $p.path
      tech    = $p.tech
      skills  = [System.Collections.Generic.List[string]]@($p.skills)
      report  = $p.report
      outPath = $p.outPath
    }
  }
}
else {
  # ---- Workspace-level detection (aggregated from Projects + root) ----
  $aggTech = [ordered]@{ dotnet = $false; frontend = $false; java = $false }

  # detect in root (in case workspace itself has tech files)
  $rootTech = Detect-Tech $Root
  $keys = @($aggTech.Keys)
  foreach ($k in $keys) { if ($rootTech[$k]) { $aggTech[$k] = $true } }

  # detect in each project (isolated)
  $projects = Get-ProjectFolders
  Write-Log "INFO" ("Found projects: " + $projects.Count)

  foreach ($proj in $projects) {
    $projName = $proj.Name
    $projPath = $proj.FullName

    $tech = Detect-Tech $projPath
    $keys = @($aggTech.Keys)
    foreach ($k in $keys) { if ($tech[$k]) { $aggTech[$k] = $true } }

    $baseSkills = Skills-FromTech $tech

    # project override file: Projects/<proj>/.ai/skills.json (only within this project)
    $overrideFiles = Get-OverrideFilesUnder $projPath | ForEach-Object { $_.FullName }
    $applied = Apply-Overrides $baseSkills $overrideFiles ("project:" + $projName)

    $projSkills = $applied.skills
    $projReport = $applied.report

    $projOut = Join-Path $projPath ".cursor/rules/90-active-skills.mdc"

    $projectResults += @{
      name    = $projName
      path    = $projPath
      tech    = $tech
      skills  = $projSkills
      report  = $projReport
      outPath = $projOut
    }
  }

  # workspace skills (aggregate) + workspace overrides (optional, under root .ai/skills.json)
  $workspaceSkills = Skills-FromTech $aggTech

  $wsOverrideFiles = Get-OverrideFilesUnder $Root | ForEach-Object { $_.FullName } |
  Where-Object { $_ -match "\\.ai\\skills\.json$" -and $_ -notmatch "\\Projects\\" }

  $wsApplied = Apply-Overrides $workspaceSkills $wsOverrideFiles "workspace"
  $workspaceSkills = $wsApplied.skills
  $wsReport = $wsApplied.report

  # store workspace report into cache for diagnostics
  $workspaceReport = $wsReport

  Save-Cache @{
    signature = $signature
    workspace = @{
      skills = $workspaceSkills
      tech   = $aggTech
      report = $workspaceReport
    }
    projects  = @(
      $projectResults | ForEach-Object {
        @{
          name    = $_.name
          path    = $_.path
          tech    = $_.tech
          skills  = $_.skills
          report  = $_.report
          outPath = $_.outPath
        }
      }
    )
    updatedAt = (NowIso)
  }
}

# ------------------------
# Write outputs
# ------------------------
# Workspace 90
Write-90 -path $workspaceOutPath -skills $workspaceSkills -generatedBy "tools/update-cursor-skills.ps1"
Write-Log "INFO" ("Generated workspace 90: " + $workspaceOutPath)
Write-Log "INFO" ("Workspace enabled: " + ($workspaceSkills -join ", "))

# Per-project 90 files
foreach ($pr in $projectResults) {
  Write-90 -path $pr.outPath -skills $pr.skills -generatedBy "tools/update-cursor-skills.ps1"
  Write-Log "INFO" ("Generated project 90: " + $pr.outPath)
}

# ------------------------
# Conflict resolution report (console + log)
# ------------------------
Write-Log "INFO" "=== Conflict Resolution Report ==="

function Print-Report($rep) {
  $scope = $rep.scope
  Write-Log "INFO" ("[scope] " + $scope)

  if ($rep.files.Count -gt 0) {
    Write-Log "INFO" (" overrides: " + ($rep.files -join "; "))
  }
  else {
    Write-Log "INFO" " overrides: (none)"
  }

  if ($rep.added.Count -gt 0) { Write-Log "INFO" (" added: " + ($rep.added | Sort-Object -Unique -join ", ")) } else { Write-Log "INFO" " added: (none)" }
  if ($rep.removed.Count -gt 0) { Write-Log "INFO" (" removed: " + ($rep.removed | Sort-Object -Unique -join ", ")) } else { Write-Log "INFO" " removed: (none)" }

  if ($rep.blocked.Count -gt 0) {
    foreach ($b in $rep.blocked) { Write-Log "WARN" (" blocked: " + $b) }
  }
  else {
    Write-Log "INFO" " blocked: (none)"
  }
}

# Workspace report comes from cache when cached; re-load cache for workspace report always
$cache2 = Load-Cache
if ($cache2 -and $cache2.workspace -and $cache2.workspace.report) {
  Print-Report $cache2.workspace.report
}

foreach ($pr in $projectResults) {
  if ($pr.report) { Print-Report $pr.report }
}

Write-Log "INFO" "=== Skill Detection v1.2 done ==="
Write-Log "INFO" ("Log: " + $logPath)
