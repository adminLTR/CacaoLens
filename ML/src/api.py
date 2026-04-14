from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="CacaoLens ML API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model (placeholder - será reemplazado con tu modelo entrenado)
MODEL_PATH = os.getenv('MODEL_PATH', 'models/cacao_cnn_model.h5')
model = None

def load_model():
    global model
    try:
        if os.path.exists(MODEL_PATH):
            model = tf.keras.models.load_model(MODEL_PATH)
            print(f"✅ Model loaded from {MODEL_PATH}")
        else:
            print(f"⚠️ Model not found at {MODEL_PATH}. Please train a model first.")
    except Exception as e:
        print(f"❌ Error loading model: {e}")

load_model()

def preprocess_image(image: Image.Image, target_size=(224, 224)):
    """Preprocess image for CNN model"""
    image = image.convert('RGB')
    image = image.resize(target_size)
    img_array = np.array(image)
    img_array = img_array / 255.0  # Normalize
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

@app.get("/")
def root():
    return {
        "message": "CacaoLens ML API",
        "status": "running",
        "model_loaded": model is not None
    }

@app.get("/health")
def health():
    return {
        "status": "healthy",
        "model_status": "loaded" if model else "not loaded"
    }

@app.post("/predict")
async def predict(image: UploadFile = File(...)):
    """
    Predict cacao quality/type from image
    """
    if not model:
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Please train and load a model first."
        )
    
    try:
        # Read and preprocess image
        contents = await image.read()
        img = Image.open(io.BytesIO(contents))
        processed_img = preprocess_image(img)
        
        # Make prediction
        predictions = model.predict(processed_img)
        predicted_class = int(np.argmax(predictions[0]))
        confidence = float(np.max(predictions[0]))
        
        # Class labels (ajustar según tu modelo)
        class_labels = {
            0: "Cacao de Alta Calidad",
            1: "Cacao de Calidad Media",
            2: "Cacao de Baja Calidad"
        }
        
        return {
            "success": True,
            "prediction": class_labels.get(predicted_class, f"Class {predicted_class}"),
            "class_id": predicted_class,
            "confidence": confidence,
            "all_predictions": predictions[0].tolist()
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@app.post("/reload-model")
async def reload_model():
    """Reload the model"""
    load_model()
    return {
        "success": True,
        "message": "Model reloaded",
        "model_loaded": model is not None
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
