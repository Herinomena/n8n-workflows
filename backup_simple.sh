#!/bin/sh
# backup_simple.sh - Utilise mysqldump de l'hôte directement

cd /home/herinomena/proj_n8n/n8n-workflows || exit 1

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="pivotdb_backup_${DATE}.sql"

# Utiliser mysqldump de l'hôte (pas de Docker)
/usr/bin/mysqldump -h 217.70.190.209 -u root -p'P@ssw0rd' pivotdb > "$BACKUP_FILE"

# Vérifier que le fichier a été créé
if [ -f "$BACKUP_FILE" ]; then
    # Compresser
    gzip -f "$BACKUP_FILE"
    echo "✅ Backup créé: ${BACKUP_FILE}.gz"
    ls -lh "${BACKUP_FILE}.gz"
else
    echo "❌ Échec de la création du backup"
    exit 1
fi
