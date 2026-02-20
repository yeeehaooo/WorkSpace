# Skills Version

Current: **skills-v1.2.0**

## Versioning Policy

Skills packages under `/skills` are versioned independently from `/agent`.

- **Agent version** controls governance & policies (organization-level behavior)
- **Skills version** controls reusable playbooks / templates / patterns (implementation guidance)

This means:
- A skills update does not necessarily require an agent governance bump.
- A breaking change in skills should bump major version of **skills**, not necessarily **agent**.

## History

### skills-v1.2.0 (2026-02-21)
- Introduce multi-skill activation model and project-level overrides (documented in workspace architecture doc)
- Adopt taxonomy folders: `_shared`, `dotnet`, and sub-categories (templates/patterns/performance)

### skills-v1.1.0
- Add initial shared documentation/playbook skills

### skills-v1.0.0
- Initial skills taxonomy bootstrap
