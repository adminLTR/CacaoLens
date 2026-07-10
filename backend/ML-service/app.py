from flask import Flask, request, jsonify
import numpy as np
from PIL import Image
import io
import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

BASE_DIR = Path(__file__).resolve().parent
DEFAULT_MODEL_PATH = BASE_DIR / "models" / "Cacao_InceptionV3_best.keras"

CLASES_CACAO = [
    "Pudrición Negra",
    "Saludable",
    "Pod Borer",
]


def resolve_model_path() -> Path:
    configured = os.getenv("MODEL_PATH", "").strip()
    if not configured:
        return DEFAULT_MODEL_PATH

    model_path = Path(configured)
    if not model_path.is_absolute():
        model_path = BASE_DIR / model_path

    return model_path.resolve()


def is_keras_model(path: Path) -> bool:
    return path.suffix.lower() in {".keras", ".h5"}


MODEL_PATH = resolve_model_path()
modelo_cacao = None
model_type = None
input_details = None
output_details = None


def load_keras_model(path: Path):
    import json
    import tempfile
    import zipfile

    import tensorflow as tf

    def try_load(model_path: Path):
        try:
            return tf.keras.models.load_model(
                str(model_path),
                compile=False,
                safe_mode=False,
            )
        except TypeError as error:
            if "safe_mode" in str(error):
                return tf.keras.models.load_model(str(model_path), compile=False)
            raise

    try:
        return try_load(path)
    except Exception as first_error:
        print(f"Carga directa falló, intentando parche de compatibilidad: {first_error}")

    def strip_quantization_config(node):
        if isinstance(node, dict):
            node.pop("quantization_config", None)
            for value in node.values():
                strip_quantization_config(value)
        elif isinstance(node, list):
            for item in node:
                strip_quantization_config(item)

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)

        with zipfile.ZipFile(path, "r") as source_zip:
            source_zip.extractall(tmp_path)

        config_path = tmp_path / "config.json"
        config = json.loads(config_path.read_text(encoding="utf-8"))
        strip_quantization_config(config)
        config_path.write_text(json.dumps(config), encoding="utf-8")

        patched_model = tmp_path / "patched.keras"
        with zipfile.ZipFile(patched_model, "w", compression=zipfile.ZIP_STORED) as patched_zip:
            for file_path in tmp_path.iterdir():
                if file_path.name == patched_model.name:
                    continue
                patched_zip.write(file_path, arcname=file_path.name)

        return try_load(patched_model)


def load_model():
    global modelo_cacao, model_type, input_details, output_details

    print(f"Buscando modelo en: {MODEL_PATH}")

    if not MODEL_PATH.exists():
        print(f"Modelo no encontrado: {MODEL_PATH}")
        return

    try:
        if is_keras_model(MODEL_PATH):
            os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
            modelo_cacao = load_keras_model(MODEL_PATH)
            model_type = "keras"
            print("Modelo Keras cargado correctamente.")
            return

        if MODEL_PATH.suffix.lower() == ".tflite":
            from ai_edge_litert.interpreter import Interpreter

            modelo_cacao = Interpreter(model_path=str(MODEL_PATH))
            modelo_cacao.allocate_tensors()
            input_details = modelo_cacao.get_input_details()
            output_details = modelo_cacao.get_output_details()
            model_type = "tflite"
            print("Modelo TFLite cargado correctamente.")
            return

        print(f"Formato de modelo no soportado: {MODEL_PATH.suffix}")

    except Exception as e:
        print(f"Error cargando modelo: {e}")
        modelo_cacao = None
        model_type = None


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    imagen = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    imagen = imagen.resize((224, 224))
    arreglo_imagen = np.array(imagen, dtype=np.float32)
    arreglo_imagen = np.expand_dims(arreglo_imagen, axis=0)
    return arreglo_imagen / 255.0


def run_prediction(arreglo_imagen: np.ndarray):
    if model_type == "keras":
        predicciones = modelo_cacao.predict(arreglo_imagen, verbose=0)
        return predicciones[0]

    modelo_cacao.set_tensor(input_details[0]["index"], arreglo_imagen)
    modelo_cacao.invoke()
    return modelo_cacao.get_tensor(output_details[0]["index"])[0]


load_model()


@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return jsonify({"error": "No se envió ningún archivo"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "Archivo inválido"}), 400

    if modelo_cacao is None:
        return jsonify({
            "error": "Modelo no disponible",
            "model_path": str(MODEL_PATH),
            "model_type": model_type,
        }), 503

    try:
        predicciones = run_prediction(preprocess_image(file.read()))
        indice_clase = int(np.argmax(predicciones))
        confianza = float(np.max(predicciones))

        return jsonify({
            "estado": CLASES_CACAO[indice_clase],
            "confiabilidad": round(confianza, 4),
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "OK",
        "model_loaded": modelo_cacao is not None,
        "model_path": str(MODEL_PATH),
        "model_type": model_type,
    })


if __name__ == "__main__":
    port = int(os.getenv("ML_PORT", "8000"))
    app.run(
        host="0.0.0.0",
        port=port,
        debug=os.getenv("FLASK_ENV", "production") != "production",
    )
