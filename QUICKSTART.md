# Quick Start Guide - Docker Setup

## 🚀 Development (5 minutes)

### Start Everything

```bash
docker-compose -f docker-compose.dev.yml up --build
```

### In Another Terminal - Run Migrations

```bash
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
```

### Test It

```bash
curl http://localhost:3000/health
```

✅ App runs at `http://localhost:3000`  
✅ Database at `localhost:5432` (postgres/postgres)

---

## 🏭 Production Deployment

### Step 1: Create Neon Cloud Database

Visit https://console.neon.tech and copy your DATABASE_URL

### Step 2: Set Environment Variables

```bash
export DATABASE_URL="postgres://user:pass@ep-xxx.neon.tech/dbname"
export CORS_ORIGIN="https://yourdomain.com"
export JWT_SECRET="$(openssl rand -base64 32)"
export ARCJET_KEY="your-key"
```

### Step 3: Start Production

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Step 4: Migrate Database

```bash
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### Verify

```bash
curl https://yourdomain.com/health
docker-compose -f docker-compose.prod.yml logs
```

---

## 📚 Common Commands

| Command                                                                | Purpose                       |
| ---------------------------------------------------------------------- | ----------------------------- |
| `docker-compose -f docker-compose.dev.yml up --build`                  | Start dev (rebuilds image)    |
| `docker-compose -f docker-compose.dev.yml logs -f app`                 | Watch app logs                |
| `docker-compose -f docker-compose.dev.yml exec app npm run db:migrate` | Run migrations                |
| `docker-compose -f docker-compose.dev.yml exec app npm run db:studio`  | Visual DB editor              |
| `docker-compose -f docker-compose.dev.yml down -v`                     | Stop & delete data            |
| `docker-compose -f docker-compose.prod.yml up -d`                      | Start production (background) |
| `docker-compose -f docker-compose.prod.yml logs -f`                    | Watch prod logs               |

---

## ✅ What You Get

✨ **Development:**

- Hot-reload code changes
- Local Neon database (no cloud costs)
- Drizzle Studio for DB management
- Full logs and debugging

🔒 **Production:**

- Secure Neon Cloud database
- Environment variable injection
- Health checks
- Resource limits
- Zero downtime ready

---

## 🔗 Connection Strings

**Dev (Neon Local):** `postgres://postgres:postgres@neon-local:5432/neondb`

**Prod (Neon Cloud):** `postgres://user:pass@ep-xxx.us-east-1.neon.tech/dbname?sslmode=require`

---

For detailed documentation, see [DOCKER_SETUP.md](./DOCKER_SETUP.md)
