FROM node:20-alpine

WORKDIR /app

# Install netcat for health checks and OpenSSL for Prisma
RUN apk add --no-cache netcat-openbsd openssl openssl-dev

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy prisma schema
COPY prisma ./prisma/

# Copy application files
COPY . .

# Create uploads directory
RUN mkdir -p uploads

EXPOSE 3000

CMD ["sh", "-c", "echo 'Starting CacaoLens Backend...' && echo '================================' && echo 'Waiting for MySQL to be ready...' && until nc -z mysql 3306; do echo '   MySQL is unavailable - sleeping'; sleep 2; done && echo 'MySQL is ready!' && echo 'Generating Prisma Client...' && npx prisma generate && echo 'Syncing database schema...' && npx prisma db push --accept-data-loss && echo 'Running database seeders...' && npm run seed && echo 'Database setup complete!' && echo 'Starting application...' && echo '================================' && exec npm start"]
