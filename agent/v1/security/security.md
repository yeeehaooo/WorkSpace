# Security Guidelines (v1)

---

## General Principles

- Never expose secrets.
- Validate all external input.
- Prefer safe defaults.

---

## API Security

- Use proper authentication mechanisms.
- Do not expose internal exceptions.
- Avoid detailed error messages in production.

---

## Data Protection

- Encrypt sensitive data at rest.
- Use HTTPS only.
- Validate JWT properly (exp, iat, signature).
