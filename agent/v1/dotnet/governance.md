# .NET Governance v1

This document defines coding behavior standards.

All rules here are Hard Rules unless stated otherwise.

---

## 1. Naming Conventions

- PascalCase → types, methods, properties
- camelCase → local variables, parameters
- _camelCase → private readonly fields
- UPPER_CASE → constants

### Layer Naming

Domain:
- Aggregate → {Entity}
- ValueObject → descriptive noun
- Exception → DomainException

Application:
- {Action}Command
- {Action}Query
- {Action}Handler
- {Action}Result

API:
- {Action}Request
- {Action}Response

Infrastructure:
- {Entity}Repository
- {Entity}QueryService
- {Entity}DataModel
- {Entity}ReadModel

---

## 2. Exception Handling

- Exceptions are for exceptional cases only.
- No empty catch blocks.
- Do not swallow exceptions.
- Log only at application boundary.
- Do not expose stack traces externally.
- DomainException is reserved for business rule violations.

---

## 3. Code Organization

- Namespace = folder structure.
- One public type per file.
- File name = primary type name.
- No cross-layer naming leakage.
- Avoid Shared / Utils dumping folders.

---

## 4. Anti-Patterns (Forbidden)

- Manager / Helper / Util / Base.
- Static god classes.
- Framework leakage into Domain.
- Mixing read and write responsibilities.
- In-memory shared mutable state.

---

## 5. Engineering Practices (Soft Rules)

- Prefer async/await for I/O.
- Avoid blocking calls (.Result / .Wait()).
- Assume concurrency.
- Prefer explicit transaction control.
- Favor clarity over clever syntax.
