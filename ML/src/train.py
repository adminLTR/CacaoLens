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

def create_cnn_model(input_shape=(224, 224, 3), num_classes=3):
    """
    Create a CNN model for cacao image classification
    """
    model = keras.Sequential([
        # Convolutional Block 1
        layers.Conv2D(32, (3, 3), activation='relu', input_shape=input_shape),
        layers.BatchNormalization(),
        layers.MaxPooling2D((2, 2)),
        
        # Convolutional Block 2
        layers.Conv2D(64, (3, 3), activation='relu'),
        layers.BatchNormalization(),
        layers.MaxPooling2D((2, 2)),
        
        # Convolutional Block 3
        layers.Conv2D(128, (3, 3), activation='relu'),
        layers.BatchNormalization(),
        layers.MaxPooling2D((2, 2)),
        
        # Convolutional Block 4
        layers.Conv2D(256, (3, 3), activation='relu'),
        layers.BatchNormalization(),
        layers.MaxPooling2D((2, 2)),
        
        # Flatten and Dense Layers
        layers.Flatten(),
        layers.Dense(512, activation='relu'),
        layers.Dropout(0.5),
        layers.Dense(256, activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(num_classes, activation='softmax')
    ])
    
    return model

def train_model(train_dataset, val_dataset, model_save_path='models/cacao_cnn_model.h5'):
    """
    Train the CNN model
    
    Args:
        train_dataset: Training dataset
        val_dataset: Validation dataset
        model_save_path: Path to save the trained model
    """
    # Create model
    model = create_cnn_model(num_classes=NUM_CLASSES)
    
    # Compile model
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='categorical_crossentropy',
        metrics=['accuracy', 'precision', 'recall']
    )
    
    # Callbacks
    callbacks = [
        keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=1e-7
        ),
        keras.callbacks.ModelCheckpoint(
            model_save_path,
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        )
    ]
    
    # Train model
    history = model.fit(
        train_dataset,
        validation_data=val_dataset,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )
    
    print(f"\n✅ Model saved to {model_save_path}")
    
    return model, history

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
