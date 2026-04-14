# 🔄 Flujo de Inicio del Backend - CacaoLens

## 📋 Proceso Automático de Inicialización

Cada vez que el contenedor backend se inicia, se ejecuta el siguiente flujo:

```
┌─────────────────────────────────────────────────────────────────┐
│                   DOCKER CONTAINER START                         │
│                   (cacaolens-backend)                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ entrypoint.sh   │
                    │   ejecutado     │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
   ┌─────────┐        ┌──────────┐        ┌──────────┐
   │  PASO 1 │        │  PASO 2  │        │  PASO 3  │
   │ MySQL   │        │  Prisma  │        │ Seeders  │
   │ Ready?  │        │  Setup   │        │ (Upsert) │
   └─────────┘        └──────────┘        └──────────┘
        │                    │                    │
        │                    │                    │
        ▼                    ▼                    ▼
  ┌──────────────────────────────────────────────────┐
  │           Database Listo y Poblado               │
  └────────────────────┬─────────────────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │   npm start     │
              │ Express Server  │
              └────────┬────────┘
                       │
                       ▼
              ┌─────────────────┐
              │ 🎯 API Running  │
              │ Port 3000       │
              └─────────────────┘
```

## 🔍 Detalle de Cada Paso

### 1️⃣ Health Check - MySQL

```bash
⏳ Waiting for MySQL to be ready...
```

- Verifica conexión a MySQL cada 2 segundos
- Usa `netcat` para probar puerto 3306
- No continúa hasta que MySQL responda
- Previene errores de "database not ready"

**Duración estimada:** 5-10 segundos (primera vez)

---

### 2️⃣ Prisma Setup

```bash
📦 Generating Prisma Client...
npx prisma generate

🔄 Syncing database schema...
npx prisma db push --accept-data-loss
```

#### a) Prisma Generate
- Lee `schema.prisma`
- Genera cliente TypeScript/JavaScript
- Crea tipos automáticos para las tablas

#### b) Prisma DB Push
- Sincroniza el esquema con MySQL
- Crea/modifica tablas según el schema
- **No crea migraciones** (ideal para desarrollo)
- Flag `--accept-data-loss` para cambios destructivos

**Duración estimada:** 10-15 segundos

**Resultado:**
```sql
✅ Tabla `cacao` creada/actualizada
✅ Tabla `analysis` creada/actualizada
✅ Relaciones configuradas
```

---

### 3️⃣ Database Seeders

```bash
🌱 Running database seeders...
npm run seed
```

Ejecuta: `backend/prisma/seed.js`

**Funciones que se ejecutan:**
1. `seedCacao()` - Inserta/actualiza datos de cacao
2. `seedAnalysis()` - Inserta/actualiza análisis

**Características:**
- ✅ **UPSERT**: No duplica datos si ya existen
- ✅ **Idempotente**: Mismo resultado en múltiples ejecuciones
- ✅ **Logs claros**: Muestra qué se insertó
- ✅ **Condicional**: Puedes habilitar/deshabilitar

**Ejemplo de salida:**
```
🌱 Starting database seeding...
================================
📦 Seeding Cacao data...
   ✅ Cacao seeding complete (no data yet)
📦 Seeding Analysis data...
   ✅ Analysis seeding complete (no data yet)
================================
✅ All seeders completed successfully!
```

**Duración estimada:** 2-5 segundos (sin datos) / 10-30 seg (con datos)

---

### 4️⃣ Express Server Start

```bash
🎯 Starting application...
npm start
```

- Inicia servidor Express en puerto 3000
- Carga middlewares (CORS, Helmet, Morgan)
- Monta rutas API
- Conecta con Prisma Client

**Salida esperada:**
```
🚀 Server is running on port 3000
📊 Environment: development
```

---

## ⏱️ Tiempo Total de Inicio

| Paso | Duración | Acumulado |
|------|----------|-----------|
| 1. MySQL Ready | 5-10s | 5-10s |
| 2. Prisma Setup | 10-15s | 15-25s |
| 3. Seeders | 2-5s | 17-30s |
| 4. Express Start | 2-3s | 19-33s |

**Total:** ~20-35 segundos (primera vez)  
**Reinicios:** ~10-15 segundos (MySQL ya está listo)

---

## 🔄 Flujo de Datos - Seeders

