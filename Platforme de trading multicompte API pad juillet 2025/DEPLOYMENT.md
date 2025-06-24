# 🚀 Guide de Déploiement - Application de Trading Automatique

## 📋 Prérequis

- Git installé sur votre machine
- Compte GitHub
- Docker et Docker Compose installés
- Accès à un serveur (optionnel pour la production)

---

## 🟢 Étape 1 : Préparation du projet

### 1.1. Vérifier la structure

Assurez-vous que votre projet a la structure suivante :

```
trading-app/
├── backend/
├── frontend/
├── db/
├── docker-compose.yml
├── .gitignore
├── README.md
└── DEPLOYMENT.md
```

### 1.2. Vérifier les fichiers sensibles

- ✅ Le fichier `.env` est dans `.gitignore`
- ✅ Aucune clé API n'est exposée dans le code
- ✅ Les secrets sont dans les variables d'environnement

---

## 🟢 Étape 2 : Création du repository GitHub

### 2.1. Créer un nouveau repository

1. Allez sur [GitHub.com](https://github.com)
2. Cliquez sur "New repository"
3. Nommez-le : `trading-automation-app`
4. Description : `Application de trading automatique multi-plateforme`
5. Choisissez "Public" ou "Private"
6. **NE PAS** cocher "Initialize with README"
7. Cliquez sur "Create repository"

### 2.2. Initialiser Git localement

```bash
# Dans le dossier de votre projet
cd trading-app

# Initialiser Git
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit: Application de trading automatique"

# Ajouter le remote GitHub
git remote add origin https://github.com/VOTRE_USERNAME/trading-automation-app.git

# Pousser vers GitHub
git branch -M main
git push -u origin main
```

---

## 🟢 Étape 3 : Configuration pour les tests

### 3.1. Créer un fichier de configuration d'exemple

```bash
# Copier le fichier d'environnement d'exemple
cp backend/env.example backend/.env.example
```

### 3.2. Modifier le fichier .env.example

```bash
# Configuration de base pour les tests
DATABASE_URL=postgresql+asyncpg://trading_user:trading_password@localhost:5432/trading_db
SECRET_KEY=your-super-secret-key-here-for-testing
API_AES_SECRET=32octetsupersecretkeyfortesting!!
REDIS_URL=redis://localhost:6379

# Configuration Firebase (optionnel pour les tests)
FIREBASE_PROJECT_ID=your-test-project-id
FIREBASE_PRIVATE_KEY=your-test-private-key
FIREBASE_CLIENT_EMAIL=your-test-client-email

# Configuration des alertes (optionnel)
TELEGRAM_BOT_TOKEN=your-test-bot-token
TELEGRAM_CHAT_ID=your-test-chat-id
```

### 3.3. Mettre à jour le README

Ajoutez une section "Quick Start" dans le README.md :

```markdown
## 🚀 Quick Start

### Installation rapide
```bash
# Cloner le projet
git clone https://github.com/VOTRE_USERNAME/trading-automation-app.git
cd trading-automation-app

# Configuration
cp backend/env.example backend/.env
# Modifier backend/.env avec vos configurations

# Lancer avec Docker
docker-compose up --build
```

### Accès

- Frontend : <http://localhost:80>
- Backend API : <http://localhost:8000>
- Documentation API : <http://localhost:8000/docs>

```

---

## 🟢 Étape 4 : Tests locaux

### 4.1. Tester l'installation
```bash
# Vérifier que Docker fonctionne
docker --version
docker-compose --version

# Lancer l'application
docker-compose up --build

# Vérifier que tous les services démarrent
docker-compose ps
```

### 4.2. Tester les endpoints

```bash
# Test de l'API
curl http://localhost:8000/

# Test de la documentation
# Ouvrir http://localhost:8000/docs dans votre navigateur
```

### 4.3. Tester le frontend

1. Ouvrir <http://localhost:80>
2. Créer un compte de test
3. Tester l'ajout d'une clé API
4. Vérifier le dashboard

---

## 🟢 Étape 5 : Déploiement pour les tests

### 5.1. Option A : Déploiement local (recommandé pour les tests)

```bash
# L'application est déjà prête pour les tests locaux
# Utilisez les instructions du Quick Start
```

### 5.2. Option B : Déploiement sur serveur de test

```bash
# Sur votre serveur de test
git clone https://github.com/VOTRE_USERNAME/trading-automation-app.git
cd trading-automation-app

# Configuration
cp backend/env.example backend/.env
# Modifier backend/.env

# Lancer
docker-compose up -d --build
```

### 5.3. Option C : Déploiement sur VPS (DigitalOcean, AWS, etc.)

```bash
# Installer Docker sur le serveur
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Cloner et déployer
git clone https://github.com/VOTRE_USERNAME/trading-automation-app.git
cd trading-automation-app
cp backend/env.example backend/.env
# Configurer backend/.env
docker-compose up -d --build
```

---

## 🟢 Étape 6 : Tests de validation

### 6.1. Tests fonctionnels

- [ ] Création de compte utilisateur
- [ ] Connexion/déconnexion
- [ ] Ajout de clé API
- [ ] Affichage du dashboard
- [ ] Navigation entre les écrans
- [ ] Responsive design (mobile, tablette, desktop)

### 6.2. Tests de sécurité

- [ ] Validation des formulaires
- [ ] Protection contre les injections
- [ ] Chiffrement des clés API
- [ ] Authentification JWT

### 6.3. Tests de performance

- [ ] Temps de réponse de l'API
- [ ] Chargement du frontend
- [ ] Utilisation mémoire/CPU
- [ ] Stabilité des services

---

## 🟢 Étape 7 : Partage et collaboration

### 7.1. Inviter des testeurs

1. Rendez le repository public ou invitez des collaborateurs
2. Partagez le lien : `https://github.com/VOTRE_USERNAME/trading-automation-app`
3. Donnez les instructions d'installation

### 7.2. Collecter les retours

- Créez des "Issues" sur GitHub pour les bugs
- Utilisez les "Discussions" pour les suggestions
- Documentez les problèmes rencontrés

### 7.3. Mises à jour

```bash
# Après chaque modification
git add .
git commit -m "Description des changements"
git push origin main
```

---

## 🔧 Dépannage

### Problèmes courants

#### 1. Ports déjà utilisés

```bash
# Vérifier les ports utilisés
netstat -tulpn | grep :80
netstat -tulpn | grep :8000

# Changer les ports dans docker-compose.yml si nécessaire
```

#### 2. Erreurs de base de données

```bash
# Redémarrer les services
docker-compose down
docker-compose up --build

# Vérifier les logs
docker-compose logs postgres
```

#### 3. Erreurs de build Flutter

```bash
# Nettoyer le cache
docker-compose down
docker system prune -f
docker-compose up --build
```

---

## 📞 Support

Pour toute question ou problème :

1. Créez une "Issue" sur GitHub
2. Consultez la documentation API : <http://localhost:8000/docs>
3. Vérifiez les logs : `docker-compose logs`

---

## 🎯 Prochaines étapes

Après les tests réussis :

1. **Déploiement production** avec SSL
2. **Configuration Firebase** pour Google OAuth
3. **Intégration des exchanges** réels
4. **Tests de charge** et optimisation
5. **Monitoring** et alertes en production

---

**🎉 Votre application est maintenant prête pour les tests et le partage sur GitHub !**
