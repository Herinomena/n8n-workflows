#!/bin/bash
# executer-tout.sh - Exécute tous les scripts de tous les dossiers

# Couleurs pour l'affichage
VERT='\033[0;32m'
BLEU='\033[0;34m'
ROUGE='\033[0;31m'
JAUNE='\033[1;33m'
NC='\033[0m'

# Configuration
DB_USER="root"
DB_PASS="Her1n0mena"
DB_NAME="base_pvt_locale"

echo -e "${BLEU}================================${NC}"
echo -e "${BLEU}EXÉCUTION DE TOUS LES SCRIPTS${NC}"
echo -e "${BLEU}================================${NC}"
echo ""

# Se placer dans le répertoire
cd "$(dirname "$0")" || exit 1
REPERTOIRE_PARENT=$(pwd)
echo -e "📁 Répertoire : $REPERTOIRE_PARENT"
echo ""

# Dossiers à traiter
DOSSIERS="EXCEL FIXE KOBO MALNUT PEC Registre SECTO TB"

TOTAL_SCRIPTS=0
SCRIPTS_REUSSIS=0
SCRIPTS_ECHEC=0

for dossier in $DOSSIERS; do
    chemin="$REPERTOIRE_PARENT/$dossier"
    
    if [ ! -d "$chemin" ]; then
        continue
    fi
    
    echo -e "${BLEU}--------------------------------${NC}"
    echo -e "📂 Dossier : ${JAUNE}$dossier${NC}"
    echo -e "${BLEU}--------------------------------${NC}"
    
    cd "$chemin" || continue
    
    for script in *.sh; do
        if [ -f "$script" ] && [[ "$script" != "tout_*.sh" ]]; then
            echo -n "  ⚙️  $script... "
            
            chmod +x "$script" 2>/dev/null
            ./"$script" > /dev/null 2>&1
            
            if [ $? -eq 0 ]; then
                echo -e "${VERT}✅${NC}"
                ((SCRIPTS_REUSSIS++))
            else
                echo -e "${ROUGE}❌${NC}"
                ((SCRIPTS_ECHEC++))
            fi
            ((TOTAL_SCRIPTS++))
        fi
    done
    
    cd "$REPERTOIRE_PARENT"
    echo ""
done

# Résumé
echo -e "${BLEU}================================${NC}"
echo -e "${BLEU}RÉSUMÉ FINAL${NC}"
echo -e "${BLEU}================================${NC}"
echo -e "📊 Total scripts : ${JAUNE}$TOTAL_SCRIPTS${NC}"
echo -e "✅ Réussis : ${VERT}$SCRIPTS_REUSSIS${NC}"
echo -e "❌ Échecs : ${ROUGE}$SCRIPTS_ECHEC${NC}"

# Vérification MySQL
echo ""
echo -e "${BLEU}--------------------------------${NC}"
echo -e "🔍 VÉRIFICATION DES TABLES"
echo -e "${BLEU}--------------------------------${NC}"

TABLE_COUNT=$(mysql -u "$DB_USER" -p"$DB_PASS" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND TABLE_TYPE = 'BASE TABLE';" -sN 2>/dev/null)

if [ -n "$TABLE_COUNT" ]; then
    echo -e "📊 Tables dans $DB_NAME : ${JAUNE}$TABLE_COUNT${NC}"
else
    echo -e "${ROUGE}❌ Impossible de se connecter à MySQL${NC}"
fi

echo ""
echo -e "${VERT}✅ Processus terminé !${NC}"
