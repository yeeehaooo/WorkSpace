# .NET Exception Policy

AI must follow these exception handling principles.

## Exception Usage

- Use exceptions for exceptional cases only.
- Do not use exceptions for control flow.
- Do not swallow exceptions.

## Exception Handling

- No empty catch blocks.
- Log at application boundary.
- Use structured logging.

## Exception Exposure

- Do not expose internal stack traces.
- Do not expose internal exceptions.

## Best Practices

- Surface failure modes explicitly.
- Avoid swallowing exceptions.
- Log only at boundary.
