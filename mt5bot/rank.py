"""Classement hors connexion : `python -m mt5bot.rank dossier_csv [--top N]`.

Chaque fichier <SYMBOLE>.csv doit contenir les colonnes open, high, low, close
(export MT5 : Affichage > Symboles > Barres, ou n'importe quelle source OHLC)."""
import argparse
import glob
import os

import pandas as pd

from .backtest import rank_pairs, backtest


def load_dir(folder):
    data = {}
    for f in sorted(glob.glob(os.path.join(folder, "*.csv"))):
        df = pd.read_csv(f, sep=None, engine="python")
        df.columns = [c.strip().strip("<>").lower() for c in df.columns]
        if {"open", "high", "low", "close"} <= set(df.columns):
            data[os.path.splitext(os.path.basename(f))[0]] = df.reset_index(drop=True)
        else:
            print(f"Ignoré (colonnes OHLC manquantes) : {f}")
    return data


def main():
    p = argparse.ArgumentParser(description="Classe les paires à partir de fichiers CSV")
    p.add_argument("folder")
    p.add_argument("--top", type=int, default=3)
    p.add_argument("--cost-r", type=float, default=0.05)
    a = p.parse_args()
    data = {s: d for s, d in load_dir(a.folder).items() if len(d) > 600}
    if not data:
        raise SystemExit("Aucun CSV exploitable (600 barres minimum par fichier).")
    print("Toutes les paires :")
    print(pd.DataFrame([dict(symbol=s, **backtest(d, a.cost_r)) for s, d in data.items()]).round(3).to_string())
    r = rank_pairs(data, a.top, cost_r=a.cost_r)
    print("\nRetenues :\n", r.round(3).to_string() if len(r) else "aucune")


if __name__ == "__main__":
    main()
