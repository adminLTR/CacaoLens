from flask import Flask, request, jsonify
import numpy as np
from PIL import Image
import io
import os
from ai_edge_litert.interpreter import Interpreter

app = Flask(__name__)

# Ruta exacta del modelo según tus logs
MODEL_PATH = "models/Cacao_InceptionV3_best.tflite"

# Variables globales
modelo_cacao = None
input_details = None
output_details = None

# Clases del modelo
CLASES_CACAO = [
    "Saludable",
    "Pudrición Negra",
    "Pod Borer"
]

# Cargar modelo TFLite con ai_edge_litert
try:
    if os.path.exists(MODEL_PATH):
        # Inicializar el intérprete usando la nueva librería
        modelo_cacao = Interpreter(model_path=MODEL_PATH)
        modelo_cacao.allocate_tensors()
        
        # Guardar detalles de entrada y salida
        input_details = modelo_cacao.get_input_details()
        output_details = modelo_cacao.get_output_details()
        
        print("Modelo TFLite cargado correctamente con ai_edge_litert.")
    else:
        print(f"Modelo no encontrado: {MODEL_PATH}")

except Exception as e:
    print(f"Error cargando modelo: {e}")
    modelo_cacao = None

# Endpoint principal
@app.route('/predict', methods=['POST'])
def predict():

    # Verificar archivo
    if 'file' not in request.files:
        return jsonify({
            "error": "No se envió ningún archivo"
        }), 400

    file = request.files['file']

    # Verificar nombre
    if file.filename == '':
        return jsonify({
            "error": "Archivo inválido"
        }), 400

    # Verificar modelo
    if modelo_cacao is None:
        return jsonify({
            "error": "Modelo no disponible"
        }), 503

    try:
        # Leer imagen
        image_bytes = file.read()

        # Convertir imagen
        imagen = Image.open(
            io.BytesIO(image_bytes)
        ).convert("RGB")

        # Resize según modelo
        imagen = imagen.resize((224, 224))

        # Convertir a array usando numpy directamente 
        arreglo_imagen = np.array(imagen, dtype=np.float32)

        # Expandir dimensiones
        arreglo_imagen = np.expand_dims(
            arreglo_imagen,
            axis=0
        )

        # Normalizar
        arreglo_imagen = arreglo_imagen / 255.0

        # Predicción usando el intérprete
        modelo_cacao.set_tensor(input_details[0]['index'], arreglo_imagen)
        modelo_cacao.invoke()
        predicciones = modelo_cacao.get_tensor(output_details[0]['index'])

        indice_clase = int(
            np.argmax(predicciones[0])
        )

        confianza = float(
            np.max(predicciones[0])
        )

        resultado = CLASES_CACAO[indice_clase]

        # Respuesta para Express (Node.js)
        return jsonify({
            "estado": resultado,
            "confiabilidad": round(
                confianza,
                4
            )
        })

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500

# Health check opcional
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "OK",
        "model_loaded": modelo_cacao is not None
    })

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=8000,
        debug=True
    )