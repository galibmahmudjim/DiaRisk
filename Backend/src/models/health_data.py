from pydantic import BaseModel, Field, GetJsonSchemaHandler
from datetime import datetime, UTC
from typing import Optional, Any
from bson import ObjectId
from pydantic_core import CoreSchema, core_schema

class PyObjectId(str):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return str(v)

    @classmethod
    def __get_pydantic_core_schema__(
        cls,
        _source_type: Any,
        _handler: Any,
    ) -> CoreSchema:
        return core_schema.json_or_python_schema(
            json_schema=core_schema.str_schema(),
            python_schema=core_schema.union_schema([
                core_schema.str_schema(),
                core_schema.is_instance_schema(ObjectId),
            ]),
            serialization=core_schema.plain_serializer_function_ser_schema(
                lambda x: str(x), return_schema=core_schema.str_schema()
            ),
        )

class HealthData(BaseModel):
    id: Optional[PyObjectId] = Field(default_factory=PyObjectId, alias="_id")
    user_id: str
    age: int = Field(..., ge=0, le=120)
    weight: float = Field(..., ge=0, le=500)  # in kg
    height: float = Field(..., ge=0, le=300)  # in cm
    blood_glucose: float = Field(..., ge=0)  # in mg/dL
    blood_pressure_systolic: int = Field(..., ge=0, le=300)
    blood_pressure_diastolic: int = Field(..., ge=0, le=200)
    hba1c: Optional[float] = Field(None, ge=0, le=20)  # in %
    diabetes_type: Optional[str] = Field(None)  # Type 1, Type 2, or None
    medications: Optional[list[str]] = []
    family_history: Optional[bool] = False
    lifestyle_factors: Optional[dict] = Field(default_factory=dict)  # exercise, diet, etc.
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))

    model_config = {
        "json_encoders": {ObjectId: str},
        "populate_by_name": True,
        "arbitrary_types_allowed": True,
        "json_schema_mode": "serialization"
    }

class HealthDataUpdate(BaseModel):
    age: Optional[int] = Field(None, ge=0, le=120)
    weight: Optional[float] = Field(None, ge=0, le=500)
    height: Optional[float] = Field(None, ge=0, le=300)
    blood_glucose: Optional[float] = Field(None, ge=0)
    blood_pressure_systolic: Optional[int] = Field(None, ge=0, le=300)
    blood_pressure_diastolic: Optional[int] = Field(None, ge=0, le=200)
    hba1c: Optional[float] = Field(None, ge=0, le=20)
    diabetes_type: Optional[str] = None
    medications: Optional[list[str]] = None
    family_history: Optional[bool] = None
    lifestyle_factors: Optional[dict] = None

    model_config = {
        "json_schema_mode": "serialization"
    } 