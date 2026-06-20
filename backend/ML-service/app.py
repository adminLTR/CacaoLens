from flask import Flask, request, jsonify
import numpy as np
from PIL import Image
import io
import json
import os
import tempfile
import tensorflow as tf
import zipfile

app = Flask(__name__)

MODEL_PATH = os.getenv("MODEL_PATH", "models/Cacao_InceptionV3_best.tflite")
KERAS_MODEL_PATH = os.getenv("KERAS_MODEL_PATH", "models/Cacao_InceptionV3_best.keras")

modelo_cacao = None
input_details = None
output_details = None
model_type = None

CLASES_CACAO = [
    "Saludable",
    "Pudrición Negra",
    "Pod Borer"
]

def remove_null_quantization_config(value):
    if isinstance(value, dict):
        return {
            key: remove_null_quantization_config(item)
            for key, item in value.items()
            if not (key == "quantization_config" and item is None)
        }

    if isinstance(value, list):
        return [remove_null_quantization_config(item) for item in value]

    return value

def load_keras_model(model_path):
    try:
        return tf.keras.models.load_model(model_path, compile=False)
    except Exception as original_error:
        temp_path = None

        try:
            with zipfile.ZipFile(model_path, "r") as source:
                with tempfile.NamedTemporaryFile(suffix=".keras", delete=False) as temp_file:
                    temp_path = temp_file.name

                with zipfile.ZipFile(temp_path, "w") as target:
                    for item in source.infolist():
                        content = source.read(item.filename)

                        if item.filename == "config.json":
                            config = json.loads(content.decode("utf-8"))
                            config = remove_null_quantization_config(config)
                            content = json.dumps(config).encode("utf-8")

                        target.writestr(item, content)

            return tf.keras.models.load_model(temp_path, compile=False)
        except Exception:
            raise original_error
        finally:
            if temp_path and os.path.exists(temp_path):
                os.remove(temp_path)

def load_model():
    global modelo_cacao, input_details, output_details, model_type

    modelo_cacao = None
    input_details = None
    output_details = None
    model_type = None

    if MODEL_PATH.endswith(".keras") and os.path.exists(MODEL_PATH):
        modelo_cacao = load_keras_model(MODEL_PATH)
        model_type = "keras"
        print(f"Modelo Keras cargado correctamente: {MODEL_PATH}")
        return

    if os.path.exists(MODEL_PATH):
        modelo_cacao = tf.lite.Interpreter(model_path=MODEL_PATH)
        modelo_cacao.allocate_tensors()
        input_details = modelo_cacao.get_input_details()
        output_details = modelo_cacao.get_output_details()
        model_type = "tflite"
        print(f"Modelo TFLite cargado correctamente: {MODEL_PATH}")
        return

    if os.path.exists(KERAS_MODEL_PATH):
        modelo_cacao = load_keras_model(KERAS_MODEL_PATH)
        model_type = "keras"
        print(f"Modelo Keras cargado correctamente: {KERAS_MODEL_PATH}")
        return

    print(f"Modelo no encontrado: {MODEL_PATH} ni {KERAS_MODEL_PATH}")

try:
    load_model()
except Exception as e:
    print(f"Error cargando modelo: {e}")
    modelo_cacao = None

def preprocess_image(image_bytes):
    imagen = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    imagen = imagen.resize((224, 224))
    arreglo_imagen = np.array(imagen, dtype=np.float32)
    arreglo_imagen = np.expand_dims(arreglo_imagen, axis=0)
    return arreglo_imagen / 255.0

def run_prediction(arreglo_imagen):
    if model_type == "tflite":
        modelo_cacao.set_tensor(input_details[0]["index"], arreglo_imagen)
        modelo_cacao.invoke()
        return modelo_cacao.get_tensor(output_details[0]["index"])

    return modelo_cacao.predict(arreglo_imagen, verbose=0)

@app.route("/", methods=["GET"])
def index():
    return jsonify({
        "service": "CacaoLens ML Service",
        "status": "OK",
        "model_loaded": modelo_cacao is not None,
        "model_type": model_type
    })

@app.route('/predict', methods=['POST'])
def predict():

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
        image_bytes = file.read()
        arreglo_imagen = preprocess_image(image_bytes)
        predicciones = run_prediction(arreglo_imagen)

        indice_clase = int(
            np.argmax(predicciones[0])
        )

        confianza = float(
            np.max(predicciones[0])
        )

        resultado = CLASES_CACAO[indice_clase]

        return jsonify({
            "estado": resultado,
            "prediccion": resultado,
            "confiabilidad": round(
                confianza,
                4
            ),
            "confianza": round(
                confianza,
                4
            ),
            "model_type": model_type
        })

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "OK",
        "model_loaded": modelo_cacao is not None,
        "model_type": model_type
    })

@app.route('/reload-model', methods=['POST'])
def reload_model():
    try:
        load_model()
        return jsonify({
            "status": "OK",
            "model_loaded": modelo_cacao is not None,
            "model_type": model_type
        })
    except Exception as e:
        return jsonify({
            "status": "ERROR",
            "error": str(e)
        }), 500

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=8000,
        debug=True
    )
