#!/bin/bash
set -e

echo "=== Réduction scaling pour économie de ressources ==="

# Vérifier que l'ID de l'application est disponible
if [ -z "${CC_APP_ID}" ]; then
    echo "ERREUR: CC_APP_ID non disponible"
    exit 1
fi

echo "Application ID: ${CC_APP_ID}"

# Attendre que l'application soit stable avant de scale down
echo "Attente de stabilisation (30s)..."
sleep 30

# Scaling économique pour le runtime
# - pico minimum pour économiser (256MB peut suffire une fois démarré)
# - M maximum pour gérer les pics de trafic
# - 1-2 instances pour réduire les coûts
clever scale --app "${CC_APP_ID}" --min-flavor pico --max-flavor M --min-instances 1 --max-instances 2

echo "✓ Scaling réduit : pico-M, 1-2 instances"
echo "  - Instance minimum : pico (256MB RAM)"
echo "  - Instance maximum : M (1GB RAM)" 
echo "  - Instances : 1-2 pour économie"
echo "  - Application prête et optimisée !"