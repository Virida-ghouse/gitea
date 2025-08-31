#!/bin/bash
set -e

echo "=== Déploiement Intelligent Gitea ==="
echo "Workflow : Scale UP → Deploy → Vérification → Scale DOWN"
echo ""

# 1. Configuration du scaling pour le démarrage
echo "1/4 🚀 Scale UP pour démarrage optimal..."
./scripts/scale-for-startup.sh

# 2. Déploiement
echo ""
echo "2/4 📦 Déploiement en cours..."
clever deploy --follow

# 3. Vérification que l'application démarre
echo ""
echo "3/4 ⏳ Vérification du démarrage..."
echo "Attente de la stabilisation de l'application (60s)..."
sleep 60

# Vérifier le statut de l'application
APP_STATUS=$(clever status --format json | jq -r '.state')
if [ "$APP_STATUS" = "UP" ]; then
    echo "✅ Application démarrée avec succès !"
else
    echo "⚠️ Application en cours de démarrage (status: $APP_STATUS)"
    echo "Attente supplémentaire de 30s..."
    sleep 30
fi

# 4. Scale DOWN pour économiser les ressources
echo ""
echo "4/4 💰 Scale DOWN pour économie..."
./scripts/scale-for-runtime.sh

echo ""
echo "=== 🎉 Déploiement Intelligent Terminé ==="
echo "✅ Gitea déployé avec scaling optimal"
echo "📊 Logs temps réel : clever logs"
echo "🔧 Status actuel : clever status"
echo "🌐 Ouvrir l'app : clever open"