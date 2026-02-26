---
name: domain-event
description: |
  Enable domain entities to publish events when significant business events occur, allowing decoupled side effects in Clean Architecture applications.

  Use when:
  - Domain entities need to notify other parts of the system about business events
  - Implementing event-driven architecture with decoupled handlers
  - Coordinating side effects after domain changes
  - Building reactive systems that respond to domain state changes
  - Implementing eventual consistency between bounded contexts

  Triggers: "domain event", "event publishing", "event handler", "domain notification", "event-driven", "side effect"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - domain-driven-design
  - event-driven
---

# Domain Event Pattern

## Purpose

Enable domain entities to publish events when significant business events occur, allowing decoupled side effects.

## Scope

Applies to:
- Domain Layer
- Application Layer
- Infrastructure Layer
- Event-driven architectures
- Bounded context integration

## Rules

- Domain events represent business facts that have occurred
- Events raised by aggregates, not by application services
- Events dispatched after transaction commit (to ensure consistency)
- Multiple handlers can react to the same event
- Handlers should be idempotent when possible
- `IDomainEvent` interface defined in Domain layer
- `IDomainEventDispatcher` defined in Application layer, implemented in Infrastructure

## Anti-Patterns

- Raising events from application services instead of domain entities
- Dispatching events before transaction commit
- Using events for synchronous command flow (use return values instead)
- Events containing too much data or implementation details
- Handlers with business logic instead of side effects

## Minimal Example

```csharp
// Domain Layer
public interface IDomainEvent
{
  DateTime OccurredOn { get; }
}

public class OrderCreatedEvent : IDomainEvent
{
  public DateTime OccurredOn { get; init; } = DateTime.UtcNow;
  public Guid OrderId { get; init; }
  public Guid CustomerId { get; init; }
  public decimal TotalAmount { get; init; }
}

public class Order : AggregateRoot
{
  private readonly List<IDomainEvent> _domainEvents = new();

  public IReadOnlyCollection<IDomainEvent> DomainEvents => _domainEvents.AsReadOnly();

  public void Create(Guid customerId, decimal totalAmount)
  {
    // Business logic...
    Id = Guid.NewGuid();
    CustomerId = customerId;
    TotalAmount = totalAmount;

    // Raise domain event
    _domainEvents.Add(new OrderCreatedEvent
    {
      OrderId = Id,
      CustomerId = customerId,
      TotalAmount = totalAmount
    });
  }

  public void ClearDomainEvents()
  {
    _domainEvents.Clear();
  }
}

// Application Layer
public interface IDomainEventDispatcher
{
  Task DispatchAsync<T>(T domainEvent) where T : IDomainEvent;
  Task DispatchAllAsync(IEnumerable<IDomainEvent> domainEvents);
}

// Handler
public interface IDomainEventHandler<T> where T : IDomainEvent
{
  Task Handle(T domainEvent, CancellationToken cancellationToken = default);
}

public class SendOrderConfirmationHandler : IDomainEventHandler<OrderCreatedEvent>
{
  private readonly IEmailService _emailService;

  public async Task Handle(OrderCreatedEvent evt, CancellationToken ct)
  {
    await _emailService.SendOrderConfirmationAsync(evt.CustomerId, evt.OrderId, ct);
  }
}

// Usage in Command Handler
public class CreateOrderHandler : ICommandHandler<CreateOrderCommand>
{
  private readonly IOrderRepository _orderRepo;
  private readonly IDomainEventDispatcher _eventDispatcher;
  private readonly IUnitOfWork _uow;

  public async Task<Result> Handle(CreateOrderCommand cmd, CancellationToken ct)
  {
    var order = new Order();
    order.Create(cmd.CustomerId, cmd.TotalAmount);

    await _orderRepo.AddAsync(order, ct);

    // Dispatch events after commit
    await _uow.CommitAsync(ct);
    await _eventDispatcher.DispatchAllAsync(order.DomainEvents, ct);

    order.ClearDomainEvents();
    return Result.Success();
  }
}
```

## Combination with Other Patterns

This pattern works well with:
- **Unit of Work**: Dispatch events after successful transaction commit
- **Outbox Pattern**: Store events in outbox for reliable delivery
- **Execution Tracking**: Track event publishing in execution logs

## Notes

- Events should be immutable
- Events should contain only data needed by handlers
- Always dispatch events after transaction commit
- Consider using Outbox pattern for reliable event delivery
