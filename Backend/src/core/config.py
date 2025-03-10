from pydantic_settings import BaseSettings
from typing import List
from functools import lru_cache

class Settings(BaseSettings):
    # Project settings
    PROJECT_NAME: str = "DiaRisk"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # MongoDB settings
    MONGODB_URL: str
    MONGODB_DB_NAME: str = "DiaRisk"
    
    # JWT settings
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Google OAuth settings
    GOOGLE_CLIENT_ID: str
    GOOGLE_CLIENT_SECRET: str
    GOOGLE_REDIRECT_URI: str = "http://localhost:8000/api/v1/auth/callback"
    
    # CORS settings
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000"]
    
    # Debug mode
    DEBUG: bool = False

    class Config:
        env_file = ".env.prod"
        case_sensitive = True
        extra = "ignore"
@lru_cache()
def get_settings() -> Settings:
    return Settings()

settings = get_settings() 