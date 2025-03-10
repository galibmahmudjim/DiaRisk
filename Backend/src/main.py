from src.core.config import settings
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi import Request
from fastapi.openapi.utils import get_openapi
from src.auth.utils import security

from src.core.database import db
from src.auth.routes.login import router as login_router
from src.auth.routes.signup import router as signup_router
from src.api.health_data import router as health_router
import os

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    swagger_ui_parameters={"persistAuthorization": True}
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        description="DiaRisk API with Bearer token authentication",
        routes=app.routes,
    )

    # Add Bearer Auth security scheme
    openapi_schema["components"] = {
        "securitySchemes": {
            "Authorization": {
                "type": "http",
                "scheme": "bearer"
            }
        }
    }

    # Apply security globally to all routes
    openapi_schema["security"] = [{"Authorization": []}]

    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi

# Templates
templates = Jinja2Templates(directory="templates")

# Include routers
app.include_router(
    login_router,
    prefix=f"{settings.API_V1_STR}/auth",
    tags=["auth"]
)
app.include_router(
    signup_router,
    prefix=f"{settings.API_V1_STR}/auth",
    tags=["auth"]
)
app.include_router(
    health_router,
    prefix=f"{settings.API_V1_STR}/health",
    tags=["health"],
    dependencies=[Depends(security)]
)

@app.on_event("startup")
async def startup_event():
    await db.connect_to_database()

@app.on_event("shutdown")
async def shutdown_event():
    await db.close_database_connection()

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    ) 