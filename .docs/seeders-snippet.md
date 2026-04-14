## 🌱 Database Seeders

El backend incluye un sistema automático de seeders que:

1. **Se ejecuta automáticamente** al iniciar el backend
2. **Sincroniza el esquema** con `prisma db push`
3. **Inserta/actualiza datos** usando UPSERT (idempotente)

### Configurar Seeders

Edita `backend/prisma/seed.js` y descomenta los ejemplos:

```javascript
await prisma.cacao.upsert({
  where: { id: 1 },
  update: {},
  create: {
    id: 1,
    name: 'Cacao Criollo',
    variety: 'Criollo',
    origin: 'Ecuador',
    description: 'Cacao de alta calidad'
  }
});
```

### Ejecutar Seeders Manualmente

```bash
docker-compose exec backend npm run seed
```

Ver más en: [SEEDERS.md](SEEDERS.md)
