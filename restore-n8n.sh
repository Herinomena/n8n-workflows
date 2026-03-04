#!/bin/sh
# restore-n8n-final.sh - Version production avec chemin absolu

DOCKER="/home/node/.local/bin/docker"
cd /home/node/n8n-workflows || exit 1

LOCAL_DB_NAME="base_pvt_locale"
LOCAL_DB_USER="root"
LOCAL_DB_PASS="Her1n0mena"
HOST_BACKUP_DIR="/home/herinomena/proj_n8n/n8n-workflows"
DOCKER_GATEWAY="172.17.0.1"

echo "🔄 Restauration MySQL"
echo "===================="

# Prendre le dernier vrai backup (exclure les petits tests)
LATEST_BACKUP=$(ls -t /home/node/n8n-workflows/pivotdb_backup_*.sql.gz | grep -v "201105" | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Aucun backup trouvé"
    exit 1
fi

BACKUP_FILENAME=$(basename "$LATEST_BACKUP")
BACKUP_SIZE=$(ls -lh "$LATEST_BACKUP" | awk '{print $5}')
echo "📦 Backup: $BACKUP_FILENAME ($BACKUP_SIZE)"

# Restaurer avec l'option -f pour ignorer les erreurs de vues
echo "⏳ Restauration en cours..."
"$DOCKER" run --rm \
  -v "$HOST_BACKUP_DIR:/backup" \
  mysql:8.0 \
  sh -c "gunzip -c /backup/$BACKUP_FILENAME | mysql -f -h $DOCKER_GATEWAY -u $LOCAL_DB_USER -p$LOCAL_DB_PASS $LOCAL_DB_NAME 2>&1"

if [ $? -eq 0 ]; then
    echo "✅ Restauration réussie (avec avertissements possibles)"
    
    # Optionnel : Compter les tables
    TABLE_COUNT=$("$DOCKER" run --rm mysql:8.0 mysql -h $DOCKER_GATEWAY -u $LOCAL_DB_USER -p$LOCAL_DB_PASS -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$LOCAL_DB_NAME';" -sN 2>/dev/null)
    echo "📊 Tables dans la base : ${TABLE_COUNT:-inconnu}"
else
    echo "❌ Erreur lors de la restauration"
    exit 1
fi
