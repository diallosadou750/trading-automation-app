import os
from dataclasses import dataclass, field


def load_env(path=".env"):
    """Charge .env (sans dépendance) sans écraser les variables déjà définies."""
    if not os.path.exists(path):
        return
    for line in open(path, encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip().strip('"\''))


load_env()


def _f(name, default):
    return float(os.getenv(name, default))


@dataclass
class Config:
    login: int = int(os.getenv("MT5_LOGIN", "0") or 0)
    password: str = os.getenv("MT5_PASSWORD", "")
    server: str = os.getenv("MT5_SERVER", "")
    path: str = os.getenv("MT5_PATH", "")
    mode: str = os.getenv("BOT_MODE", "demo").lower()
    confirm_live: str = os.getenv("CONFIRM_LIVE", "")
    timeframe: str = os.getenv("TIMEFRAME", "H1")
    risk_per_trade: float = _f("RISK_PER_TRADE", 0.01)
    max_daily_loss: float = _f("MAX_DAILY_LOSS", 0.03)
    max_open_positions: int = int(os.getenv("MAX_OPEN_POSITIONS", "3"))
    top_n: int = int(os.getenv("TOP_N_PAIRS", "3"))
    symbols: list = field(default_factory=lambda: [
        s.strip() for s in os.getenv(
            "SYMBOLS", "EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD,USDCHF,NZDUSD,EURJPY,GBPJPY,XAUUSD"
        ).split(",") if s.strip()])
    magic: int = 20260601
    max_spread_atr: float = _f("MAX_SPREAD_ATR", 0.2)  # spread max = 20 % de l'ATR
    cost_r: float = _f("BACKTEST_COST_R", 0.05)  # coût (spread/slippage) en R par trade
    poll_seconds: int = int(os.getenv("POLL_SECONDS", "30"))

    @property
    def live(self) -> bool:
        return self.mode == "live" and self.confirm_live == "YES_I_ACCEPT_REAL_MONEY_RISK"

    def validate(self):
        from .broker import TF
        if self.timeframe not in TF:
            raise ValueError(f"TIMEFRAME invalide : {self.timeframe} (choix : {', '.join(TF)})")
        if not 0 < self.risk_per_trade <= 0.05:
            raise ValueError("RISK_PER_TRADE doit être entre 0 et 0.05")
        if self.mode not in ("demo", "live"):
            raise ValueError("BOT_MODE doit valoir demo ou live")
        if self.login and not (self.password and self.server):
            raise ValueError("MT5_LOGIN renseigné : MT5_PASSWORD et MT5_SERVER sont aussi requis "
                             "(ou laisse les trois vides pour utiliser le compte déjà connecté dans MT5)")
