"""Couche MT5 (import paresseux : la librairie n'existe que sous Windows)."""
import pandas as pd
from .config import Config

TF = {"M5": "TIMEFRAME_M5", "M15": "TIMEFRAME_M15", "M30": "TIMEFRAME_M30",
      "H1": "TIMEFRAME_H1", "H4": "TIMEFRAME_H4", "D1": "TIMEFRAME_D1"}


class Broker:
    def __init__(self, cfg: Config):
        import MetaTrader5 as mt5
        self.mt5, self.cfg = mt5, cfg
        kw = dict(login=cfg.login, password=cfg.password, server=cfg.server)
        if cfg.path:
            kw["path"] = cfg.path
        if not mt5.initialize(**kw):
            raise RuntimeError(f"Connexion MT5 impossible : {mt5.last_error()}")
        acc = mt5.account_info()
        is_real = acc.trade_mode == mt5.ACCOUNT_TRADE_MODE_REAL
        if is_real and not cfg.live:
            print("Compte RÉEL détecté mais mode live non confirmé : aucun ordre ne sera envoyé.")
        self.dry_run = not cfg.live
        print(f"Connecté : {acc.login} @ {acc.server} ({'RÉEL' if is_real else 'démo'}) "
              f"solde={acc.balance} {acc.currency} | ordres {'SIMULÉS' if self.dry_run else 'RÉELS'}")

    def rates(self, symbol, count=3000) -> pd.DataFrame:
        self.mt5.symbol_select(symbol, True)
        r = self.mt5.copy_rates_from_pos(symbol, getattr(self.mt5, TF[self.cfg.timeframe]), 0, count)
        if r is None or len(r) == 0:
            return pd.DataFrame()
        df = pd.DataFrame(r)
        df["time"] = pd.to_datetime(df["time"], unit="s")
        return df

    def account(self):
        return self.mt5.account_info()

    def positions(self):
        return [p for p in (self.mt5.positions_get() or []) if p.magic == self.cfg.magic]

    def symbol(self, s):
        return self.mt5.symbol_info(s), self.mt5.symbol_info_tick(s)

    def send(self, symbol, side, lots, sl, tp):
        info, tick = self.symbol(symbol)
        price = tick.ask if side == 1 else tick.bid
        req = dict(action=self.mt5.TRADE_ACTION_DEAL, symbol=symbol, volume=lots,
                   type=self.mt5.ORDER_TYPE_BUY if side == 1 else self.mt5.ORDER_TYPE_SELL,
                   price=price, sl=round(sl, info.digits), tp=round(tp, info.digits), deviation=20,
                   magic=self.cfg.magic, comment="mt5bot", type_time=self.mt5.ORDER_TIME_GTC,
                   type_filling=self.mt5.ORDER_FILLING_IOC)
        if self.dry_run:
            print(f"[SIMULATION] {symbol} {'BUY' if side == 1 else 'SELL'} {lots} @ {price} sl={sl} tp={tp}")
            return None
        res = self.mt5.order_send(req)
        print(f"[ORDRE] {symbol} -> retcode={res.retcode} {res.comment}")
        return res
