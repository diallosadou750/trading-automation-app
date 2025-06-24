# 🚀 Application de Trading Automatique Multi-Plateforme

Une application de trading automatique professionnelle, accessible depuis PC, mobile et tablette, avec interface responsive universelle.

## 🚀 Quick Start

### Installation rapide (5 minutes)

```bash
# 1. Cloner le projet
git clone https://github.com/VOTRE_USERNAME/trading-automation-app.git
cd trading-automation-app

# 2. Configuration
cp backend/env.example backend/.env
# Modifier backend/.env avec vos configurations (optionnel pour les tests)

# 3. Lancer avec Docker
docker-compose up --build
```

### Accès immédiat

- **Frontend** : <http://localhost:80>
- **Backend API** : <http://localhost:8000>
- **Documentation API** : <http://localhost:8000/docs>

### Test rapide

1. Ouvrez <http://localhost:80>
2. Créez un compte de test
3. Testez l'ajout d'une clé API
4. Explorez le dashboard

---

## 📋 Fonctionnalités

### 🔐 Authentification sécurisée

- Création de compte utilisateur sécurisé
- Authentification par email + mot de passe
- Google OAuth 2.0 (préparé)
- Gestion des sessions avec JWT

### 🔑 Gestion dynamique des clés API

- Espace paramétrable pour ajouter/modifier/supprimer les clés API
- Support multi-exchange : Binance, Bybit, Hyperliquid, KuCoin, etc.
- Stockage sécurisé avec chiffrement AES-256

### 📊 Analyse et exécution automatique

- Scanner les marchés en temps réel
- Détection d'opportunités (RSI, EMA, VWAP, price action)
- Exécution automatique des ordres
- Réajustement dynamique SL/TP
- Optimisation profit/pertes

### 🧠 Intelligence adaptative

- Connexion multi-plateformes
- Adaptation automatique selon chaque exchange
- Historique complet avec logs, timestamps, PnL

### 🖥️ Interface responsive

- Accessible sur PC, mobile, tablette
- Design moderne et professionnel
- Navigation fluide et intuitive

## 🏗️ Architecture

```
trading-app/
├── backend/                 # API FastAPI (Python)
│   ├── app/
│   │   ├── main.py         # Point d'entrée
│   │   ├── models.py       # Modèles SQLAlchemy
│   │   ├── schemas.py      # Schémas Pydantic
│   │   ├── auth.py         # Authentification
│   │   ├── api/            # Endpoints
│   │   └── utils/          # Utilitaires
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/               # Application Flutter
│   ├── lib/
│   │   ├── main.dart       # Point d'entrée
│   │   ├── screens/        # Écrans
│   │   ├── providers/      # Gestion d'état
│   │   └── services/       # Services API
│   ├── pubspec.yaml
│   └── Dockerfile
├── db/                     # Scripts base de données
├── docker-compose.yml      # Orchestration Docker
└── README.md
```

## 🚀 Installation et Démarrage

### Prérequis

- Docker et Docker Compose
- Git

### 1. Cloner le projet

```bash
git clone <url-du-repo>
cd trading-app
```

### 2. Configuration

```bash
# Copier le fichier d'environnement
cp backend/env.example backend/.env

# Modifier les variables dans backend/.env
# - DATABASE_URL
# - SECRET_KEY
# - API_AES_SECRET
# - Configuration Firebase (pour Google OAuth)
```

### 3. Lancement avec Docker

```bash
# Construire et démarrer tous les services
docker-compose up --build

# Ou en arrière-plan
docker-compose up -d --build
```

### 4. Accès à l'application

- **Frontend** : <http://localhost:80>
- **Backend API** : <http://localhost:8000>
- **Documentation API** : <http://localhost:8000/docs>
- **Nginx (optionnel)** : <http://localhost:8080>

## 📱 Utilisation

### 1. Création de compte

- Accédez à l'application via votre navigateur
- Cliquez sur "S'inscrire"
- Remplissez vos informations (email, mot de passe)

### 2. Configuration des clés API

- Connectez-vous à votre compte
- Allez dans "Gérer les clés API"
- Ajoutez vos clés API pour chaque exchange
- Les clés sont automatiquement chiffrées

### 3. Monitoring et trading

- Consultez votre dashboard pour voir les statistiques
- L'application détecte automatiquement les opportunités
- Les trades sont exécutés automatiquement
- Consultez l'historique pour analyser vos performances

## 🔧 Configuration avancée

### Variables d'environnement

```bash
# Base de données
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/trading_db

# Sécurité
SECRET_KEY=your-super-secret-key-here
API_AES_SECRET=32octetsupersecretkey!!

# Redis
REDIS_URL=redis://localhost:6379

# Firebase (Google OAuth)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email

# Exchanges
BINANCE_API_URL=https://api.binance.com
BYBIT_API_URL=https://api.bybit.com
```

### Déploiement en production

1. Configurez un serveur avec Docker
2. Modifiez les variables d'environnement
3. Utilisez un reverse proxy (Nginx) avec SSL
4. Configurez les sauvegardes de base de données

## 🧪 Tests

### Backend

```bash
cd backend
pip install pytest pytest-asyncio
pytest tests/ -v
```

### Frontend

```bash
cd frontend
flutter test
```

## 📊 Monitoring

### Logs

```bash
# Voir les logs de tous les services
docker-compose logs

# Logs d'un service spécifique
docker-compose logs backend
docker-compose logs frontend
```

### Base de données

```bash
# Accéder à PostgreSQL
docker-compose exec postgres psql -U trading_user -d trading_db
```

## 🔒 Sécurité

- Chiffrement AES-256 pour les clés API
- Authentification JWT sécurisée
- Validation des données côté serveur
- Headers de sécurité HTTP
- Rate limiting (à implémenter)

## 🚀 CI/CD

Le projet inclut un pipeline GitHub Actions qui :

- Exécute les tests automatiquement
- Construit les images Docker
- Déploie sur le serveur de production

## 📈 Évolutions futures

- [ ] Intégration TradingView (webhooks)
- [ ] Bot Telegram pour les alertes
- [ ] SMS via Twilio
- [ ] Interface admin avancée
- [ ] Stratégies de trading personnalisées
- [ ] Backtesting des stratégies
- [ ] Intégration Orange Money
- [ ] Analytics avancées

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :

- Ouvrez une issue sur GitHub
- Consultez la documentation API : <http://localhost:8000/docs>
- Consultez le guide de déploiement : [DEPLOYMENT.md](DEPLOYMENT.md)

---

**⚠️ Avertissement** : Le trading automatique comporte des risques. Utilisez cette application à vos propres risques et ne tradez que ce que vous pouvez vous permettre de perdre.
