#!/bin/sh
# executer-utilitaire.sh - Utilise un conteneur utilitaire

# Monter le dossier des scripts dans un conteneur Alpine avec les outils nécessaires
docker run --rm \
  -v /home/herinomena/Images/backup_Dashboard/Dash_vers_DHIS2:/scripts \
  -v /home/herinomena/Documents/Export_dashbord_DHIS:/output \
  --network host \
  alpine:latest \
  sh -c "
    # Installer bash, mysql-client, curl
    apk add --no-cache bash mysql-client curl
    
    cd /scripts
    
    # Variables d'environnement
    export MYSQL_USER=root
    export MYSQL_PASSWORD=Her1n0mena
    export MYSQL_HOST=172.17.0.1
    export MYSQL_DATABASE=base_pvt_locale
    
    echo '=================================='
    echo 'EXÉCUTION DES SCRIPTS'
    echo '=================================='
    
    # Créer les fichiers .env
    for dossier in EXCEL FIXE KOBO MALNUT PEC Registre SECTO TB; do
        if [ -d \"\$dossier\" ]; then
            cat > \"\$dossier/.env\" << EOF
MYSQL_USER=\$MYSQL_USER
MYSQL_PASSWORD=\$MYSQL_PASSWORD
MYSQL_HOST=\$MYSQL_HOST
MYSQL_DATABASE=\$MYSQL_DATABASE
EOF
        fi
    done
    
    # Exécuter les scripts
    for dossier in EXCEL FIXE KOBO MALNUT PEC Registre SECTO TB; do
        if [ -d \"\$dossier\" ]; then
            echo ''
            echo \"📂 \$dossier\"
            cd \"\$dossier\"
            
            for script in *.sh; do
                if [ -f \"\$script\" ]; then
                    echo -n \"  ⚙️  \$script... \"
                    bash \"\$script\" > /dev/null 2>&1 && echo \"✅\" || echo \"❌\"
                fi
            done
            cd /scripts
        fi
    done
  "

echo "✅ Terminé"
