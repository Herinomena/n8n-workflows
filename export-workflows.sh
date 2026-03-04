#!/bin/bash

# Configuration
N8N_URL="http://localhost:5678"
EXPORT_DIR="exports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
EXPORT_FILE="n8n_workflows_${TIMESTAMP}.json"

# Créer le répertoire d'export s'il n'existe pas
mkdir -p "$EXPORT_DIR"

# Exporter tous les workflows
echo "📤 Exportation des workflows depuis n8n..."
curl -X GET "$N8N_URL/api/v1/workflows" \
  -H "accept: application/json" > "$EXPORT_DIR/$EXPORT_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Export réussi : $EXPORT_DIR/$EXPORT_FILE"
    
    # Afficher le nombre de workflows exportés
    COUNT=$(jq '.data | length' "$EXPORT_DIR/$EXPORT_FILE" 2>/dev/null || echo "inconnu")
    echo "📊 Nombre de workflows : $COUNT"
    
    # Créer une copie avec un nom fixe pour le déploiement
    cp "$EXPORT_DIR/$EXPORT_FILE" "$EXPORT_DIR/workflows_latest.json"
    echo "📋 Copie créée : $EXPORT_DIR/workflows_latest.json"
else
    echo "❌ Erreur lors de l'export"
    exit 1
fi
