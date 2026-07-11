FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache openssl openssl-dev

COPY package*.json ./
RUN npm install --omit=dev

COPY prisma ./prisma/

# Copy application files
COPY . .
RUN chmod +x entrypoint.sh startup.sh && mkdir -p uploads

EXPOSE 3000

CMD ["./startup.sh"]
