#!/bin/bash
set -e

echo "=== Déploiement Intelligent Gitea ==="
echo "Scaling automatique : startup (S-L) → runtime (pico-M)"
echo ""

# 1. Configuration du scaling pour le démarrage
echo "1/4 Configuration du scaling pour démarrage..."
./scripts/scale-for-startup.sh

# 2. Configuration des hooks
echo ""
echo "2/4 Configuration des hooks..."
clever env set CC_PRE_RUN_HOOK "git lfs pull"
clever env set CC_RUN_SUCCEEDED_HOOK "./scripts/scale-for-runtime.sh"
echo "✓ Hook LFS configuré pour télécharger les binaires"
echo "✓ Hook configuré pour scale down après succès"

# 3. Déploiement avec suivi des logs
echo ""
echo "3/4 Déploiement en cours..."
clever deploy --follow

# 4. Affichage du statut final
echo ""
echo "4/4 Vérification du statut final..."
sleep 5
clever status

echo ""
echo "=== Déploiement Terminé ==="
echo "🚀 Application déployée avec scaling intelligent"
echo "📊 Monitoring : clever logs"
echo "🔧 Status : clever status"
echo ""
echo "Le scaling se réduira automatiquement après démarrage réussi."