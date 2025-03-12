from fastapi import APIRouter, HTTPException, status
import logging
from pydantic import BaseModel, Field, ConfigDict
import joblib
import numpy as np
from typing import Dict, Annotated
import os

# Configure logging
logger = logging.getLogger(__name__)

router = APIRouter()

# Load the model at startup
try:
    model_path = './src/ml/models/diabetes_risk_model.joblib'
    if not os.path.exists(model_path):
        logger.warning(f"Model file not found at {model_path}. Please run the training script first.")
    else:   
        model_data = joblib.load(model_path)
        model = model_data['rf_model']
        scaler = model_data['scaler']
        feature_names = model_data['feature_names']
        logger.info("Model loaded successfully")
except Exception as e:
    logger.error(f"Error loading model: {str(e)}")
    model = None
    scaler = None
    feature_names = None

class HealthDataInput(BaseModel):
    model_config = ConfigDict(title="Health Data Input")
    HighBP: Annotated[int, Field(ge=0, le=1, description="High blood pressure (0=no, 1=yes)")]
    HighChol: Annotated[int, Field(ge=0, le=1, description="High cholesterol (0=no, 1=yes)")]
    BMI: Annotated[float, Field(ge=0, description="Body Mass Index")]
    Smoker: Annotated[int, Field(ge=0, le=1, description="Smoking status (0=no, 1=yes)")]
    Stroke: Annotated[int, Field(ge=0, le=1, description="Ever had a stroke (0=no, 1=yes)")]
    HeartDiseaseorAttack: Annotated[int, Field(ge=0, le=1, description="Heart disease or attack (0=no, 1=yes)")]
    PhysActivity: Annotated[int, Field(ge=0, le=1, description="Physical activity in past 30 days (0=no, 1=yes)")]
    Fruits: Annotated[int, Field(ge=0, le=1, description="Consume fruit 1 or more times per day (0=no, 1=yes)")]
    Veggies: Annotated[int, Field(ge=0, le=1, description="Consume vegetables 1 or more times per day (0=no, 1=yes)")]
    HvyAlcoholConsump: Annotated[int, Field(ge=0, le=1, description="Heavy alcohol consumption (0=no, 1=yes)")]
    AnyHealthcare: Annotated[int, Field(ge=0, le=1, description="Have any healthcare coverage (0=no, 1=yes)")]
    NoDocbcCost: Annotated[int, Field(ge=0, le=1, description="Was there a time in the past 12 months when you needed to see a doctor but could not because of cost? (0=no, 1=yes)")]
    GenHlth: Annotated[int, Field(ge=1, le=5, description="General health (1=excellent, 2=very good, 3=good, 4=fair, 5=poor)")]
    CholCheck: Annotated[int, Field(ge=0, le=1, description="Have you ever had your blood cholesterol checked? (0=no, 1=yes)")]
    MentHlth: Annotated[int, Field(ge=0, le=30, description="Days of poor mental health in past 30 days")]
    PhysHlth: Annotated[int, Field(ge=0, le=30, description="Days of poor physical health in past 30 days")]
    DiffWalk: Annotated[int, Field(ge=0, le=1, description="Do you have serious difficulty walking or climbing stairs? (0=no, 1=yes)")]
    Sex: Annotated[int, Field(ge=0, le=1, description="Sex (0=female, 1=male)")]
    Age: Annotated[int, Field(ge=18, le=120, description="Age in years")]
    Education: Annotated[int, Field(ge=1, le=6, description="Education level (1=Never attended school, 2=Elementary, 3=Some high school, 4=High school graduate, 5=Some college or technical school, 6=College graduate)")]
    Income: Annotated[int, Field(ge=1, le=8, description="Income level (1=less than $10,000, ..., 8=more than $75,000)")]

class RiskPredictionResponse(BaseModel):

    model_config = ConfigDict(title="Risk Prediction Response")
    
    risk_probability: Annotated[float, Field(description="Probability of having diabetes (0-1)")]
    risk_level: Annotated[str, Field(description="Risk level classification (No Diabetes, Prediabetes, or Diabetes)")]
    confidence_score: Annotated[float, Field(description="Model's confidence in the prediction (0-1)")]
    feature_importance: Annotated[Dict[str, float], Field(description="Importance score of each feature in the prediction")]

@router.post(
    "/predict"
)
async def predict_diabetes_risk(health_data: HealthDataInput):


    try:
        if not model or not scaler or not feature_names:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Model not loaded. Please ensure the model is trained and available."
            )
            
        # Convert input data to feature array
        input_data = np.array([[
            getattr(health_data, feature) for feature in feature_names
        ]])
        
        # Scale the input data
        scaled_data = scaler.transform(input_data)
        
        # Get prediction probabilities
        probabilities = model.predict_proba(scaled_data)[0]
        
        # Get feature importance
        feature_importance = dict(zip(feature_names, 
                                    model.feature_importances_))
        
        # Determine risk level
        max_prob_idx = np.argmax(probabilities)
        risk_levels = ["No Diabetes", "Prediabetes", "Diabetes"]
        risk_level = risk_levels[max_prob_idx]
        
        # Calculate confidence score
        confidence_score = float(max(probabilities))
        
        # Get probability for the highest risk (diabetes)
        risk_probability = float(probabilities[2])  # Probability for class 2 (Diabetes)
        
        return RiskPredictionResponse(
            risk_probability=risk_probability,
            risk_level=risk_level,
            confidence_score=confidence_score,
            feature_importance=feature_importance
        )
        
    except Exception as e:
        logger.error(f"Error predicting diabetes risk: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error predicting diabetes risk: {str(e)}"
        ) 