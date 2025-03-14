import joblib
from fastapi import APIRouter, HTTPException, status, Depends
import logging
from pydantic import BaseModel, Field, ConfigDict
import pickle
import numpy as np

from sklearn.preprocessing import StandardScaler
from typing import Dict, Annotated, List
import os
import pandas as pd
from src.core.database import db
from src.auth.utils import get_current_user
from src.models.user import User
from src.models.prediction import Prediction, PredictionCreate
from datetime import datetime
from fastapi.security import OAuth2PasswordBearer

# Configure logging
logger = logging.getLogger(__name__)

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Initialize model variables
model = None
scaler = None
feature_names = None

try:
    model_path = './src/ml/models/diaHealth_012.joblib'
    if not os.path.exists(model_path):
        logger.warning(f"Model file not found at {model_path}. Please run the training script first.")
    else:
        logger.info(f"NumPy version: {np.__version__}")
        logger.info("Loading model file...")
        
        with open(model_path, 'rb') as f:
            model_data = joblib.load(f)
            
        model = model_data['model']
        scaler = model_data['scaler']
        feature_names = model_data['feature_names']
        
        logger.info("Model components loaded successfully")
        logger.info(f"Feature names: {feature_names}")
        logger.info(f"Model type: {type(model)}")


    
except Exception as e:
    logger.error(f"Error in model initialization: {str(e)}")
    logger.error(f"Error type: {type(e)}")
    model = None
    scaler = None
    feature_names = None

class HealthDataInput(BaseModel):
    model_config = ConfigDict(title="Health Data Input")
    Height: Annotated[float, Field(ge=0)]
    Weight: Annotated[float, Field(ge=0)]
    Stroke: Annotated[int, Field(ge=0, le=1)]
    HeartDiseaseorAttack: Annotated[int, Field(ge=0, le=1)]
    Sex: Annotated[int, Field(ge=0, le=1)]
    Age: Annotated[int, Field(ge=1, le=120)]

class RiskPredictionResponse(BaseModel):
    model_config = ConfigDict(title="Risk Prediction Response")
    
    risk_probability: Annotated[float, Field(description="Probability of having diabetes (0-1)")]
    risk_level: Annotated[str, Field(description="Risk level classification (No Diabetes, Prediabetes, or Diabetes)")]
    confidence_score: Annotated[float, Field(description="Model's confidence in the prediction (0-1)")]
    feature_importance: Annotated[Dict[str, float], Field(description="Importance score of each feature in the prediction")]
    created_at: datetime = Field(default_factory=datetime.utcnow)

@router.post(
    "/predict",
    response_model=RiskPredictionResponse,
    summary="Predict Diabetes Risk",
    description="Predicts diabetes risk based on input health data and returns risk assessment with feature importance."
)
async def predict_diabetes_risk(
    health_data: HealthDataInput,
    current_user: User = Depends(get_current_user)
):
    try:
        if not model or not scaler or not feature_names:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Model not loaded. Please ensure the model is trained and available."
            )
        
        # Calculate BMI from height and weight
        height_m = health_data.Height / 100  # Convert cm to m
        bmi = health_data.Weight / (height_m * height_m)
        
        # Convert input data to DataFrame with correct feature order
        input_data = np.array([[
            bmi,  # Calculate BMI from height and weight
            health_data.Stroke,
            health_data.HeartDiseaseorAttack,
            health_data.Sex,
            health_data.Age
        ]])
        input_df = pd.DataFrame(input_data, columns=feature_names)
        
        # Scale the input data using pre-trained scaler
        scaled_data = scaler.transform(input_df)
        # Convert scaled data back to DataFrame with feature names
        scaled_df = pd.DataFrame(scaled_data, columns=feature_names)
        
        # Get prediction probabilities from model
        predictions = model.predict(scaled_df)
        probabilities = model.predict_proba(scaled_df)[0]
        
        # Get feature importance
        estimators = model.estimators_
        if len(estimators) > 0 and hasattr(estimators[0], 'feature_importances_'):
            feature_importance = dict(zip(feature_names, estimators[0].feature_importances_))
        else:
            feature_importance = dict(zip(feature_names, [1.0/len(feature_names)] * len(feature_names)))
        
        # Sort feature importance by value
        feature_importance = dict(sorted(
            feature_importance.items(),
            key=lambda x: x[1],
            reverse=True
        ))
        
        # Determine risk level
        max_prob_idx = np.argmax(probabilities)
        risk_levels = ["No Diabetes", "Prediabetes", "Diabetes"]
        risk_level = risk_levels[max_prob_idx]
        
        # Calculate confidence score
        confidence_score = float(max(probabilities))
        
        # Get probability for the highest risk (diabetes)
        risk_probability = float(probabilities[2])  # Probability for class 2 (Diabetes)
        
        # Create prediction result
        prediction = PredictionCreate(
            user_id=str(current_user.id),
            risk_probability=risk_probability,
            risk_level=risk_level,
            confidence_score=confidence_score,
            feature_importance=feature_importance,
            input_data=health_data.model_dump(),
            created_at=datetime.now().astimezone()  # Store with timezone info
        )
        
        # Store prediction in database
        result = await db.get_database().predictions.insert_one(
            prediction.model_dump(by_alias=True)
        )
        
        return RiskPredictionResponse(
            id=str(result.inserted_id),
            risk_probability=risk_probability,
            risk_level=risk_level,
            confidence_score=confidence_score,
            feature_importance=feature_importance,
            created_at=prediction.created_at
        )
        
    except Exception as e:
        logger.error(f"Error predicting diabetes risk: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error predicting diabetes risk: {str(e)}"
        )

@router.get(
    "/predictions",
    response_model=List[Prediction],
    summary="Get Prediction History",
    description="Retrieves all previous predictions for the current user."
)
async def get_prediction_history(current_user: User = Depends(get_current_user)):
    try:
        # Get predictions for current user
        cursor = db.get_database().predictions.find(
            {"user_id": str(current_user.id)}
        ).sort("created_at", -1)  # Sort by newest first
        
        predictions = []
        async for doc in cursor:
            predictions.append(Prediction.from_mongo(doc))
            
        return predictions
        
    except Exception as e:
        logger.error(f"Error retrieving prediction history: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving prediction history: {str(e)}"
        ) 