#!/bin/bash
set -e

echo "=== Démarrage de Gitea sur Clever Cloud ==="
echo "Port: ${PORT}"
echo "Instance: ${CC_INSTANCE_ID:-unknown}"

mkdir -p data/repositories
mkdir -p data/attachments
mkdir -p data/avatars
mkdir -p data/repo-avatars
mkdir -p data/indexers
mkdir -p logs
mkdir -p custom/conf

echo "Génération du fichier de configuration dynamique..."

# Debug des variables d'environnement critiques
echo "=== DEBUG VARIABLES ==="
echo "PORT: ${PORT:-NOT_SET}"
echo "POSTGRESQL_ADDON_HOST: ${POSTGRESQL_ADDON_HOST:-NOT_SET}"
echo "POSTGRESQL_ADDON_DB: ${POSTGRESQL_ADDON_DB:-NOT_SET}"
echo "GITEA_SECRET_KEY: ${GITEA_SECRET_KEY:+SET}"
echo "CC_PGPOOL_SOCKET_PATH: ${CC_PGPOOL_SOCKET_PATH:-NOT_SET}"
echo "========================"

# Déterminer la configuration de connexion DB
if [ -n "${CC_PGPOOL_SOCKET_PATH}" ]; then
    echo "Utilisation de Pgpool-II via socket Unix: ${CC_PGPOOL_SOCKET_PATH}"
    DB_HOST="${CC_PGPOOL_SOCKET_PATH}"
    DB_PORT=""
else
    echo "Connexion PostgreSQL directe"
    DB_HOST="${POSTGRESQL_ADDON_HOST}:${POSTGRESQL_ADDON_PORT}"
    DB_PORT=""
fi

# Générer app.ini avec les vraies valeurs
cat > custom/conf/app.ini << EOF
APP_NAME = Gitea
RUN_MODE = prod
RUN_USER = bas

[server]
HTTP_ADDR = 0.0.0.0
HTTP_PORT = ${PORT:-8080}
DISABLE_SSH = true
START_SSH_SERVER = false

[database]
DB_TYPE = postgres
HOST = ${DB_HOST}
NAME = ${POSTGRESQL_ADDON_DB}
USER = ${POSTGRESQL_ADDON_USER}
PASSWD = ${POSTGRESQL_ADDON_PASSWORD}
SSL_MODE = require
MAX_OPEN_CONNS = 5
MAX_IDLE_CONNS = 2
CONN_MAX_LIFETIME = 300s

[security]
INSTALL_LOCK = true
SECRET_KEY = ${GITEA_SECRET_KEY}
INTERNAL_TOKEN = ${GITEA_INTERNAL_TOKEN}

[oauth2]
JWT_SECRET = ${GITEA_JWT_SECRET}

[service]
DISABLE_REGISTRATION = false
ENABLE_CAPTCHA = true
DEFAULT_KEEP_EMAIL_PRIVATE = true
DEFAULT_ALLOW_CREATE_ORGANIZATION = false

[session]
PROVIDER = memory
COOKIE_SECURE = true

[log]
MODE = console
LEVEL = Info
ROOT_PATH = /tmp

[repository]
ROOT = data/repositories
SCRIPT_TYPE = bash

[mailer]
ENABLED = false

[attachment]
ENABLED = true
PATH = data/attachments
MAX_SIZE = 10

[picture]
AVATAR_UPLOAD_PATH = data/avatars
REPOSITORY_AVATAR_UPLOAD_PATH = data/repo-avatars

[indexer]
ISSUE_INDEXER_PATH = data/indexers/issues.bleve
REPO_INDEXER_ENABLED = true
REPO_INDEXER_PATH = data/indexers/repos.bleve

[admin]
DISABLE_REGULAR_ORG_CREATION = true
EOF

echo "Configuration générée, démarrage de Gitea..."

# Vérifier que Gitea existe et est exécutable
if [ ! -f "./gitea" ]; then
    echo "ERREUR: ./gitea n'existe pas!"
    exit 1
fi

if [ ! -x "./gitea" ]; then
    echo "ERREUR: ./gitea n'est pas exécutable!"
    exit 1
fi

echo "Tentative de démarrage de Gitea..."
echo "Commande: ./gitea web --config custom/conf/app.ini"

# Démarrer Gitea
exec ./gitea web --config custom/conf/app.ini