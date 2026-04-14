# CacaoLens 🌱

Aplicación móvil con deep learning para la clasificación de frutos de cacao con pudrición negra, daño por pod borer y estado saludable

## 👥 Autores

- José Luis La Torre Romero ([AdminLTR](https://github.com/adminLTR))
- Asthri Joanne Pardave Jara ([AsthriPardave](https://github.com/AsthriPardave))
- Bruno Pumapillo Sarmiento ([Brun0West](https://github.com/Brun0West))
- Diego Alonso Calderon Mathias ([DiegoKeiO](https://github.com/DiegoKeiO))
- Kiltom Adolfo Paucar

## 📋 Estructura del Proyecto

```
CacaoLens/
├── backend/          # API REST con ExpressJS + Prisma + MySQL
├── ML/               # Servicio ML con FastAPI + TensorFlow/Keras
├── frontend/         # Aplicación Flutter
├── docker-compose.yml
└── .env.example
```

## 🚀 Tecnologías

### Backend
- **ExpressJS**: Framework web para Node.js
- **Prisma ORM**: ORM moderno para TypeScript/JavaScript
- **MySQL**: Base de datos relacional
- **Arquitectura MVC**: Separación de responsabilidades

### Machine Learning
- **TensorFlow/Keras**: Framework de Deep Learning
- **FastAPI**: API moderna y rápida para Python
- **OpenCV**: Procesamiento de imágenes
- **CNN**: Redes Neuronales Convolucionales

### Frontend
- **Flutter**: Framework multiplataforma
- **Provider**: Gestión de estado
- **Material Design 3**: Diseño moderno

## 📚 Recursos

- [Docker Documentation](https://docs.docker.com/)
- [Express.js](https://expressjs.com/)
- [Prisma](https://www.prisma.io/docs)
- [Flutter](https://flutter.dev/docs)
- [TensorFlow](https://www.tensorflow.org/)
- [FastAPI](https://fastapi.tiangolo.com/)

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

## 📦 Instalación y Configuración

### Prerequisitos
- Docker & Docker Compose
- Git

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/adminLTR/CacaoLens.git
cd CacaoLens
```

2. **Configurar variables de entorno**
```bash
# Copiar archivos de ejemplo
cp .env.example .env
cp backend/.env.example backend/.env
cp ML/.env.example ML/.env
cp frontend/.env.example frontend/.env

# Editar los archivos .env con tus configuraciones
```

3. **Construir y ejecutar con Docker**
```bash
# Construir las imágenes
docker-compose build

# Iniciar los servicios
docker-compose up -d

# Ver los logs
docker-compose logs -f
```

4. **Inicializar la base de datos**

El backend se encarga automáticamente de:
- ✅ Generar el cliente de Prisma
- ✅ Sincronizar el esquema con `prisma db push`
- ✅ Ejecutar seeders con datos iniciales (upsert)

Esto ocurre en cada inicio del backend gracias al `entrypoint.sh`.

Para agregar datos de prueba, edita `backend/prisma/seed.js`:
```bash
# Ver logs del proceso de seeding
docker-compose logs backend
```

## 🌐 Acceso a los Servicios

Una vez iniciados los contenedores:

- **Frontend**: http://localhost:80
- **Backend API**: http://localhost:3000
- **ML Service**: http://localhost:8000
- **ML API Docs**: http://localhost:8000/docs

## 📱 Desarrollo Local

### Frontend (Flutter)
Para desarrollo de la app móvil sin Docker:

```bash
cd frontend

# Instalar dependencias
flutter pub get

# Ejecutar en desarrollo
flutter run

# Para Android
flutter run -d android

# Para iOS
flutter run -d ios
```

### Backend (Express)
```bash
# Instalar dependencias
npm install

# Desarrollo
npm run dev

# Producción
npm start

# Prisma
npm run prisma:generate
npm run prisma:push     # Sincronizar esquema
npm run seed            # Ejecutar seeders
```

### Backend (ML Service)
```bash
# Instalar dependencias
pip install -r requirements.txt

# Ejecutar API
uvicorn src.api:app --reload --host 0.0.0.0 --port 8000

# Entrenar modelo
python src/train.py

# Recargar el modelo
curl -X POST http://localhost:8000/reload-model
```

## 🧠 Entrenamiento del Modelo con docker

1. **Preparar el dataset**
```
ML/data/
├── train/
│   ├── alta_calidad/
│   ├── media_calidad/
│   └── baja_calidad/
└── validation/
    ├── alta_calidad/
    ├── media_calidad/
    └── baja_calidad/
```

2. **Entrenar el modelo**
```bash
docker-compose exec ml-service python src/train.py
```

3. **Recargar el modelo en la API**
```bash
curl -X POST http://localhost:8000/reload-model
```

## 🛠️ Comandos Útiles

```bash
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Reconstruir servicios
docker-compose up -d --build

# Ver logs de un servicio específico
docker-compose logs -f backend
docker-compose logs -f ml-service
docker-compose logs -f frontend

# Acceder al contenedor
docker-compose exec backend sh
docker-compose exec ml-service bash
```


## 📊 API Endpoints

### Backend API

#### Cacao
- `GET /api/cacao` - Obtener todos los registros de cacao
- `GET /api/cacao/:id` - Obtener un registro específico
- `POST /api/cacao` - Crear nuevo registro
- `PUT /api/cacao/:id` - Actualizar registro
- `DELETE /api/cacao/:id` - Eliminar registro

#### Analysis
- `POST /api/analysis/image` - Analizar imagen
- `GET /api/analysis` - Obtener historial de análisis
- `GET /api/analysis/:id` - Obtener análisis específico

### ML Service API

- `GET /` - Estado del servicio
- `GET /health` - Health check
- `POST /predict` - Predecir desde imagen
- `POST /reload-model` - Recargar modelo

## 🏗️ Arquitectura

```
┌─────────────┐
│   Flutter   │
│  Frontend   │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────┐
│  Express    │────▶│   MySQL      │
│  Backend    │     │   Database   │
└──────┬──────┘     └──────────────┘
       │
       ▼
┌─────────────┐
│  FastAPI    │
│  ML Service │
└─────────────┘
```

## 🔒 Seguridad

- Cambiar todas las credenciales por defecto en producción
- Usar variables de entorno para datos sensibles
- Implementar autenticación JWT para el backend
- Configurar CORS apropiadamente
- Usar HTTPS en producción

## 📝 Notas de Desarrollo

### Base de Datos
- Las migraciones de Prisma se aplican automáticamente al iniciar
- El schema se encuentra en `backend/prisma/schema.prisma`

### Machine Learning
- El modelo base usa una arquitectura CNN simple
- El modelo entrenado se guarda en `ML/models/`

### Frontend
- Usa Provider para gestión de estado
- Arquitectura en capas: screens, providers, services, widgets
- Responsive design con Material Design 3

## 🤝 Contribuir

1. Fork el proyecto
2. Crea tu rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

