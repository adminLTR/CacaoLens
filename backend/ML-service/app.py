from flask import Flask, jsonify, request
from ai_edge_litert.interpreter import Interpreter
from PIL import Image
import io
import os
import numpy as np

app = Flask(__name__)

MODEL_PATH = os.getenv("MODEL_PATH", "models/Cacao_InceptionV3_best.tflite")
PORT = int(os.getenv("PORT", os.getenv("ML_PORT", "8000")))

modelo_cacao = None
input_details = None
output_details = None

CLASES_CACAO = [
    "Saludable",
    "Pudrición Negra",
    "Pod Borer",
]


def load_model():
    global modelo_cacao, input_details, output_details

    modelo_cacao = None
    input_details = None
    output_details = None

    if not os.path.exists(MODEL_PATH):
        print(f"Modelo TFLite no encontrado: {MODEL_PATH}")
        return

    modelo_cacao = Interpreter(model_path=MODEL_PATH)
    modelo_cacao.allocate_tensors()
    input_details = modelo_cacao.get_input_details()
    output_details = modelo_cacao.get_output_details()
    print(f"Modelo TFLite cargado correctamente: {MODEL_PATH}")


try:
    load_model()
except Exception as error:
    print(f"Error cargando modelo TFLite: {error}")
    modelo_cacao = None


def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image = image.resize((224, 224))
    image_array = np.array(image, dtype=np.float32)
    image_array = np.expand_dims(image_array, axis=0)
    return image_array / 255.0


@app.route("/", methods=["GET"])
def index():
    return jsonify({
        "service": "CacaoLens ML Service",
        "status": "OK",
        "model_loaded": modelo_cacao is not None,
        "model_type": "tflite" if modelo_cacao is not None else None,
        "model_path": MODEL_PATH,
    })


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "OK",
        "model_loaded": modelo_cacao is not None,
        "model_type": "tflite" if modelo_cacao is not None else None,
        "model_path": MODEL_PATH,
    })


@app.route("/reload-model", methods=["POST"])
def reload_model():
    try:
        load_model()
        return jsonify({
            "status": "OK",
            "model_loaded": modelo_cacao is not None,
            "model_type": "tflite" if modelo_cacao is not None else None,
            "model_path": MODEL_PATH,
        })
    except Exception as error:
        return jsonify({
            "status": "ERROR",
            "error": str(error),
            "model_path": MODEL_PATH,
        }), 500


@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return jsonify({"error": "No se envio ningun archivo"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "Archivo invalido"}), 400

    if modelo_cacao is None:
        return jsonify({
            "error": "Modelo no disponible",
            "model_path": MODEL_PATH,
            "model_type": None,
        }), 503

    try:
        input_data = preprocess_image(file.read())
        modelo_cacao.set_tensor(input_details[0]["index"], input_data)
        modelo_cacao.invoke()
        predictions = modelo_cacao.get_tensor(output_details[0]["index"])

        class_index = int(np.argmax(predictions[0]))
        confidence = float(np.max(predictions[0]))
        result = CLASES_CACAO[class_index]

        return jsonify({
            "estado": result,
            "prediccion": result,
            "confiabilidad": round(confidence, 4),
            "confianza": round(confidence, 4),
            "model_type": "tflite",
        })
    except Exception as error:
        return jsonify({"error": str(error)}), 500


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=PORT,
        debug=os.getenv("FLASK_ENV", "production") != "production",
    )
