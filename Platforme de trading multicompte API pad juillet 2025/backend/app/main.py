from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import users, api_keys, trading

app = FastAPI(
    title="Trading Automatique API",
    description="API pour application de trading automatique multi-plateforme",
    version="1.0.0"
)

# Configuration CORS pour le frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # À configurer selon l'environnement
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclusion des routeurs
app.include_router(users.router, prefix="/users", tags=["users"])
app.include_router(api_keys.router, prefix="/api-keys", tags=["api-keys"])
app.include_router(trading.router, prefix="/trading", tags=["trading"])

@app.get("/")
def read_root():
    return {
        "message": "Bienvenue sur l'API de trading automatique !",
        "version": "1.0.0",
        "docs": "/docs"
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"} 