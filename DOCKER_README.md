# Docker & Neon Database Setup - Complete Guide

Welcome to the fully containerized **Acquisitions** application with support for both **Neon Local** (development) and **Neon Cloud** (production).

## 📋 What You Get

This setup provides:

✅ **Development Environment**

- Neon Local PostgreSQL running in Docker
- Hot-reload code changes
- Drizzle Studio for visual database management
- Full debugging capabilities
- Zero cloud costs during development

✅ **Production Environment**

- Neon Cloud serverless PostgreSQL
- Environment variable injection for secrets
- Health checks and auto-recovery
- Resource limits and monitoring
- Ready for Kubernetes/Docker Swarm deployment

✅ **Documentation**

- Quick start (5 minutes)
- Detailed setup guide
- Docker & Kubernetes examples
- CI/CD workflow (GitHub Actions)
- Troubleshooting guide

---

## 🚀 Quick Start (5 Minutes)

### For Developers

```bash
# 1. Start everything
docker-compose -f docker-compose.dev.yml up --build

# 2. In another terminal, run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# 3. Test the app
curl http://localhost:3000/health
```

**That's it!** Your app is running at `http://localhost:3000`

See [QUICKSTART.md](./QUICKSTART.md) for more details.

### For DevOps/Production

```bash
# 1. Set environment variables
export DATABASE_URL="postgres://user:pass@ep-xxx.neon.tech/dbname"
export CORS_ORIGIN="https://yourdomain.com"
export JWT_SECRET="$(openssl rand -base64 32)"
export ARCJET_KEY="your-key"

# 2. Start production
docker-compose -f docker-compose.prod.yml up -d

# 3. Run migrations
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate

# 4. Verify
curl https://yourdomain.com/health
```

---

## 📁 File Structure

```
acquisitions/
│
├── 🐳 Docker & Compose Files
├── Dockerfile                      # Multi-stage build (lightweight)
├── docker-compose.dev.yml          # Dev: App + Neon Local
├── docker-compose.prod.yml         # Prod: App only
├── .dockerignore                   # Optimization
│
├── 🔧 Environment Configuration
├── .env.development                # Dev variables (Neon Local)
├── .env.production                 # Prod variables (Neon Cloud)
├── .env.example                    # Template
│
├── 📚 Documentation
├── README.md                       # This file
├── QUICKSTART.md                   # 5-minute setup
├── DOCKER_SETUP.md                 # Comprehensive guide
├── DOCKER_REFERENCE.md             # Technical reference
│
├── 🚀 Deployment Automation
├── setup-dev.sh                    # Dev setup script
├── setup-prod.sh                   # Prod setup script
│
├── 🔗 CI/CD & Kubernetes
├── .github/
│   └── workflows/
│       └── docker-deploy.yml       # GitHub Actions workflow
├── k8s/
│   └── deployment.yaml             # Kubernetes manifests
├── helm/
│   └── values.yaml                 # Helm chart values
│
└── 📦 Application (existing)
    ├── package.json
    ├── drizzle.config.js
    ├── src/
    ├── drizzle/
    └── ... (your code)
```

---

## 🎯 Choose Your Path

### Path 1: Local Development with Neon Local ⚡

Perfect for:

- Fast iteration and testing
- No cloud costs
- Full control over database
- Team collaboration with hot-reload

**Start here:**

```bash
docker-compose -f docker-compose.dev.yml up
```

**Read:** [QUICKSTART.md](./QUICKSTART.md) (5 min)

---

### Path 2: Production with Neon Cloud 🔒

Perfect for:

- Production deployments
- Scalability and reliability
- Managed PostgreSQL
- Security and compliance

**Start here:**

```bash
docker-compose -f docker-compose.prod.yml up -d
```

