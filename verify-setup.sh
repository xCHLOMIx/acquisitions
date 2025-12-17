#!/bin/bash
# Verification and Health Check Script
# Run this to verify your Docker setup is working correctly

set -e

echo "🔍 Acquisitions Docker Setup Verification"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 1. Check Docker installation
echo "1️⃣  Checking Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    check_pass "Docker installed: $DOCKER_VERSION"
else
    check_fail "Docker not installed"
fi

# 2. Check Docker Compose
echo ""
echo "2️⃣  Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    DC_VERSION=$(docker-compose --version)
    check_pass "Docker Compose installed: $DC_VERSION"
else
    check_fail "Docker Compose not installed"
fi

# 3. Check Docker daemon
echo ""
echo "3️⃣  Checking Docker daemon..."
if docker info &> /dev/null; then
    check_pass "Docker daemon is running"
else
    check_fail "Docker daemon is not running. Start Docker Desktop."
fi

# 4. Check required files
echo ""
echo "4️⃣  Checking required files..."
REQUIRED_FILES=(
    "Dockerfile"
    "docker-compose.dev.yml"
    "docker-compose.prod.yml"
    ".env.development"
    ".env.production"
    "package.json"
    "drizzle.config.js"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        check_pass "Found: $file"
    else
        check_fail "Missing: $file"
    fi
done

# 5. Check Node.js dependencies
echo ""
echo "5️⃣  Checking Node.js dependencies..."
if [ -f "package.json" ]; then
    check_pass "package.json found"
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        check_pass "Node.js installed: $NODE_VERSION"
    else
        check_warn "Node.js not installed (OK if using Docker)"
    fi
else
    check_fail "package.json not found"
fi

# 6. Check environment files
echo ""
echo "6️⃣  Checking environment files..."
if [ -f ".env.development" ]; then
    check_pass ".env.development exists"
    if grep -q "DATABASE_URL" .env.development; then
        check_pass "DATABASE_URL configured in .env.development"
    else
        check_warn "DATABASE_URL not found in .env.development"
    fi
else
    check_fail ".env.development not found"
fi

if [ -f ".env.production" ]; then
    check_pass ".env.production exists"
else
    check_fail ".env.production not found"
fi

# 7. Check if containers are running
echo ""
echo "7️⃣  Checking running containers..."
RUNNING=$(docker ps --filter "name=acquisitions" --format "{{.Names}}" | wc -l)
if [ $RUNNING -gt 0 ]; then
    check_pass "Found $RUNNING acquisitions container(s) running"
    docker ps --filter "name=acquisitions" --format "table {{.Names}}\t{{.Status}}"
else
    check_warn "No acquisitions containers running (expected for first setup)"
fi

# 8. Build test
echo ""
echo "8️⃣  Testing Docker image build..."
if docker build --no-cache -t acquisitions-test . > /dev/null 2>&1; then
    check_pass "Docker image builds successfully"
    docker rmi acquisitions-test > /dev/null 2>&1
else
    check_fail "Docker image build failed"
fi

# 9. Docker network
echo ""
echo "9️⃣  Checking Docker network..."
if docker network inspect acquisitions_acquisitions-network &> /dev/null; then
    check_pass "Docker network exists"
else
    check_warn "Docker network not found (will be created on first run)"
fi

# 10. Port availability
echo ""
echo "🔟 Checking port availability..."
if ! lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    check_pass "Port 3000 is available"
else
    check_warn "Port 3000 is already in use"
fi

if ! lsof -Pi :5432 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    check_pass "Port 5432 is available"
else
    check_warn "Port 5432 is already in use"
fi

# Summary
echo ""
echo "=========================================="
echo -e "${GREEN}✅ Verification Complete!${NC}"
echo ""
echo "🚀 Next steps:"
echo "1. Start development: docker-compose -f docker-compose.dev.yml up"
echo "2. Or run setup script: bash setup-dev.sh"
echo ""
echo "📖 Read the documentation:"
echo "   - QUICKSTART.md (5 min)"
echo "   - DOCKER_SETUP.md (detailed)"
echo "   - DOCKER_README.md (overview)"
echo ""
