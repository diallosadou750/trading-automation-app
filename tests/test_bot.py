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


def test_lot_rounding_float_safe():
    assert lot_size(10000, 0.01, 0.0014, 1.0, 0.00001, 0.01, 100, 0.01) == 0.71


def test_full_loop_with_fake_broker(capsys):
    """Boucle complète avec un faux broker : aucune connexion MT5 nécessaire."""
    from types import SimpleNamespace as NS
    from mt5bot.config import Config
    from mt5bot import bot as botmod
    from mt5bot.strategy import add_signals

    # série qui finit par un croisement haussier pour déclencher un signal
    base = fake(1500, seed=3)
    d = add_signals(base)
    idx = d.index[d.signal != 0]
    k = int(idx[-1]) + 1  # bougie clôturée = juste après le signal ; +1 bougie en cours
    series = base.iloc[: k + 1].copy()
    series["time"] = pd.date_range("2024-01-01", periods=len(series), freq="h")

    class FB:
        sent = []
        def resolve(self, s): return s
        def account(self): return NS(equity=10000, balance=10000)
        def positions(self): return []
        def rates(self, s, count=3000): return series.iloc[-count:].reset_index(drop=True)
        def symbol(self, s):
            px = float(series.close.iloc[-1])
            return (NS(trade_tick_value=1.0, trade_tick_size=1e-5, volume_min=0.01, volume_max=100, volume_step=0.01),
                    NS(ask=px + 1e-6, bid=px))
        def send(self, *a): FB.sent.append(a)

    cfg = Config(symbols=["X"], login=1, password="p", server="s")
    orig = botmod.rank_pairs
    botmod.rank_pairs = lambda data, n, cost_r=0.05: pd.DataFrame({"symbol": list(data)})
    try:
        botmod.run(cfg, broker=FB(), once=True)
    finally:
        botmod.rank_pairs = orig
    assert len(FB.sent) == 1
    sym, side, lots, sl, tp = FB.sent[0]
    assert side in (-1, 1) and lots > 0 and (sl < tp if side == 1 else sl > tp)


def test_rank_cli_loads_csv(tmp_path, capsys):
    from mt5bot.rank import load_dir
    fake(1200, seed=5).to_csv(tmp_path / "EURUSD.csv", index=False)
    (tmp_path / "bad.csv").write_text("a,b\n1,2\n")
    data = load_dir(str(tmp_path))
    assert list(data) == ["EURUSD"] and len(data["EURUSD"]) == 1200


def test_break_even_in_backtest_and_bot():
    from types import SimpleNamespace as NS
    from mt5bot.bot import break_even_target
    a, b = backtest(fake(4000, seed=7), 0.05, be_r=None), backtest(fake(4000, seed=7), 0.05, be_r=1.0)
    assert a["trades"] > 0 and b["trades"] > 0
    buy = NS(type=0, price_open=1.1000, sl=1.0985, tp=1.1045)
    assert break_even_target(buy, bid=1.1014, ask=1.1015, be_r=1.0) is None          # < 1R
    assert break_even_target(buy, bid=1.1016, ask=1.1017, be_r=1.0) == 1.1000        # >= 1R
    assert break_even_target(NS(type=0, price_open=1.1, sl=1.1, tp=1.2), 1.2, 1.2, be_r=1.0) is None  # déjà au BE
    sell = NS(type=1, price_open=1.1000, sl=1.1015, tp=1.0955)
    assert break_even_target(sell, bid=1.0983, ask=1.0984, be_r=1.0) == 1.1000


def test_detect_terminal(tmp_path):
    from mt5bot.detect import find_terminal, find_terminals
    old = tmp_path / "MetaTrader 5 Old"; new = tmp_path / "MetaTrader 5 EXNESS"
    for d in (old, new):
        d.mkdir(); (d / "terminal64.exe").write_text("x")
    import os; os.utime(old / "terminal64.exe", (1, 1))
    env = {"PROGRAMFILES": str(tmp_path)}
    assert find_terminal(env) == str(new / "terminal64.exe")          # le plus récent d'abord
    assert len(find_terminals(env)) == 2
    env["MT5_PATH"] = str(old / "terminal64.exe")
    assert find_terminal(env) == str(old / "terminal64.exe")          # chemin explicite prioritaire
    assert find_terminal({}) is None or isinstance(find_terminal({}), str)


def test_validate_allows_no_credentials():
    from mt5bot.config import Config
    Config(login=0, password="", server="").validate()
    import pytest
    with pytest.raises(ValueError):
        Config(login=5, password="", server="").validate()
