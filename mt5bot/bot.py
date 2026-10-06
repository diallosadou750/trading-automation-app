"""Boucle automatique : classe les paires, puis trade les plus rentables à chaque nouvelle bougie."""
import argparse
import time
from datetime import date

from .config import Config
from .strategy import add_signals, SL_ATR, TP_ATR
from .backtest import rank_pairs
from .risk import lot_size, daily_loss_hit


def run(cfg: Config, once=False):
    from .broker import Broker
    b = Broker(cfg)
    last_bar, ranked_day, best, day_equity, day = {}, None, [], None, None
    while True:
        today = date.today()
        if day != today:
            day, day_equity = today, b.account().equity
        if ranked_day != today:  # reclassement quotidien automatique
            data = {s: b.rates(s) for s in cfg.symbols}
            ranking = rank_pairs({s: d for s, d in data.items() if len(d) > 300}, cfg.top_n)
            print("Paires retenues :\n", ranking.to_string() if len(ranking) else "aucune (aucun trade)")
            best, ranked_day = list(ranking.symbol) if len(ranking) else [], today
        acc = b.account()
        if daily_loss_hit(day_equity, acc.equity, cfg.max_daily_loss):
            print("Perte journalière max atteinte : pause jusqu'à demain.")
        else:
            held = {p.symbol for p in b.positions()}
            for s in best:
                if s in held or len(held) >= cfg.max_open_positions:
                    continue
                df = b.rates(s, 400)
                if len(df) < 250:
                    continue
                bar = df.time.iloc[-2]  # dernière bougie clôturée
                if last_bar.get(s) == bar:
                    continue
                last_bar[s] = bar
                d = add_signals(df.iloc[:-1])
                sig = int(d.signal.iloc[-1])
                if sig == 0:
                    continue
                info, tick = b.symbol(s)
                a = d.atr.iloc[-1]
                price = tick.ask if sig == 1 else tick.bid
                sl, tp = price - sig * SL_ATR * a, price + sig * TP_ATR * a
                lots = lot_size(acc.balance, cfg.risk_per_trade, SL_ATR * a, info.trade_tick_value,
                                info.trade_tick_size, info.volume_min, info.volume_max, info.volume_step)
                if lots > 0:
                    b.send(s, sig, lots, sl, tp)
                    held.add(s)
        if once:
            return
        time.sleep(30)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--once", action="store_true")
    a = p.parse_args()
    run(Config(), once=a.once)


if __name__ == "__main__":
    main()
