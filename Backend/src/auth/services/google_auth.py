from datetime import datetime
import httpx
import logging
from fastapi import HTTPException, status
from src.core.config import settings
from src.core.database import db
from src.models.user import User, UserCreate

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class GoogleAuthService:
    @staticmethod
    async def get_user_info(code: str, callback_url: str) -> dict:
        """
        Get user information from Google using the authorization code.
        
        Args:
            code: Google OAuth2 authorization code
            callback_url: The callback URL used in the login request
            
        Returns:
            dict: User information from Google
            
        Raises:
            HTTPException: If token exchange fails
        """
        try:
            # Exchange code for tokens
            token_url = "https://oauth2.googleapis.com/token"
            data = {
                "client_id": settings.GOOGLE_CLIENT_ID,
                "client_secret": settings.GOOGLE_CLIENT_SECRET,
                "code": code,
                "redirect_uri": callback_url,
                "grant_type": "authorization_code"
            }
            
            logger.info(f"Requesting token from Google with redirect URI: {callback_url}")
            
            async with httpx.AsyncClient() as client:
                # Get access token
                token_response = await client.post(token_url, data=data)
                logger.info(f"Token response status: {token_response.status_code}")
                
                if token_response.status_code != 200:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Failed to get access token from Google: {token_response.text}"
                    )
                
                token_data = token_response.json()
                access_token = token_data["access_token"]
                
                # Get user info
                user_info_response = await client.get(
                    "https://www.googleapis.com/oauth2/v3/userinfo",
                    headers={"Authorization": f"Bearer {access_token}"}
                )
                
                if user_info_response.status_code != 200:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="Failed to get user info from Google"
                    )
                
                return user_info_response.json()
                
        except Exception as e:
            logger.error(f"Error getting user info from Google: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error getting user info from Google: {str(e)}"
            )

    @staticmethod
    async def create_or_update_user(user_info: dict) -> User:
        """
        Create or update a user in the database.
        
        Args:
            user_info: User information from Google
            
        Returns:
            User: The created or updated user
            
        Raises:
            HTTPException: If user creation/update fails
        """
        try:
            # Check if user exists
            existing_user = await db.get_database().users.find_one({"email": user_info["email"]})
            
            if existing_user:
                # Update existing user
                update_data = {
                    "name": user_info.get("name"),
                    "picture": user_info.get("picture"),
                    "is_active": True
                }
                
                await db.get_database().users.update_one(
                    {"email": user_info["email"]},
                    {"$set": update_data}
                )
                
                # Get updated user
                updated_user = await db.get_database().users.find_one({"email": user_info["email"]})
                return User(**updated_user)
            else:
                # Create new user
                user_data = UserCreate(
                    email=user_info["email"],
                    name=user_info.get("name"),
                    picture=user_info.get("picture")
                )
                
                result = await db.get_database().users.insert_one(user_data.model_dump(by_alias=True))
                
                # Get created user
                created_user = await db.get_database().users.find_one({"_id": result.inserted_id})
                return User(**created_user)
                
        except Exception as e:
            logger.error(f"Database error: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error creating/updating user: {str(e)}"
            )