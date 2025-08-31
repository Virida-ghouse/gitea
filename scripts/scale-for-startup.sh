#!/bin/bash
set -e

echo "=== Configuration scaling pour démarrage Gitea ==="

# Récupérer l'ID de l'application (context local ou hook)
if [ -n "${CC_APP_ID}" ]; then
    APP_ID="${CC_APP_ID}"
else
    # Context local - récupérer via clever status
    APP_ID=$(clever status --format json | jq -r '.id')
    if [ -z "$APP_ID" ] || [ "$APP_ID" = "null" ]; then
        echo "ERREUR: Impossible de récupérer l'ID de l'application"
        exit 1
    fi
fi

echo "Application ID: ${APP_ID}"

# Scaling optimal pour le démarrage de Gitea
# - S minimum car Gitea a besoin de 512MB+ RAM
# - L maximum pour gérer les pics de démarrage  
# - 1-4 instances pour la redondance
clever scale --app "${APP_ID}" --min-flavor S --max-flavor L --min-instances 1 --max-instances 4

echo "✓ Scaling configuré : S-L, 1-4 instances"
echo "  - Instance minimum : S (512MB RAM)"
echo "  - Instance maximum : L (2GB RAM)"
echo "  - Instances : 1-4 pour redondance"