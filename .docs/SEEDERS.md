# 🌱 Guía de Seeders - CacaoLens Backend

## 📖 ¿Qué son los Seeders?

Los seeders son scripts que insertan datos iniciales en la base de datos cuando se inicia la aplicación. En CacaoLens, los seeders:

- ✅ Se ejecutan **automáticamente** al iniciar el backend
- ✅ Usan **UPSERT** para no duplicar datos
- ✅ Son **idempotentes** (mismo resultado múltiples veces)
- ✅ Perfectos para datos de configuración, pruebas o demostración

## 🔄 Flujo del Entrypoint

Cada vez que se inicia el contenedor backend, ocurre:

```
1. 🐳 Container Start
         ↓
2. ⏳ Espera MySQL (health check)
         ↓
3. 📦 Genera Prisma Client
         ↓
4. 🔄 Sincroniza Schema (prisma db push)
         ↓
5. 🌱 Ejecuta Seeders (npm run seed)
         ↓
6. 🚀 Inicia Express App
```

## 📂 Archivos Importantes

```
backend/
├── entrypoint.sh           # Script de inicio automático
├── prisma/
│   ├── seed.js            # Archivo de seeders
│   ├── schema.prisma      # Schema de la DB
│   └── README.md          # Documentación seeders
└── package.json           # Configuración npm
```

## 🎯 Cómo Usar los Seeders

### 1. Editar el Archivo de Seeders

Abre `backend/prisma/seed.js` y descomenta los ejemplos:

```javascript
async function seedCacao() {
  console.log('📦 Seeding Cacao data...');
  
  // Descomenta este bloque para insertar datos
  await prisma.cacao.upsert({
    where: { id: 1 },
    update: {},  // Campos a actualizar si existe
    create: {    // Datos a insertar si no existe
      id: 1,
      name: 'Cacao Criollo',
      variety: 'Criollo',
      origin: 'Ecuador',
      description: 'Cacao de alta calidad'
    }
  });

  console.log('   ✅ Inserted: Cacao Criollo');
}
```

### 2. Agregar Más Datos

Puedes crear un array de datos y hacer un loop:

```javascript
async function seedCacao() {
  const cacaoData = [
    {
      id: 1,
      name: 'Cacao Criollo',
      variety: 'Criollo',
      origin: 'Ecuador',
      description: 'Cacao premium con notas florales'
    },
    {
      id: 2,
      name: 'Cacao Forastero',
      variety: 'Forastero',
      origin: 'Brasil',
      description: 'Variedad más común y resistente'
    },
    {
      id: 3,
      name: 'Cacao Trinitario',
      variety: 'Trinitario',
      origin: 'Trinidad',
      description: 'Híbrido de Criollo y Forastero'
    }
  ];

  for (const cacao of cacaoData) {
    await prisma.cacao.upsert({
      where: { id: cacao.id },
      update: cacao,
      create: cacao
    });
    console.log(`   ✅ Upserted: ${cacao.name}`);
  }
}
```

### 3. Reiniciar el Backend

Los seeders se ejecutan automáticamente:

```bash
# Opción 1: Reiniciar solo el backend
docker-compose restart backend

# Opción 2: Reconstruir (si cambiaste Dockerfile)
docker-compose up -d --build backend

# Ver logs para confirmar
docker-compose logs backend
```

Busca en los logs:
```
🌱 Running database seeders...
📦 Seeding Cacao data...
   ✅ Upserted: Cacao Criollo
   ✅ Upserted: Cacao Forastero
✅ All seeders completed successfully!
```

## 🔧 Ejecutar Seeders Manualmente

Si quieres ejecutar los seeders sin reiniciar:

```bash
# Ejecutar seeders
docker-compose exec backend npm run seed

# O con Prisma directamente
docker-compose exec backend npx prisma db seed
```

## ⚙️ Configuración Avanzada

### Deshabilitar Seeders

Si no quieres que se ejecuten automáticamente, edita `backend/entrypoint.sh`:

```bash
# Comenta esta línea:
# npm run seed
```

### Seeders Condicionales

Puedes agregar lógica para ejecutar seeders solo en desarrollo:

```javascript
async function main() {
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  if (isDevelopment) {
    await seedCacao();
    await seedAnalysis();
  } else {
    console.log('⏭️  Skipping seeders in production');
  }
}
```

### Datos de Ejemplo vs Producción

