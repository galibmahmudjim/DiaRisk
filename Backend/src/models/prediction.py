from datetime import datetime
from typing import Dict, Any
from pydantic import BaseModel, Field
from bson import ObjectId

class PredictionCreate(BaseModel):
    user_id: str
    risk_probability: float
    risk_level: str
    confidence_score: float
    feature_importance: Dict[str, float]
    input_data: Dict[str, Any]
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Prediction(PredictionCreate):
    id: str

    @classmethod
    def from_mongo(cls, data: dict):
        if data.get("_id"):
            data["id"] = str(data["_id"])
        return cls(**data)

    class Config:
        from_attributes = True 