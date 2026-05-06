# Database Seeders

Este directorio contiene los archivos de seeders para inicializar la base de datos con datos.

## 📋 Cómo Funcionan

Los seeders se ejecutan automáticamente al iniciar el backend mediante el `entrypoint.sh`.

El proceso es:
1. **Prisma Generate**: Genera el cliente de Prisma
2. **Prisma DB Push**: Sincroniza el esquema con la base de datos
3. **Seeders**: Ejecuta `npm run seed` que corre `prisma/seed.js`
4. **Start App**: Inicia el servidor Express

## 🌱 Usar Seeders

### Agregar Datos de Prueba

Edita `prisma/seed.js` y descomenta/modifica las funciones de upsert:

```javascript
async function seedCacao() {
  console.log('📦 Seeding Cacao data...');
  
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
}
```

### Ejecutar Seeders Manualmente

```bash
# Dentro del contenedor
docker-compose exec backend npm run seed

# O directamente con Prisma
docker-compose exec backend npx prisma db seed
```

## 🔄 UPSERT vs INSERT

Los seeders usan **UPSERT** en lugar de INSERT para:
- ✅ No duplicar datos en reinicios
- ✅ Actualizar datos existentes si cambian
- ✅ Ser idempotentes (mismo resultado múltiples veces)

## 📝 Ejemplo Completo

```javascript
async function seedCacao() {
  const cacaoData = [
    {
      id: 1,
      name: 'Cacao Criollo',
      variety: 'Criollo',
      origin: 'Ecuador',
      description: 'Cacao premium'
    },
    {
      id: 2,
      name: 'Cacao Forastero',
      variety: 'Forastero',
      origin: 'Brasil',
      description: 'Cacao común'
    }
  ];

  for (const cacao of cacaoData) {
    await prisma.cacao.upsert({
      where: { id: cacao.id },
      update: cacao,
      create: cacao
    });
  }
}
```

## 🚀 Deshabilitar Seeders

Si no quieres ejecutar seeders en cada inicio, comenta la línea en `entrypoint.sh`:

```bash
# npm run seed
```

## 📚 Mejores Prácticas

1. **IDs Fijos**: Usa IDs específicos para datos de seeders
2. **Upsert**: Siempre usa upsert para ser idempotente
3. **Organización**: Agrupa seeders por modelo
4. **Comentarios**: Documenta qué hace cada seeder
5. **Datos Reales**: Usa datos representativos pero no sensibles
