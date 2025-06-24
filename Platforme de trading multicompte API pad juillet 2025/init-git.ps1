# 🚀 Script PowerShell d'initialisation Git pour l'application de trading
# Ce script automatise la création du repository GitHub et la première publication

# Arrêter en cas d'erreur
$ErrorActionPreference = "Stop"

Write-Host "🚀 Initialisation Git pour l'application de trading automatique" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green

# Fonction pour afficher les messages colorés
function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Blue
}

# Vérifier que Git est installé
try {
    $null = git --version
    Write-Success "✅ Git est installé"
} catch {
    Write-Error "❌ Git n'est pas installé. Veuillez l'installer d'abord depuis https://git-scm.com/"
    exit 1
}

# Demander le nom d'utilisateur GitHub
Write-Host ""
Write-Info "📝 Configuration GitHub"
$GITHUB_USERNAME = Read-Host "Entrez votre nom d'utilisateur GitHub"

if ([string]::IsNullOrEmpty($GITHUB_USERNAME)) {
    Write-Error "❌ Le nom d'utilisateur GitHub est requis"
    exit 1
}

# Demander le nom du repository
$REPO_NAME = Read-Host "Entrez le nom du repository (défaut: trading-automation-app)"
if ([string]::IsNullOrEmpty($REPO_NAME)) {
    $REPO_NAME = "trading-automation-app"
}

# Demander si le repository doit être public ou privé
Write-Host ""
Write-Info "🔒 Visibilité du repository"
Write-Host "1. Public (visible par tous)"
Write-Host "2. Privé (visible uniquement par vous et vos collaborateurs)"
$VISIBILITY = Read-Host "Choisissez la visibilité (1 ou 2)"

if ($VISIBILITY -eq "2") {
    $REPO_PRIVATE = $true
    Write-Success "✅ Repository privé sélectionné"
} else {
    $REPO_PRIVATE = $false
    Write-Success "✅ Repository public sélectionné"
}

# Vérifier que nous sommes dans le bon répertoire
if (-not (Test-Path "docker-compose.yml") -or -not (Test-Path "backend") -or -not (Test-Path "frontend")) {
    Write-Error "❌ Ce script doit être exécuté depuis la racine du projet (où se trouve docker-compose.yml)"
    exit 1
}

Write-Success "✅ Répertoire de projet détecté"

# Vérifier si Git est déjà initialisé
if (Test-Path ".git") {
    Write-Warning "⚠️  Git est déjà initialisé dans ce répertoire"
    $OVERWRITE = Read-Host "Voulez-vous continuer et écraser la configuration existante? (y/N)"
    if ($OVERWRITE -ne "y" -and $OVERWRITE -ne "Y") {
        Write-Info "❌ Opération annulée"
        exit 0
    }
    Remove-Item -Recurse -Force ".git"
    Write-Success "✅ Configuration Git existante supprimée"
}

# Initialiser Git
Write-Info "🔧 Initialisation de Git..."
git init

# Ajouter tous les fichiers
Write-Info "📁 Ajout des fichiers..."
git add .

# Premier commit
Write-Info "💾 Premier commit..."
git commit -m "Initial commit: Application de trading automatique multi-plateforme

- Backend FastAPI avec authentification sécurisée
- Frontend Flutter responsive
- Gestion des clés API avec chiffrement AES-256
- Interface admin avancée
- Monitoring et alertes
- Configuration Docker complète"

# Créer le repository sur GitHub
Write-Info "🌐 Création du repository sur GitHub..."
$REPO_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME"

