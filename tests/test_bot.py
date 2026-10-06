import numpy as np
import pandas as pd
from mt5bot.strategy import add_signals
from mt5bot.backtest import backtest, rank_pairs
from mt5bot.risk import lot_size, daily_loss_hit


def fake(n=3000, seed=1):
    rng = np.random.default_rng(seed)
    c = 1.1 + np.cumsum(rng.normal(0, 0.001, n))
    return pd.DataFrame(dict(open=np.r_[c[0], c[:-1]], high=c + 0.0006, low=c - 0.0006, close=c))


def test_signals_and_backtest():
    d = add_signals(fake())
    assert set(d.signal.unique()) <= {-1, 0, 1}
    r = backtest(fake())
    assert r["trades"] > 0 and r["max_dd_r"] >= 0


def test_rank_filters_unprofitable():
    out = rank_pairs({"A": fake(seed=1), "B": fake(seed=2)}, top_n=2)
    assert all(out.expectancy_r > 0)


def test_lot_size_and_daily_loss():
    assert lot_size(10000, 0.01, 0.0015, 1.0, 0.00001, 0.01, 100, 0.01) == 0.66
    assert lot_size(10000, 0.01, 0, 1, 1e-5, 0.01, 100, 0.01) == 0
    assert daily_loss_hit(10000, 9690, 0.03) and not daily_loss_hit(10000, 9800, 0.03)
