#!/bin/bash
set -e

echo "=== Réduction scaling pour économie de ressources ==="

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

# Attendre que l'application soit stable avant de scale down
echo "Attente de stabilisation (30s)..."
sleep 30

# Scaling économique pour le runtime
# - pico minimum pour économiser (256MB peut suffire une fois démarré)
# - M maximum pour gérer les pics de trafic
# - 1-2 instances pour réduire les coûts
clever scale --app "${APP_ID}" --min-flavor pico --max-flavor M --min-instances 1 --max-instances 2

echo "✓ Scaling réduit : pico-M, 1-2 instances"
echo "  - Instance minimum : pico (256MB RAM)"
echo "  - Instance maximum : M (1GB RAM)" 
echo "  - Instances : 1-2 pour économie"
echo "  - Application prête et optimisée !"