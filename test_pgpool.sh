#!/bin/bash
# Script de test pour valider la configuration Pgpool-II

set -e

echo "=== Test de validation Pgpool-II pour Gitea ==="

# Vérification des variables d'environnement
echo "1. Vérification des variables d'environnement..."

if [ "${CC_ENABLE_PGPOOL}" = "true" ]; then
    echo "✓ Pgpool-II est activé"
    
    if [ -n "${CC_PGPOOL_SOCKET_PATH}" ]; then
        echo "✓ Socket Pgpool-II disponible: ${CC_PGPOOL_SOCKET_PATH}"
    else
        echo "⚠ CC_PGPOOL_SOCKET_PATH non disponible (normal si Pgpool pas encore démarré)"
    fi
    
    echo "Configuration Pgpool:"
    echo "  - NUM_INIT_CHILDREN: ${CC_PGPOOL_NUM_INIT_CHILDREN:-"non défini"}"
    echo "  - MAX_POOL: ${CC_PGPOOL_MAX_POOL:-"non défini"}"
    echo "  - CHILD_LIFE_TIME: ${CC_PGPOOL_CHILD_LIFE_TIME:-"non défini"}"
    echo "  - CONNECTION_LIFE_TIME: ${CC_PGPOOL_CONNECTION_LIFE_TIME:-"non défini"}"
else
    echo "ℹ Pgpool-II désactivé, utilisation connexion directe PostgreSQL"
fi

# Test de génération de configuration
echo -e "\n2. Test de génération de configuration..."

# Simuler la logique du script start.sh
if [ -n "${CC_PGPOOL_SOCKET_PATH}" ]; then
    DB_HOST="${CC_PGPOOL_SOCKET_PATH}"
    echo "✓ Configuration socket: ${DB_HOST}"
else
    DB_HOST="${POSTGRESQL_ADDON_HOST:-"localhost"}:${POSTGRESQL_ADDON_PORT:-"5432"}"
    echo "✓ Configuration TCP: ${DB_HOST}"
fi

# Générer un aperçu de la config
echo -e "\n3. Aperçu de la configuration Gitea générée:"
echo "[database]"
echo "DB_TYPE = postgres"
echo "HOST = ${DB_HOST}"
echo "NAME = ${POSTGRESQL_ADDON_DB:-"gitea"}"
echo "USER = ${POSTGRESQL_ADDON_USER:-"gitea"}"
echo "PASSWD = [HIDDEN]"
echo "SSL_MODE = require"
echo "MAX_OPEN_CONNS = 5"
echo "MAX_IDLE_CONNS = 2" 
echo "CONN_MAX_LIFETIME = 300s"

echo -e "\n=== Test terminé ==="

# Instructions pour les diagnostics post-déploiement
cat << 'EOL'

Instructions post-déploiement:
1. Se connecter via SSH: ssh -t ssh@sshgateway-clever-cloud.services.clever-cloud.com <app_id>
2. Lancer psql et exécuter:
   - SHOW POOL_POOLS;
   - SHOW POOL_BACKEND_STATS;
   - SHOW POOL_PROCESSES;
3. Tester le scaling et vérifier l'absence d'erreurs "too many connections"

Pour désactiver Pgpool-II:
clever env unset CC_ENABLE_PGPOOL
EOL