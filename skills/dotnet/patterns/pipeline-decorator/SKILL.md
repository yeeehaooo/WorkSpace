---
name: pipeline-decorator
description: |
  Build cross-cutting concern pipelines using decorator pattern for handlers in Clean Architecture applications.

  Use when:
  - Implementing cross-cutting concerns (logging, validation, transaction, etc.)
  - Building handler pipelines with multiple concerns
  - Composing decorators for different operation types
  - Separating cross-cutting logic from business logic
  - Applying concerns in specific order

  Triggers: "decorator", "pipeline", "cross-cutting", "handler decorator", "middleware", "aspect"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - decorator
  - cross-cutting
---

# Pipeline Decorator Pattern

## Purpose

Build cross-cutting concern pipelines using decorator pattern for handlers.

## Scope

Applies to:
- Application Layer
- Infrastructure Layer
- Cross-cutting concerns
- Handler composition

## Rules

- One decorator per concern
- Decorators can be composed
- Decorators wrap handlers, not replace them
- Decorator order matters (e.g., validation before transaction)
- Decorators registered in DI container
- Base decorator classes in Application layer
- Concrete decorators in Infrastructure layer

## Anti-Patterns

- God decorator that does everything
- Decorators with business logic
- Decorators that break handler contract
- Ignoring decorator execution order
- Decorators that depend on specific handler implementations

## Minimal Example

```csharp
// Application Layer
public interface ICommandHandler<TCommand>
{
  Task<Result> HandleAsync(TCommand command, CancellationToken ct = default);
}

public abstract class CommandHandlerDecorator<TCommand> : ICommandHandler<TCommand>
{
  protected readonly ICommandHandler<TCommand> _next;

  protected CommandHandlerDecorator(ICommandHandler<TCommand> next)
  {
    _next = next;
  }

  public abstract Task<Result> HandleAsync(TCommand command, CancellationToken ct = default);
}

// Infrastructure Layer
public class LoggingDecorator<TCommand> : CommandHandlerDecorator<TCommand>
{
  private readonly ILogger<LoggingDecorator<TCommand>> _logger;

  public LoggingDecorator(
    ICommandHandler<TCommand> next,
    ILogger<LoggingDecorator<TCommand>> logger) : base(next)
  {
    _logger = logger;
  }

  public override async Task<Result> HandleAsync(TCommand command, CancellationToken ct = default)
  {
    _logger.LogInformation("Handling command {CommandType}", typeof(TCommand).Name);
    var stopwatch = Stopwatch.StartNew();

    try
    {
      var result = await _next.HandleAsync(command, ct);
      stopwatch.Stop();
      _logger.LogInformation("Command handled in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
      return result;
    }
    catch (Exception ex)
    {
      stopwatch.Stop();
      _logger.LogError(ex, "Command failed after {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
      throw;
    }
  }
}

public class ValidationDecorator<TCommand> : CommandHandlerDecorator<TCommand>
{
  private readonly IValidator<TCommand> _validator;

  public ValidationDecorator(
    ICommandHandler<TCommand> next,
    IValidator<TCommand> validator) : base(next)
  {
    _validator = validator;
  }

  public override async Task<Result> HandleAsync(TCommand command, CancellationToken ct = default)
  {
    var validationResult = await _validator.ValidateAsync(command, ct);
    if (!validationResult.IsValid)
    {
      return Result.Failure(string.Join(", ", validationResult.Errors.Select(e => e.ErrorMessage)));
    }

    return await _next.HandleAsync(command, ct);
  }
}

// DI Registration
services.AddScoped<ICommandHandler<CreateOrderCommand>>(sp =>
{
  var handler = new CreateOrderHandler(/* dependencies */);
  var validated = new ValidationDecorator<CreateOrderCommand>(handler, /* validator */);
  var logged = new LoggingDecorator<CreateOrderCommand>(validated, /* logger */);
  return logged;
});
```

## Notes

- Decorator order matters (validation → transaction → logging → handler)
- Each decorator should handle one concern
- Decorators should not modify command/query objects
