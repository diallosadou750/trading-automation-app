from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from ..database import SessionLocal
from ..models import Trade, Deposit, Withdrawal, User
from ..schemas import TradeOut, DepositOut, WithdrawalOut
from ..auth import get_current_user

router = APIRouter()

@router.get("/history", response_model=List[TradeOut])
async def get_trade_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(SessionLocal)
):
    """Récupérer l'historique des trades de l'utilisateur"""
    result = await db.execute(select(Trade).where(Trade.user_id == current_user.id))
    return result.scalars().all()

@router.get("/deposits", response_model=List[DepositOut])
async def get_deposits(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(SessionLocal)
):
    """Récupérer l'historique des dépôts de l'utilisateur"""
    result = await db.execute(select(Deposit).where(Deposit.user_id == current_user.id))
    return result.scalars().all()

@router.get("/withdrawals", response_model=List[WithdrawalOut])
async def get_withdrawals(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(SessionLocal)
):
    """Récupérer l'historique des retraits de l'utilisateur"""
    result = await db.execute(select(Withdrawal).where(Withdrawal.user_id == current_user.id))
    return result.scalars().all()

@router.post("/execute")
async def execute_trade(
    symbol: str,
    side: str,
    quantity: float,
    exchange: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(SessionLocal)
):
    """Exécuter un trade automatique (placeholder pour l'intégration exchange)"""
    # TODO: Intégrer avec les APIs des exchanges (Binance, Bybit, etc.)
    # Pour l'instant, on simule l'exécution
    trade = Trade(
        symbol=symbol,
        side=side,
        quantity=quantity,
        price=0.0,  # À récupérer depuis l'exchange
        exchange=exchange,
        user_id=current_user.id
    )
    db.add(trade)
    await db.commit()
    await db.refresh(trade)
    return {"message": "Trade exécuté", "trade_id": trade.id} 