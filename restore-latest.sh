#!/bin/bash
# restore-latest-force.sh - Restaure en ignorant les erreurs de vue

LOCAL_DB_NAME="base_pvt_locale"
LOCAL_DB_USER="root"
LOCAL_DB_PASS="Her1n0mena"
BACKUP_DIR="/home/herinomena/proj_n8n/n8n-workflows"

# Trouver le dernier backup
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/pivotdb_backup_*.sql.gz | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Aucun backup trouvé"
    exit 1
fi

echo "📦 Dernier backup : $(basename "$LATEST_BACKUP")"
echo "🗄️  Restauration vers : $LOCAL_DB_NAME (mode forcé)"

# Créer la base si elle n'existe pas
mysql -h localhost -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $LOCAL_DB_NAME;"

# Option 1: Ignorer les erreurs et continuer
gunzip -c "$LATEST_BACKUP" | mysql -f -h localhost -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" "$LOCAL_DB_NAME" 2>/tmp/mysql_errors.log

if [ $? -eq 0 ]; then
    echo "✅ Restauration terminée (avec avertissements)"
else
    echo "⚠️  Restauration avec erreurs - Voir /tmp/mysql_errors.log"
fi

# Afficher les erreurs
echo ""
echo "📋 Résumé des erreurs :"
grep -i error /tmp/mysql_errors.log | head -10
