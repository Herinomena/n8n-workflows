#!/bin/sh
# diagnostic-restore.sh - Vérifie où sont réellement les tables

export PATH="$HOME/.local/bin:$PATH"
DOCKER="/home/node/.local/bin/docker"
cd /home/node/n8n-workflows || exit 1

LOCAL_DB_NAME="base_pvt_locale"
LOCAL_DB_USER="root"
LOCAL_DB_PASS="Her1n0mena"
DB_HOST="172.17.0.1"

echo "🔍 DIAGNOSTIC COMPLET DE LA RESTAURATION"
echo "========================================"

# 1. Lister toutes les bases de données
echo ""
echo "📋 BASES DE DONNÉES DISPONIBLES :"
"$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" -e "SHOW DATABASES;" 2>/dev/null

# 2. Chercher des tables dans toutes les bases (sauf systemes)
echo ""
echo "🔎 RECHERCHE DE TABLES DANS CHAQUE BASE :"
for DB in $("$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" -e "SHOW DATABASES;" -s 2>/dev/null | grep -v "Database\|information_schema\|performance_schema\|mysql\|sys"); do
    if [ -n "$DB" ]; then
        TABLE_COUNT=$("$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB' AND TABLE_TYPE = 'BASE TABLE';" -sN 2>/dev/null)
        echo "- $DB : $TABLE_COUNT tables"
        
        if [ "$TABLE_COUNT" -gt 0 ]; then
            echo "  Tables dans $DB :"
            "$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" -e "USE $DB; SHOW TABLES;" 2>/dev/null | tail -n +2 | head -5
            if [ "$TABLE_COUNT" -gt 5 ]; then
                echo "  ... et $(($TABLE_COUNT - 5)) autres"
            fi
        fi
    fi
done

# 3. Examiner le contenu du backup
echo ""
echo "📦 ANALYSE DU DERNIER BACKUP :"
LATEST_BACKUP=$(ls -t pivotdb_backup_*.sql.gz | grep -v "201105" | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    echo "Fichier: $LATEST_BACKUP"
    echo "Premières lignes du backup (recherche de CREATE DATABASE/USE) :"
    gunzip -c "$LATEST_BACKUP" | head -50 | grep -i "create database\|use \`\|create table" | head -10
fi

echo ""
echo "✅ Diagnostic terminé"
