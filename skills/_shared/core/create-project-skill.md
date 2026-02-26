---
name: create-project-skill
description: |
  Create reusable project Skill for cross-project use that is abstract, version-controlled, and follows Antigravity Agent Skills standards.

  Use when:
  - Creating new reusable skills for cross-project use
  - Abstracting common patterns or templates
  - Building skills that can be shared across multiple projects
  - Establishing standard processes that are used 2+ times
  - Creating skills that follow Antigravity standards

  Triggers: "create skill", "new skill", "skill template", "reusable skill", "cross-project skill"
type: template
version: 1.2.1
tags:
  - skill
  - template
  - reusable
  - cross-project
  - antigravity
---

# Create Project Skill

## Purpose

Create new Skill that is reusable across projects, abstract, and version-controlled.

## Scope

Applies to:
- Skill creation
- Cross-project reusable capabilities
- Standardizing common patterns
- Building skill library

## Rules

### When to Create Skill

Create skill only if:
- Used 2+ times
- Has standard process
- Can be abstracted
- Can be shared across projects

### Skill Categories

- **shared**: Common skills
- **architecture**: Clean Architecture skills
- **api**: API Adapter skills
- **domain**: Domain modeling skills
- **infrastructure**: Infrastructure skills
- **devops**: Docker / CI skills

### File Naming

Format: `{action}-{scope}-skill.md`

Examples:
- create-api-adapter-skill.md
- create-domain-aggregate-skill.md
- create-clean-module-skill.md

### Skill Structure (Antigravity Standard)

```
skill-name/
├── SKILL.md          (required)
├── scripts/          (optional)
├── references/       (optional)
└── assets/           (optional)
```

### Frontmatter Requirements

```yaml
---
name: skill-name
description: |
  [Core description]

  Use when:
  - [Scenario 1]
  - [Scenario 2]

  Triggers: "[keyword1]", "[keyword2]"
type: structure | generator | pattern | template
version: 1.0.0
tags:
  - tag1
  - tag2
---
```

### Abstraction Rules

- Use placeholders like `{Entity}`, `{ModuleName}`
- Do NOT copy specific project names
- Do NOT hard-code module names
- Keep content generic and reusable

## Anti-Patterns

- Copying specific project names
- Hard-coding module names
- Creating project-specific skills
- Including business logic in skill
- Missing "Use when" in description
- Missing tags

## Minimal Example

**Skill Template:**
```markdown
---
name: skill-name
description: |
  [One sentence core description]

  Use when:
  - [Specific scenario 1]
  - [Specific scenario 2]
  - [Specific scenario 3]

  Triggers: "[keyword1]", "[keyword2]", "[keyword3]"
type: structure | generator | pattern | template
version: 1.0.0
tags:
  - category1
  - category2
  - category3
---

# Skill Title

## Purpose

One sentence describing the skill's value.

## Scope

Applies to:
- Layer/Architecture
- Use case

## Rules

- Rule 1
- Rule 2

## Anti-Patterns

- Forbidden 1
- Forbidden 2

## Minimal Example

[Code example]
```

## Notes

- Follow Antigravity Agent Skills standards
- Include comprehensive description with "Use when" and "Triggers"
- Add appropriate tags (at least 3)
- Keep content under 5000 words
- Use Progressive Disclosure (split to references/ if needed)
