"""Backtest simple (SL/TP en ATR, entrée à l'ouverture suivante) et classement des paires."""
import numpy as np
import pandas as pd
from .strategy import add_signals, SL_ATR, TP_ATR


def backtest(df: pd.DataFrame, cost_r: float = 0.0) -> dict:
    d = add_signals(df).reset_index(drop=True)
    trades = []  # résultats en multiples de R
    i, n = 200, len(d)
    while i < n - 2:
        s = d.signal.iloc[i]
        if s == 0 or np.isnan(d.atr.iloc[i]):
            i += 1
            continue
        entry = d.open.iloc[i + 1]
        a = d.atr.iloc[i]
        sl, tp = entry - s * SL_ATR * a, entry + s * TP_ATR * a
        r = None
        for j in range(i + 1, n):
            hi, lo = d.high.iloc[j], d.low.iloc[j]
            hit_sl = lo <= sl if s == 1 else hi >= sl
            hit_tp = hi >= tp if s == 1 else lo <= tp
            if hit_sl:  # hypothèse prudente : SL d'abord si les deux sont touchés
                r = -1.0
            elif hit_tp:
                r = TP_ATR / SL_ATR
            if r is not None:
                break
        if r is None:
            break
        r -= cost_r
        trades.append(r)
        i = j + 1
    t = np.array(trades)
    if len(t) == 0:
        return dict(trades=0, win_rate=0, expectancy_r=0, profit_factor=0, total_r=0, max_dd_r=0)
    eq = np.cumsum(t)
    gp, gl = t[t > 0].sum(), -t[t < 0].sum()
    return dict(trades=len(t), win_rate=float((t > 0).mean()), expectancy_r=float(t.mean()),
                profit_factor=float(gp / gl) if gl else float("inf"), total_r=float(eq[-1]),
                max_dd_r=float((np.maximum.accumulate(eq) - eq).max()))


def rank_pairs(data: dict, top_n: int = 3, min_trades: int = 15, cost_r: float = 0.05,
               train_frac: float = 0.7) -> pd.DataFrame:
    """Classe sur 70 % de l'historique (entraînement) et exige aussi un résultat positif sur
    les 30 % restants (hors échantillon), pour limiter le sur-ajustement. Coûts inclus."""
    rows = []
    for s, df in data.items():
        k = int(len(df) * train_frac)
        full, oos = backtest(df, cost_r), backtest(df.iloc[k - 250:].reset_index(drop=True), cost_r)
        rows.append(dict(symbol=s, **full, oos_trades=oos["trades"], oos_expectancy_r=oos["expectancy_r"]))
    r = pd.DataFrame(rows)
    if r.empty:
        return r
    ok = r[(r.trades >= min_trades) & (r.expectancy_r > 0) & (r.profit_factor > 1.2)
           & (r.oos_trades >= 3) & (r.oos_expectancy_r > 0)]
    return ok.sort_values("expectancy_r", ascending=False).head(top_n).reset_index(drop=True)
