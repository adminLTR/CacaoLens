# Modelos de Entrenamiento

Esta carpeta contiene los modelos entrenados de ML.

⚠️ **IMPORTANTE**: Los archivos de modelos (.keras, .h5, .pb) NO están en el repo debido a su gran tamaño.

## Cómo entrenar:
```bash
cd ML
python src/train.py
```

## Despliegue:
Después de entrenar, copia el modelo al servicio:
```bash
cp ML/models/Cacao_InceptionV3_best.keras backend/ML-service/models/
```
