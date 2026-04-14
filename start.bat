@echo off
echo 🌱 CacaoLens - Quick Start Script
echo ==================================
echo.

REM Check if .env files exist
if not exist .env (
    echo 📝 Creating .env files from examples...
    copy .env.example .env
    copy backend\.env.example backend\.env
    copy ML\.env.example ML\.env
    copy frontend\.env.example frontend\.env
    echo ✅ Environment files created!
    echo ⚠️  Please review and update the .env files with your configurations
    echo.
) else (
    echo ✅ Environment files already exist
    echo.
)

echo 🐳 Down Docker containers...
docker-compose down

REM Build and start Docker containers
echo 🐳 Building Docker containers...
docker-compose build

echo.
echo 🚀 Starting services...
docker-compose up -d

echo.
echo ⏳ Waiting for services to be ready...
timeout /t 15 /nobreak > nul

echo.
echo ✅ Setup complete!
echo.
echo 📱 Access your services:
echo   - Frontend:  http://localhost:80
echo   - Backend:   http://localhost:3000
echo   - ML API:    http://localhost:8000
echo   - ML Docs:   http://localhost:8000/docs
echo.
echo 📝 View logs:
echo   docker-compose logs -f
echo.
echo 🛑 Stop services:
echo   docker-compose down
echo.
pause
