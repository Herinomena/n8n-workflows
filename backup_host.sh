#!/bin/sh
# backup_host.sh - Version corrigée

cd /home/herinomena/proj_n8n/n8n-workflows || exit 1

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="pivotdb_backup_${DATE}.sql"

# Créer un répertoire temporaire avec les bons droits
TMP_DIR="/tmp/mysql_backup_$$"
mkdir -p "$TMP_DIR"
chmod 777 "$TMP_DIR"

# Exécuter mysqldump dans le conteneur et sauvegarder dans le répertoire temporaire
docker run --rm \
  -v "$TMP_DIR":/backup \
  mysql:8.0 \
  mysqldump -h 217.70.190.209 -u root -p'P@ssw0rd' pivotdb > "$TMP_DIR/$BACKUP_FILE"

# Copier le fichier vers votre répertoire de travail
cp "$TMP_DIR/$BACKUP_FILE" "./$BACKUP_FILE"

# Compresser
gzip -f "$BACKUP_FILE"

# Nettoyer
rm -rf "$TMP_DIR"

echo "✅ Backup créé: ${BACKUP_FILE}.gz"
ls -lh "${BACKUP_FILE}.gz"
