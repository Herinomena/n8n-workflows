#!/bin/sh
# executer-tout-mysql.sh - Version avec conteneur mysql-client

export PATH="$HOME/.local/bin:$PATH"
DOCKER="/home/node/.local/bin/docker"

DB_USER="root"
DB_PASS="Her1n0mena"
DB_HOST="172.17.0.1"
DB_NAME="base_pvt_locale"

echo "=================================="
echo "EXÉCUTION DES SCRIPTS DASHBOARD"
echo "=================================="
echo ""

# Utiliser un conteneur avec mysql-client
docker run --rm \
  -v /home/herinomena/Images/backup_Dashboard/Dash_vers_DHIS2:/scripts \
  -v /var/run/docker.sock:/var/run/docker.sock \
  alpine:latest \
  sh -c "
    # Installer mysql-client
    apk add --no-cache mysql-client bash > /dev/null 2>&1
    
    cd /scripts
    echo '📂 Dossiers trouvés :'
    
    TOTAL=0
    SUCCESS=0
    
    for dossier in EXCEL FIXE KOBO MALNUT PEC Registre SECTO TB; do
        if [ -d \"\$dossier\" ]; then
            echo ''
            echo \"📂 \$dossier\"
            cd \"\$dossier\"
            
            for script in *.sh; do
                if [ -f \"\$script\" ] && [ \"\$script\" != \"tout_*.sh\" ]; then
                    echo -n \"  ⚙️  \$script... \"
                    
                    # Rendre exécutable et exécuter
                    chmod +x \"\$script\" 2>/dev/null
                    
                    # Capturer la sortie
                    OUTPUT=\$(./\"\$script\" 2>&1)
                    RESULT=\$?
                    
                    if [ \$RESULT -eq 0 ]; then
                        echo \"✅\"
                        SUCCESS=\$((SUCCESS + 1))
                    else
                        echo \"❌\"
                        echo \"     Erreur: \$OUTPUT\" | head -1
                    fi
                    TOTAL=\$((TOTAL + 1))
                fi
            done
            cd /scripts
        fi
    done
    
    echo ''
    echo \"📊 Total: \$TOTAL, Réussis: \$SUCCESS\"
  "

echo ""
echo "=================================="
echo "VÉRIFICATION DES TABLES"
echo "=================================="

# Vérifier les tables
TABLE_COUNT=$("$DOCKER" run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND TABLE_TYPE = 'BASE TABLE';" -sN 2>/dev/null)
echo "📊 Tables dans $DB_NAME : $TABLE_COUNT"

echo ""
echo "✅ Terminé"
