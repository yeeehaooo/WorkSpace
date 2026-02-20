# Skill Detection Specification

## Detection Signals

### .NET
- `*.sln`, `*.csproj`, `Directory.Build.props`, `global.json`

### Frontend
- `package.json`, `pnpm-lock.yaml`, `yarn.lock`

### Java
- `pom.xml`, `build.gradle`, `settings.gradle`

## Priority Order

1. `skills/_shared` - Always enabled
2. `skills/dotnet` - If .NET signals detected
3. `skills/frontend` - If frontend signals detected
4. `skills/java` - If Java signals detected

## Merge Strategy

When multiple technologies are detected:
- All relevant skill packs are enabled
- No conflicts (skills are additive)
- Governance rules from `/agent` always take precedence

## Overrides

If a project has `.ai/skills.json`:
- Merge project-specific overrides with detected skills
- Project overrides can add additional skills
- Project overrides cannot disable governance rules
