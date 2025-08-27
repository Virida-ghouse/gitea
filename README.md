# Gitea sur CleverCloud

Instance Gitea déployée sur CleverCloud avec un runtime Linux pour des performances optimales et des coûts réduits.

## Architecture

### Runtime Linux vs Go
- **Runtime Linux** : Utilise un binaire pré-compilé Gitea (v1.24.5), déploiement ~30 secondes
- **Runtime Go** : Compilation à chaque déploiement, ~5+ minutes, plus coûteux
- Choix fait pour l'efficacité et la réduction des coûts

### Structure du projet
```
├── gitea                 # Binaire pré-compilé Gitea v1.24.5 Linux amd64 (113MB)
├── start.sh              # Script de démarrage qui génère la config dynamique
├── custom/               # Configuration Gitea (générée à l'exécution)
├── data/                 # Données Gitea (créées automatiquement)
└── logs/                 # Logs Gitea (créées automatiquement)
```

## Configuration dynamique

La configuration est générée dynamiquement par `start.sh` au démarrage pour injecter les variables d'environnement CleverCloud :

- **Base de données** : PostgreSQL addon avec variables `POSTGRESQL_ADDON_*`
- **Connection pooling** : Support Pgpool-II pour éviter les erreurs de connexion lors du scaling
- **Sécurité** : Clés secrètes via variables d'environnement `GITEA_*`  
- **Serveur** : Port via `${PORT}` (injecté par CleverCloud)

## Déploiement sur CleverCloud

### Prérequis
1. Compte CleverCloud avec accès à l'organisation
2. [clever-tools](https://github.com/clevercloud/clever-tools) (CLI CleverCloud) installé (`clever`)
3. [Git LFS](https://git-lfs.github.io/) installé (`git lfs`) pour gérer le binaire Gitea
4. PostgreSQL addon créé

### Étapes de déploiement

1. **Cloner le repo avec Git LFS**
   ```bash
   git lfs install
   git clone <repo-url>
   cd gitea
   ```

2. **Créer l'application CleverCloud**
   ```bash
   clever create gitea.app --type linux --org ${ORGANISATION}
   ```

3. **Lier l'addon PostgreSQL**
   ```bash
   clever link gitea.db --org ${ORGANISATION}
   ```

4. **Configurer les variables d'environnement**
   ```bash
   clever env set GITEA_SECRET_KEY="votre-clé-secrète"
   clever env set GITEA_INTERNAL_TOKEN="votre-token-interne"
   clever env set GITEA_JWT_SECRET="votre-jwt-secret"
   ```

5. **Déployer**
   ```bash
   git add .
   git commit -m "Deploy"
   clever deploy
   ```

### Variables d'environnement importantes

- `GITEA_SECRET_KEY` : Clé secrète pour la sécurité
- `GITEA_INTERNAL_TOKEN` : Token pour les opérations internes
- `GITEA_JWT_SECRET` : Secret pour les tokens JWT
- `POSTGRESQL_ADDON_*` : Variables injectées automatiquement par l'addon
- `PORT` : Port injecté automatiquement par CleverCloud

## Maintenance

### Consultation des logs
```bash
clever logs --follow
```

### Mise à jour de Gitea
1. Télécharger le nouveau binaire depuis [Gitea releases](https://github.com/go-gitea/gitea/releases)
2. Remplacer le fichier `gitea`
3. Commit et deploy

### Accès à la base de données
```bash
clever addon list  # Voir les addons liés
```

## Troubleshooting

### Erreur de connexion base de données
- Vérifier que l'addon PostgreSQL est bien lié
- Consulter les logs pour les détails de connexion
- En cas d'erreur "too many connections" lors du scaling : voir la configuration Pgpool-II dans `PGPOOL_CONFIG.md`

### Erreur de démarrage
- Vérifier les permissions du binaire `gitea` (doit être exécutable)
- Consulter les logs CleverCloud

### Variables d'environnement manquantes
- Vérifier avec `clever env` que toutes les variables sont définies
- Régénérer les secrets si nécessaire

### Problème avec Git LFS
- Erreur "File gitea is X.XX MB; this exceeds GitHub's file size limit" : Git LFS n'est pas configuré
- Solution : Installer Git LFS et re-cloner le repository
  ```bash
  git lfs install
  git lfs track "gitea"
  git add .gitattributes
  git add gitea
  git commit -m "Track gitea binary with LFS"
  git push
  ```

## Git LFS (Large File Storage)

Le binaire Gitea (~113MB) dépasse la limite de fichier GitHub (100MB). Il est donc géré via Git LFS.

### Installation de Git LFS
```bash
# Sur Ubuntu/Debian
sudo apt install git-lfs

# Sur macOS
brew install git-lfs

# Sur Windows
# Télécharger depuis https://git-lfs.github.io/
```

### Configuration initiale (déjà fait dans ce repo)
```bash
git lfs install
git lfs track "gitea"
git add .gitattributes gitea
git commit -m "Track gitea binary with Git LFS"
```

### Vérification
```bash
git lfs ls-files  # Doit montrer le fichier gitea
```

## Support

Pour toute question sur CleverCloud, consulter la [documentation officielle](https://www.clever-cloud.com/doc/) ou contacter le support technique.
