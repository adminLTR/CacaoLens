# Arquitectura CacaoLens

## 🎯 Visión General

CacaoLens es una aplicación full-stack para análisis de calidad de cacao utilizando Deep Learning (CNN). La arquitectura está completamente dockerizada y consta de 4 servicios principales.

## 🏗️ Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────────────┐
│                        USUARIO / CLIENTE                          │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                    📱 HTTP/HTTPS (Puerto 80)
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                     FRONTEND (Flutter Web)                        │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  • Material Design 3 UI                                    │  │
│  │  • Provider (State Management)                             │  │
│  │  • HTTP Client para API calls                              │  │
│  │  • Image Picker para cámara/galería                        │  │
│  │                                                             │  │
│  │  Screens:                                                   │  │
│  │  ├─ HomeScreen (Captura de imagen)                         │  │
│  │  ├─ AnalysisScreen (Resultados)                            │  │
│  │  └─ HistoryScreen (Historial)                              │  │
│  └────────────────────────────────────────────────────────────┘  │
│                          Puerto: 80                               │
│                      Container: cacaolens-frontend                │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                    🔗 REST API Calls
                    (http://backend:3000/api)
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                  BACKEND API (Express.js + Prisma)                │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  ARQUITECTURA MVC                                          │  │
│  │                                                             │  │
│  │  Controllers:                                               │  │
│  │  ├─ CacaoController      (CRUD operations)                 │  │
│  │  └─ AnalysisController   (Image analysis)                  │  │
│  │                                                             │  │
│  │  Models (Prisma ORM):                                       │  │
│  │  ├─ Cacao               (info de cacao)                    │  │
│  │  └─ Analysis            (resultados ML)                    │  │
│  │                                                             │  │
│  │  Routes:                                                    │  │
│  │  ├─ /api/cacao          (GET, POST, PUT, DELETE)           │  │
│  │  └─ /api/analysis       (POST image, GET results)          │  │
│  │                                                             │  │
│  │  Middlewares:                                               │  │
│  │  ├─ Upload (Multer)                                        │  │
│  │  ├─ CORS                                                    │  │
│  │  ├─ Helmet (Security)                                      │  │
│  │  └─ Morgan (Logging)                                       │  │
│  └────────────────────────────────────────────────────────────┘  │
│                          Puerto: 3000                             │
│                     Container: cacaolens-backend                  │
└──────────┬──────────────────────────┬────────────────────────────┘
           │                          │
           │                          │
    Prisma ORM              🔗 HTTP Request
    (MySQL Client)        (http://ml-service:8000)
           │                          │
           ▼                          ▼
┌─────────────────────┐   ┌──────────────────────────────────────┐
│   MYSQL DATABASE    │   │    ML SERVICE (FastAPI + TensorFlow) │
│  ┌───────────────┐  │   │  ┌────────────────────────────────┐  │
│  │  Tables:      │  │   │  │  MODELO CNN                    │  │
│  │  ├─ cacao     │  │   │  │  ┌──────────────────────────┐  │  │
│  │  └─ analysis  │  │   │  │  │ Input: 224x224x3 RGB    │  │  │
│  │               │  │   │  │  ├──────────────────────────┤  │  │
│  │  Relations:   │  │   │  │  │ Conv2D Blocks (4)       │  │  │
│  │  Cacao 1:N    │  │   │  │  │ - 32, 64, 128, 256      │  │  │
│  │  Analysis     │  │   │  │  │ - BatchNorm + MaxPool   │  │  │
│  └───────────────┘  │   │  │  ├──────────────────────────┤  │  │
│                     │   │  │  │ Dense Layers            │  │  │
│  Persistent Volume: │   │  │  │ - 512 → 256 → 3         │  │  │
│  mysql_data         │   │  │  │ - Dropout (0.5, 0.3)    │  │  │
│                     │   │  │  ├──────────────────────────┤  │  │
│  Puerto: 3306       │   │  │  │ Output: Softmax (3)     │  │  │
│  Container:         │   │  │  │ - Alta Calidad          │  │  │
│  cacaolens-mysql    │   │  │  │ - Media Calidad         │  │  │
└─────────────────────┘   │  │  │ - Baja Calidad          │  │  │
                          │  │  └──────────────────────────┘  │  │
                          │  │                                │  │
                          │  │  Endpoints:                    │  │
                          │  │  ├─ POST /predict (inference)  │  │
                          │  │  ├─ GET /health               │  │
                          │  │  └─ POST /reload-model        │  │
                          │  └────────────────────────────────┘  │
                          │                                      │
                          │  Persistent Volumes:                 │
                          │  ├─ ml_models (trained models)       │
                          │  └─ ml_data (training datasets)      │
                          │                                      │
                          │  Puerto: 8000                        │
                          │  Container: cacaolens-ml             │
                          └──────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════
                        DOCKER NETWORK
                    cacaolens-network (bridge)
═══════════════════════════════════════════════════════════════════
```

## 📊 Flujo de Datos

### 1. Análisis de Imagen (Flujo Principal)

```
Usuario (App) → Frontend → Backend → ML Service
     │              │          │           │
     │              │          │           ├─ Preprocesar imagen
     │              │          │           ├─ Ejecutar modelo CNN
     │              │          │           └─ Retornar predicción
     │              │          │                    │
     │              │          │ ◄──────────────────┘
     │              │          │
     │              │          ├─ Guardar en MySQL
     │              │          └─ Retornar resultado
     │              │                    │
     │              │ ◄──────────────────┘
     │              │
     │ ◄────────────┘
     │
  Mostrar resultados
```

### 2. Consulta de Historial

```
Usuario (App) → Frontend → Backend → MySQL
     │              │          │        │
     │              │          │ ◄──────┘ (SELECT * FROM analysis)
     │              │          │
     │              │ ◄────────┘
     │              │
     │ ◄────────────┘
  Mostrar historial
```

## 🔧 Stack Tecnológico

### Frontend (Flutter)
```yaml
Lenguaje: Dart
Framework: Flutter 3.x
Arquitectura: Provider Pattern
Librerías clave:
  - provider: State management
  - http/dio: API calls
  - image_picker: Cámara/galería
  - cached_network_image: Cache de imágenes
  - flutter_dotenv: Variables entorno
Build: Flutter Web (nginx en Docker)
```

### Backend (Express.js)
```yaml
Lenguaje: JavaScript (Node.js)
Framework: Express.js 4.x
Arquitectura: MVC
ORM: Prisma
Base de datos: MySQL 8.0
Librerías clave:
  - @prisma/client: ORM client
  - express: Web framework
  - multer: File uploads
  - helmet: Security
  - cors: Cross-origin
  - morgan: Logging
  - dotenv: Env variables
```

### ML Service (FastAPI)
```yaml
Lenguaje: Python 3.11
Framework: FastAPI
Deep Learning: TensorFlow 2.15 + Keras
Librerías clave:
  - tensorflow: DL framework
  - opencv-python: Image processing
  - pillow: Image manipulation
  - numpy/pandas: Data processing
  - uvicorn: ASGI server
  - albumentations: Data augmentation
Modelo: CNN custom
```

### Base de Datos (MySQL)
```yaml
Version: MySQL 8.0
Gestión: Prisma ORM
Esquema:
  - Tabla cacao: Info de variedades
  - Tabla analysis: Resultados ML
Volumen: mysql_data (persistent)
```

## 🐳 Configuración Docker

### Servicios y Puertos

| Servicio | Imagen Base | Puerto | Container Name |
|----------|------------|--------|----------------|
| Frontend | flutter:stable + nginx | 80 | cacaolens-frontend |
| Backend | node:20-alpine | 3000 | cacaolens-backend |
| ML Service | python:3.11-slim | 8000 | cacaolens-ml |
| MySQL | mysql:8.0 | 3306 | cacaolens-mysql |

### Volúmenes Persistentes

| Volumen | Propósito | Montaje |
|---------|-----------|---------|
| mysql_data | Base de datos | /var/lib/mysql |
| backend_uploads | Archivos subidos | /app/uploads |
| ml_models | Modelos entrenados | /app/models |
| ml_data | Datasets de entrenamiento | /app/data |

### Red Docker

```yaml
Network: cacaolens-network
Driver: bridge
Containers: frontend, backend, ml-service, mysql
Comunicación interna:
  - frontend → backend (http://backend:3000)
  - backend → ml-service (http://ml-service:8000)
  - backend → mysql (mysql://mysql:3306)
```

## 🔐 Seguridad

### Variables de Entorno
- Archivo `.env` separado por servicio
- Credenciales de DB no hardcodeadas
- JWT_SECRET para autenticación (preparado)
- CORS configurado por defecto

### Middlewares de Seguridad
- Helmet: Headers de seguridad HTTP
- CORS: Control de orígenes
- Rate limiting: (Por implementar)
- Input validation: express-validator

### Docker
- Containers aislados en red bridge
- Volúmenes con permisos apropiados
- Health checks para MySQL
- No se exponen puertos innecesarios

## 📈 Escalabilidad

### Horizontal
```
Load Balancer
     │
     ├─ Backend Instance 1
     ├─ Backend Instance 2
     └─ Backend Instance 3
          │
          ├─ ML Service 1
          └─ ML Service 2
```

### Vertical
- Backend: Aumentar memoria para Node.js
- ML Service: GPU support para TensorFlow
- MySQL: Configurar para mayor concurrencia

### Optimizaciones Futuras
1. Redis para caché
2. Queue (RabbitMQ/Kafka) para análisis async
3. CDN para assets estáticos
4. Nginx como reverse proxy
5. Kubernetes para orquestación

## 🔄 CI/CD Pipeline (Sugerido)

```yaml
Pipeline:
  1. Code Push → GitHub
  2. GitHub Actions:
     - Lint & Test
     - Build Docker images
     - Push to Docker Hub
  3. Deploy:
     - Pull images
     - docker-compose up
     - Run migrations
     - Health checks
```

## 📊 Base de Datos - Esquema Prisma

```prisma
model Cacao {
  id          Int        @id @default(autoincrement())
  name        String
  variety     String?
  origin      String?
  description String?
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt
  analyses    Analysis[] // Relación 1:N
}

model Analysis {
  id         Int      @id @default(autoincrement())
  cacaoId    Int?
  imagePath  String
  prediction String   // Resultado del ML
  confidence Float    // Confidence score
  metadata   Json?    // Datos adicionales
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt
  cacao      Cacao?   @relation(...)
}
```

## 🎯 Casos de Uso

### 1. Usuario Analiza Cacao
1. Usuario abre app
2. Toma/sube foto de cacao
3. App envía imagen a backend
4. Backend reenvía a ML service
5. ML procesa con CNN
6. Resultado guarda en MySQL
7. Usuario ve calidad predicha

### 2. Usuario Ve Historial
1. Usuario navega a historial
2. App consulta backend
3. Backend consulta MySQL
4. Retorna lista de análisis previos
5. Usuario ve resultados históricos

### 3. Admin Entrena Modelo
1. Admin prepara dataset
2. Ejecuta script de training
3. Modelo se guarda en volumen
4. Recarga modelo en API
5. Nuevas predicciones usan modelo actualizado

## 📚 Referencias

- [Express MVC Pattern](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Flutter Architecture](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [TensorFlow CNN Guide](https://www.tensorflow.org/tutorials/images/cnn)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [FastAPI Best Practices](https://fastapi.tiangolo.com/tutorial/)

---

**Versión:** 1.0.0  
**Última actualización:** 2026-04-14  
**Autor:** CacaoLens Team
