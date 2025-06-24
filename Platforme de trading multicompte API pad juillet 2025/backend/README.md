# Backend - API Trading Automatique

## Description

Backend FastAPI pour l'application de trading automatique multi-plateforme.

## Installation

### 1. Prérequis

- Python 3.8+
- PostgreSQL
- Redis (optionnel)

### 2. Installation des dépendances

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

pip install -r requirements.txt
```

### 3. Configuration

1. Copiez le fichier d'exemple :

```bash
cp env.example .env
```

2. Modifiez le fichier `.env` avec vos configurations :

- Base de données PostgreSQL
- Clés de sécurité
- Configuration Firebase (pour Google OAuth)
- Configuration des exchanges

### 4. Base de données

1. Créez une base PostgreSQL nommée `trading_db`
2. Les tables seront créées automatiquement au premier lancement

### 5. Lancement

```bash
uvicorn app.main:app --reload
```

L'API sera disponible sur : <http://localhost:8000>
Documentation interactive : <http://localhost:8000/docs>

## Endpoints disponibles

### Authentification

- `POST /users/register` - Création de compte
- `POST /users/login` - Connexion
- `GET /users/me` - Informations utilisateur

### Gestion des clés API

- `POST /api-keys/` - Ajouter une clé API
- `GET /api-keys/` - Lister les clés API
- `DELETE /api-keys/{id}` - Supprimer une clé API

### Trading

- `GET /trading/history` - Historique des trades
- `GET /trading/deposits` - Historique des dépôts
- `GET /trading/withdrawals` - Historique des retraits
- `POST /trading/execute` - Exécuter un trade

## Sécurité

- Chiffrement AES-256 pour les clés API
- Authentification JWT
- Hash bcrypt pour les mots de passe
- Intégration Firebase pour Google OAuth
