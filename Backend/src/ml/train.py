import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
import joblib
import os
from pathlib import Path

def load_data():
    data_path = "./datasets/processed/diabetes_012_health_indicators.csv"
    
    df = pd.read_csv("./datasets/processed/diabetes_012_health_indicators.csv")
    
    # Separate features and target
    X = df.drop('Diabetes_012', axis=1)
    y = df['Diabetes_012']
    
    return X, y

def train_model():
    print("Loading data...")
    X, y = load_data()
    
    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Scale the features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train Random Forest model
    print("Training Random Forest model...")
    rf_model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42
    )
    rf_model.fit(X_train_scaled, y_train)
    
    # Calculate accuracy
    train_accuracy = rf_model.score(X_train_scaled, y_train)
    test_accuracy = rf_model.score(X_test_scaled, y_test)
    print(f"Train accuracy: {train_accuracy:.4f}")
    print(f"Test accuracy: {test_accuracy:.4f}")
    
    # Save the model and scaler
    model_dir = Path(__file__).parent / "models"
    model_dir.mkdir(exist_ok=True)
    model_path = model_dir / "diabetes_risk_model.joblib"
    
    model_data = {
        'rf_model': rf_model,
        'scaler': scaler,
        'feature_names': list(X.columns),
        'train_accuracy': train_accuracy,
        'test_accuracy': test_accuracy
    }
    
    print(f"Saving model to {model_path}...")
    joblib.dump(model_data, model_path)
    print("Model saved successfully!")

if __name__ == "__main__":
    train_model()
