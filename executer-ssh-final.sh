#!/bin/sh
# executer-ssh-final.sh - Connexion SSH par clé

HOST_IP="172.17.0.1"
SSH_KEY="/home/node/.ssh/id_rsa"

# Vérifier que la clé SSH existe
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Clé SSH non trouvée: $SSH_KEY"
    echo "Veuillez d'abord copier la clé SSH:"
    echo "docker cp ~/.ssh/id_rsa_n8n n8n:/home/node/.ssh/id_rsa"
    exit 1
fi

# Test de connexion
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no herinomena@$HOST_IP echo "Connexion SSH établie" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Échec de la connexion SSH"
    exit 1
fi

echo "✅ Connexion SSH établie"
echo ""

# Exécuter les scripts
ssh -i "$SSH_KEY" herinomena@$HOST_IP << 'EOF'
    cd /home/herinomena/Images/backup_Dashboard/Dash_vers_DHIS2 || exit 1
    
    echo "=================================="
    echo "EXÉCUTION DES SCRIPTS SUR L'HÔTE"
    echo "=================================="
    
    export MYSQL_USER=root
    export MYSQL_PASSWORD=Her1n0mena
    export MYSQL_HOST=localhost
    export MYSQL_DATABASE=base_pvt_locale
    
    echo "Test de connexion MySQL..."
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Connexion MySQL OK"
    else
        echo "❌ Connexion MySQL échouée"
        exit 1
    fi
    echo ""
    
    # Créer les fichiers .env
    for dossier in EXCEL FIXE KOBO MALNUT PEC Registre SECTO TB; do
        if [ -d "$dossier" ]; then
            cat > "$dossier/.env" << ENVFILE
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_HOST=$MYSQL_HOST
MYSQL_DATABASE=$MYSQL_DATABASE
ENVFILE
            echo "✅ .env créé dans $dossier"
        fi
    done
    
    # Compteurs
    TOTAL=0
    SUCCESS=0
    
    # Exécuter les scripts
    for dossier in EXCEL FIXE KOBO MALNUT PEC Registre SECTO TB; do
        if [ -d "$dossier" ]; then
            echo ""
            echo "📂 $dossier"
            cd "$dossier" || continue
            
            for script in *.sh; do
                if [ -f "$script" ] && [ "$script" != "tout_*.sh" ]; then
                    echo -n "  ⚙️  $script... "
                    
                    chmod +x "$script" 2>/dev/null
                    ./"$script" > /dev/null 2>&1
                    
                    if [ $? -eq 0 ]; then
                        echo "✅"
                        SUCCESS=$((SUCCESS + 1))
                    else
                        echo "❌"
                    fi
                    TOTAL=$((TOTAL + 1))
                fi
            done
            cd ..
        fi
    done
    
    echo ""
    echo "📊 Total: $TOTAL, Réussis: $SUCCESS"
    
    # Vérification finale
    TABLE_COUNT=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$MYSQL_DATABASE' AND TABLE_TYPE = 'BASE TABLE';" -sN)
    echo "📊 Tables: $TABLE_COUNT"
EOF

echo "✅ Scripts exécutés sur l'hôte"
