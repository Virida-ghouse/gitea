# Configuration Pgpool-II pour Gitea sur CleverCloud

⚠️ **IMPORTANT** : Les variables Pgpool-II se configurent sur l'**APPLICATION Linux** (Gitea), pas sur l'addon PostgreSQL.

## Variables d'environnement à configurer

### Variables essentielles Pgpool-II
```bash
# Activer Pgpool-II
CC_ENABLE_PGPOOL=true

# Configuration du pool de connexions
CC_PGPOOL_NUM_INIT_CHILDREN=3
CC_PGPOOL_MAX_POOL=1
CC_PGPOOL_CHILD_LIFE_TIME=300
CC_PGPOOL_CONNECTION_LIFE_TIME=600

# Monitoring et timeouts (optionnel)
CC_PGPOOL_HEALTH_CHECK_PERIOD=30
CC_PGPOOL_CLIENT_IDLE_LIMIT=300
```

### Commandes CleverCloud CLI

#### Méthode 1 : Via alias (recommandé)
```bash
# Identifier votre application Gitea
clever app list

# Configurer les variables sur l'APPLICATION Gitea
clever env set CC_ENABLE_PGPOOL true --alias <votre-alias-gitea>
clever env set CC_PGPOOL_NUM_INIT_CHILDREN 3 --alias <votre-alias-gitea>
clever env set CC_PGPOOL_MAX_POOL 1 --alias <votre-alias-gitea>
clever env set CC_PGPOOL_CHILD_LIFE_TIME 300 --alias <votre-alias-gitea>
clever env set CC_PGPOOL_CONNECTION_LIFE_TIME 600 --alias <votre-alias-gitea>

# Variables de monitoring (optionnelles)
clever env set CC_PGPOOL_HEALTH_CHECK_PERIOD 30 --alias <votre-alias-gitea>
clever env set CC_PGPOOL_CLIENT_IDLE_LIMIT 300 --alias <votre-alias-gitea>
```

#### Méthode 2 : Via link
```bash
# Se positionner dans le repo et lier l'app
cd /path/to/gitea
clever link <app-id>

# Puis configurer normalement
clever env set CC_ENABLE_PGPOOL true
clever env set CC_PGPOOL_NUM_INIT_CHILDREN 3
# etc...
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│        APPLICATION Linux (Gitea)                │
│                                                 │
│  Variables Pgpool-II:                          │
│  ├── CC_ENABLE_PGPOOL=true                     │
│  ├── CC_PGPOOL_NUM_INIT_CHILDREN=3             │
│  ├── CC_PGPOOL_MAX_POOL=1                      │
│  └── CC_PGPOOL_*                               │
│                                                 │
│  Socket Unix généré automatiquement:           │
│  └── CC_PGPOOL_SOCKET_PATH=/path/to/socket     │
└─────────────────────────────────────────────────┘
                         │
                         ▼ Connexion via Pgpool
┌─────────────────────────────────────────────────┐
│           ADDON PostgreSQL                      │
│                                                 │
│  Variables automatiques:                        │
│  ├── POSTGRESQL_ADDON_HOST                      │
│  ├── POSTGRESQL_ADDON_PORT                      │
│  ├── POSTGRESQL_ADDON_DB                        │
│  ├── POSTGRESQL_ADDON_USER                      │
│  └── POSTGRESQL_ADDON_PASSWORD                  │
└─────────────────────────────────────────────────┘
```

## Calcul des paramètres

### CC_PGPOOL_NUM_INIT_CHILDREN
Formule CleverCloud : `(MaxPostgreSQLConnections - SpareConnections) / MaxConcurrentInstances`

Exemple pour un plan PostgreSQL avec 20 connexions max et 2 instances concurrentes :
- `(20 - 5) / 2 = 7.5` → arrondi à 3 pour être sûr

### Rationale
- **NUM_INIT_CHILDREN=3** : Permet 3 processus Pgpool, chacun gérant les connexions
- **MAX_POOL=1** : Une seule connexion cache par processus (recommandation CleverCloud)
- **CHILD_LIFE_TIME=300** : Recyclage des processus toutes les 5min pour éviter les fuites mémoire
- **CONNECTION_LIFE_TIME=600** : Expiration des connexions après 10min pour renouvellement

## Diagnostics post-déploiement

### Vérification SSH
```bash
# Se connecter à l'instance
ssh -t ssh@sshgateway-clever-cloud.services.clever-cloud.com <app_id>

# Lancer psql et vérifier les pools
psql
```

### Commandes de diagnostic
```sql
-- Voir les pools actifs
SHOW POOL_POOLS;

-- Voir les statistiques backend  
SHOW POOL_BACKEND_STATS;

-- Voir les processus Pgpool
SHOW POOL_PROCESSES;

-- Voir les noeuds configurés
SHOW POOL_NODES;
```