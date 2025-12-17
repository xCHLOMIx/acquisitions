#!/bin/bash
# Production Setup Script
# Run this before deploying to production

set -e

echo "🏭 Acquisitions Docker Production Setup"
echo "=========================================="
echo ""

# Check required environment variables
required_vars=("DATABASE_URL" "CORS_ORIGIN" "JWT_SECRET")

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Required environment variable not set: $var"
        echo ""
        echo "Please set the following environment variables:"
        echo "  export DATABASE_URL='postgres://user:pass@ep-xxx.neon.tech/dbname'"
        echo "  export CORS_ORIGIN='https://yourdomain.com'"
        echo "  export JWT_SECRET='$(openssl rand -base64 32)'"
        exit 1
    fi
done

echo "✅ All required environment variables are set"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed."
    exit 1
fi

echo "✅ Docker found"
echo ""

echo "🔨 Building and starting production stack..."
echo ""

docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "⏳ Waiting for application to be ready..."
sleep 10

# Check health
echo ""
echo "🏥 Checking application health..."
if docker-compose -f docker-compose.prod.yml ps | grep -q "healthy"; then
    echo "✅ Application is healthy"
else
    echo "⚠️  Application may still be starting. Check logs with:"
    echo "   docker-compose -f docker-compose.prod.yml logs"
fi

echo ""
echo "=========================================="
echo "✅ Production setup complete!"
echo ""
echo "📊 To view logs:"
echo "   docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "🛑 To stop:"
echo "   docker-compose -f docker-compose.prod.yml down"
echo ""
