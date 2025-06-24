# 🚀 Guide de Publication sur GitHub - Windows

## ⚡ Publication Rapide (5 minutes)

### **Étape 1 : Préparation**

1. **Ouvrir PowerShell** dans le dossier de votre projet
2. **Vérifier que Git est installé** :

   ```powershell
   git --version
   ```

   Si Git n'est pas installé, téléchargez-le depuis : <https://git-scm.com/>

### **Étape 2 : Exécuter le script automatique**

```powershell
# Exécuter le script PowerShell
.\init-git.ps1
```

Le script va :

- ✅ Vérifier votre installation Git
- ✅ Demander votre nom d'utilisateur GitHub
- ✅ Créer le repository automatiquement
- ✅ Pousser tout le code
- ✅ Configurer les templates GitHub

### **Étape 3 : Test rapide**

```powershell
# Lancer l'application pour tester
docker-compose up --build
```

---

## 🔧 Méthode Manuelle (si le script ne fonctionne pas)

### **1. Créer le repository GitHub**

1. Allez sur <https://github.com/new>
2. Nom : `trading-automation-app`
3. Description : `Application de trading automatique multi-plateforme`
4. Choisissez Public ou Privé
5. **NE PAS** cocher "Initialize with README"
6. Cliquez "Create repository"

### **2. Initialiser Git localement**

```powershell
# Initialiser Git
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit: Application de trading automatique"

# Ajouter le remote (remplacez VOTRE_USERNAME)
git remote add origin https://github.com/VOTRE_USERNAME/trading-automation-app.git

# Pousser vers GitHub
git branch -M main
git push -u origin main
```

---

## 🧪 Tests Immédiats

### **Test 1 : Vérifier l'installation**

```powershell
# Vérifier Docker
docker --version
docker-compose --version

# Lancer l'application
docker-compose up --build
```

### **Test 2 : Accéder à l'application**

- **Frontend** : <http://localhost:80>
- **Backend API** : <http://localhost:8000>
- **Documentation** : <http://localhost:8000/docs>

### **Test 3 : Créer un compte de test**

1. Ouvrir <http://localhost:80>
2. Cliquer "S'inscrire"
3. Remplir les informations
4. Se connecter
5. Tester l'ajout d'une clé API

---

## 📤 Partage avec les Testeurs

### **Option 1 : Repository Public**

- Partagez directement le lien : `https://github.com/VOTRE_USERNAME/trading-automation-app`
- Les testeurs peuvent cloner et tester

### **Option 2 : Repository Privé**

- Invitez des collaborateurs dans les paramètres GitHub
- Ils recevront un email d'invitation

### **Instructions pour les testeurs**

```bash
# Cloner le projet
git clone https://github.com/VOTRE_USERNAME/trading-automation-app.git
cd trading-automation-app

# Lancer l'application
docker-compose up --build

# Accéder à l'application
# Frontend : http://localhost:80
# Backend : http://localhost:8000
```

---

## 🔍 Vérification

### **Vérifier que tout fonctionne**

```powershell
# Vérifier les services
docker-compose ps

# Vérifier les logs
docker-compose logs

# Tester l'API
curl http://localhost:8000/
```

### **Vérifier le repository GitHub**

- ✅ Code poussé
- ✅ README visible
- ✅ Structure des dossiers correcte
- ✅ Pas de fichiers sensibles exposés

---

## 🚨 Problèmes Courants

### **Erreur : Git non reconnu**

```powershell
# Installer Git depuis : https://git-scm.com/
# Redémarrer PowerShell après installation
```

### **Erreur : Docker non reconnu**

```powershell
# Installer Docker Desktop depuis : https://www.docker.com/products/docker-desktop/
# Redémarrer l'ordinateur après installation
```

### **Erreur : Ports déjà utilisés**

```powershell
# Vérifier les ports utilisés
netstat -ano | findstr :80
netstat -ano | findstr :8000

# Arrêter les services qui utilisent ces ports
# Ou modifier les ports dans docker-compose.yml
```

### **Erreur : Permission PowerShell**

```powershell
# Exécuter PowerShell en tant qu'administrateur
# Ou changer la politique d'exécution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📞 Support

Si vous rencontrez des problèmes :

1. **Vérifiez les logs** : `docker-compose logs`
2. **Créez une issue** sur GitHub
3. **Consultez la documentation** : <http://localhost:8000/docs>

---

## 🎯 Prochaines Étapes

Après la publication réussie :

1. **Testez l'application** localement
2. **Partagez le lien** avec vos testeurs
3. **Collectez les retours** via les issues GitHub
4. **Améliorez l'application** selon les retours
5. **Déployez en production** quand prêt

---

**🎉 Votre application est maintenant prête pour les tests et le partage sur GitHub !**
