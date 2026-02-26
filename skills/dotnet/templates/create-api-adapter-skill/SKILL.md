---
name: create-api-adapter
description: |
  Create adapter structure for integrating third-party APIs in Clean Architecture applications.

  Use when:
  - Integrating external APIs or services
  - Creating HTTP client adapters for third-party services
  - Implementing API integration with error handling
  - Setting up adapter pattern for external dependencies
  - Building resilient external service integrations

  Triggers: "api adapter", "third-party api", "external service", "http client adapter", "api integration"
type: template
version: 1.2.1
tags:
  - dotnet
  - template
  - boilerplate
  - api
  - integration
---

# Create API Adapter

## Purpose

Create adapter structure for integrating third-party APIs.

## Scope

Applies to:
- Infrastructure Layer
- External service integration
- HTTP-based API integrations

## Rules

- Interface defined in Application layer
- Implementation in Infrastructure layer
- Use HttpClient for HTTP calls
- Return Result pattern for error handling
- Register in DI container
- Use retry policy for transient failures

## Template Structure

**Interface (Application Layer):**
```csharp
public interface I{ProviderName}Service
{
    Task<Result<{ResponseType}>> ExecuteAsync({RequestType} request, CancellationToken ct = default);
}
```

**Implementation (Infrastructure Layer):**
```csharp
public class {ProviderName}Service : I{ProviderName}Service
{
    private readonly HttpClient _httpClient;
    private readonly IRetryPolicy _retryPolicy;
    private readonly ILogger<{ProviderName}Service> _logger;

    public {ProviderName}Service(
        HttpClient httpClient,
        IRetryPolicy retryPolicy,
        ILogger<{ProviderName}Service> logger)
    {
        _httpClient = httpClient;
        _retryPolicy = retryPolicy;
        _logger = logger;
    }

    public async Task<Result<{ResponseType}>> ExecuteAsync({RequestType} request, CancellationToken ct = default)
    {
        return await _retryPolicy.ExecuteAsync(async () =>
        {
            var response = await _httpClient.PostAsJsonAsync("endpoint", request, ct);
            response.EnsureSuccessStatusCode();
            var content = await response.Content.ReadFromJsonAsync<{ResponseType}>(ct);
            return Result<{ResponseType}>.Success(content!);
        }, ct);
    }
}
```

**DI Registration:**
```csharp
services.AddHttpClient<I{ProviderName}Service, {ProviderName}Service>(client =>
{
    client.BaseAddress = new Uri(configuration["{ProviderName}:BaseUrl"]);
    client.Timeout = TimeSpan.FromSeconds(30);
});
```

## Anti-Patterns

- Using HttpClient directly in Application layer
- Calling third-party API from Controller
- No error handling
- Hard-coded endpoints
- No retry policy for transient failures

## Notes

- Use typed HttpClient for better configuration
- Implement retry policy for resilience
- Use Result pattern for error handling
- Log API calls for observability