```
┌─────────────────────────────────────────────────────────────┐
│                    prisma/seed.js                            │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
         ▼                               ▼
  ┌─────────────┐               ┌───────────────┐
  │ seedCacao() │               │seedAnalysis() │
  └──────┬──────┘               └───────┬───────┘
         │                              │
         │ FOR cada dato                │ FOR cada dato
         ▼                              ▼
  ┌──────────────────┐          ┌──────────────────┐
  │ prisma.cacao     │          │ prisma.analysis  │
  │   .upsert({      │          │   .upsert({      │
  │     where,       │          │     where,       │
  │     update,      │          │     update,      │
  │     create       │          │     create       │
  │   })             │          │   })             │
  └──────┬───────────┘          └──────┬───────────┘
         │                              │
         │  ¿Existe el ID?              │
         ├─ SÍ → UPDATE                 │
         └─ NO → CREATE                 │
                  │                     │
                  ▼                     ▼
         ┌─────────────────────────────────┐
         │         MySQL Database          │
         │  ┌──────────┐  ┌──────────┐    │
         │  │  cacao   │  │ analysis │    │
         │  │ (tabla)  │  │ (tabla)  │    │
         │  └──────────┘  └──────────┘    │
         └─────────────────────────────────┘
```

---

## 📝 Logs Completos de Inicio

```bash
$ docker-compose up -d backend

# Luego ver logs:
$ docker-compose logs -f backend
```

**Salida esperada:**
```
🚀 Starting CacaoLens Backend...
================================
⏳ Waiting for MySQL to be ready...
   MySQL is unavailable - sleeping
   MySQL is unavailable - sleeping
✅ MySQL is ready!

📦 Generating Prisma Client...
Prisma schema loaded from prisma/schema.prisma
✔ Generated Prisma Client (v5.11.0)

🔄 Syncing database schema...
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Datasource "db": MySQL database "cacaolens"

🚀 Your database is now in sync with your Prisma schema.
✔ Generated Prisma Client (v5.11.0)

🌱 Running database seeders...
🌱 Starting database seeding...
================================
📦 Seeding Cacao data...
   ✅ Cacao seeding complete (no data yet)
📦 Seeding Analysis data...
   ✅ Analysis seeding complete (no data yet)
================================
✅ All seeders completed successfully!

✅ Database setup complete!
🎯 Starting application...
================================

> cacaolens-backend@1.0.0 start
> node src/index.js

🚀 Server is running on port 3000
📊 Environment: development
```

---

## 🎯 Casos de Uso

### Caso 1: Primera Vez (Sin Base de Datos)

```
INICIO
  ↓
MySQL vacío
  ↓
prisma db push → Crea tablas
  ↓
seeders → Inserta datos iniciales
  ↓
Express → API lista
```

### Caso 2: Reinicio (Base de Datos Existe)

```
INICIO
  ↓
MySQL con datos
  ↓
prisma db push → Verifica/actualiza schema
  ↓
seeders → UPSERT (actualiza si cambió, ignora si igual)
  ↓
Express → API lista
```

### Caso 3: Cambio en Schema

```
INICIO
  ↓
MySQL con datos + schema.prisma modificado
  ↓
prisma db push → ALTER TABLE (añade/modifica columnas)
  ↓
seeders → Ajusta datos según nuevo schema
  ↓
Express → API lista con nuevo schema
```

---

## 🛠️ Personalizar el Flujo

### Deshabilitar Seeders

Edita `backend/entrypoint.sh`:
```bash
# npm run seed  # Comentar esta línea
```

### Agregar Paso Adicional

```bash
# Después de seeders, antes de npm start
echo "🔧 Running custom setup..."
npm run custom-setup
```

### Solo Seeders en Development

En `backend/prisma/seed.js`:
```javascript
if (process.env.NODE_ENV !== 'production') {
  await seedCacao();
  await seedAnalysis();
}
```

---

## 🐛 Troubleshooting

### MySQL no responde

```bash
# Ver logs de MySQL
docker-compose logs mysql

# Verificar health
docker-compose ps mysql
```

### Prisma db push falla

```bash
# Resetear database (⚠️ borra datos)
docker-compose exec backend npx prisma db push --force-reset
```

### Seeders fallan

```bash
# Ejecutar manualmente con más logs
docker-compose exec backend npm run seed
```

### Ver todos los pasos

```bash
docker-compose logs -f backend | tee backend-logs.txt
```

---

## 📚 Archivos Relacionados

- `backend/entrypoint.sh` - Script principal
- `backend/prisma/seed.js` - Seeders
- `backend/prisma/schema.prisma` - Schema DB
- `backend/package.json` - Scripts npm
- `backend/Dockerfile` - Configuración Docker

---

**¿Necesitas modificar el flujo? Edita `backend/entrypoint.sh`**
