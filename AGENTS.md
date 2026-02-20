# Workspace Skill Index

This workspace may contain optional reference skills under:

- `.claude/skills`        (Claude-style reference skills)
- `agent/skills`          (Workspace .NET skills)

These are documentation-based skills, not auto-loaded runtime plugins.

## .NET Workspace Skills

- API Adapter  
  → agent/skills/dotnet/api/create-api-adapter-skill.md

- Domain Aggregate  
  → agent/skills/dotnet/domain/create-domain-aggregate-skill.md

- Repository Pattern  
  → agent/skills/dotnet/infrastructure/create-repository-skill.md

- Clean Architecture Module  
  → agent/skills/dotnet/architecture/create-clean-module-skill.md

- Docker / DevOps  
  → agent/skills/dotnet/devops/create-docker-compose-skill.md

- Project Skill  
  → agent/skills/shared/create-project-skill.md

## Built-in Office Skills (Reference Only)

If task involves:
- docx
- pdf
- pptx
- xlsx

Check:
`.claude/skills/{skill-name}/SKILL.md`

Load only when directly relevant.
Do not assume automatic activation.