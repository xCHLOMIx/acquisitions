# Docker & Neon Database Integration Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     DEVELOPMENT                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐         ┌─────────────────────────┐  │
│  │  Node.js App     │         │  Neon Local (Postgres)  │  │
│  │  :3000           │ <-----> │  :5432                  │  │
│  └──────────────────┘         └─────────────────────────┘  │
│                                                              │
│  📁 Code Auto-Reloads  |  🔄 Hot Module Reload             │
│  📊 Full Debugging     |  ⚡ Fast Iteration                │
│                                                              │
│  docker-compose.dev.yml                                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     PRODUCTION                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐         ┌─────────────────────────┐  │
│  │  Node.js App     │         │ Neon Cloud Database     │  │
│  │  :3000           │ <-----> │ (Managed Postgres)      │  │
│  └──────────────────┘         └─────────────────────────┘  │
│                                                              │
│  🔒 Secure Secrets     |  📈 Scalable                     │
│  🏥 Health Checks      |  🔐 Encrypted Connection         │
│                                                              │
│  docker-compose.prod.yml  |  .env.production              │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Reference

### Start Development

```bash
docker-compose -f docker-compose.dev.yml up
```

### Start Production

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Run Migrations

```bash
# Dev
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Prod
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### View Logs

```bash
# Dev
docker-compose -f docker-compose.dev.yml logs -f app

# Prod
docker-compose -f docker-compose.prod.yml logs -f app
```

---

## File Structure

```
acquisitions/
├── Dockerfile                    # Multi-stage build for app
├── docker-compose.dev.yml       # Dev: App + Neon Local
├── docker-compose.prod.yml      # Prod: App only (uses Neon Cloud)
├── .dockerignore                # What to exclude from images
├── .env.development             # Dev environment variables
├── .env.production              # Prod environment variables
├── .env.example                 # Template for .env files
├── DOCKER_SETUP.md              # Comprehensive guide
├── QUICKSTART.md                # 5-minute setup
├── setup-dev.sh                 # Dev setup automation
├── setup-prod.sh                # Prod setup automation
├── package.json                 # Dependencies
├── drizzle.config.js            # ORM configuration
├── src/
│   ├── app.js                   # Express app
│   ├── index.js                 # Entry point
│   ├── server.js                # Server startup
│   ├── config/
│   │   └── database.js          # DB connection
│   ├── models/                  # Drizzle schemas
│   ├── routes/                  # API routes
│   └── ...
└── drizzle/                     # Migrations & snapshots
```

---

## Environment Variables by Scenario

### Scenario 1: Local Development with Neon Local

**File:** `.env.development`

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgres://postgres:postgres@neon-local:5432/neondb
LOG_LEVEL=debug
CORS_ORIGIN=http://localhost:3000
JWT_SECRET=dev_secret_change_in_production
ARCJET_KEY=placeholder_dev_key
```

**Connection Flow:**

1. App container connects to Neon Local at `neon-local:5432`
2. Neon Local provides ephemeral PostgreSQL instance
3. Data persists in Docker volume: `neon-data`

---

### Scenario 2: Production with Neon Cloud

**File:** `.env.production` (or use Docker secrets)

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgres://user:password@ep-xxxxx.us-east-1.neon.tech/dbname?sslmode=require
LOG_LEVEL=info
CORS_ORIGIN=https://yourdomain.com
JWT_SECRET=<secure-random-string>
ARCJET_KEY=<production-key>
```

**Connection Flow:**

1. App container connects to Neon Cloud
2. Connection uses SSL/TLS (mandatory)
3. Credentials injected via environment variables
4. No local database in production container

---

### Scenario 3: Staging with Neon Cloud

Same as production but different domain/keys:

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgres://user:password@ep-yyyyy.staging.neon.tech/dbname?sslmode=require
CORS_ORIGIN=https://staging.yourdomain.com
LOG_LEVEL=info
JWT_SECRET=<staging-secret>
```

---

## Database Connection Details

### Development (Neon Local)

```
Host: neon-local (Docker) or localhost (Host)
Port: 5432
Username: postgres
Password: postgres
Database: neondb
SSL: Not required
Connection String: postgres://postgres:postgres@neon-local:5432/neondb
```

**From Host Machine:**

```
psql postgres://postgres:postgres@localhost:5432/neondb
```

**From Container:**

```bash
docker-compose -f docker-compose.dev.yml exec neon-local psql -U postgres
```

### Production (Neon Cloud)

```
Host: ep-xxxxx.region.neon.tech
Port: 5432
Username: <your-username>
Password: <secure-password>
Database: <dbname>
SSL: Required (sslmode=require)
Connection String: postgres://user:password@ep-xxxxx.us-east-1.neon.tech/dbname?sslmode=require
```

**From Application:**

```javascript
// Automatically handled by drizzle config
const url = process.env.DATABASE_URL;
// postgres://user:password@ep-xxxxx.us-east-1.neon.tech/dbname?sslmode=require
```

---

## Docker Image Details

### Dockerfile

**Multi-stage build:**

1. **Builder Stage**: Installs dependencies
2. **Runtime Stage**: Minimal image with only needed files

**Benefits:**

- ✅ Smaller image size (~300MB vs 1GB+)
- ✅ Faster deployments
- ✅ No npm install tools in runtime
- ✅ Production-ready

**Image layers:**

