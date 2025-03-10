from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
from src.core.database import db
from src.models.user import User
from src.auth.services.token import TokenService
import logging

logger = logging.getLogger(__name__)
security = HTTPBearer()

async def get_current_user(credentials = Depends(security)):
    """
    Get current user from access token
    Token format should be: Bearer <access_token>
    """
    try:
        token = credentials.credentials
        token_data = TokenService.verify_token(token)
        if not token_data or not token_data.email:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )
            
        user = await db.get_database().users.find_one({"email": token_data.email})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
            
        return User(**user)
        
    except Exception as e:
        logger.error(f"Authentication error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        ) 