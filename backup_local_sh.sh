#!/bin/sh

# Trouver d'abord le chemin de mysqldump (exécutez cette commande dans votre terminal)
# which mysqldump
# Typiquement : /usr/bin/mysqldump

# Utiliser le chemin absolu
MYSQLDUMP="/usr/bin/mysqldump"  # Ajustez selon le résultat de 'which mysqldump'

# Répertoire de destination (chemin absolu)
BACKUP_DIR="/home/node/n8n-workflows/"

# Timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/pivotdb_backup_${TIMESTAMP}.sql"
COMPRESSED_FILE="$BACKUP_FILE.gz"

# Variables de connexion MySQL
DB_HOST="217.70.190.209"
DB_NAME="pivotdb"
DB_USER="mysqlwb"  # Remplacez
DB_PASS="Pivot**15"  # Remplacez

echo "📤 Sauvegarde de la base MySQL distante ${DB_NAME} sur ${DB_HOST}..."

# Sauvegarde avec mysqldump
$MYSQLDUMP -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ Sauvegarde réussie : $BACKUP_FILE"
    gzip $BACKUP_FILE
    echo "📦 Fichier compressé : $COMPRESSED_FILE"
    ls -lh $COMPRESSED_FILE
else
    echo "❌ Échec de la sauvegarde"
    exit 1
fi
