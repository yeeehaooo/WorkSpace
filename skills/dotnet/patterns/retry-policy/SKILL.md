---
name: retry-policy
description: |
  Define explicit retry policies for handling transient failures in external dependencies in .NET applications.

  Use when:
  - Handling transient failures from external services
  - Implementing resilient service calls
  - Building systems that need to recover from temporary failures
  - Implementing circuit breaker patterns
  - Handling network timeouts and connection issues

  Triggers: "retry policy", "transient failure", "circuit breaker", "resilience", "exponential backoff", "retry logic"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - resilience
  - retry
---

# Retry Policy Pattern

## Purpose

Define explicit retry policies for handling transient failures in external dependencies.

## Scope

Applies to:
- Application Layer
- Infrastructure Layer
- External service calls
- Transient failure handling

## Rules

- Retry only transient failures (network errors, timeouts)
- Do not retry non-retryable failures (validation errors, authentication failures)
- Use exponential backoff to prevent retry storms
- Limit maximum retry attempts
- Support circuit breaker pattern for repeated failures
- Retry policy interfaces defined in Application layer
- Policy implementations in Infrastructure layer

## Anti-Patterns

- Retrying all exceptions
- No backoff strategy (immediate retries)
- Infinite retry loops
- Retrying non-retryable failures
- No circuit breaker for repeated failures

## Minimal Example

```csharp
// Application Layer
public interface IRetryPolicy
{
  Task<T> ExecuteAsync<T>(Func<Task<T>> operation, CancellationToken ct = default);
  Task ExecuteAsync(Func<Task> operation, CancellationToken ct = default);
}

public enum RetryableExceptionType
{
  NetworkError,
  Timeout,
  ServiceUnavailable
}

// Infrastructure Layer
public class ExponentialBackoffRetryPolicy : IRetryPolicy
{
  private readonly int _maxRetries;
  private readonly TimeSpan _initialDelay;
  private readonly double _backoffMultiplier;
  private readonly ILogger<ExponentialBackoffRetryPolicy> _logger;

  public ExponentialBackoffRetryPolicy(
    int maxRetries = 3,
    TimeSpan? initialDelay = null,
    double backoffMultiplier = 2.0,
    ILogger<ExponentialBackoffRetryPolicy>? logger = null)
  {
    _maxRetries = maxRetries;
    _initialDelay = initialDelay ?? TimeSpan.FromSeconds(1);
    _backoffMultiplier = backoffMultiplier;
    _logger = logger;
  }

  public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation, CancellationToken ct = default)
  {
    var delay = _initialDelay;

    for (int attempt = 0; attempt <= _maxRetries; attempt++)
    {
      try
      {
        return await operation();
      }
      catch (Exception ex) when (IsRetryable(ex) && attempt < _maxRetries)
      {
        _logger?.LogWarning(
          ex,
          "Operation failed (attempt {Attempt}/{MaxRetries}), retrying in {DelayMs}ms",
          attempt + 1, _maxRetries + 1, delay.TotalMilliseconds);

        await Task.Delay(delay, ct);
        delay = TimeSpan.FromMilliseconds(delay.TotalMilliseconds * _backoffMultiplier);
      }
    }

    // Last attempt failed, throw exception
    return await operation();
  }

  public async Task ExecuteAsync(Func<Task> operation, CancellationToken ct = default)
  {
    await ExecuteAsync(async () => { await operation(); return 0; }, ct);
  }

  private bool IsRetryable(Exception ex)
  {
    return ex is HttpRequestException ||
           ex is TaskCanceledException ||
           ex is TimeoutException ||
           (ex is HttpRequestException httpEx &&
            (httpEx.Message.Contains("timeout") ||
             httpEx.Message.Contains("connection")));
  }
}

// Usage
public class ExternalApiService
{
  private readonly IRetryPolicy _retryPolicy;
  private readonly HttpClient _httpClient;

  public async Task<ApiResponse> CallExternalApiAsync(string endpoint, CancellationToken ct = default)
  {
    return await _retryPolicy.ExecuteAsync(async () =>
    {
      var response = await _httpClient.GetAsync(endpoint, ct);
      response.EnsureSuccessStatusCode();
      var content = await response.Content.ReadAsStringAsync(ct);
      return JsonSerializer.Deserialize<ApiResponse>(content)!;
    }, ct);
  }
}
```

## Notes

- Only retry transient failures
- Use exponential backoff to prevent retry storms
- Consider circuit breaker for repeated failures
- Log retry attempts for observability
