from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import os

app = Flask(__name__)

# --- AQUÍ ESTÁ EL CAMBIO ---
# Pon el nombre exacto del archivo .keras que te pasó La Torre
MODEL_PATH = "./models/Cacao_InceptionV3_best.keras"

try:
    if os.path.exists(MODEL_PATH):
        # TensorFlow carga los .keras exactamente igual que los .h5
        modelo_cacao = tf.keras.models.load_model(MODEL_PATH)
        print("Modelo .keras cargado correctamente.")
    else:
        modelo_cacao = None
        print(f"Advertencia: Archivo {MODEL_PATH} no encontrado.")
except Exception as e:
    modelo_cacao = None
    print(f"Error al cargar el modelo: {e}")

# Las clases según su proyecto
CLASES_CACAO = ["Saludable", "Pudrición Negra", "Pod Borer"]

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({"estado": "error", "mensaje": "No se envió ningún archivo"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"estado": "error", "mensaje": "El archivo no tiene nombre"}), 400

    try:
        image_bytes = file.read()
        imagen = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # Redimensionar a 224x224 (verifica este tamaño con La Torre si falla)
        imagen = imagen.resize((224, 224))
        arreglo_imagen = tf.keras.preprocessing.image.img_to_array(imagen)
        arreglo_imagen = np.expand_dims(arreglo_imagen, axis=0) / 255.0

        if modelo_cacao:
            predicciones = modelo_cacao.predict(arreglo_imagen)
            indice_clase = np.argmax(predicciones[0])
            confianza = float(np.max(predicciones[0]))
            resultado = CLASES_CACAO[indice_clase]
        else:
            resultado = "Modo de Prueba (Modelo no cargado)"
            confianza = 0.99

        return jsonify({
            "estado": resultado,
            "confiabilidad": confianza,
            "fechaRegistro": None,
            "idCacao": 1,
            "idUsuario": 1
        })

    except Exception as e:
        return jsonify({"estado": "error", "mensaje": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)