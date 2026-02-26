---
name: execution-tracking
description: |
  Track handler execution for observability, auditing, and debugging in .NET applications.

  Use when:
  - Implementing observability and monitoring
  - Tracking handler execution for performance analysis
  - Building audit trails for business operations
  - Debugging production issues
  - Implementing distributed tracing

  Triggers: "execution tracking", "observability", "audit trail", "performance monitoring", "tracing", "correlation id"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - observability
  - monitoring
---

# Execution Tracking Pattern

## Purpose

Track handler execution for observability, auditing, and debugging.

## Scope

Applies to:
- Application Layer
- Infrastructure Layer
- Observability and monitoring
- Audit requirements

## Rules

- Track execution time for performance monitoring
- Record input parameters and results (sanitized)
- Track errors and exceptions
- Support correlation IDs for request tracing
- Configurable tracking levels (none, errors only, full)
- Tracking interface defined in Application layer
- Tracking implementations in Infrastructure layer

## Anti-Patterns

- Tracking sensitive data (passwords, tokens)
- Over-tracking causing performance issues
- No correlation IDs for distributed tracing
- Tracking implementation details instead of business events
- Ignoring privacy and compliance requirements

## Minimal Example

```csharp
// Application Layer
public interface IExecutionTracker
{
  Task TrackAsync(string operation, object? input, object? output, TimeSpan duration, string? correlationId = null);
  Task TrackErrorAsync(string operation, object? input, Exception error, TimeSpan duration, string? correlationId = null);
}

// Infrastructure Layer
public class LoggingExecutionTracker : IExecutionTracker
{
  private readonly ILogger<LoggingExecutionTracker> _logger;

  public async Task TrackAsync(string operation, object? input, object? output, TimeSpan duration, string? correlationId = null)
  {
    _logger.LogInformation(
      "Operation {Operation} completed in {DurationMs}ms. CorrelationId: {CorrelationId}",
      operation, duration.TotalMilliseconds, correlationId);
  }

  public async Task TrackErrorAsync(string operation, object? input, Exception error, TimeSpan duration, string? correlationId = null)
  {
    _logger.LogError(
      error,
      "Operation {Operation} failed after {DurationMs}ms. CorrelationId: {CorrelationId}",
      operation, duration.TotalMilliseconds, correlationId);
  }
}

// Usage in Decorator
public class ExecutionTrackingDecorator<TCommand> : CommandHandlerDecorator<TCommand>
{
  private readonly IExecutionTracker _tracker;
  private readonly ICorrelationIdProvider _correlationIdProvider;

  public override async Task<Result> HandleAsync(TCommand command, CancellationToken ct = default)
  {
    var correlationId = _correlationIdProvider.GetCorrelationId();
    var stopwatch = Stopwatch.StartNew();

    try
    {
      var result = await _next.HandleAsync(command, ct);
      stopwatch.Stop();

      await _tracker.TrackAsync(
        typeof(TCommand).Name,
        SanitizeInput(command),
        SanitizeOutput(result),
        stopwatch.Elapsed,
        correlationId);

      return result;
    }
    catch (Exception ex)
    {
      stopwatch.Stop();
      await _tracker.TrackErrorAsync(
        typeof(TCommand).Name,
        SanitizeInput(command),
        ex,
        stopwatch.Elapsed,
        correlationId);
      throw;
    }
  }

  private object? SanitizeInput(TCommand command)
  {
    // Remove sensitive data before tracking
    return command;
  }

  private object? SanitizeOutput(Result result)
  {
    // Sanitize output if needed
    return result.IsSuccess ? "Success" : result.Error;
  }
}
```

## Notes

- Always sanitize sensitive data before tracking
- Use correlation IDs for distributed tracing
- Consider performance impact of tracking
- Comply with privacy and compliance requirements