# Vérifier si l'utilisateur a GitHub CLI configuré
try {
    $null = gh --version
    $null = gh auth status
    Write-Success "✅ GitHub CLI détecté, création du repository..."
    
    if ($REPO_PRIVATE) {
        gh repo create "$REPO_NAME" --description "Application de trading automatique multi-plateforme" --private --source=. --remote=origin --push
    } else {
        gh repo create "$REPO_NAME" --description "Application de trading automatique multi-plateforme" --public --source=. --remote=origin --push
    }
    Write-Success "✅ Repository créé et code poussé avec succès!"
} catch {
    Write-Warning "⚠️  GitHub CLI non détecté ou non authentifié"
    Write-Info "📋 Instructions manuelles:"
    Write-Host ""
    Write-Host "1. Allez sur https://github.com/new"
    Write-Host "2. Nom du repository: $REPO_NAME"
    Write-Host "3. Description: Application de trading automatique multi-plateforme"
    Write-Host "4. Visibilité: $(if ($REPO_PRIVATE) { 'Privé' } else { 'Public' })"
    Write-Host "5. NE PAS cocher 'Initialize with README'"
    Write-Host "6. Cliquez sur 'Create repository'"
    Write-Host ""
    Read-Host "Appuyez sur Entrée une fois le repository créé..."

    # Ajouter le remote et pousser
    Write-Info "🔗 Ajout du remote GitHub..."
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    
    Write-Info "📤 Push vers GitHub..."
    git branch -M main
    git push -u origin main
}

# Mettre à jour les URLs dans les fichiers
Write-Info "🔧 Mise à jour des URLs dans les fichiers..."

# Mettre à jour le README
(Get-Content "README.md") -replace "VOTRE_USERNAME", $GITHUB_USERNAME -replace "trading-automation-app", $REPO_NAME | Set-Content "README.md"

# Mettre à jour le DEPLOYMENT.md
(Get-Content "DEPLOYMENT.md") -replace "VOTRE_USERNAME", $GITHUB_USERNAME -replace "trading-automation-app", $REPO_NAME | Set-Content "DEPLOYMENT.md"

# Commit des modifications
git add README.md DEPLOYMENT.md
git commit -m "docs: Mise à jour des URLs avec le nom d'utilisateur GitHub"
git push

# Créer les branches de développement
Write-Info "🌿 Création des branches de développement..."
git checkout -b develop
git push -u origin develop

git checkout -b feature/initial-setup
git push -u origin feature/initial-setup

git checkout main

# Créer les fichiers de configuration GitHub
Write-Info "⚙️  Configuration GitHub..."

# Créer le dossier .github
if (-not (Test-Path ".github")) {
    New-Item -ItemType Directory -Path ".github"
}

# Créer le fichier .github/ISSUE_TEMPLATE.md
$issueTemplate = @"
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
"@

$issueTemplate | Out-File -FilePath ".github/ISSUE_TEMPLATE.md" -Encoding UTF8

# Créer le fichier .github/PULL_REQUEST_TEMPLATE.md
$prTemplate = @"
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
"@

$prTemplate | Out-File -FilePath ".github/PULL_REQUEST_TEMPLATE.md" -Encoding UTF8

# Commit des templates
git add .github/
git commit -m "docs: Ajout des templates GitHub pour issues et PR"
git push

# Afficher les informations finales
Write-Host ""
Write-Success "🎉 Initialisation Git terminée avec succès!"
Write-Host ""
Write-Info "📋 Informations du repository:"
Write-Host "   URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
Write-Host "   Visibilité: $(if ($REPO_PRIVATE) { 'Privé' } else { 'Public' })"
Write-Host ""
Write-Info "🚀 Prochaines étapes:"
Write-Host "   1. Testez l'application localement: docker-compose up --build"
Write-Host "   2. Partagez le lien GitHub avec vos testeurs"
Write-Host "   3. Créez des issues pour les bugs trouvés"
Write-Host "   4. Consultez le guide de déploiement: DEPLOYMENT.md"
Write-Host ""
Write-Info "🔗 Liens utiles:"
Write-Host "   - Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
Write-Host "   - Issues: https://github.com/$GITHUB_USERNAME/$REPO_NAME/issues"
Write-Host "   - Actions: https://github.com/$GITHUB_USERNAME/$REPO_NAME/actions"
Write-Host ""
Write-Success "✅ Votre application est maintenant prête pour les tests et le partage!" 