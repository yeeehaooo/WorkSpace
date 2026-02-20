# Clean Architecture Principles

AI must follow Clean Architecture principles when designing and implementing systems.

## Core Principles

- Follow Clean Architecture (API / Application / Domain / Infrastructure).
- Respect dependency direction (Domain must not depend on Infrastructure).
- Keep business logic inside Domain or Application.
- Avoid framework leakage into Domain layer.
- Prefer vertical slice organization.

## Layer Responsibilities

### API Layer
- Keep business logic out of API layer.
- API must not contain business logic.
- Stateless endpoints.
- No in-memory shared state.

### Application Layer
- Handlers coordinate use cases.
- Keep use cases cohesive.
- Avoid fat handlers.
- Do not expose DbContext directly to upper layers.

### Domain Layer
- Domain is framework-agnostic.
- Domain must remain framework-agnostic.
- Protect invariants inside aggregates.
- Use Value Objects when appropriate.

### Infrastructure Layer
- Implements interfaces defined in application or domain.
- Never referenced by domain layer.
- Can be replaced without touching business logic.

## Dependency Direction

- Domain must not depend on Infrastructure.
- No cross-layer leakage.
- API → Application → Domain → Infrastructure (dependency flow).

## Organization

- Prefer vertical slice structure.
- Organize by feature: `Modules/{Feature}/{Action}`.
