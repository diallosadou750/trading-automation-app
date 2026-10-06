# trading-automation-app
Application de trading automatique multi-plateforme


## Robot MT5 automatique (`mt5bot/`)

Tourne **sur ta machine Windows** où MT5 est installé et connecté.

```
pip install -r requirements.txt
copy .env.example .env      # renseigne MT5_LOGIN / MT5_PASSWORD / MT5_SERVER, puis charge les variables
python -m mt5bot.bot        # boucle automatique
```

Fonctionnement : chaque jour il backteste les paires de `SYMBOLS` (EMA20/50 + filtre EMA200 + RSI, SL 1.5 ATR / TP 3 ATR),
ne garde que celles à espérance positive et profit factor > 1.2 (top `TOP_N_PAIRS`), puis trade chaque nouvelle bougie clôturée.

Sécurité : `BOT_MODE=demo` par défaut (ordres simulés). Le réel exige `BOT_MODE=live` **et**
`CONFIRM_LIVE=YES_I_ACCEPT_REAL_MONEY_RISK`. Risque 1 %/trade, arrêt à -3 %/jour, 3 positions max.
Les résultats de backtest ne garantissent aucun gain futur : teste d'abord en démo plusieurs semaines.
