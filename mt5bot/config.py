import os
from dataclasses import dataclass, field


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

    @property
    def live(self) -> bool:
        return self.mode == "live" and self.confirm_live == "YES_I_ACCEPT_REAL_MONEY_RISK"
