#!/bin/sh
# backup_docker_final.sh - Utilise Docker pour le backup

cd /home/herinomena/proj_n8n/n8n-workflows || exit 1

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="pivotdb_backup_${DATE}.sql"

echo "📤 Sauvegarde de la base MySQL distante pivotdb sur 217.70.190.209..."

# Lancer un conteneur MySQL temporaire pour faire le dump
docker run --rm \
  -v "$(pwd)":/backup \
  mysql:8.0 \
  mysqldump -h 217.70.190.209 -u mysqlwb -p'Pivot**15' pivotdb > "$BACKUP_FILE"

# Vérifier si le backup a réussi
if [ -s "$BACKUP_FILE" ]; then
    echo "✅ Sauvegarde réussie : $BACKUP_FILE"
    
    # Compresser
    gzip -f "$BACKUP_FILE"
    echo "📦 Fichier compressé : ${BACKUP_FILE}.gz"
    ls -lh "${BACKUP_FILE}.gz"
else
    echo "❌ Échec de la sauvegarde"
    rm -f "$BACKUP_FILE"
    exit 1
fi
