---
name: create-snippet
description: |
  Create reusable .NET atomic capability code snippets that can be directly copied and pasted.

  Use when:
  - Creating single-purpose code snippets
  - Building reusable code templates
  - Implementing atomic technical capabilities
  - Creating copy-pasteable code blocks
  - Building snippet library for common patterns

  Triggers: "create snippet", "code snippet", "reusable snippet", "atomic snippet", "copy-paste code"
type: template
version: 1.2.1
tags:
  - dotnet
  - template
  - boilerplate
  - snippet
  - reusable
---

# Create Snippet

## Purpose

Create atomic capability code snippets that can be directly copied and pasted.

## Scope

Applies to:
- Code snippets
- Reusable templates
- Single technical capabilities

## Rules

- Single responsibility (one snippet solves one thing)
- No project-specific names (use placeholders like `{Entity}`)
- No multi-step processes
- No architecture decisions
- No dependencies on project-specific modules
- Directly copy-pasteable

## Anti-Patterns

- Including multi-step workflows
- Creating entire modules
- Using specific business names
- Including architecture decisions
- Dependencies on specific modules

## Template Structure

**Snippet Template:**
```csharp
public class {Entity}Repository : I{Entity}Repository
{
    private readonly IDbContext _db;

    public {Entity}Repository(IDbContext db)
    {
        _db = db;
    }

    public async Task<{Entity}?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        return await _db.Set<{Entity}>().FindAsync(new object[] { id }, ct);
    }

    public async Task AddAsync({Entity} entity, CancellationToken ct = default)
    {
        await _db.Set<{Entity}>().AddAsync(entity, ct);
    }
}
```

## Notes

- Use placeholders for entity names
- Keep snippets focused on one capability
- Make snippets directly usable
- Avoid project-specific dependencies
