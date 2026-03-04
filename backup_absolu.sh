#!/bin/sh
# backup_absolu.sh - Avec chemin absolu de docker

cd "$(dirname "$0")" || exit 1

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="pivotdb_backup_${DATE}.sql"

echo "📤 Sauvegarde de la base MySQL distante pivotdb sur 217.70.190.209..."

# Utiliser le chemin absolu de docker
/home/node/.local/bin/docker run --rm \
  -v "$(pwd)":/backup \
  mysql:8.0 \
  mysqldump -h 217.70.190.209 -u mysqlwb -p'Pivot**15' pivotdb > "$BACKUP_FILE"

if [ -s "$BACKUP_FILE" ]; then
    echo "✅ Sauvegarde réussie : $BACKUP_FILE"
    gzip -f "$BACKUP_FILE"
    echo "📦 Fichier compressé : ${BACKUP_FILE}.gz"
    ls -lh "${BACKUP_FILE}.gz"
    exit 0
else
    echo "❌ Échec de la sauvegarde"
    rm -f "$BACKUP_FILE" 2>/dev/null
    exit 1
fi