```javascript
async function seedCacao() {
  // Solo datos de configuración en producción
  const productionData = [
    { id: 1, name: 'Config Item', variety: 'System' }
  ];

  // Datos de prueba adicionales en desarrollo
  const devData = [
    { id: 2, name: 'Test Cacao 1', variety: 'Test' },
    { id: 3, name: 'Test Cacao 2', variety: 'Test' }
  ];

  const dataToSeed = process.env.NODE_ENV === 'production' 
    ? productionData 
    : [...productionData, ...devData];

  for (const item of dataToSeed) {
    await prisma.cacao.upsert({
      where: { id: item.id },
      update: item,
      create: item
    });
  }
}
```

## 📊 Seeders para Relaciones

Cuando tienes relaciones entre modelos:

```javascript
async function seedWithRelations() {
  // Primero crear el cacao
  const cacao = await prisma.cacao.upsert({
    where: { id: 1 },
    update: {},
    create: {
      id: 1,
      name: 'Cacao Criollo',
      variety: 'Criollo',
      origin: 'Ecuador'
    }
  });

  // Luego crear análisis relacionado
  await prisma.analysis.upsert({
    where: { id: 1 },
    update: {},
    create: {
      id: 1,
      cacaoId: cacao.id,  // Relación
      imagePath: '/sample.jpg',
      prediction: 'Alta Calidad',
      confidence: 0.95
    }
  });
}
```

## 🐛 Debugging

### Ver Logs Detallados

```bash
# Logs en tiempo real
docker-compose logs -f backend

# Solo logs del seeding
docker-compose logs backend | grep -A 20 "Running database seeders"
```

### Errores Comunes

**Error: "Unique constraint failed"**
```javascript
// Solución: Verifica que estés usando 'where' correcto
await prisma.cacao.upsert({
  where: { id: 1 },  // ✅ Usar campo único (ID)
  // NO usar: where: { name: 'Cacao' } si name no es único
  ...
});
```

**Error: "Foreign key constraint failed"**
```javascript
// Solución: Crea primero el registro padre
await seedCacao();     // Primero
await seedAnalysis();  // Después (si usa cacaoId)
```

### Resetear Base de Datos

```bash
# ADVERTENCIA: Esto borra todos los datos
docker-compose exec backend npx prisma db push --force-reset

# Luego los seeders se ejecutarán automáticamente
docker-compose restart backend
```

## 📝 Mejores Prácticas

1. **IDs Explícitos**: Usa IDs fijos para seeders
   ```javascript
   create: { id: 1, ... }  // ✅
   create: { ... }         // ❌ (ID auto-incrementado)
   ```

2. **Upsert Siempre**: No uses `create`, usa `upsert`
   ```javascript
   prisma.cacao.upsert(...)  // ✅
   prisma.cacao.create(...)  // ❌
   ```

3. **Ordenar por Dependencias**: Crea primero los padres
   ```javascript
   await seedCacao();      // Primero
   await seedAnalysis();   // Después
   ```

4. **Logs Claros**: Agrega console.log para debugging
   ```javascript
   console.log(`✅ Upserted: ${cacao.name}`);
   ```

5. **Datos Realistas**: Usa datos representativos
   ```javascript
   // ✅ Bueno
   { name: 'Cacao Criollo', origin: 'Ecuador' }
   
   // ❌ Malo
   { name: 'Test 1', origin: 'Test' }
   ```

## 🎓 Ejemplos Completos

### Seeders Básicos

```javascript
async function seedCacao() {
  const datos = [
    { id: 1, name: 'Criollo', variety: 'Premium', origin: 'Ecuador' },
    { id: 2, name: 'Forastero', variety: 'Común', origin: 'Brasil' },
    { id: 3, name: 'Trinitario', variety: 'Híbrido', origin: 'Trinidad' }
  ];

  for (const item of datos) {
    await prisma.cacao.upsert({
      where: { id: item.id },
      update: item,
      create: item
    });
  }
}
```

### Seeders con Datos JSON

```javascript
const fs = require('fs');
const path = require('path');

async function seedFromJSON() {
  const jsonPath = path.join(__dirname, 'data', 'cacao.json');
  const data = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));

  for (const item of data) {
    await prisma.cacao.upsert({
      where: { id: item.id },
      update: item,
      create: item
    });
  }
}
```

## 🚀 Siguientes Pasos

1. ✅ Edita `backend/prisma/seed.js`
2. ✅ Agrega tus datos de prueba
3. ✅ Reinicia el backend: `docker-compose restart backend`
4. ✅ Verifica: `docker-compose logs backend`
5. ✅ Confirma en Prisma Studio: `docker-compose exec backend npx prisma studio`

---

¿Necesitas ayuda? Consulta:
- [Prisma Seeding Docs](https://www.prisma.io/docs/guides/database/seed-database)
- [backend/prisma/README.md](backend/prisma/README.md)
- Logs: `docker-compose logs backend`
