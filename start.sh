#!/bin/bash

echo "🌱 CacaoLens - Quick Start Script"
echo "=================================="
echo ""

# Check if .env files exist
if [ ! -f .env ]; then
    echo "📝 Creating .env files from examples..."
    cp .env.example .env
    cp backend/.env.example backend/.env
    cp ML/.env.example ML/.env
    cp frontend/.env.example frontend/.env
    echo "✅ Environment files created!"
    echo "⚠️  Please review and update the .env files with your configurations"
    echo ""
else
    echo "✅ Environment files already exist"
    echo ""
fi

# Build and start Docker containers
echo "🐳 Building Docker containers..."
docker-compose build

echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Run Prisma migrations
echo ""
echo "📊 Running database migrations..."
docker-compose exec -T backend npx prisma generate
docker-compose exec -T backend npx prisma migrate deploy

echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 Access your services:"
echo "  - Frontend:  http://localhost:80"
echo "  - Backend:   http://localhost:3000"
echo "  - ML API:    http://localhost:8000"
echo "  - ML Docs:   http://localhost:8000/docs"
echo ""
echo "📝 View logs:"
echo "  docker-compose logs -f"
echo ""
echo "🛑 Stop services:"
echo "  docker-compose down"
echo ""
