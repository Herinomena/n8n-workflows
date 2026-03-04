#!/bin/sh
# restore-force-to-local.sh - Force la restauration dans la base locale

export PATH="$HOME/.local/bin:$PATH"
DOCKER="/home/node/.local/bin/docker"
cd /home/node/n8n-workflows || exit 1

LOCAL_DB_NAME="base_pvt_locale"
LOCAL_DB_USER="root"
LOCAL_DB_PASS="Her1n0mena"
DB_HOST="172.17.0.1"

echo "🔄 RESTAURATION FORCÉE vers $LOCAL_DB_NAME"
echo "=========================================="

# Prendre le dernier backup
LATEST_BACKUP=$(ls -t pivotdb_backup_*.sql.gz | grep -v "201105" | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Aucun backup trouvé"
    exit 1
fi

BACKUP_SIZE=$(ls -lh "$LATEST_BACKUP" | awk '{print $5}')
echo "📦 Backup: $LATEST_BACKUP ($BACKUP_SIZE)"

# Étape 1: Supprimer et recréer la base cible
echo "🗑️  Suppression et recréation de la base '$LOCAL_DB_NAME'..."
"$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" -e "DROP DATABASE IF EXISTS $LOCAL_DB_NAME; CREATE DATABASE $LOCAL_DB_NAME;"

# Étape 2: Restaurer en forçant l'utilisation de la bonne base
echo "⏳ Restauration des données (injection de 'USE $LOCAL_DB_NAME')..."

# Cette ligne est la clé : elle décompresse le backup et ajoute "USE ...;" au début
# avant de tout envoyer à la commande mysql.
(echo "USE \`$LOCAL_DB_NAME\`;" && gunzip -c "$LATEST_BACKUP") | \
  "$DOCKER" run --rm -i mysql:8.0 mysql -f -h "$DB_HOST" -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" 2>/tmp/restore_error.log

if [ $? -eq 0 ]; then
    echo "✅ Commande de restauration exécutée avec succès."

    # Vérification du nombre de tables
    TABLE_COUNT=$("$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$LOCAL_DB_NAME' AND TABLE_TYPE = 'BASE TABLE';" -sN)
    echo "📊 Tables trouvées dans $LOCAL_DB_NAME après restauration : $TABLE_COUNT"

    if [ "$TABLE_COUNT" -gt 0 ]; then
        echo "✅ Succès ! Les tables ont été restaurées."
    else
        echo "⚠️  Attention : La restauration s'est terminée mais aucune table n'a été trouvée."
        echo "   Vérifions le contenu du backup :"
        echo "   --------------------------------------------------"
        gunzip -c "$LATEST_BACKUP" | grep "^CREATE TABLE" | head -5
        echo "   --------------------------------------------------"
        echo "   Si des commandes 'CREATE TABLE' apparaissent, le problème est ailleurs."
    fi
else
    echo "❌ Erreur lors de la restauration"
    cat /tmp/restore_error.log | head -20
    exit 1
fi

# Nettoyage
rm -f /tmp/restore_error.log
