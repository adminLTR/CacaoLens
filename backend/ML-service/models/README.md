# Modelos de Machine Learning

⚠️ **IMPORTANTE**: Los archivos de modelos NO están incluidos en el repositorio debido a su gran tamaño.

## Modelos requeridos

Este servicio necesita el siguiente modelo para funcionar:

- **Cacao_InceptionV3_best.keras** - Modelo entrenado para clasificación de enfermedades en cacao

## Cómo obtener los modelos

### Opción 1: Entrenar el modelo
```bash
# Desde el directorio raíz del proyecto
cd ML
python src/train.py
```

Después de entrenar, copia el modelo generado a esta carpeta:
```bash
cp ML/models/Cacao_InceptionV3_best.keras backend/ML-service/models/
```

### Opción 2: Obtener modelo pre-entrenado
Contacta al equipo de desarrollo para obtener acceso al modelo pre-entrenado.

## Ubicación esperada

El modelo debe estar ubicado en:
```
backend/ML-service/models/Cacao_InceptionV3_best.keras
```

## Verificación

Para verificar que el modelo está correctamente ubicado:
```bash
ls backend/ML-service/models/
```

Deberías ver: `Cacao_InceptionV3_best.keras`

## Formatos soportados

- `.keras` (recomendado - formato nativo de TensorFlow/Keras)
- `.h5` (formato legacy de Keras)

---

**Nota**: Los modelos pueden pesar varios GB y no deben ser incluidos en el control de versiones (git).
