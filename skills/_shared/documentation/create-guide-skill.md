---
name: create-guide-skill
description: |
  Create .NET composite capability Guide with multi-step implementation flow for complex features.

  Use when:
  - Creating multi-step implementation flows
  - Documenting architecture decisions
  - Combining multiple snippets into a complete solution
  - Setting up DI, Middleware, or Policy configurations
  - Building comprehensive implementation guides

  Triggers: "create guide", "implementation guide", "multi-step guide", "setup guide", "configuration guide"
type: template
version: 1.2.1
tags:
  - guide
  - template
  - documentation
  - multi-step
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

## Template Structure

**Guide Template:**
```markdown
---
name: guide-name
description: |
  [Brief description of guide functionality]

  Use when:
  - [Scenario 1]
  - [Scenario 2]

  Triggers: "[keyword1]", "[keyword2]"
type: template
version: 1.0.0
tags:
  - guide
  - feature-name
---

# Guide Title

## Purpose

When to use this guide.

## Scope

Applies to:
- Architecture/Scenario

## Prerequisites

- Requirement 1
- Requirement 2

## Step-by-Step Process

### Step 1: Create Interface

[Code example and explanation]

### Step 2: Create Implementation

[Code example and explanation]

### Step 3: DI Registration

[Code example and explanation]

### Step 4: Middleware Setup

[Code example and explanation]

## Anti-Patterns

- Anti-pattern 1
- Anti-pattern 2

## Notes

- Additional considerations
- Common pitfalls
```

## Notes

- Guides should be comprehensive but focused
- Include architecture rationale
- Reference snippets when applicable
- Provide complete working examples
