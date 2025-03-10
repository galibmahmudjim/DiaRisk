from fastapi import APIRouter, HTTPException, status, Depends
from src.models.health_data import HealthData
from src.models.user import User
from src.core.database import db
from src.auth.utils import get_current_user
from datetime import datetime, UTC
from bson import ObjectId
import logging

# Configure logging
logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/data", response_model=dict)
async def store_health_data(health_data: HealthData, current_user: User = Depends(get_current_user)):
    """
    Store health data for the authenticated user.
    Requires Bearer token authentication.
    """
    try:
        # Set user_id from authenticated user
        health_data.user_id = str(current_user.id)
        
        # Convert to dict and insert
        health_dict = health_data.model_dump(by_alias=True)
        result = await db.get_database().health_data.insert_one(health_dict)
        
        # Get the created document
        created_data = await db.get_database().health_data.find_one(
            {"_id": result.inserted_id}
        )
        
        return {
            "status": "success",
            "data": {
                "health_data": {
                    **created_data,
                    "id": str(created_data["_id"])
                }
            }
        }
        
    except Exception as e:
        logger.error(f"Error storing health data: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error storing health data: {str(e)}"
        )

@router.get("/data", response_model=dict)
async def get_health_data(current_user: User = Depends(get_current_user)):
    """
    Get health data for the authenticated user.
    Requires Bearer token authentication.
    """
    try:
        logger.info(f"Retrieving health data for user: {current_user.id}")
        # Get user's health data
        health_data = await db.get_database().health_data.find_one(
            {"user_id": str(current_user.id)}
        )
        
        if not health_data:
            logger.warning(f"No health data found for user: {current_user.id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Health data not found"
            )
        
        logger.info(f"Successfully retrieved health data for user: {current_user.id}")
        return {
            "status": "success",
            "data": {
                "health_data": {
                    **health_data,
                    "id": str(health_data["_id"])
                }
            }
        }
        
    except Exception as e:
        logger.error(f"Error retrieving health data: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving health data: {str(e)}"
        ) 