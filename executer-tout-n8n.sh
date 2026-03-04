#!/bin/sh
# executer-tout-n8n.sh - Version adaptée pour n8n

export PATH="$HOME/.local/bin:$PATH"
DOCKER="/home/node/.local/bin/docker"

# Configuration MySQL via Docker
DB_USER="root"
DB_PASS="Her1n0mena"
DB_HOST="172.17.0.1"
DB_NAME="base_pvt_locale"

echo "=================================="
echo "EXÉCUTION DES SCRIPTS DASHBOARD"
echo "=================================="
echo ""

# Les scripts sont dans /home/herinomena/Images/backup_Dashboard/Dash_vers_DHIS2 sur l'hôte
# Mais on va les exécuter via un conteneur Docker

# Monter le répertoire des scripts
docker run --rm \
  -v /home/herinomena/Images/backup_Dashboard/Dash_vers_DHIS2:/scripts \
  alpine:latest \
  sh -c "
    cd /scripts
    echo '📂 Contenu du répertoire :'
    ls -la
    
    echo ''
    echo '📂 Dossiers trouvés :'
    for dossier in EXCEL FIXE KOBO MALNUT PEC Registre SECTO TB; do
        if [ -d \"\$dossier\" ]; then
            echo \"  ✓ \$dossier\"
            cd \"\$dossier\"
            for script in *.sh; do
                if [ -f \"\$script\" ]; then
                    echo \"    ⚙️  \$script\"
                    chmod +x \"\$script\"
                    ./\"\$script\" > /dev/null 2>&1 && echo \"      ✅\" || echo \"      ❌\"
                fi
            done
            cd /scripts
        else
            echo \"  ✗ \$dossier (non trouvé)\"
        fi
    done
  "

echo ""
echo "=================================="
echo "VÉRIFICATION DES TABLES"
echo "=================================="

# Vérifier les tables via Docker MySQL
TABLE_COUNT=$("$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND TABLE_TYPE = 'BASE TABLE';" -sN 2>/dev/null)

if [ -n "$TABLE_COUNT" ]; then
    echo "📊 Tables dans $DB_NAME : $TABLE_COUNT"
else
    echo "❌ Impossible de se connecter à MySQL"
    
    # Test de connexion
    echo ""
    echo "🔍 Test de connexion MySQL :"
    "$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" 2>&1 || echo "Échec connexion"
fi

echo ""
echo "✅ Terminé"
