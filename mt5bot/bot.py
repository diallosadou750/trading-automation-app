"""Boucle automatique : classe les paires, puis trade les plus rentables à chaque nouvelle bougie."""
import argparse
import time
from datetime import date

from .config import Config
from .strategy import add_signals, SL_ATR, TP_ATR, BE_R
from .backtest import rank_pairs
from .risk import lot_size, daily_loss_hit


def break_even_target(pos, bid, ask, be_r=BE_R):
    """Nouveau SL (prix d'entrée) si le gain a atteint be_r x le risque initial, sinon None."""
    buy = pos.type == 0
    risk = abs(pos.price_open - pos.sl) if pos.sl else 0
    if not be_r or risk <= 0:
        return None
    already = pos.sl >= pos.price_open if buy else pos.sl <= pos.price_open
    gain = (bid - pos.price_open) if buy else (pos.price_open - ask)
    return pos.price_open if (not already and gain >= be_r * risk) else None


def run(cfg: Config, broker=None, once=False, sleep=time.sleep):
    b = broker
    if b is None:
        from .broker import Broker
        cfg.validate()
        b = Broker(cfg)
    names = {}
    for s in cfg.symbols:
        real = b.resolve(s) if hasattr(b, "resolve") else s
        if real:
            names[real] = s
        else:
            print(f"Symbole introuvable chez ce broker, ignoré : {s}")
    last_bar, ranked_day, best, day_equity, day = {}, None, [], None, None
    while True:
        today = date.today()
        if day != today:
            day, day_equity = today, b.account().equity
        if ranked_day != today:  # reclassement quotidien automatique
            data = {s: b.rates(s)[:-1] for s in names}  # on retire la bougie en cours
            data = {s: d.reset_index(drop=True) for s, d in data.items() if len(d) > 600}
            ranking = rank_pairs(data, cfg.top_n, cost_r=cfg.cost_r)
            print("Paires retenues :\n", ranking.round(3).to_string() if len(ranking) else "aucune (aucun trade)")
            best, ranked_day = list(ranking.symbol) if len(ranking) else [], today
        acc = b.account()
        if daily_loss_hit(day_equity, acc.equity, cfg.max_daily_loss):
            print("Perte journalière max atteinte : pause jusqu'à demain.")
        else:
            positions = b.positions()
            held = {p.symbol for p in positions}
            for pos in positions:
                _, tick = b.symbol(pos.symbol)
                target = break_even_target(pos, tick.bid, tick.ask) if tick else None
                if target is not None and hasattr(b, "move_sl"):
                    b.move_sl(pos, target)
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
                if info is None or tick is None:
                    continue
                a = d.atr.iloc[-1]
                if (tick.ask - tick.bid) > cfg.max_spread_atr * a:
                    print(f"[SKIP] {s} : spread trop large")
                    continue
                price = tick.ask if sig == 1 else tick.bid
                sl, tp = price - sig * SL_ATR * a, price + sig * TP_ATR * a
                lots = lot_size(acc.balance, cfg.risk_per_trade, SL_ATR * a, info.trade_tick_value,
                                info.trade_tick_size, info.volume_min, info.volume_max, info.volume_step)
                if lots > 0:
                    b.send(s, sig, lots, sl, tp)
                    held.add(s)
        if once:
            return
        sleep(cfg.poll_seconds)


def main():
    p = argparse.ArgumentParser(description="Robot MT5 automatique")
    p.add_argument("--once", action="store_true", help="un seul passage puis arrêt")
    a = p.parse_args()
    try:
        run(Config(), once=a.once)
    except KeyboardInterrupt:
        print("Arrêt demandé.")


if __name__ == "__main__":
    main()
