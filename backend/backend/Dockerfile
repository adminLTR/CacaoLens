FROM node:20-alpine

WORKDIR /app

# Install netcat for health checks and OpenSSL for Prisma
RUN apk add --no-cache netcat-openbsd openssl openssl-dev

# Copy package files
COPY package*.json ./

# Install dependencies (prisma CLI is required at runtime for deploy)
RUN npm install --omit=dev

# Copy prisma schema and generate client at build time
COPY prisma ./prisma/
RUN npx prisma generate

# Copy entrypoint script
COPY entrypoint.sh ./

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Copy application files
COPY . .

# Create uploads directory
RUN mkdir -p uploads

EXPOSE 3000

# Use entrypoint script
ENTRYPOINT ["./entrypoint.sh"]