```
FROM node:20-alpine       # ~100MB
COPY node_modules         # ~200MB
COPY application          # ~1MB
dumb-init                 # Proper signal handling
```

### docker-compose.dev.yml

**Services:**

- `neon-local`: PostgreSQL server for development
- `app`: Node.js application

**Features:**

- Volume mounts for code hot-reload
- Health checks for startup sequencing
- Network isolation
- Auto-restart on failure

### docker-compose.prod.yml

**Service:**

- `app`: Node.js application only

**Features:**

- No database service (uses Neon Cloud)
- Health checks for monitoring
- Resource limits (CPU, Memory)
- Restart policy for high availability
- Detached mode (`-d` flag)

---

## Migration Workflow

### Development

```bash
# 1. Update schema in src/models/user.model.js
# 2. Generate migration
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# 3. Review generated SQL in drizzle/
# 4. Apply migration
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# 5. Test with Drizzle Studio
docker-compose -f docker-compose.dev.yml exec app npm run db:studio

# 6. Commit changes to version control
git add drizzle/
git commit -m "Add new user fields migration"
```

### Production

```bash
# Option A: Pre-deployment migration
docker-compose -f docker-compose.prod.yml up -d
sleep 5
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate

# Option B: Blue-green deployment
# 1. Deploy new version with migration
# 2. Run migration on new instance
# 3. Switch traffic from old to new
# 4. Keep old instance as rollback
```

---

## Volume & Networking

### Development Volumes

```yaml
neon-data:
  # Persists Neon Local database between restarts
  # Located at: docker volume ls | grep neon-data

app code mount:
  # Enables hot-reload
  # src/ changes auto-update in container
  # node_modules/ from container (not host)
```

**Inspect volume:**

```bash
docker volume inspect acquisitions_neon-data
```

**Clean up:**

```bash
docker-compose -f docker-compose.dev.yml down -v
# Removes all volumes including neon-data
```

### Development Network

```
acquisitions-network (bridge)
├── neon-local:5432   (PostgreSQL)
└── app:3000          (Node.js)

Container DNS:
- neon-local resolves to neon-local container
- app resolves to app container
- External: localhost:5432, localhost:3000
```

---

## Performance Optimization

### Development

```yaml
# Hot-reload for fast iteration
volumes:
  - .:/app
  - /app/node_modules
command: node --watch src/index.js
```

### Production

```yaml
# Optimized for stability
restart: unless-stopped
healthcheck: # Auto-recovery
resources:
  limits:
    cpus: '1'
    memory: 512M
```

---

## Security Checklist

- [ ] `.env.production` NOT in version control
- [ ] `JWT_SECRET` is 32+ characters
- [ ] `DATABASE_URL` uses SSL mode in production
- [ ] CORS_ORIGIN set to actual domain (not \*)
- [ ] Arcjet key is valid and active
- [ ] Docker secrets used for sensitive data
- [ ] Health checks configured
- [ ] Logs not exposing sensitive data
- [ ] Network isolated to private networks
- [ ] Resource limits set in production

---

## Troubleshooting

| Issue             | Dev                  | Prod                      |
| ----------------- | -------------------- | ------------------------- |
| DB won't start    | Check port 5432      | N/A                       |
| App can't connect | Check neon-local DNS | Check Neon Cloud status   |
| Slow startup      | Neon Local init time | Check resource allocation |
| Logs hard to read | `logs -f app`        | `logs -f app \| less`     |
| Need fresh DB     | `down -v`            | N/A (contact Neon)        |
| Container exits   | `logs app`           | `logs app`                |

---

## Deployment Checklist

```bash
# Pre-deployment
[ ] Test locally: docker-compose.dev.yml works
[ ] Review migrations: drizzle/ directory
[ ] Update .env.production with real values
[ ] Validate DATABASE_URL format
[ ] Generate JWT_SECRET: openssl rand -base64 32
[ ] Get Arcjet production key
[ ] Set up Neon Cloud project

# Deployment
[ ] docker-compose -f docker-compose.prod.yml up -d
[ ] docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
[ ] curl http://localhost:3000/health (verify)
[ ] Check logs: docker-compose logs app
[ ] Monitor for 5 minutes
[ ] Set up log aggregation
[ ] Configure backups (Neon Cloud)

# Post-deployment
[ ] Monitor application
[ ] Set up alerts
[ ] Document any custom settings
[ ] Plan for scaling
```

---

## Resources

- [Neon Documentation](https://neon.tech/docs)
- [Neon Local Quick Start](https://neon.com/docs/local/neon-local)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Node.js Docker Guide](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
- [Drizzle ORM Docs](https://orm.drizzle.team)
- [PostgreSQL Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)

---

## Next Steps

1. ✅ Review `Dockerfile` - understand multi-stage build
2. ✅ Review `docker-compose.dev.yml` - understand services
3. ✅ Review `docker-compose.prod.yml` - understand production setup
4. ✅ Review `.env.development` - understand variables
5. ✅ Review `.env.production` - understand secrets injection
6. ✅ Read `QUICKSTART.md` - 5-minute setup
7. ✅ Read `DOCKER_SETUP.md` - detailed guide
8. ✅ Run `docker-compose -f docker-compose.dev.yml up`
9. ✅ Verify at `http://localhost:3000`
10. ✅ Test migrations workflow
