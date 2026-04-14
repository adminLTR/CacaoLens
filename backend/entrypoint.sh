#!/bin/sh

echo "🚀 Starting CacaoLens Backend..."
echo "================================"

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
until nc -z mysql 3306; do
  echo "   MySQL is unavailable - sleeping"
  sleep 2
done
echo "✅ MySQL is ready!"

# Generate Prisma Client
echo "📦 Generating Prisma Client..."
npx prisma generate

# Sync database schema (push changes without migrations)
echo "🔄 Syncing database schema..."
npx prisma db push --accept-data-loss

# Run seeders (upsert data)
echo "🌱 Running database seeders..."
npm run seed

echo "✅ Database setup complete!"
echo "🎯 Starting application..."
echo "================================"

# Start the application
exec npm start
