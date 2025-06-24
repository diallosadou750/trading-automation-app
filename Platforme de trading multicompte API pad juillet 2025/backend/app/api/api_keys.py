from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from ..database import SessionLocal
from ..models import APIKey, User
from ..schemas import APIKeyCreate, APIKeyOut
from ..auth import get_current_user
from ..utils.crypto import encrypt_api_key

router = APIRouter()

@router.post("/", response_model=APIKeyOut)
async def add_api_key(
    api_key: APIKeyCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(SessionLocal)
):
    """Ajouter une nouvelle clé API (chiffrée)"""
    encrypted_key = encrypt_api_key(api_key.key)
    encrypted_secret = encrypt_api_key(api_key.secret)
    
    db_api_key = APIKey(
        exchange=api_key.exchange,
        encrypted_key=encrypted_key,
        encrypted_secret=encrypted_secret,
        user_id=current_user.id
    )
    db.add(db_api_key)
    await db.commit()
    await db.refresh(db_api_key)
    return db_api_key

@router.get("/", response_model=List[APIKeyOut])
async def list_api_keys(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(SessionLocal)
):
    """Lister toutes les clés API de l'utilisateur connecté"""
    result = await db.execute(select(APIKey).where(APIKey.user_id == current_user.id))
    return result.scalars().all()

@router.delete("/{api_key_id}")
async def delete_api_key(
    api_key_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(SessionLocal)
):
    """Supprimer une clé API"""
    result = await db.execute(select(APIKey).where(APIKey.id == api_key_id, APIKey.user_id == current_user.id))
    api_key = result.scalar_one_or_none()
    
    if not api_key:
        raise HTTPException(status_code=404, detail="Clé API non trouvée")
    
    await db.delete(api_key)
    await db.commit()
    return {"message": "Clé API supprimée avec succès"} 