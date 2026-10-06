"""Stratégie : croisement EMA rapide/lente, filtre de tendance EMA200 et RSI, stops en ATR."""
import os

import numpy as np
import pandas as pd

FAST, SLOW, TREND, RSI_N, ATR_N = 20, 50, 200, 14, 14
SL_ATR, TP_ATR = 1.5, 3.0
# Break-even optionnel (BREAK_EVEN_R=1.0 dans .env) : le SL passe à l'entrée quand le gain atteint BE_R x le risque.
# Désactivé par défaut : il n'a pas montré d'avantage en test. Backtest et robot utilisent la même valeur.
BE_R = float(os.getenv("BREAK_EVEN_R", "0") or 0) or None


def rsi(close: pd.Series, n: int = RSI_N) -> pd.Series:
    d = close.diff()
    up = d.clip(lower=0).ewm(alpha=1 / n, adjust=False).mean()
    dn = (-d.clip(upper=0)).ewm(alpha=1 / n, adjust=False).mean()
    return 100 - 100 / (1 + up / dn.replace(0, np.nan))


def atr(df: pd.DataFrame, n: int = ATR_N) -> pd.Series:
    pc = df["close"].shift()
    tr = pd.concat([df["high"] - df["low"], (df["high"] - pc).abs(), (df["low"] - pc).abs()], axis=1).max(axis=1)
    return tr.ewm(alpha=1 / n, adjust=False).mean()


def add_signals(df: pd.DataFrame) -> pd.DataFrame:
    """Ajoute la colonne `signal` (+1 achat, -1 vente, 0 rien) sur la bougie clôturée."""
    df = df.copy()
    c = df["close"]
    df["ema_f"], df["ema_s"], df["ema_t"] = (c.ewm(span=s, adjust=False).mean() for s in (FAST, SLOW, TREND))
    df["rsi"] = rsi(c)
    df["atr"] = atr(df)
    up = (df.ema_f > df.ema_s) & (df.ema_f.shift() <= df.ema_s.shift())
    dn = (df.ema_f < df.ema_s) & (df.ema_f.shift() >= df.ema_s.shift())
    df["signal"] = 0
    df.loc[up & (c > df.ema_t) & (df.rsi > 50) & (df.rsi < 75), "signal"] = 1
    df.loc[dn & (c < df.ema_t) & (df.rsi < 50) & (df.rsi > 25), "signal"] = -1
    return df
