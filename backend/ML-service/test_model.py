import os
import warnings

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

warnings.filterwarnings("ignore")

from keras.models import load_model

MODEL_PATH = "models/Cacao_InceptionV3_best.keras"

try:

    print("Intentando cargar modelo...")

    modelo = load_model(
        MODEL_PATH,
        compile=False
    )

    print("MODELO CARGADO OK")

except Exception as e:

    print("\nERROR REAL:")
    print(type(e).__name__)
    print(str(e)[:1000])