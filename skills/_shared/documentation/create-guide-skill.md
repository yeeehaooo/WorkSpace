---
name: create-guide-skill
description: Create .NET composite capability Guide (multi-step implementation flow)
type: template
version: 1.2.1
---

# Create Guide Skill

## Purpose

Create composite capability Guide with multi-step implementation flow.

## Scope

Applies to:
- Multi-step implementation flows
- Architecture decisions
- Combining multiple snippets
- DI / Middleware / Policy setup

## Rules

### Guide Characteristics

- Multi-step process
- Involves architecture decisions
- May combine multiple snippets
- May create folder structures
- May involve DI / Middleware / Policy

### File Naming

Format: `implement-{feature}-guide.md`

Examples:
- implement-jwt-authentication-guide.md
- implement-unit-of-work-guide.md
- implement-clean-module-guide.md

### Must Include

- Step-by-step process
- Architecture decisions explanation
- Code examples for each step
- Can reference snippets

## Anti-Patterns

- Only code without process (that's a snippet)
- Missing process flow
- Missing design explanation
- Single-step guides (should be snippet)

## Minimal Example

**Guide Template:**
```markdown
---
name: guide-name
description: Brief description of guide functionality
type: template
version: 1.2.1
---

# Guide Title

## Purpose
When to use this guide.

## Scope
Applies to:
- Architecture/Scenario

## Rules
- Step 1: Create Interface
- Step 2: Create Implementation
- Step 3: DI Registration
- Step 4: Middleware Setup

## Anti-Patterns
- Anti-pattern 1
- Anti-pattern 2

## Minimal Example
[Step-by-step code examples]
```