FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache openssl openssl-dev

COPY package*.json ./
RUN npm install --omit=dev

COPY prisma ./prisma/
RUN npx prisma generate

COPY . .
RUN chmod +x entrypoint.sh && mkdir -p uploads

EXPOSE 3000

CMD ["/bin/sh", "./entrypoint.sh"]
