# API Design Guidelines (v1)

---

## Endpoint Design

- Keep endpoints thin.
- Map Request → Command/Query.
- Map Result → Response DTO.
- Return consistent response format.

---

## Structure

- Organize endpoints by feature.
- Avoid exposing domain entities directly.
- Avoid leaking internal models.
