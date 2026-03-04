#!/bin/sh
# executer-debug.sh - Version avec logs détaillés

echo "=== DÉBUT DE L'EXÉCUTION ==="
echo "Date: $(date)"
echo ""

# Créer un fichier de log
LOG_FILE="/tmp/execution_debug_$$.log"
exec 2>&1 > "$LOG_FILE"

# Chercher le répertoire
echo "Recherche du répertoire..."
for path in \
    "/home/node/backup_Dashboard/Dash_vers_DHIS2" \
    "/home/node/n8n-workflows/Dash_vers_DHIS2" \
    "/home/herinomena/Images/backup_Dashboard/Dash_vers_DHIS2" \
    "/home/node/n8n-workflows/backup_Dashboard/Dash_vers_DHIS2"; do
    if [ -d "$path" ]; then
        echo "✅ Répertoire trouvé: $path"
        cd "$path" || continue
        FOUND=1
        break
    fi
done

if [ -z "$FOUND" ]; then
    echo "❌ Répertoire non trouvé"
    echo "Contenu de /home/node:"
    ls -la /home/node/
    echo ""
    echo "Contenu de /home/node/n8n-workflows:"
    ls -la /home/node/n8n-workflows/
    exit 1
fi

echo ""
echo "📂 Contenu du répertoire:"
ls -la

echo ""
echo "📂 Dossiers disponibles:"
ls -d */ 2>/dev/null || echo "Aucun dossier"

DB_USER="root"
DB_PASS="Her1n0mena"
DB_HOST="172.17.0.1"
DB_NAME="base_pvt_locale"

echo ""
echo "=================================="
echo "TEST DE CONNEXION MYSQL"
echo "=================================="

# Tester MySQL avec Docker
if command -v docker >/dev/null 2>&1; then
    echo "Test de connexion MySQL via Docker..."
    docker run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Connexion MySQL OK"
    else
        echo "❌ Connexion MySQL échouée"
    fi
else
    echo "❌ Docker non trouvé"
fi

echo ""
echo "=================================="
echo "FIN DU DIAGNOSTIC"
echo "=================================="

# Afficher le log
echo ""
echo "=== LOG COMPLET ==="
cat "$LOG_FILE"

# Nettoyer
rm -f "$LOG_FILE"
