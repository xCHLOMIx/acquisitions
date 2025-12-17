# Docker Setup Guide for Acquisitions

This guide explains how to run the Acquisitions application in both development and production environments using Docker and Neon Database.

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Production Environment Setup](#production-environment-setup)
3. [Environment Variables](#environment-variables)
4. [Database Migrations](#database-migrations)
5. [Troubleshooting](#troubleshooting)

---

## Development Environment Setup

### Prerequisites

- Docker and Docker Compose installed
- Node.js 20+ (for local development without Docker)

### Running Locally with Neon Local

Neon Local provides a local PostgreSQL database that mirrors Neon's serverless experience without cloud dependencies.

#### Step 1: Start the Development Stack

```bash
docker-compose -f docker-compose.dev.yml up --build
```

This command:

- Builds the application Docker image
- Starts a Neon Local PostgreSQL instance
- Starts the Node.js application
- Enables hot-reload (changes to `src/` files auto-update)

#### Step 2: Verify the Setup

Check if the application is running:

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{
  "status": "OK",
  "timestamp": "2025-12-17T10:30:45.123Z",
  "uptime": 12.345
}
```

#### Step 3: Run Database Migrations

In a new terminal:

```bash
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
```

Or to generate schema changes:

```bash
docker-compose -f docker-compose.dev.yml exec app npm run db:generate
```

#### Step 4: Access Drizzle Studio (Optional)

For visual database management:

```bash
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

#### Step 5: Stop the Stack

```bash
docker-compose -f docker-compose.dev.yml down
```

To also remove the Neon Local data volume:

```bash
docker-compose -f docker-compose.dev.yml down -v
```

### Development Workflow

1. **Make code changes**: All changes in `src/` are automatically hot-reloaded
2. **Database changes**: Edit schema in `src/models/`, then run migrations
3. **View logs**:
   ```bash
   docker-compose -f docker-compose.dev.yml logs -f app
   ```
4. **Execute shell commands**:
   ```bash
   docker-compose -f docker-compose.dev.yml exec app npm run lint:fix
   ```

### Connecting from Host Machine

To connect directly to Neon Local from your host machine (e.g., with pgAdmin or DBeaver):

```
Host: localhost
Port: 5432
Username: postgres
Password: postgres
Database: neondb
```

---

## Production Environment Setup

### Prerequisites

- Docker and Docker Compose installed
- Active Neon Cloud account (free tier available at https://neon.tech)
- Production database URL from Neon

### Step 1: Create Neon Cloud Database

1. Go to [Neon Console](https://console.neon.tech)
2. Create a new project
3. Get your database connection string (looks like: `postgres://user:password@ep-xxx.us-east-1.neon.tech/dbname`)

### Step 2: Configure Environment Variables

Create a `.env.production` file (or use Docker secrets):

```bash
# Using .env file
export DATABASE_URL="postgres://user:password@ep-xxx.us-east-1.neon.tech/dbname"
export CORS_ORIGIN="https://yourdomain.com"
export ARCJET_KEY="your-arcjet-key"
export JWT_SECRET="your-secure-jwt-secret"
```

Or pass them directly to Docker:

```bash
docker-compose -f docker-compose.prod.yml \
  --env-file .env.production \
  up -d
```

### Step 3: Run Database Migrations

Before starting the application:

```bash
docker run --rm \
  -e DATABASE_URL="postgres://user:password@ep-xxx.us-east-1.neon.tech/dbname" \
  -v $(pwd):/app \
  acquisitions-app \
  npm run db:migrate
```

Or if the container is already running:

```bash
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### Step 4: Start Production Stack

```bash
docker-compose -f docker-compose.prod.yml up -d
```

Verify the application:

```bash
curl https://yourdomain.com/health
```

### Step 5: View Logs

```bash
docker-compose -f docker-compose.prod.yml logs -f app
```

### Step 6: Stop Production Stack

```bash
docker-compose -f docker-compose.prod.yml down
```

---

## Environment Variables

### Development (`.env.development`)

| Variable       | Default                                             | Description                  |
| -------------- | --------------------------------------------------- | ---------------------------- |
| `NODE_ENV`     | development                                         | Application environment      |
| `PORT`         | 3000                                                | Application port             |
| `DATABASE_URL` | postgres://postgres:postgres@neon-local:5432/neondb | Neon Local connection string |
| `LOG_LEVEL`    | debug                                               | Logging verbosity            |
| `CORS_ORIGIN`  | http://localhost:3000                               | CORS allowed origin          |
| `JWT_SECRET`   | dev_secret_key_change_in_production                 | JWT signing secret           |
| `ARCJET_KEY`   | placeholder_dev_key                                 | Arcjet security key          |

### Production (`.env.production`)

| Variable       | Default    | Required | Description                                  |
| -------------- | ---------- | -------- | -------------------------------------------- |
| `NODE_ENV`     | production | Yes      | Application environment                      |
| `PORT`         | 3000       | No       | Application port                             |
| `DATABASE_URL` | -          | **Yes**  | Neon Cloud connection string                 |
| `LOG_LEVEL`    | info       | No       | Logging verbosity (use 'info' in production) |
| `CORS_ORIGIN`  | -          | **Yes**  | Your production domain                       |
| `JWT_SECRET`   | -          | **Yes**  | Secure JWT signing secret (min 32 chars)     |
| `ARCJET_KEY`   | -          | No       | Production Arcjet key                        |

### Database URL Format

**Development (Neon Local):**

```
postgres://postgres:postgres@neon-local:5432/neondb
```

**Production (Neon Cloud):**

```
postgres://username:password@ep-xxxxx.region.neon.tech/dbname?sslmode=require
```

> **Note:** Neon Cloud automatically adds `?sslmode=require` to connection strings. Always use SSL in production.

---

## Database Migrations

### Generate New Migration

1. Update your schema in `src/models/`
2. Run:
   ```bash
   docker-compose -f docker-compose.dev.yml exec app npm run db:generate
   ```
3. Review the generated SQL in `drizzle/`
4. Commit the migration file

### Apply Migrations

**Development:**

```bash
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
```

**Production:**

```bash
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### View Database Changes

**Development:**

```bash
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

---

## Troubleshooting

### Neon Local Container Won't Start

**Error:** `port 5432 is in use`

**Solution:**

```bash
# Find and stop the container using port 5432
docker ps
docker stop <container_id>

# Or change the port in docker-compose.dev.yml
# Change "5432:5432" to "5433:5432" and update DATABASE_URL
```

### Application Can't Connect to Database

**Development:**

- Verify Neon Local is running: `docker ps`
- Check Neon Local logs: `docker-compose -f docker-compose.dev.yml logs neon-local`
- Verify DATABASE_URL in `.env.development`: `postgres://postgres:postgres@neon-local:5432/neondb`

**Production:**

- Verify DATABASE_URL is correct from Neon Console
- Check SSL mode is enabled: `?sslmode=require`
- Ensure your IP/server is whitelisted in Neon (if applicable)
- Verify JWT_SECRET is set and correct

### Container Exits Immediately

**Solution:**

```bash
# Check logs
docker-compose -f docker-compose.dev.yml logs app

# Or for production
docker-compose -f docker-compose.prod.yml logs app
```

### Permission Denied Errors

**Solution:**

```bash
# Run with appropriate user
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
```

### Port Already in Use

Change the port mapping in `docker-compose.dev.yml` or `docker-compose.prod.yml`:

```yaml
ports:
  - '3001:3000' # Host port 3001 → Container port 3000
```

### Database Connection Timeout

**Development:**

- Ensure Neon Local container is healthy: `docker-compose -f docker-compose.dev.yml ps`
- Wait for health check to pass (takes ~10-15 seconds)

**Production:**

- Verify Neon project is active (not paused)
- Check network connectivity to Neon region
- Verify SSL certificate trust (some proxies may need special config)

---

## Advanced Usage

### Custom Database Name (Development)

Edit `docker-compose.dev.yml`:

```yaml
environment:
  POSTGRES_DB: my_custom_db
  # Update DATABASE_URL to match
```

Then update `.env.development`:

```
DATABASE_URL=postgres://postgres:postgres@neon-local:5432/my_custom_db
```

### Multiple Environments

Keep separate compose files:

- `docker-compose.dev.yml` - Local development
- `docker-compose.staging.yml` - Staging with Neon Cloud
- `docker-compose.prod.yml` - Production with Neon Cloud

### Health Checks in Production

The production compose includes automatic health checks:

```bash
# Check health status
docker-compose -f docker-compose.prod.yml ps

# Or manually
curl -f http://localhost:3000/health || exit 1
```

### Resource Limits

Production compose includes CPU and memory limits. Adjust as needed:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 1G
```

---

## Summary

| Task       | Development                                                            | Production                                                              |
| ---------- | ---------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Start      | `docker-compose -f docker-compose.dev.yml up`                          | `docker-compose -f docker-compose.prod.yml up -d`                       |
| Logs       | `docker-compose -f docker-compose.dev.yml logs -f`                     | `docker-compose -f docker-compose.prod.yml logs -f`                     |
| Migrate DB | `docker-compose -f docker-compose.dev.yml exec app npm run db:migrate` | `docker-compose -f docker-compose.prod.yml exec app npm run db:migrate` |
| Stop       | `Ctrl+C` or `docker-compose -f docker-compose.dev.yml down`            | `docker-compose -f docker-compose.prod.yml down`                        |
| Database   | Neon Local (ephemeral)                                                 | Neon Cloud (persistent)                                                 |

---

## Security Notes

1. **Never commit `.env` files** to version control
2. **Change `JWT_SECRET`** to a cryptographically secure random string
3. **Use Docker secrets** for sensitive data in production (not environment files)
4. **Rotate `ARCJET_KEY`** regularly
5. **Use strong passwords** for Neon database users
6. **Enable SSL/TLS** for all database connections (automatic with Neon)
7. **Implement rate limiting** with Arcjet in production
8. **Use health checks** to detect failed containers

---

For more information:

- [Neon Documentation](https://neon.tech/docs)
- [Neon Local Guide](https://neon.com/docs/local/neon-local)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Node.js Docker Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
