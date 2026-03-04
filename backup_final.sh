#!/bin/sh
# backup_final.sh - Avec PATH explicite

# Charger le PATH personnel
export PATH="$HOME/.local/bin:$PATH"

# Utiliser le répertoire courant
cd "$(dirname "$0")" || exit 1

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="pivotdb_backup_${DATE}.sql"

echo "📤 Sauvegarde de la base MySQL distante pivotdb sur 217.70.190.209..."

# Vérifier que docker est accessible
which docker || echo "docker not found in PATH"

# Utiliser docker (maintenant disponible)
docker run --rm \
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
