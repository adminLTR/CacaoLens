# CacaoLens - Machine Learning Model

Este directorio contiene el modelo de CNN para análisis de imágenes de cacao.

## Estructura

```
ML/
├── models/          # Modelos entrenados
├── data/            # Datos de entrenamiento
├── notebooks/       # Jupyter notebooks para experimentación
├── src/             # Código fuente
│   ├── train.py     # Script de entrenamiento
│   ├── predict.py   # Script de predicción
│   └── api.py       # API FastAPI
├── Dockerfile
├── requirements.txt
└── README.md
```

## Instalación

```bash
pip install -r requirements.txt
```

## Uso

### Entrenar el modelo
```bash
python src/train.py
```

### Ejecutar la API
```bash
uvicorn src.api:app --host 0.0.0.0 --port 8000
```
