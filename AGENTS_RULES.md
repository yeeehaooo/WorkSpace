# Agent Governance Rules

## Purpose

Defines how the Agent should reason and optionally use workspace skills.

This workspace supports two optional skill locations:

- `.agent-skills/skills`     (architecture / reasoning reference)
- `.claude/skills`           (artifact / tooling reference)

These are documentation-based skills.
They are NOT runtime plugins.

---

## Core Principles

1. Do not preload skills.
2. Only read a skill file when directly relevant.
3. Do not assume automatic skill activation.
4. Task completion has priority over skill usage.

---

## Skill Usage

### Architecture / Context Skills

Located under:
`.agent-skills/skills`

Use when:
- Designing architecture
- Planning systems
- Evaluating context management

These guide reasoning only.

---

### Execution / Tooling Skills

Located under:
`.claude/skills`

Use when:
- Generating artifacts (docx, pdf, pptx, xlsx)
- UI / design tasks
- Automation tasks

These guide output generation only.

---

## Precedence

If conflict exists:

1. Project-specific rules
2. AGENT_RULES.md
3. AGENTS.md
4. Skill documents

---

## Constraint

No implicit discovery.
No mandatory skill scanning.
No forced two-phase reasoning.