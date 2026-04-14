# 🚀 Guía de Inicio Rápido - CacaoLens

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- ✅ **Docker Desktop** (v20.10 o superior)
- ✅ **Docker Compose** (v2.0 o superior)
- ✅ **Git** (opcional, para clonar el repositorio)

### Verificar instalación de Docker

```bash
docker --version
docker-compose --version
```

## 🏗️ Arquitectura del Proyecto

```
┌─────────────────────────────────────────────────────────────┐
│                      CACAOLENS STACK                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐                                            │
│  │   Flutter    │  (Puerto 80)                               │
│  │   Frontend   │  Aplicación móvil web                      │
│  └───────┬──────┘                                            │
│          │                                                    │
│          │ HTTP/REST                                         │
│          ▼                                                    │
│  ┌──────────────┐      ┌──────────────┐                     │
│  │  Express.js  │◄─────┤    MySQL     │                     │
│  │   Backend    │      │   Database   │                     │
│  │  (MVC + ORM) │      │  (Puerto 3306)                     │
│  └───────┬──────┘      └──────────────┘                     │
│          │ (Puerto 3000)                                     │
│          │                                                    │
│          │ HTTP/REST                                         │
│          ▼                                                    │
│  ┌──────────────┐                                            │
│  │   FastAPI    │  (Puerto 8000)                            │
│  │  ML Service  │  Modelo CNN con TensorFlow                │
│  │   (Python)   │                                            │
│  └──────────────┘                                            │
│                                                               │
│  🔗 Red: cacaolens-network                                   │
│  💾 Volúmenes: mysql_data, backend_uploads, ml_models        │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 📂 Estructura de Directorios

```
CacaoLens/
├── 📱 frontend/              # Flutter App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/         # Pantallas
│   │   ├── providers/       # Gestión de estado
│   │   ├── services/        # API calls
│   │   └── widgets/         # Componentes
│   ├── pubspec.yaml
│   ├── Dockerfile
│   └── .env
│
├── 🔧 backend/              # Express + Prisma
│   ├── src/
│   │   ├── controllers/     # Lógica de negocio
│   │   ├── routes/          # Rutas API
│   │   ├── middlewares/     # Middlewares
│   │   └── index.js         # Entry point
│   ├── prisma/
│   │   └── schema.prisma    # Esquema DB
│   ├── package.json
│   ├── Dockerfile
│   └── .env
│
├── 🧠 ML/                   # Machine Learning
│   ├── src/
│   │   ├── api.py          # FastAPI server
│   │   └── train.py        # Entrenamiento
│   ├── models/             # Modelos guardados
│   ├── data/               # Datasets
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env
│
├── 🐳 docker-compose.yml    # Orquestación
├── 📋 .env                  # Variables globales
├── 📖 README.md
└── 🚀 start.bat / start.sh  # Scripts de inicio
```

## 🎯 Inicio Rápido

### Opción 1: Script Automático (Recomendado)

**Windows:**
```bash
start.bat
```

**Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

### Opción 2: Paso a Paso Manual

1. **Verificar variables de entorno**
```bash
# Los archivos .env ya están creados. Revísalos y modifícalos si es necesario
notepad .env
notepad backend\.env
notepad ML\.env
notepad frontend\.env
```

2. **Construir las imágenes Docker**
```bash
docker-compose build
```

3. **Iniciar los servicios**
```bash
docker-compose up -d
```

4. **Esperar a que MySQL esté listo** (unos 15 segundos)
```bash
docker-compose logs mysql
```

5. **Verificar que todo está funcionando**

El backend se encargará automáticamente de:
- ✅ Generar Prisma Client
- ✅ Sincronizar el esquema (db push)
- ✅ Ejecutar seeders (si hay datos configurados)
- ✅ Iniciar el servidor

```bash
docker-compose ps
docker-compose logs backend  # Ver el proceso de inicio
```

## 🌐 Acceder a los Servicios

Una vez que todos los contenedores estén en ejecución:

| Servicio | URL | Descripción |
|----------|-----|-------------|
| 📱 **Frontend** | http://localhost:80 | Aplicación móvil web |
| 🔧 **Backend API** | http://localhost:3000/api | API REST |
| 🧠 **ML Service** | http://localhost:8000 | Servicio de ML |
| 📚 **ML API Docs** | http://localhost:8000/docs | Documentación interactiva |
| 🔍 **Prisma Studio** | `docker-compose exec backend npx prisma studio` | DB GUI |

### Verificar endpoints

```bash
# Backend health check
curl http://localhost:3000/health

# ML service health check
curl http://localhost:8000/health

# Frontend (debe devolver HTML)
curl http://localhost:80
```

## 🧪 Probar la Aplicación

1. **Abrir el navegador** en http://localhost:80
2. **Tomar o cargar una foto** de cacao
3. **Analizar la imagen** (nota: el modelo necesita ser entrenado primero)
4. **Ver resultados** del análisis

## 🧠 Entrenar el Modelo CNN

### 1. Preparar el Dataset

Organiza tus imágenes en la siguiente estructura:

```
ML/data/
├── train/
│   ├── alta_calidad/
│   │   ├── imagen1.jpg
│   │   ├── imagen2.jpg
│   │   └── ...
│   ├── media_calidad/
│   │   └── ...
│   └── baja_calidad/
│       └── ...
└── validation/
    ├── alta_calidad/
    ├── media_calidad/
    └── baja_calidad/
