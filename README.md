# trading-automation-app
Application de trading automatique multi-plateforme


## Robot MT5 automatique (`mt5bot/`)

Tourne **sur ta machine Windows** où MT5 est installé et connecté.

```
pip install -r requirements.txt
copy .env.example .env      # renseigne MT5_LOGIN / MT5_PASSWORD / MT5_SERVER (le .env est lu automatiquement)
python -m mt5bot.bot        # boucle automatique
```

Fonctionnement : chaque jour il backteste les paires de `SYMBOLS` (EMA20/50 + filtre EMA200 + RSI, SL 1.5 ATR / TP 3 ATR),
ne garde que celles à espérance positive et profit factor > 1.2 (top `TOP_N_PAIRS`), puis trade chaque nouvelle bougie clôturée.

Sécurité : `BOT_MODE=demo` par défaut (ordres simulés). Le réel exige `BOT_MODE=live` **et**
`CONFIRM_LIVE=YES_I_ACCEPT_REAL_MONEY_RISK`. Risque 1 %/trade, arrêt à -3 %/jour, 3 positions max.
Les résultats de backtest ne garantissent aucun gain futur : teste d'abord en démo plusieurs semaines.

Garde-fous supplémentaires : classement validé hors échantillon (70 % entraînement / 30 % test) avec coûts inclus,
filtre de spread, détection des suffixes de symboles du broker (`EURUSD.m`), mode de remplissage adapté au symbole,
vérification du bouton « Algo Trading » en mode live, contrôle du retour de chaque ordre.
Tests : `python -m pytest` (aucune connexion MT5 requise).

### Valider les paires hors connexion
Exporte tes barres en CSV (colonnes open, high, low, close), un fichier par symbole (`EURUSD.csv`), puis :
```
python -m mt5bot.rank dossier_csv --top 3
```
Une CI GitHub (`.github/workflows/tests.yml`) lance les tests à chaque push.

### Break-even (optionnel)
`BREAK_EVEN_R=1.0` déplace le stop à l'entrée une fois +1R atteint (modélisé aussi dans le backtest).
Désactivé par défaut : sur mes données de test il a réduit l'espérance. Compare avec `mt5bot.rank` sur ton historique avant de l'activer.

### Détection automatique de MT5
Le robot trouve seul le terminal MT5 (Program Files, AppData, lecteurs C: à F:) et, si `MT5_LOGIN` est vide,
se rattache au compte déjà connecté dans MT5 : aucun identifiant à écrire. Ouvre MT5, connecte-toi à un compte
**démo**, active « Algo Trading », puis lance `python -m mt5bot.bot`.
