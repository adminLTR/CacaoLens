import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import numpy as np
import os
from dotenv import load_dotenv

load_dotenv()

# Configuration
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 50
NUM_CLASSES = 3  # Ajustar según tus necesidades


if __name__ == "__main__":
    print("🚀 Starting model training...")
    print("⚠️ Note: You need to prepare your dataset first!")
    print("Expected structure:")
    print("  data/")
    print("    ├── train/")
    print("    │   ├── class1/")
    print("    │   ├── class2/")
    print("    │   └── class3/")
    print("    └── validation/")
    print("        ├── class1/")
    print("        ├── class2/")
    print("        └── class3/")
    
    # Example: Load dataset (uncomment and modify when you have data)
    # train_dataset = tf.keras.preprocessing.image_dataset_from_directory(
    #     'data/train',
    #     image_size=IMG_SIZE,
    #     batch_size=BATCH_SIZE
    # )
    # 
    # val_dataset = tf.keras.preprocessing.image_dataset_from_directory(
    #     'data/validation',
    #     image_size=IMG_SIZE,
    #     batch_size=BATCH_SIZE
    # )
    # 
    # model, history = train_model(train_dataset, val_dataset)
