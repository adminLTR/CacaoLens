#!/bin/sh
set -e

if [ -n "$DATABASE_URL" ]; then
  DB_WAIT_HOST=$(node -e "const url = new URL(process.env.DATABASE_URL); console.log(url.hostname)")
  DB_WAIT_PORT=$(node -e "const url = new URL(process.env.DATABASE_URL); console.log(url.port || '3306')")
else
  DB_WAIT_HOST=${DB_HOST:-mysql}
  DB_WAIT_PORT=${DB_PORT:-3306}
fi

echo "Starting CacaoLens Backend..."
echo "================================"
echo "Waiting for MySQL at ${DB_WAIT_HOST}:${DB_WAIT_PORT} to be ready..."

until nc -z "$DB_WAIT_HOST" "$DB_WAIT_PORT"; do
  echo "   MySQL is unavailable - sleeping"
  sleep 2
done

echo "MySQL is ready!"
echo "Generating Prisma Client..."
npx prisma generate
echo "Syncing database schema..."
npx prisma db push --accept-data-loss
echo "Running database seeders..."
npm run seed
echo "Database setup complete!"
echo "Starting application..."
echo "================================"
exec npm start
