#!/bin/bash
set -e

echo "=== Configuration scaling pour démarrage Gitea ==="

# Vérifier que l'ID de l'application est disponible
if [ -z "${CC_APP_ID}" ]; then
    echo "ERREUR: CC_APP_ID non disponible"
    exit 1
fi

echo "Application ID: ${CC_APP_ID}"

# Scaling optimal pour le démarrage de Gitea
# - S minimum car Gitea a besoin de 512MB+ RAM
# - L maximum pour gérer les pics de démarrage  
# - 1-4 instances pour la redondance
clever scale --app "${CC_APP_ID}" --min-flavor S --max-flavor L --min-instances 1 --max-instances 4

echo "✓ Scaling configuré : S-L, 1-4 instances"
echo "  - Instance minimum : S (512MB RAM)"
echo "  - Instance maximum : L (2GB RAM)"
echo "  - Instances : 1-4 pour redondance"