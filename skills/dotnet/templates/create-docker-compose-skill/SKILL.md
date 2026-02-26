---
name: create-docker-compose
description: |
  Create Docker Compose configuration for containerized .NET application development and deployment.

  Use when:
  - Containerizing .NET applications
  - Setting up local development environment with dependencies
  - Creating multi-container setups (API + DB + Redis)
  - Defining service dependencies and networking
  - Building docker-compose.yml for development or production

  Triggers: "docker compose", "containerize", "multi-container", "docker-compose.yml", "docker setup"
type: template
version: 1.2.1
tags:
  - dotnet
  - template
  - boilerplate
  - docker
  - containerization
---

# Create Docker Compose

## Purpose

Create basic containerized environment structure.

## Scope

Applies to:
- Docker-based deployments
- Local development environments
- Multi-container applications

## Rules

- Use environment variables for configuration
- Do not hard-code connection strings in containers
- Define services clearly
- Use appropriate image versions
- Use health checks for services

## Template Structure

```yaml
version: '3.9'

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "${API_PORT:-5000}:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT:-Development}
      - ConnectionStrings__DefaultConnection=${CONNECTION_STRING}
      - Redis__ConnectionString=${REDIS_CONNECTION_STRING}
    depends_on:
      - db
      - redis
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    ports:
      - "${DB_PORT:-1433}:1433"
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=${SA_PASSWORD}
      - MSSQL_PID=Developer
    volumes:
      - db-data:/var/opt/mssql
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P ${SA_PASSWORD} -Q 'SELECT 1' || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis-data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  db-data:
  redis-data:

networks:
  app-network:
    driver: bridge
```

## Anti-Patterns

- Hard-coded connection strings in containers
- No environment variable usage
- Missing service definitions
- Using latest tag without version
- No health checks
- No volume persistence

## Notes

- Use environment variables for all configuration
- Specify image versions explicitly
- Use health checks for service dependencies
- Use volumes for data persistence
- Define networks for service isolation
