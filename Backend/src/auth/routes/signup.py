from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
from src.core.database import db
from src.models.user import User

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@router.post("/signup", response_model=User)
async def signup(user: User):
    """
    Create a new user account.
    
    Args:
        user: User information
        
    Returns:
        User: Created user information
        
    Raises:
        HTTPException: If user already exists or creation fails
    """
    # Check if user already exists
    existing_user = await db.get_database().users.find_one({"email": user.email})
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    user_dict = user.dict()
    result = await db.get_database().users.insert_one(user_dict)
    
    # Get created user
    created_user = await db.get_database().users.find_one({"_id": result.inserted_id})
    created_user["id"] = str(created_user["_id"])
    del created_user["_id"]
    
    return User(**created_user)

@router.get("/me", response_model=User)
async def get_current_user(token: str = Depends(oauth2_scheme)):
    """
    Get the current authenticated user.
    
    Args:
        token: JWT token
        
    Returns:
        User: Current user information
        
    Raises:
        HTTPException: If token is invalid or user not found
    """
    token_data = TokenService.verify_token(token)
    if not token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user = await db.get_database().users.find_one({"email": token_data.email})
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    user["id"] = str(user["_id"])
    del user["_id"]
    return User(**user) 