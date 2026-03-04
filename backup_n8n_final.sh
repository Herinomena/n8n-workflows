#!/bin/sh
# backup_n8n_final.sh - Version pour n8n (basée sur votre script qui fonctionne)

# Se placer dans le répertoire de travail (monté depuis l'hôte)
cd /home/node/n8n-workflows || exit 1

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="pivotdb_backup_${DATE}.sql"

echo "📤 Sauvegarde de la base MySQL distante pivotdb sur 217.70.190.209..."

# Utiliser Docker pour lancer mysqldump
# Note: Le chemin /home/node/n8n-workflows est monté sur /home/herinomena/proj_n8n/n8n-workflows
docker run --rm \
  -v /home/herinomena/proj_n8n/n8n-workflows:/backup \
  mysql:8.0 \
  mysqldump -h 217.70.190.209 -u mysqlwb -p'Pivot**15' pivotdb > "/backup/$BACKUP_FILE"

# Vérifier si le backup a réussi
if [ -s "/backup/$BACKUP_FILE" ]; then
    echo "✅ Sauvegarde réussie"
    
    # Compresser le fichier (gzip est disponible)
    gzip -f "$BACKUP_FILE"
    echo "📦 Fichier compressé : ${BACKUP_FILE}.gz"
    ls -lh "${BACKUP_FILE}.gz"
    exit 0
else
    echo "❌ Échec de la sauvegarde"
    rm -f "/backup/$BACKUP_FILE" 2>/dev/null
    exit 1
fi
