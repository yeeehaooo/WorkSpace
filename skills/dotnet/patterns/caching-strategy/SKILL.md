---
name: caching-strategy
description: |
  Define explicit caching strategies for different data access patterns and consistency requirements in .NET applications.

  Use when:
  - Implementing caching for frequently accessed data
  - Optimizing read-heavy workloads
  - Reducing database load with appropriate caching
  - Handling cache invalidation strategies
  - Building systems with varying cache requirements

  Triggers: "caching strategy", "cache", "redis", "cache invalidation", "TTL", "cache warming"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - caching
  - performance
---

# Caching Strategy Pattern

## Purpose

Define explicit caching strategies for different data access patterns and consistency requirements.

## Scope

Applies to:
- Application Layer
- Infrastructure Layer
- Read-heavy operations
- Performance optimization scenarios

## Rules

- Cache is never source of truth
- Explicit cache invalidation strategies
- Appropriate TTL per data type
- Handle cache misses gracefully
- Support cache warming when needed
- Caching strategy interfaces defined in Application layer
- Strategy implementations in Infrastructure layer (Redis, in-memory, etc.)

## Anti-Patterns

- Treating cache as source of truth
- No cache invalidation strategy
- Too long or too short TTL
- Caching everything without strategy
- Ignoring cache consistency requirements
- Cache keys without namespace/prefix

## Minimal Example

```csharp
// Application Layer
public interface ICachingStrategy
{
  Task<T?> GetAsync<T>(string key, CancellationToken ct = default);
  Task SetAsync<T>(string key, T value, TimeSpan? ttl = null, CancellationToken ct = default);
  Task InvalidateAsync(string key, CancellationToken ct = default);
  Task InvalidateByPatternAsync(string pattern, CancellationToken ct = default);
}

// Infrastructure Layer
public class RedisCachingStrategy : ICachingStrategy
{
  private readonly IDatabase _redis;
  private readonly string _keyPrefix;

  public async Task<T?> GetAsync<T>(string key, CancellationToken ct = default)
  {
    var fullKey = $"{_keyPrefix}:{key}";
    var value = await _redis.StringGetAsync(fullKey);
    return value.HasValue ? JsonSerializer.Deserialize<T>(value!) : default;
  }

  public async Task SetAsync<T>(string key, T value, TimeSpan? ttl = null, CancellationToken ct = default)
  {
    var fullKey = $"{_keyPrefix}:{key}";
    var json = JsonSerializer.Serialize(value);
    await _redis.StringSetAsync(fullKey, json, ttl);
  }

  public async Task InvalidateAsync(string key, CancellationToken ct = default)
  {
    var fullKey = $"{_keyPrefix}:{key}";
    await _redis.KeyDeleteAsync(fullKey);
  }
}

// Usage in Query Handler
public class GetUserHandler : IQueryHandler<GetUserQuery, UserDto>
{
  private readonly IUserRepository _userRepo;
  private readonly ICachingStrategy _cache;

  public async Task<UserDto> Handle(GetUserQuery query, CancellationToken ct)
  {
    var cacheKey = $"user:{query.UserId}";
    var cached = await _cache.GetAsync<UserDto>(cacheKey, ct);

    if (cached != null)
      return cached;

    var user = await _userRepo.GetByIdAsync(query.UserId, ct);
    var dto = MapToDto(user);

    await _cache.SetAsync(cacheKey, dto, TimeSpan.FromMinutes(10), ct);
    return dto;
  }
}
```

## Notes

- Always handle cache misses gracefully
- Use appropriate TTL based on data volatility
- Implement cache invalidation on writes
- Use namespaced cache keys to avoid collisions
