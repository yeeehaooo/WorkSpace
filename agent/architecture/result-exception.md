# Result & Exception Handling Principles

AI must follow these principles when handling business outcomes and exceptions.

## Result Pattern

- Use Result<T> for business outcomes.
- Surface failure modes explicitly.

## Exception Types

### Business Exceptions
- BusinessException → handled by ExceptionHandlerDecorator.
- Throw DomainException only for business rule violations.
- Use exceptions for exceptional cases only.
- Do not use exceptions for control flow.

### Infrastructure Exceptions
- InfrastructureException → bubble to global handler.
- Do not expose internal exceptions.
- Do not expose internal stack traces.

## Exception Handling Rules

- No empty catch blocks.
- Do not swallow exceptions.
- Log at application boundary.
- Use structured logging.

## Error Handling Best Practices

- Avoid swallowing exceptions.
- Log only at boundary.
- Do not handle business exceptions in Endpoint.
