from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserCreate(BaseModel):
    email: EmailStr
    password: Optional[str] = None

class UserOut(BaseModel):
    id: int
    email: EmailStr
    is_admin: bool
    created_at: datetime
    class Config:
        orm_mode = True

class APIKeyCreate(BaseModel):
    exchange: str
    key: str
    secret: str

class APIKeyOut(BaseModel):
    id: int
    exchange: str
    created_at: datetime
    class Config:
        orm_mode = True

class TradeOut(BaseModel):
    id: int
    symbol: str
    side: str
    quantity: float
    price: float
    pnl: Optional[float]
    strategy: Optional[str]
    timestamp: datetime
    exchange: str
    class Config:
        orm_mode = True

class DepositOut(BaseModel):
    id: int
    amount: float
    currency: str
    status: str
    tx_id: Optional[str]
    exchange: str
    created_at: datetime
    class Config:
        orm_mode = True

class WithdrawalOut(BaseModel):
    id: int
    amount: float
    currency: str
    status: str
    tx_id: Optional[str]
    exchange: str
    created_at: datetime
    class Config:
        orm_mode = True

class AlertOut(BaseModel):
    id: int
    channel: str
    message: str
    sent: bool
    created_at: datetime
    class Config:
        orm_mode = True 