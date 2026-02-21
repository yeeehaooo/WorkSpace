# Workspace Skill Index

This workspace contains reusable skill packs under:

- `skills/` - Reusable skill packs organized by technology and shared capabilities

These are documentation-based skills, not auto-loaded runtime plugins.

## .NET Skills

Located under `skills/dotnet/`:

- **Templates** (`skills/dotnet/templates/`)
  - API Adapter: `create-api-adapter-skill.md`
  - Docker Compose: `create-docker-compose-skill.md`
  - Snippets: `create-snippet-skill.md`

- **Patterns** (`skills/dotnet/patterns/`)
  - Unit of Work: `unit-of-work/skill.mdc`
  - Domain Event: `domain-event/skill.mdc`
  - Transaction Policy: `transaction-policy/skill.mdc`
  - Caching Strategy: `caching-strategy/skill.mdc`
  - Pipeline Decorator: `pipeline-decorator/skill.mdc`
  - Execution Tracking: `execution-tracking/skill.mdc`
  - Outbox: `outbox/skill.mdc`
  - Retry Policy: `retry-policy/skill.mdc`
  - Result Wrapper: `result-wrapper/skill.mdc`

  **Note:** Patterns are behavioral extensions, not generators. They add design capabilities to existing architecture without creating project structure or full modules.

## Shared Skills

Located under `skills/_shared/`:

- **Core** (`skills/_shared/core/`)
  - Project Skill: `create-project-skill.md`

- **Documentation** (`skills/_shared/documentation/`)
  - Guide Skill: `create-guide-skill.md`
  - Coverage Report Guide: `implement-backend-coverage-report-guide.md`

## Governance

Governance rules are located under `/agent`. See `AGENTS_RULES.md` for details.

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
