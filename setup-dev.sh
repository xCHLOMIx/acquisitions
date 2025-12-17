#!/bin/bash
# Development Setup Script
# Run this script to set up Docker development environment

set -e

echo "🐳 Acquisitions Docker Development Setup"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    exit 1
fi

echo "✅ Docker and Docker Compose found"
echo ""

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "⚠️  .env.development not found. Creating..."
    cp .env.development .env.development
    echo "✅ Created .env.development"
else
    echo "✅ .env.development exists"
fi

echo ""
echo "🚀 Starting Docker Compose..."
echo ""

docker-compose -f docker-compose.dev.yml up --build

echo ""
echo "=========================================="
echo "✅ Setup complete!"
echo ""
echo "📝 In another terminal, run:"
echo "   docker-compose -f docker-compose.dev.yml exec app npm run db:migrate"
echo ""
echo "🌐 App: http://localhost:3000"
echo "🐘 DB:  localhost:5432"
echo ""