**Read:** [DOCKER_SETUP.md](./DOCKER_SETUP.md#production-environment-setup) (Prod section)

---

### Path 3: Kubernetes Deployment ☸️

Perfect for:

- Multi-server deployments
- Auto-scaling
- High availability
- Enterprise environments

**Read:** [k8s/deployment.yaml](./k8s/deployment.yaml)

---

### Path 4: Helm Chart ⚙️

Perfect for:

- Templated deployments
- Version management
- Easy upgrades

**Read:** [helm/values.yaml](./helm/values.yaml)

---

## 📖 Documentation Map

| Document                                     | Duration | For Whom         | Content              |
| -------------------------------------------- | -------- | ---------------- | -------------------- |
| [QUICKSTART.md](./QUICKSTART.md)             | 5 min    | Developers       | Get running fast     |
| [DOCKER_SETUP.md](./DOCKER_SETUP.md)         | 20 min   | Everyone         | Complete guide       |
| [DOCKER_REFERENCE.md](./DOCKER_REFERENCE.md) | 15 min   | DevOps/Technical | Architecture details |
| [k8s/deployment.yaml](./k8s/deployment.yaml) | 30 min   | DevOps           | Kubernetes setup     |
| [.github/workflows/](../.github/workflows/)  | 15 min   | CI/CD            | GitHub Actions       |

---

## 🔑 Key Concepts

### Database Connections

**Development (Neon Local):**

```
postgres://postgres:postgres@neon-local:5432/neondb
                    ↑          ↑
                 password   hostname (inside docker network)
```

**Production (Neon Cloud):**

```
postgres://user:password@ep-xxxxx.us-east-1.neon.tech/dbname?sslmode=require
                         ↑
                    Neon endpoint (with SSL required)
```

### Environment Variables

**Development uses `.env.development`:**

```env
NODE_ENV=development
DATABASE_URL=postgres://postgres:postgres@neon-local:5432/neondb
```

**Production uses `.env.production` or Docker secrets:**

```env
NODE_ENV=production
DATABASE_URL=postgres://...@ep-xxx.neon.tech/dbname
```

---

## 🛠️ Common Tasks

### Start Development

```bash
docker-compose -f docker-compose.dev.yml up
```

### Stop Development

```bash
# Stop without removing data
docker-compose -f docker-compose.dev.yml down

# Stop and remove data
docker-compose -f docker-compose.dev.yml down -v
```

### View Logs

```bash
# Development
docker-compose -f docker-compose.dev.yml logs -f app

# Production
docker-compose -f docker-compose.prod.yml logs -f app
```

### Run Database Migrations

```bash
# Development
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Production
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### Open Drizzle Studio (Dev Only)

```bash
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

### Connect to Database

**Development (from host):**

```bash
psql postgres://postgres:postgres@localhost:5432/neondb
```

**Development (from Docker):**

```bash
docker-compose -f docker-compose.dev.yml exec neon-local psql -U postgres
```

**Production:**
Use your Neon dashboard or connect with your credentials.

### Rebuild Image

```bash
docker-compose -f docker-compose.dev.yml up --build
```

### Execute Commands in Container

```bash
# Lint
docker-compose -f docker-compose.dev.yml exec app npm run lint:fix

# Run custom npm script
docker-compose -f docker-compose.dev.yml exec app npm run your-script
```

---

## 🔐 Security Best Practices

✅ **Development:**

- Use dummy credentials (safe to commit `.env.development`)
- Data automatically cleaned up with `down -v`
- No secrets exposed

✅ **Production:**

- Never commit `.env.production` with real secrets
- Use Docker secrets or environment variable injection
- Enable SSL/TLS (automatic with Neon Cloud)
- Rotate JWT_SECRET regularly
- Use strong ARCJET_KEY

✅ **General:**

- Change default passwords
- Use 32+ character JWT_SECRET
- Enable health checks
- Monitor logs and alerts
- Keep images updated

See [Security Checklist](./DOCKER_SETUP.md#security-notes) for details.

---

## 🐛 Troubleshooting

### Issue: Port 5432 already in use

```bash
# Find what's using it
docker ps | grep 5432

# Or change port in docker-compose.dev.yml
# Change "5432:5432" to "5433:5432"
```

### Issue: Container exits immediately

```bash
# Check logs
docker-compose -f docker-compose.dev.yml logs app

# Common fixes:
# - DATABASE_URL not set
# - Neon Local not started yet
# - Syntax error in code
```

### Issue: Database migration fails

```bash
# Check if database is ready
docker-compose -f docker-compose.dev.yml exec neon-local pg_isready -U postgres

# Check if migrations directory exists
ls -la drizzle/

# Run with verbose output
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate -- --verbose
```

See [DOCKER_SETUP.md](./DOCKER_SETUP.md#troubleshooting) for more troubleshooting.

---

## 📊 Architecture

### Development

```
Your Machine
    ↓
┌─────────────────────────────────────┐
│  Docker Desktop                      │
├─────────────────────────────────────┤
│                                      │
│  ┌──────────────┐  ┌─────────────┐ │
│  │ Node.js App  │←→│ Neon Local  │ │
│  │ (hot-reload) │  │ (Postgres)  │ │
│  └──────────────┘  └─────────────┘ │
│                                      │
│  Volume: neon-data (persisted)      │
│  Network: acquisitions-network      │
└─────────────────────────────────────┘
```

### Production

```
Internet
    ↓
┌────────────────────────────────────────┐
│  Docker Host / Kubernetes Cluster      │
├────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐      ┌────────────┐ │
│  │ Node.js App  │─────→│ Neon Cloud │ │
│  │ (3 replicas) │      │ Database   │ │
│  └──────────────┘      └────────────┘ │
│                                         │
│  Health Checks: /health               │
│  Resource Limits: 1 CPU, 512MB RAM    │
│  Auto-restart: on failure             │
└────────────────────────────────────────┘
```

---

## 🚀 Deployment Options

### Option 1: Docker Compose (Single Server)

```bash
docker-compose -f docker-compose.prod.yml up -d
```

**Best for:** Small deployments, VPS hosting

---

### Option 2: Docker Swarm (Multiple Servers)

```bash
docker stack deploy -c docker-compose.prod.yml acquisitions
```

**Best for:** Multi-server setups without Kubernetes complexity

---

### Option 3: Kubernetes (Enterprise)

```bash
kubectl apply -f k8s/deployment.yaml
```

**Best for:** Large scale, high availability, auto-scaling

---

### Option 4: Helm (Kubernetes with Templates)

```bash
helm install acquisitions ./helm/
```

**Best for:** Templated deployments, easy version management

---

## 📈 Monitoring & Logs

### Local Development

```bash
# Watch logs in real-time
docker-compose -f docker-compose.dev.yml logs -f app

# Follow only app logs (less noise)
docker-compose -f docker-compose.dev.yml logs -f app --tail 50
```

### Production

```bash
# Check container health
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f app

# Kubernetes (if deployed on K8s)
kubectl logs -f -l app=acquisitions -n acquisitions
```

---

## 🔄 Continuous Integration & Deployment

We've included a GitHub Actions workflow that:

1. ✅ Tests your code
2. ✅ Builds Docker image
3. ✅ Pushes to registry
4. ✅ Deploys to dev/prod

See [.github/workflows/docker-deploy.yml](./.github/workflows/docker-deploy.yml)

---

## 📦 What's Included

| File                      | Purpose                      | Dev | Prod |
| ------------------------- | ---------------------------- | --- | ---- |
| `Dockerfile`              | App container image          | ✅  | ✅   |
| `docker-compose.dev.yml`  | Dev stack (App + Neon Local) | ✅  | ❌   |
| `docker-compose.prod.yml` | Prod stack (App only)        | ❌  | ✅   |
| `.env.development`        | Dev variables                | ✅  | ❌   |
| `.env.production`         | Prod variables               | ❌  | ✅   |
| `DOCKER_SETUP.md`         | Complete guide               | ✅  | ✅   |
| `QUICKSTART.md`           | Quick start                  | ✅  | ❌   |
| `k8s/deployment.yaml`     | Kubernetes manifests         | ❌  | ✅   |
| `helm/values.yaml`        | Helm chart                   | ❌  | ✅   |
| `.github/workflows/`      | CI/CD automation             | ✅  | ✅   |

---

## ❓ FAQ

**Q: Can I use this setup without Docker?**
A: Yes, but you won't have Neon Local. You'd need to set up PostgreSQL manually.

**Q: How do I switch between Neon Local and Neon Cloud?**
A: Change the `DATABASE_URL` environment variable. Dev uses Neon Local, Prod uses Neon Cloud.

**Q: Is .env.development safe to commit?**
A: Yes, it contains dummy/default values. Never commit `.env.production` with real secrets.

**Q: How do I scale the app?**
A: For Docker Compose, use Kubernetes. For Kubernetes, use Horizontal Pod Autoscaler (configured in k8s manifest).

**Q: How do I backup the database?**
A: Development uses Docker volumes (auto-managed). Production uses Neon Cloud (automatic backups included).

**Q: Can I use this with other databases?**
A: Yes, modify `docker-compose.dev.yml` to use PostgreSQL/MySQL/MongoDB instead of Neon Local.

**Q: How do I update to a new app version?**
A: `docker-compose -f docker-compose.prod.yml up -d` (pulls latest image)

---

## 📚 Resources

- **Neon Docs:** https://neon.tech/docs
- **Neon Local:** https://neon.com/docs/local/neon-local
- **Docker Docs:** https://docs.docker.com
- **Docker Compose:** https://docs.docker.com/compose/
- **Kubernetes:** https://kubernetes.io/docs/
- **Helm:** https://helm.sh/docs/
- **Drizzle ORM:** https://orm.drizzle.team/
- **GitHub Actions:** https://docs.github.com/en/actions

---

## 📞 Support

### Common Issues

1. **Can't connect to database?**
   - Dev: Check if Neon Local is running: `docker ps`
   - Prod: Verify DATABASE_URL is correct

2. **Port already in use?**
   - Change port mapping in docker-compose file
   - Or stop other containers: `docker ps` and `docker stop`

3. **Migrations not applying?**
   - Check drizzle.config.js has correct DATABASE_URL
   - Run: `docker-compose exec app npm run db:generate`

See [DOCKER_SETUP.md](./DOCKER_SETUP.md#troubleshooting) for detailed troubleshooting.

---

## ✅ Next Steps

1. **Read** [QUICKSTART.md](./QUICKSTART.md) (5 min)
2. **Run** `docker-compose -f docker-compose.dev.yml up`
3. **Test** `curl http://localhost:3000/health`
4. **Read** [DOCKER_SETUP.md](./DOCKER_SETUP.md) for detailed info
5. **Deploy** using docker-compose.prod.yml or k8s/

---

## 📝 License

Your project license here.

---

**Happy coding! 🚀**
