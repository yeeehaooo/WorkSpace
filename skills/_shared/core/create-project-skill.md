---
name: create-project-skill
description: Create reusable project Skill for cross-project use
type: template
version: 1.2.1
---

# Create Project Skill

## Purpose

Create new Skill that is reusable across projects, abstract, and version-controlled.

## Scope

Applies to:
- Skill creation
- Cross-project reusable capabilities

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

### Abstraction Rules

- Use placeholders like `{Entity}`, `{ModuleName}`
- Do NOT copy specific project names
- Do NOT hard-code module names

## Anti-Patterns

- Copying specific project names
- Hard-coding module names
- Creating project-specific skills
- Including business logic in skill

## Minimal Example

**Skill Template:**
```markdown
---
name: skill-name
description: Clear description for AGENT
type: structure | generator | pattern | template
version: 1.2.1
---

# Skill Title

## Purpose
One sentence describing the skill's value.

## Scope
Applies to:
- Layer/Architecture

## Rules
- Rule 1
- Rule 2

## Anti-Patterns
- Forbidden 1
- Forbidden 2

## Minimal Example
[Code example]
```