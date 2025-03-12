import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
import xgboost as xgb
import joblib
import logging
from pathlib import Path
from typing import Dict, List, Union, Tuple

logger = logging.getLogger(__name__)

class DiabetesRiskModel:
    def __init__(self):
        self.model = None
        self.scaler = None
        self.feature_names = None
        self.load_model()
        
    def load_model(self) -> None:
        """Load the trained model and scaler from disk."""
        model_path = Path(__file__).parent / "models" / "diabetes_risk_model.joblib"
        if not model_path.exists():
            raise FileNotFoundError(f"Model file not found at {model_path}")
        
        model_data = joblib.load(model_path)
        self.model = model_data['rf_model']
        self.scaler = model_data['scaler']
        self.feature_names = model_data['feature_names']
        
    def train(self, X: np.ndarray, y: np.ndarray):
        """Train the model with given data."""
        try:
            # Scale features
            X_scaled = self.scaler.fit_transform(X)
            
            # Train model
            self.model.fit(X_scaled, y)
            
            # Store feature names if X is a DataFrame
            if isinstance(X, pd.DataFrame):
                self.feature_names = list(X.columns)
            
            logger.info("Model trained successfully")
        except Exception as e:
            logger.error(f"Error training model: {str(e)}")
            raise
            
    def predict(self, features: Dict[str, Union[float, int]]) -> Tuple[float, float]:
        """
        Predict diabetes risk for given features.
        Returns (risk_score, confidence)
        """
        if self.model is None or self.scaler is None:
            raise ValueError("Model not loaded")
        
        # Convert input features to DataFrame with correct column order
        feature_array = np.array([[features.get(feature, 0) for feature in self.feature_names]])
        X = pd.DataFrame(feature_array, columns=self.feature_names)
        
        # Scale features
        X_scaled = self.scaler.transform(X)
        
        # Get probability predictions
        probabilities = self.model.predict_proba(X_scaled)[0]
        
        # Calculate risk score (probability of having diabetes - classes 1 or 2)
        risk_score = probabilities[1] + probabilities[2]
        
        # Calculate confidence as the max probability
        confidence = max(probabilities)
        
        return risk_score, confidence
            
    def save_model(self, path: str):
        """Save model and scaler to disk."""
        try:
            model_data = {
                'model': self.model,
                'scaler': self.scaler,
                'feature_names': self.feature_names
            }
            joblib.dump(model_data, path)
            logger.info(f"Model saved to {path}")
        except Exception as e:
            logger.error(f"Error saving model: {str(e)}")
            raise
            
    def load_model(self, path: str):
        """Load model and scaler from disk."""
        try:
            model_data = joblib.load(path)
            self.model = model_data['model']
            self.scaler = model_data['scaler']
            self.feature_names = model_data['feature_names']
            logger.info(f"Model loaded from {path}")
        except Exception as e:
            logger.error(f"Error loading model: {str(e)}")
            raise 