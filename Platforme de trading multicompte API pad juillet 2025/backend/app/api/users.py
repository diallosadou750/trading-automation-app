from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from ..database import SessionLocal
from ..models import User
from ..schemas import UserCreate, UserOut
from ..auth import create_user, authenticate_user, create_access_token, get_current_user

router = APIRouter()

@router.post("/register", response_model=UserOut)
async def register(user: UserCreate, db: AsyncSession = Depends(SessionLocal)):
    """Créer un nouveau compte utilisateur"""
    if not user.password:
        raise HTTPException(status_code=400, detail="Password is required for registration")
    
    db_user = await create_user(user, db)
    return db_user

@router.post("/login")
async def login(email: str, password: str, db: AsyncSession = Depends(SessionLocal)):
    """Connexion utilisateur avec email et mot de passe"""
    user = await authenticate_user(email, password, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=UserOut)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Récupérer les informations de l'utilisateur connecté"""
    return current_user 