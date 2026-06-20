#!/bin/sh
set -e

echo "Starting CacaoLens Backend..."
echo "================================"

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set. Link a PostgreSQL database in Render."
  exit 1
fi

echo "Generating Prisma Client..."
npx prisma generate

echo "Syncing database schema..."
npx prisma db push --accept-data-loss

if [ "$RUN_SEED" = "true" ]; then
  echo "Running database seeders..."
  npm run seed
fi

echo "Database setup complete!"
echo "Starting application..."
echo "================================"

exec npm start
