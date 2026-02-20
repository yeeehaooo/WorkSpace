# API Design Principles

AI must follow these principles when designing APIs.

## API Style

- Prefer Minimal API over MVC Controllers.
- Organize by feature: `Modules/{Feature}/{Action}`.
- Keep endpoints thin.

## Request/Response Mapping

- Map Request to Command or Query.
- Map Result to Response DTO.
- Return consistent API responses.

## Stateless Design

- Stateless endpoints.
- No in-memory shared state.
- Do not handle business exceptions in Endpoint.

## Response Format

- Return consistent APIResponse format.
- Do not expose internal exceptions.
- Do not expose internal stack traces.
