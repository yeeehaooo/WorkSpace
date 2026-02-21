# Clean Architecture Principles (v1)

---

## Layering

API → Application → Domain → Infrastructure

- Domain must not depend on framework.
- Dependency direction must be respected.
- Business logic must not live in API layer.

---

## CQRS

- Commands mutate state.
- Queries do not change state.
- Separate read and write concerns.

---

## Vertical Slice

- Organize by feature:
  Modules/{Feature}/{Action}
- Avoid technical grouping by layer alone.

---

## Domain Rules

- Protect invariants.
- Use Value Objects where appropriate.
- Keep business rules inside Domain or Application layer.
