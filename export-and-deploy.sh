#!/bin/bash
# export-and-deploy-github.sh - Exporte les workflows n8n et les push sur GitHub

# Configuration
REPO_PATH="/home/herinomena/proj_n8n/n8n-workflows"

# OU
 GITHUB_REPO="https://github.com/Herinomena/n8n-workflows"  # URL HTTPS

BRANCH="main"  # ou master selon votre config
API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiMTQxZGVmMy0zYWE5LTQ3NjUtOTE2MS1iMzcxMjg3OWRiYTIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiZDhjNzkzMzctYjI1YS00MDAwLThkNDItYjY1OWNmZWY1MjNkIiwiaWF0IjoxNzcyNTkxOTI4fQ.qrIrC5b8NuTVxQU_UBBQeeWzOLV2DEafsAqCAxnz6i8"  # À remplacer par votre clé API n8n

DATE=$(date +%Y%m%d_%H%M%S)
EXPORT_DIR="$REPO_PATH/exports"
EXPORT_FILE="$EXPORT_DIR/n8n_workflows_$DATE.json"
COMMIT_MSG="🔄 Backup auto n8n workflows - $DATE"

echo "🚀 Début du processus d'export et déploiement GitHub..."

# 1. Vérifier que le repo git existe
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "❌ Le répertoire n'est pas un dépôt git"
    echo "📦 Initialisation du dépôt git..."
    cd "$REPO_PATH" || exit 1
    git init
    git remote add origin "$GITHUB_REPO"
fi

# 2. Créer le répertoire d'export
mkdir -p "$EXPORT_DIR"

# 3. Exporter depuis n8n (avec API)
echo "📤 Exportation des workflows depuis n8n..."
curl -s -X GET http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Accept: application/json" > "$EXPORT_FILE"

# 4. Vérifier l'export
WORKFLOW_COUNT=$(jq '. | length' "$EXPORT_FILE" 2>/dev/null || echo "0")

if [ "$WORKFLOW_COUNT" -gt 0 ] && [ -s "$EXPORT_FILE" ]; then
    echo "✅ Export réussi : $WORKFLOW_COUNT workflows"
    
    # Compression
    gzip -f "$EXPORT_FILE"
    echo "📦 Fichier compressé : ${EXPORT_FILE}.gz"
    
    # Export individuel par workflow (optionnel)
    mkdir -p "$EXPORT_DIR/individual"
    jq -c '.[]' "$EXPORT_FILE" | while read -r workflow; do
        NAME=$(echo "$workflow" | jq -r '.name' | sed 's/[ /]/_/g')
        echo "$workflow" | jq '.' > "$EXPORT_DIR/individual/${NAME}.json"
    done
    echo "📁 Exports individuels créés dans exports/individual/"
    
else
    echo "⚠️ Aucun workflow exporté, tentative depuis la base de données..."
    
    # Fallback: export depuis SQLite
    sqlite3 "$REPO_PATH/database.sqlite" << EOF
.mode json
.output $EXPORT_FILE
SELECT * FROM workflow_entity;
.output stdout
EOF
    WORKFLOW_COUNT=$(jq '. | length' "$EXPORT_FILE")
    echo "📊 Workflows trouvés dans DB : $WORKFLOW_COUNT"
fi

# 5. Générer un README avec le statut
cat > "$EXPORT_DIR/README.md" << EOF
# Backup n8n Workflows

Dernier backup : $(date)
Nombre de workflows : $WORKFLOW_COUNT

## Structure
- \`n8n_workflows_*.json.gz\` : Archive complète
- \`individual/*.json\` : Workflows individuels

## Workflows présents :
$(jq -r '.[] | "- " + .name' "$EXPORT_FILE" 2>/dev/null || echo "- Aucun workflow")
EOF

# 6. Git: add, commit, push
cd "$REPO_PATH" || exit 1

echo "📦 Préparation du commit git..."

# Ajouter les fichiers
git add exports/
git add *.sh
git add docker-compose.yml
git add README.md 2>/dev/null || true

# Commit
git commit -m "$COMMIT_MSG" -m "Workflows exportés: $WORKFLOW_COUNT"

# Push vers GitHub
echo "☁️ Push vers GitHub..."
if git push origin "$BRANCH" 2>/dev/null; then
    echo "✅ Push réussi vers GitHub"
else
    echo "⚠️ Push échoué. Vérifiez votre connexion et les permissions."
    echo "👉 Essayez : git pull origin $BRANCH --rebase puis relancez"
fi

echo ""
echo "✅ Processus terminé !"
echo "📁 Dossier d'export : $EXPORT_DIR"
echo "🔗 GitHub : $GITHUB_REPO"
echo "🕒 Date : $DATE"
