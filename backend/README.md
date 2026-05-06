# Backend Services

Este directorio contiene todos los servicios backend de CacaoLens.

## Estructura

```
backend/
├── backend/       # API principal Node.js + Express + Prisma
│   ├── src/
│   ├── prisma/
│   ├── uploads/
│   └── ...
│
└── ML-service/    # Servicio de Machine Learning Flask
    ├── app.py
    ├── models/
    └── requirements.txt
```

## Servicios

### Backend (Node.js)
- **Puerto**: 3000 (configurable via BACKEND_PORT)
- **Tecnologías**: Express, Prisma, MySQL
- **Función**: API REST principal, autenticación, gestión de usuarios e historial

### ML-service (Flask)
- **Puerto**: 8000 (configurable via ML_PORT)
- **Tecnologías**: Flask, TensorFlow, Keras
- **Función**: Servicio de predicción de enfermedades en cacao usando modelos de IA

## Configuración

Cada servicio tiene su propio archivo `.env`:
- `backend/.env` - Configuración del backend Node.js
- `ML-service/.env` - Configuración del servicio ML

Usa los archivos `.env.example` como plantilla.

## Desarrollo

Para ejecutar los servicios:

```bash
# Desde el directorio raíz del proyecto
docker-compose up --build
```

Los servicios se comunican a través de la red Docker `cacaolens-network`.
