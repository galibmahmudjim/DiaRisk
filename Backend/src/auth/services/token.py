from datetime import datetime, timedelta, UTC
from typing import Optional
from jose import JWTError, jwt
from fastapi import HTTPException, status
from src.core.config import settings
from src.models.user import TokenData, User
import secrets

class TokenService:
    @staticmethod
    def create_access_token(email: str, expires_delta: Optional[timedelta] = None) -> str:
        to_encode = {"sub": email}
        
        if expires_delta:
            expire = datetime.now(UTC) + expires_delta
        else:
            expire = datetime.now(UTC) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
            
        to_encode.update({"exp": expire.timestamp()})
        
        try:
            encoded_jwt = jwt.encode(
                to_encode,
                settings.SECRET_KEY,
                algorithm=settings.ALGORITHM
            )
            return encoded_jwt
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Could not create access token: {str(e)}"
            )
    
    @staticmethod
    def verify_token(token: str) -> TokenData:
        try:
            # Decode JWT token
            payload = jwt.decode(
                token,
                settings.SECRET_KEY,
                algorithms=[settings.ALGORITHM]
            )
            
            # Extract email from token
            email: str = payload.get("sub")
            if email is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token format"
                )
                
            # Extract expiration time
            exp: datetime = datetime.fromtimestamp(payload.get("exp"), tz=UTC)
            if datetime.now(UTC) >= exp:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token has expired",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            
            return TokenData(email=email, exp=exp)
            
        except JWTError as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid token: {str(e)}",
                headers={"WWW-Authenticate": "Bearer"},
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error verifying token: {str(e)}"
            )

    @staticmethod
    def create_state_token() -> str:

        return secrets.token_urlsafe(32) 