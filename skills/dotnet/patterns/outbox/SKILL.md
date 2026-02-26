---
name: outbox
description: |
  Ensure reliable event publishing and message delivery by storing events in the same transaction as domain changes, solving the dual-write problem.

  Use when:
  - Implementing reliable event publishing in distributed systems
  - Ensuring events are published even if application crashes
  - Solving dual-write problem (domain changes + event publishing)
  - Building event-driven architectures with guaranteed delivery
  - Implementing eventual consistency between services

  Triggers: "outbox", "reliable event", "dual-write", "event publishing", "message delivery", "transactional outbox"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - event-driven
  - reliability
---

# Outbox Pattern

## Purpose

Ensure reliable event publishing and message delivery by storing events in the same transaction as domain changes.

## Scope

Applies to:
- Domain Layer
- Application Layer
- Infrastructure Layer
- Event-driven architectures
- Distributed systems requiring reliable messaging

## Rules

- Events stored in outbox within same transaction as domain changes
- Background worker publishes events from outbox
- Idempotent publishing (handle duplicate deliveries)
- Mark events as published after successful delivery
- Retry failed publications with exponential backoff
- `IOutbox` interface defined in Application layer
- Outbox implementation in Infrastructure layer

## Anti-Patterns

- Publishing events directly without outbox (dual-write problem)
- Publishing events before transaction commit
- No idempotency handling in event handlers
- No retry mechanism for failed publications
- Publishing events synchronously (blocking transaction)

## Minimal Example

```csharp
// Application Layer
public interface IOutbox
{
  Task AddAsync<T>(T domainEvent) where T : IDomainEvent;
  Task<IEnumerable<OutboxMessage>> GetUnpublishedAsync(int batchSize);
  Task MarkAsPublishedAsync(Guid messageId);
}

public class OutboxMessage
{
  public Guid Id { get; set; }
  public string EventType { get; set; }
  public string EventData { get; set; }
  public DateTime OccurredOn { get; set; }
  public DateTime? PublishedOn { get; set; }
}

// Infrastructure Layer
public class DatabaseOutbox : IOutbox
{
  private readonly IDbSession _session;

  public async Task AddAsync<T>(T domainEvent) where T : IDomainEvent
  {
    var message = new OutboxMessage
    {
      Id = Guid.NewGuid(),
      EventType = typeof(T).Name,
      EventData = JsonSerializer.Serialize(domainEvent),
      OccurredOn = DateTime.UtcNow
    };

    // Store in same transaction as domain changes
    await _session.ExecuteAsync(
      "INSERT INTO OutboxMessages (Id, EventType, EventData, OccurredOn) VALUES (@Id, @EventType, @EventData, @OccurredOn)",
      message
    );
  }

  public async Task<IEnumerable<OutboxMessage>> GetUnpublishedAsync(int batchSize)
  {
    return await _session.QueryAsync<OutboxMessage>(
      "SELECT * FROM OutboxMessages WHERE PublishedOn IS NULL ORDER BY OccurredOn LIMIT @BatchSize",
      new { BatchSize = batchSize }
    );
  }

  public async Task MarkAsPublishedAsync(Guid messageId)
  {
    await _session.ExecuteAsync(
      "UPDATE OutboxMessages SET PublishedOn = @PublishedOn WHERE Id = @Id",
      new { Id = messageId, PublishedOn = DateTime.UtcNow }
    );
  }
}

// Background Worker
public class OutboxPublisher : BackgroundService
{
  private readonly IOutbox _outbox;
  private readonly IDomainEventDispatcher _eventDispatcher;
  private readonly ILogger<OutboxPublisher> _logger;

  protected override async Task ExecuteAsync(CancellationToken stoppingToken)
  {
    while (!stoppingToken.IsCancellationRequested)
    {
      try
      {
        var messages = await _outbox.GetUnpublishedAsync(batchSize: 100);

        foreach (var message in messages)
        {
          try
          {
            var domainEvent = DeserializeEvent(message);
            await _eventDispatcher.DispatchAsync(domainEvent, stoppingToken);
            await _outbox.MarkAsPublishedAsync(message.Id);
          }
          catch (Exception ex)
          {
            _logger.LogError(ex, "Failed to publish event {MessageId}", message.Id);
            // Retry with exponential backoff
          }
        }

        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Error in outbox publisher");
        await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
      }
    }
  }
}

// Usage in Command Handler
public class CreateOrderHandler : ICommandHandler<CreateOrderCommand>
{
  private readonly IOrderRepository _orderRepo;
  private readonly IOutbox _outbox;
  private readonly IUnitOfWork _uow;

  public async Task<Result> Handle(CreateOrderCommand cmd, CancellationToken ct)
  {
    await _uow.BeginAsync(ct);
    try
    {
      var order = new Order();
      order.Create(cmd.CustomerId, cmd.TotalAmount);

      await _orderRepo.AddAsync(order, ct);

      // Store event in outbox (same transaction)
      foreach (var domainEvent in order.DomainEvents)
      {
        await _outbox.AddAsync(domainEvent);
      }

      await _uow.CommitAsync(ct);
      order.ClearDomainEvents();

      return Result.Success();
    }
    catch
    {
      await _uow.RollbackAsync(ct);
      throw;
    }
  }
}
```

## Combination with Other Patterns

This pattern works well with:
- **Unit of Work**: Store events in outbox within the same transaction
- **Domain Events**: Publish domain events reliably through outbox
- **Retry Policy**: Retry failed event publications

## Notes

- Outbox table should be in the same database as domain entities
- Background worker should run continuously
- Implement idempotency in event handlers
- Consider using message broker (RabbitMQ, Azure Service Bus) for event delivery
