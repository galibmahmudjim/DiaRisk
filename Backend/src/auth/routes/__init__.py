from fastapi import APIRouter
from src.auth.routes.login import router as login_router
from src.auth.routes.signup import router as signup_router

router = APIRouter()

router.include_router(login_router, tags=["auth"])
router.include_router(signup_router, tags=["auth"]) 