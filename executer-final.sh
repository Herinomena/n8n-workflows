#!/bin/sh
# executer-final.sh - Version avec le chemin du volume monté

# Chemin dans le conteneur (monté depuis l'hôte)
cd /home/node/backup_Dashboard/Dash_vers_DHIS2 2>/dev/null || \
cd /home/node/n8n-workflows/Dash_vers_DHIS2 2>/dev/null || \
cd /home/herinomena/Images/backup_Dashboard/Dash_vers_DHIS2 2>/dev/null || {
    echo "❌ Répertoire non trouvé"
    echo "Recherche en cours..."
    find /home/node -name "Dash_vers_DHIS2" -type d 2>/dev/null
    exit 1
}

echo "📂 Répertoire trouvé: $(pwd)"
echo ""

DB_USER="root"
DB_PASS="Her1n0mena"
DB_HOST="172.17.0.1"
DB_NAME="base_pvt_locale"

echo "=================================="
echo "EXÉCUTION DES SCRIPTS DASHBOARD"
echo "=================================="
echo ""

# Lister les dossiers disponibles
echo "📋 Dossiers disponibles :"
ls -la | grep ^d
echo ""

# Compteurs
TOTAL=0
SUCCESS=0

# Fonction pour exécuter les scripts d'un dossier
executer_dossier() {
    dossier=$1
    if [ -d "$dossier" ]; then
        echo ""
        echo "📂 $dossier"
        echo "----------------"
        
        cd "$dossier" || return
        
        for script in *.sh; do
            if [ -f "$script" ] && [ "$script" != "tout_*.sh" ]; then
                echo -n "  ⚙️  $script... "
                
                # Rendre exécutable
                chmod +x "$script" 2>/dev/null
                
                # Exécuter
                ./"$script" > /tmp/script_output.log 2>&1
                
                if [ $? -eq 0 ]; then
                    echo "✅"
                    SUCCESS=$((SUCCESS + 1))
                else
                    echo "❌"
                    echo "     Erreur: $(cat /tmp/script_output.log | head -1)"
                fi
                TOTAL=$((TOTAL + 1))
            fi
        done
        
        cd ..
    fi
}

# Exécuter pour chaque dossier
executer_dossier "EXCEL"
executer_dossier "FIXE"
executer_dossier "KOBO"
executer_dossier "MALNUT"
executer_dossier "PEC"
executer_dossier "Registre"
executer_dossier "SECTO"
executer_dossier "TB"

# Résumé
echo ""
echo "=================================="
echo "📊 RÉSUMÉ"
echo "=================================="
echo "Total scripts: $TOTAL"
echo "Réussis: $SUCCESS"
echo "Échecs: $((TOTAL - SUCCESS))"

# Vérification MySQL
echo ""
echo "=================================="
echo "🔍 VÉRIFICATION DES TABLES"
echo "=================================="

if command -v mysql >/dev/null 2>&1; then
    TABLE_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND TABLE_TYPE = 'BASE TABLE';" -sN 2>/dev/null)
    echo "📊 Tables dans $DB_NAME : $TABLE_COUNT"
else
    echo "⚠️  mysql non trouvé, utilisation de Docker..."
    docker run --rm mysql:8.0 mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND TABLE_TYPE = 'BASE TABLE';" -sN 2>/dev/null
fi

echo ""
echo "✅ Terminé"
