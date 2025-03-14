from fastapi import APIRouter, HTTPException, status
from src.core.database import db
from src.models.user import User

router = APIRouter()

@router.post("/signup", response_model=User)
async def signup(user: User):

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