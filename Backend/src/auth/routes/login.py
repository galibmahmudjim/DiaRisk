from fastapi import APIRouter, HTTPException, status, Request, Depends
from fastapi.responses import RedirectResponse, JSONResponse
import logging
from src.core.config import settings
from src.auth.services.google_auth import GoogleAuthService
from src.auth.services.token import TokenService
from src.models.user import User
from src.auth.utils import get_current_user

logger = logging.getLogger(__name__)
router = APIRouter()

@router.get("/me")
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Get current user information using access token"""
    try:
        return {
            "status": "success",
            "data": {
                "user": {
                    "id": str(current_user.id),
                    "email": current_user.email,
                    "name": current_user.name,
                    "picture": current_user.picture,
                    "is_active": current_user.is_active,
                    "created_at": current_user.created_at.isoformat() if current_user.created_at else None
                }
            }
        }
    except AttributeError as e:
        logger.error(f"Invalid user data structure: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Invalid user data structure"
        )
    except Exception as e:
        logger.error(f"Error getting user info: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving user information"
        )

@router.get("/login", response_class=RedirectResponse)
async def login(request: Request):
    """Start Google OAuth2 login flow"""
    try:
        # Ensure base URL is properly formatted
        base_url = str(request.base_url).rstrip('/')
        callback_url = f"{base_url}/api/v1/auth/callback"
        
        # Generate state token for CSRF protection
        state = TokenService.create_state_token()
        
        google_auth_url = (
            f"https://accounts.google.com/o/oauth2/v2/auth"
            f"?client_id={settings.GOOGLE_CLIENT_ID}"
            f"&redirect_uri={callback_url}"
            f"&response_type=code"
            f"&scope=openid email profile"
            f"&access_type=offline"
            f"&prompt=consent"
            f"&state={state}"
        )
        
        response = RedirectResponse(url=google_auth_url)
        response.set_cookie(
            key="oauth_state",
            value=state,
            httponly=True,
            secure=True,
            samesite='lax',
            max_age=300  # 5 minutes
        )
        return response
        
    except Exception as e:
        logger.error(f"Error in login route: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error starting login flow"
        )

@router.get("/callback")
async def callback(
    code: str,
    state: str,
    request: Request,
    error: str = None,
    error_description: str = None
):
    """Handle Google OAuth2 callback and return access token"""
    try:
        # Check for OAuth errors
        if error:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"OAuth error: {error}. {error_description or ''}"
            )
        
        # Validate state token
        stored_state = request.cookies.get("oauth_state")
        if not stored_state or stored_state != state:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid state token"
            )
            
        # Ensure base URL is properly formatted
        base_url = str(request.base_url).rstrip('/')
        callback_url = f"{base_url}/api/v1/auth/callback"
        
        # Get user info from Google
        try:
            user_info = await GoogleAuthService.get_user_info(code, callback_url)
        except Exception as e:
            logger.error(f"Google OAuth error: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Failed to authenticate with Google"
            )
            
        # Create or update user
        try:
            user = await GoogleAuthService.create_or_update_user(user_info)
        except Exception as e:
            logger.error(f"Database error: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error creating/updating user"
            )
            
        # Generate access token
        try:
            access_token = TokenService.create_access_token(user.email)
        except Exception as e:
            logger.error(f"Token generation error: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error generating access token"
            )
        
        # Create response with token and user info
        response = JSONResponse(
            content={
                "status": "success",
                "data": {
                    "access_token": access_token,
                    "token_type": "bearer",
                    "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
                    "user": {
                        "id": str(user.id),
                        "email": user.email,
                        "name": user.name,
                        "picture": user.picture,
                        "is_active": user.is_active,
                        "created_at": user.created_at.isoformat() if user.created_at else None
                    }
                }
            }
        )
        
        # Clear the oauth_state cookie
        response.delete_cookie(key="oauth_state")
        
        # Set the Authorization header
        response.headers["Authorization"] = f"Bearer {access_token}"
        
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in callback route: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Authentication error"
        ) 