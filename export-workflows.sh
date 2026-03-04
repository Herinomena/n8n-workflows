#!/bin/bash
# export-workflows.sh - Version avec clé API

API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiMTQxZGVmMy0zYWE5LTQ3NjUtOTE2MS1iMzcxMjg3OWRiYTIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiZDhjNzkzMzctYjI1YS00MDAwLThkNDItYjY1OWNmZWY1MjNkIiwiaWF0IjoxNzcyNTkxOTI4fQ.qrIrC5b8NuTVxQU_UBBQeeWzOLV2DEafsAqCAxnz6i8"  # Remplacez par votre vraie clé

DATE=$(date +%Y%m%d_%H%M%S)
EXPORT_FILE="exports/n8n_workflows_${DATE}.json"

echo "📤 Exportation des workflows depuis n8n..."

# Exporter depuis l'API
curl -s -X GET http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Accept: application/json" > "$EXPORT_FILE"

API_COUNT=$(jq '. | length' "$EXPORT_FILE")
echo "✅ Export API : $API_COUNT workflows"

# Exporter depuis la base de données (tous les workflows)
echo "📦 Export complet depuis la base de données..."
sqlite3 database.sqlite << EOF
.mode json
.output exports/all_workflows_${DATE}.json
SELECT * FROM workflow_entity;
.output stdout
EOF

DB_COUNT=$(jq '. | length' "exports/all_workflows_${DATE}.json")
echo "✅ Export DB : $DB_COUNT workflows"

# Créer des copies avec noms fixes
cp "$EXPORT_FILE" "exports/workflows_latest.json"
cp "exports/all_workflows_${DATE}.json" "exports/all_workflows_latest.json"

echo ""
echo "📊 RÉSUMÉ"
echo "=========="
echo "API (workflows actifs) : $API_COUNT"
echo "Base de données (tous) : $DB_COUNT"
echo ""
echo "📁 Fichiers créés :"
echo "  - exports/n8n_workflows_${DATE}.json ($API_COUNT workflows)"
echo "  - exports/all_workflows_${DATE}.json ($DB_COUNT workflows)"
echo "  - exports/workflows_latest.json (copie API)"
echo "  - exports/all_workflows_latest.json (copie DB)"
