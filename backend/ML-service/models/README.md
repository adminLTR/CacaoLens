# Modelos de Machine Learning

⚠️ **IMPORTANTE**: Los archivos de modelos NO están incluidos en el repositorio debido a su gran tamaño.

## Modelos requeridos

Este servicio necesita al menos uno de estos modelos para funcionar:

- **Cacao_InceptionV3_best.tflite** - Modelo optimizado para inferencia móvil/ligera
- **Cacao_InceptionV3_best.keras** - Modelo TensorFlow/Keras usado como fallback

## Cómo obtener los modelos

### Opción 1: Entrenar el modelo
```bash
# Desde el directorio raíz del proyecto
# Usa el notebook/código de entrenamiento disponible en ML/src
```

Después de entrenar, copia el modelo generado a esta carpeta:
```bash
cp ML/models/Cacao_InceptionV3_best.keras backend/ML-service/models/
```

### Opción 2: Obtener modelo pre-entrenado
Contacta al equipo de desarrollo para obtener acceso al modelo pre-entrenado.

## Ubicación esperada

El modelo debe estar ubicado en alguna de estas rutas:
```
backend/ML-service/models/Cacao_InceptionV3_best.tflite
backend/ML-service/models/Cacao_InceptionV3_best.keras
```

## Verificación

Para verificar que el modelo está correctamente ubicado:
```bash
ls backend/ML-service/models/
```

Deberías ver: `Cacao_InceptionV3_best.tflite` o `Cacao_InceptionV3_best.keras`

## Formatos soportados

- `.tflite`
- `.keras`

---

**Nota**: Los modelos pueden pesar varios GB y no deben ser incluidos en el control de versiones (git).
