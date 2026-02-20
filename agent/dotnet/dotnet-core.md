# .NET Core Engineering Principles

AI must follow these principles when working with .NET backend systems.

## Core Philosophy

- Focus on Clean Architecture, CQRS, and scalable API design.
- Favor correctness, clarity, and maintainability.
- Provide production-ready .NET 6+ examples when needed.

## Architecture

- Follow Clean Architecture (API / Application / Domain / Infrastructure).
- Respect dependency direction.
- Keep business logic out of API layer.
- Avoid framework leakage into Domain.
- Prefer vertical slice structure.

## API Design

- Prefer Minimal API.
- Map Request to Command or Query.
- Map Result to Response DTO.
- Keep endpoints thin.
- Organize by feature: `Modules/{Feature}/{Action}`.
- Return consistent API responses.

## Application Layer

- Handlers coordinate use cases.
- Keep use cases cohesive.
- Avoid fat handlers.
- Do not expose DbContext directly to upper layers.
- Use repository abstraction or Dapper where appropriate.
- Keep use cases cohesive and single-purpose.

## Domain Layer

- Domain is framework-agnostic.
- Protect invariants inside aggregates.
- Use Value Objects when appropriate.
- Use Value Objects for validation.
- Throw DomainException only for business rule violations.
- Keep business logic inside Domain or Application.

## Infrastructure Layer

- Optimize database access.
- Avoid N+1 queries.
- Use async/await for I/O.
- Use async/await for all I/O operations.
- Prefer explicit transactions when atomicity is required.
- Do not mix read and write concerns improperly.

## Concurrency and Reliability

- Assume concurrency.
- Avoid in-memory shared state.
- Assume concurrent requests.
- Avoid in-memory shared state.
- Discuss race conditions if relevant.
- Use idempotency or transaction control when needed.

## Coding Conventions

- Use clear naming conventions.
- Prefer readability over clever code.
- PascalCase for types and public members.
- camelCase for local variables and private fields.
- Prefix interfaces with `I`.
- Use modern C# (10 or later).
- Prefer readability over clever syntax.
- Use `var` when the type is obvious.

## Performance

- Use async/await properly.
- Avoid blocking calls (.Result or .Wait()).
- Implement pagination for large queries.
- Cache only when justified.

## Testing

- Write unit tests for business logic.
- Prefer integration tests for API flows.
- Mock only external dependencies.

## Output Expectations

- Be concise and technical.
- Use structured bullet points.
- Provide production-ready .NET 6 or .NET 8 examples when code is required.
- Avoid unnecessary theory or academic explanation.
