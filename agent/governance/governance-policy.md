# Governance Policy

## Rule Types

### Hard Rules (不可覆蓋)
- Architecture principles (Clean Architecture, CQRS)
- Security guidelines
- Naming conventions
- Exception handling policy

### Soft Rules (可專案 override)
- Code style preferences
- Testing strategies
- Performance optimization approaches

## Modification Policy

### Who Can Modify
- Only designated maintainers can modify agent rules
- Changes require team consensus

### Change Process
- All changes must go through PR + Review
- Impact assessment required
- Update change-log.md with version bump
- Tag governance version after approval

## Freeze Mechanism
- Hard Rules are frozen and cannot be overridden by projects
- Soft Rules can be overridden with explicit project-level configuration
- Conflicts must be documented and resolved through governance review