```

### 2. Modificar el script de entrenamiento

Edita `ML/src/train.py` y descomenta las líneas de carga de dataset:

```python
train_dataset = tf.keras.preprocessing.image_dataset_from_directory(
    'data/train',
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE
)

val_dataset = tf.keras.preprocessing.image_dataset_from_directory(
    'data/validation',
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE
)

model, history = train_model(train_dataset, val_dataset)
```

### 3. Entrenar el modelo

```bash
docker-compose exec ml-service python src/train.py
```

### 4. Recargar el modelo en la API

```bash
curl -X POST http://localhost:8000/reload-model
```

## 🛠️ Comandos Útiles

### Docker Compose

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f backend
docker-compose logs -f ml-service
docker-compose logs -f frontend

# Reiniciar un servicio
docker-compose restart backend

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (⚠️ Borrará la base de datos)
docker-compose down -v

# Reconstruir y reiniciar
docker-compose up -d --build

# Ver estado de los servicios
docker-compose ps

# Acceder a un contenedor
docker-compose exec backend sh
docker-compose exec ml-service bash
```

### Backend (Express + Prisma)

```bash
# Generar cliente Prisma
docker-compose exec backend npx prisma generate

# Crear una nueva migración
docker-compose exec backend npx prisma migrate dev --name nombre_migracion

# Abrir Prisma Studio (GUI para la DB)
docker-compose exec backend npx prisma studio

# Ver logs del backend
docker-compose logs -f backend
```

### ML Service

```bash
# Entrenar modelo
docker-compose exec ml-service python src/train.py

# Recargar modelo
curl -X POST http://localhost:8000/reload-model

# Ver logs del ML service
docker-compose logs -f ml-service
```

### Frontend (Flutter)

```bash
# Reconstruir frontend
docker-compose up -d --build frontend

# Ver logs del frontend
docker-compose logs -f frontend
```

## 🐛 Solución de Problemas

### El backend no puede conectarse a MySQL

```bash
# Verificar que MySQL esté corriendo
docker-compose ps mysql

# Ver logs de MySQL
docker-compose logs mysql

# Reiniciar MySQL
docker-compose restart mysql

# Esperar 10-15 segundos y volver a intentar
```

### Error en migraciones de Prisma

```bash
# Resetear la base de datos (⚠️ Borrará todos los datos)
docker-compose exec backend npx prisma migrate reset

# O eliminar todo y empezar de nuevo
docker-compose down -v
docker-compose up -d
```

### El servicio ML no carga el modelo

```bash
# Verificar que el modelo existe
docker-compose exec ml-service ls -la models/

# Si no existe, entrenalo primero
docker-compose exec ml-service python src/train.py
```

### Puertos en uso

```bash
# Si los puertos están ocupados, modifica .env
# Cambia BACKEND_PORT, ML_PORT o FRONTEND_PORT

# Luego reinicia
docker-compose down
docker-compose up -d
```

### Frontend no carga

```bash
# Verifica que el frontend esté corriendo
docker-compose ps frontend

# Reconstruye el frontend
docker-compose up -d --build frontend

# Verifica la variable API_BASE_URL en frontend/.env
```

## 📊 Desarrollo Local (Sin Docker)

### Backend

```bash
cd backend
npm install
npx prisma generate
npx prisma migrate dev
npm run dev
```

### ML Service

```bash
cd ML
python -m venv venv
venv\Scripts\activate  # Windows
# o
source venv/bin/activate  # Linux/Mac

pip install -r requirements.txt
uvicorn src.api:app --reload
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome  # Para web
flutter run  # Para móvil
```

## 🔒 Seguridad en Producción

1. ✅ Cambiar todas las contraseñas en `.env`
2. ✅ Generar un JWT_SECRET seguro
3. ✅ Configurar CORS apropiadamente
4. ✅ Usar HTTPS
5. ✅ Actualizar puertos si es necesario
6. ✅ Revisar configuraciones de Docker

## 📝 Próximos Pasos

1. ✅ Preparar dataset de imágenes de cacao
2. ✅ Entrenar el modelo CNN
3. ✅ Probar la aplicación completa
4. ✅ Personalizar el frontend según tus necesidades
5. ✅ Agregar autenticación (JWT)
6. ✅ Implementar más endpoints API
7. ✅ Optimizar el modelo ML
8. ✅ Deploy en producción

## 🤝 Soporte

Si tienes problemas:

1. Revisa los logs: `docker-compose logs -f`
2. Verifica el estado: `docker-compose ps`
3. Consulta la documentación de cada tecnología
4. Revisa el README.md principal

## 📚 Recursos

- [Docker Documentation](https://docs.docker.com/)
- [Express.js](https://expressjs.com/)
- [Prisma](https://www.prisma.io/docs)
- [Flutter](https://flutter.dev/docs)
- [TensorFlow](https://www.tensorflow.org/)
- [FastAPI](https://fastapi.tiangolo.com/)

---

¡Listo para empezar! 🚀🌱
