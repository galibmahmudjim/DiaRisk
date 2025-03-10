from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.responses import RedirectResponse
from fastapi.security import OAuth2PasswordBearer
from src.core.config import settings
from src.core.database import db
from src.models.user import User, Token
from src.auth.utils import create_access_token, verify_token
from datetime import datetime, timedelta
import httpx
from typing import Optional

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")



@router.get("/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_user)):

    return current_user 