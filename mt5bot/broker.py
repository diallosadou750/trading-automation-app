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
        self.dry_run = not cfg.live
        if not self.dry_run and not mt5.terminal_info().trade_allowed:
            raise RuntimeError("Active le bouton « Algo Trading » dans MT5 (trading automatique désactivé).")
        if is_real and self.dry_run:
            print("Compte RÉEL détecté mais mode live non confirmé : aucun ordre ne sera envoyé.")
        print(f"Connecté : {acc.login} @ {acc.server} ({'RÉEL' if is_real else 'démo'}) "
              f"solde={acc.balance} {acc.currency} | ordres {'SIMULÉS' if self.dry_run else 'RÉELS'}")

    def resolve(self, name):
        """Trouve le symbole du broker (suffixes type EURUSD.m, EURUSDm, EURUSD#)."""
        if self.mt5.symbol_info(name):
            return name
        for s in self.mt5.symbols_get() or []:
            if s.name.startswith(name) and len(s.name) <= len(name) + 3:
                return s.name
        return None

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

    def _filling(self, info):
        m = info.filling_mode  # bitmask : 1 = FOK, 2 = IOC
        if m & 2:
            return self.mt5.ORDER_FILLING_IOC
        if m & 1:
            return self.mt5.ORDER_FILLING_FOK
        return self.mt5.ORDER_FILLING_RETURN

    def send(self, symbol, side, lots, sl, tp):
        info, tick = self.symbol(symbol)
        if info is None or tick is None or not info.trade_mode == self.mt5.SYMBOL_TRADE_MODE_FULL:
            print(f"[SKIP] {symbol} : marché fermé ou trading indisponible")
            return None
        price = tick.ask if side == 1 else tick.bid
        sl, tp = round(sl, info.digits), round(tp, info.digits)
        side_txt = "BUY" if side == 1 else "SELL"
        if self.dry_run:
            print(f"[SIMULATION] {symbol} {side_txt} {lots} @ {price} sl={sl} tp={tp}")
            return None
        req = dict(action=self.mt5.TRADE_ACTION_DEAL, symbol=symbol, volume=lots,
                   type=self.mt5.ORDER_TYPE_BUY if side == 1 else self.mt5.ORDER_TYPE_SELL,
                   price=price, sl=sl, tp=tp, deviation=20, magic=self.cfg.magic, comment="mt5bot",
                   type_time=self.mt5.ORDER_TIME_GTC, type_filling=self._filling(info))
        res = self.mt5.order_send(req)
        ok = res is not None and res.retcode == self.mt5.TRADE_RETCODE_DONE
        print(f"[ORDRE {'OK' if ok else 'ÉCHEC'}] {symbol} {side_txt} {lots} -> "
              f"{getattr(res, 'retcode', None)} {getattr(res, 'comment', '')}")
        return res if ok else None

    def move_sl(self, pos, new_sl):
        info, _ = self.symbol(pos.symbol)
        new_sl = round(new_sl, info.digits)
        if self.dry_run:
            print(f"[SIMULATION] {pos.symbol} SL -> {new_sl} (break-even)")
            return True
        res = self.mt5.order_send(dict(action=self.mt5.TRADE_ACTION_SLTP, position=pos.ticket,
                                       symbol=pos.symbol, sl=new_sl, tp=pos.tp, magic=self.cfg.magic))
        ok = res is not None and res.retcode == self.mt5.TRADE_RETCODE_DONE
        print(f"[BREAK-EVEN {'OK' if ok else 'ÉCHEC'}] {pos.symbol} -> {getattr(res, 'retcode', None)}")
        return ok
