# Agent Governance

This folder contains the Source of Truth for AI engineering governance.

## Structure

- /governance → Governance meta rules (non-versioned)
- /meta → Version tracking and change history
- /v1 → Versioned governance behavior

## Design Principles

- Governance is versioned.
- Governance defines behavior, not templates.
- Architecture rules are separated from coding behavior.
- Projects cannot override Hard Rules.

Governance evolves via version increments (v1, v2, ...).
