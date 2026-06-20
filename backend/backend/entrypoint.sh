#!/bin/sh

echo "Starting CacaoLens Backend..."
echo "================================"

# Generar el cliente de Prisma (Obligatorio en cada build/despliegue)
echo "Generating Prisma Client..."
npx prisma generate

# Aplicar cambios en la base de datos
echo "Syncing database schema..."
# NOTA: Si usas migraciones, cambia la línea de abajo por: npx prisma migrate deploy
npx prisma db push --accept-data-loss

# Ejecutar seeders si es necesario
echo "Running database seeders..."
npm run seed

echo "Database setup complete!"
echo "Starting application..."
echo "================================"

# Ceder el control al proceso principal de Node
exec npm start