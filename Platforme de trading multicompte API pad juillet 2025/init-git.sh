#!/bin/bash

# 🚀 Script d'initialisation Git pour l'application de trading
# Ce script automatise la création du repository GitHub et la première publication

set -e  # Arrêter en cas d'erreur

echo "🚀 Initialisation Git pour l'application de trading automatique"
echo "================================================================"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages colorés
print_message() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

print_info() {
    echo -e "${BLUE}$1${NC}"
}

# Vérifier que Git est installé
if ! command -v git &> /dev/null; then
    print_error "❌ Git n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

print_message "✅ Git est installé"

# Demander le nom d'utilisateur GitHub
echo ""
print_info "📝 Configuration GitHub"
read -p "Entrez votre nom d'utilisateur GitHub: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    print_error "❌ Le nom d'utilisateur GitHub est requis"
    exit 1
fi

# Demander le nom du repository
read -p "Entrez le nom du repository (défaut: trading-automation-app): " REPO_NAME
REPO_NAME=${REPO_NAME:-trading-automation-app}

# Demander si le repository doit être public ou privé
echo ""
print_info "🔒 Visibilité du repository"
echo "1. Public (visible par tous)"
echo "2. Privé (visible uniquement par vous et vos collaborateurs)"
read -p "Choisissez la visibilité (1 ou 2): " VISIBILITY

if [ "$VISIBILITY" = "2" ]; then
    REPO_PRIVATE="true"
    print_message "✅ Repository privé sélectionné"
else
    REPO_PRIVATE="false"
    print_message "✅ Repository public sélectionné"
fi

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "docker-compose.yml" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    print_error "❌ Ce script doit être exécuté depuis la racine du projet (où se trouve docker-compose.yml)"
    exit 1
fi

print_message "✅ Répertoire de projet détecté"

# Vérifier si Git est déjà initialisé
if [ -d ".git" ]; then
    print_warning "⚠️  Git est déjà initialisé dans ce répertoire"
    read -p "Voulez-vous continuer et écraser la configuration existante? (y/N): " OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
        print_info "❌ Opération annulée"
        exit 0
    fi
    rm -rf .git
    print_message "✅ Configuration Git existante supprimée"
fi

# Initialiser Git
print_info "🔧 Initialisation de Git..."
git init

# Ajouter tous les fichiers
print_info "📁 Ajout des fichiers..."
git add .

# Premier commit
print_info "💾 Premier commit..."
git commit -m "Initial commit: Application de trading automatique multi-plateforme

- Backend FastAPI avec authentification sécurisée
- Frontend Flutter responsive
- Gestion des clés API avec chiffrement AES-256
- Interface admin avancée
- Monitoring et alertes
- Configuration Docker complète"

# Créer le repository sur GitHub via l'API
print_info "🌐 Création du repository sur GitHub..."
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME"

# Vérifier si l'utilisateur a un token GitHub configuré
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    print_message "✅ GitHub CLI détecté, création du repository..."
    gh repo create "$REPO_NAME" --description "Application de trading automatique multi-plateforme" --$(if [ "$REPO_PRIVATE" = "true" ]; then echo "private"; else echo "public"; fi) --source=. --remote=origin --push
    print_message "✅ Repository créé et code poussé avec succès!"
else
    print_warning "⚠️  GitHub CLI non détecté ou non authentifié"
    print_info "📋 Instructions manuelles:"
    echo ""
    echo "1. Allez sur https://github.com/new"
    echo "2. Nom du repository: $REPO_NAME"
    echo "3. Description: Application de trading automatique multi-plateforme"
    echo "4. Visibilité: $(if [ "$REPO_PRIVATE" = "true" ]; then echo "Privé"; else echo "Public"; fi)"
    echo "5. NE PAS cocher 'Initialize with README'"
    echo "6. Cliquez sur 'Create repository'"
    echo ""
    read -p "Appuyez sur Entrée une fois le repository créé..."

    # Ajouter le remote et pousser
    print_info "🔗 Ajout du remote GitHub..."
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    
    print_info "📤 Push vers GitHub..."
    git branch -M main
    git push -u origin main
fi

# Mettre à jour les URLs dans les fichiers
print_info "🔧 Mise à jour des URLs dans les fichiers..."

# Mettre à jour le README
sed -i "s|VOTRE_USERNAME|$GITHUB_USERNAME|g" README.md
sed -i "s|trading-automation-app|$REPO_NAME|g" README.md

# Mettre à jour le DEPLOYMENT.md
sed -i "s|VOTRE_USERNAME|$GITHUB_USERNAME|g" DEPLOYMENT.md
sed -i "s|trading-automation-app|$REPO_NAME|g" DEPLOYMENT.md

# Commit des modifications
git add README.md DEPLOYMENT.md
git commit -m "docs: Mise à jour des URLs avec le nom d'utilisateur GitHub"
git push

# Créer les branches de développement
print_info "🌿 Création des branches de développement..."
git checkout -b develop
git push -u origin develop

git checkout -b feature/initial-setup
git push -u origin feature/initial-setup

git checkout main

# Créer les fichiers de configuration GitHub
print_info "⚙️  Configuration GitHub..."

# Créer le fichier .github/ISSUE_TEMPLATE.md
mkdir -p .github
cat > .github/ISSUE_TEMPLATE.md << 'EOF'
## 🐛 Description du problème
<!-- Décrivez le problème rencontré -->

## 🔍 Étapes pour reproduire
1. 
2. 
3. 

## 📱 Environnement
- OS: 
- Navigateur: 
- Version de l'app: 

## 📸 Captures d'écran
<!-- Si applicable -->

## 💻 Logs
<!-- Copiez les logs d'erreur ici -->
EOF

# Créer le fichier .github/PULL_REQUEST_TEMPLATE.md
cat > .github/PULL_REQUEST_TEMPLATE.md << 'EOF'
## 📝 Description
<!-- Décrivez les changements apportés -->

## 🔧 Type de changement
- [ ] Correction de bug
- [ ] Nouvelle fonctionnalité
- [ ] Amélioration de performance
- [ ] Documentation
- [ ] Refactoring

## ✅ Tests
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Tests manuels effectués

## 📱 Compatibilité
- [ ] Compatible mobile
- [ ] Compatible tablette
- [ ] Compatible desktop

## 📋 Checklist
- [ ] Code commenté
- [ ] Documentation mise à jour
- [ ] Pas de logs sensibles
- [ ] Variables d'environnement documentées
EOF

# Commit des templates
git add .github/
git commit -m "docs: Ajout des templates GitHub pour issues et PR"
git push

# Afficher les informations finales
echo ""
print_message "🎉 Initialisation Git terminée avec succès!"
echo ""
print_info "📋 Informations du repository:"
echo "   URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "   Visibilité: $(if [ "$REPO_PRIVATE" = "true" ]; then echo "Privé"; else echo "Public"; fi)"
echo ""
print_info "🚀 Prochaines étapes:"
echo "   1. Testez l'application localement: docker-compose up --build"
echo "   2. Partagez le lien GitHub avec vos testeurs"
echo "   3. Créez des issues pour les bugs trouvés"
echo "   4. Consultez le guide de déploiement: DEPLOYMENT.md"
echo ""
print_info "🔗 Liens utiles:"
echo "   - Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "   - Issues: https://github.com/$GITHUB_USERNAME/$REPO_NAME/issues"
echo "   - Actions: https://github.com/$GITHUB_USERNAME/$REPO_NAME/actions"
echo ""
print_message "✅ Votre application est maintenant prête pour les tests et le partage!" 