#!/bin/sh
# test-un-script.sh - Teste un script spécifique

cd /home/node/n8n-workflows/Dash_vers_DHIS2/EXCEL || exit 1

echo "=== TEST DU SCRIPT DB_EX_CHRD.sh ==="
echo ""

# Vérifier si le script existe
if [ ! -f "DB_EX_CHRD.sh" ]; then
    echo "❌ Script non trouvé"
    exit 1
fi

echo "📄 Contenu du script (premières lignes):"
head -20 DB_EX_CHRD.sh
echo ""

# Vérifier les dépendances
echo "🔍 Vérification des dépendances:"
echo "- bash: $(command -v bash || echo 'non trouvé')"
echo "- mysql: $(command -v mysql || echo 'non trouvé')"
echo "- curl: $(command -v curl || echo 'non trouvé')"
echo ""

# Tester la connexion MySQL
echo "📊 Test connexion MySQL:"
mysql -h 172.17.0.1 -u root -p'Her1n0mena' -e "SELECT 1;" 2>&1 && echo "✅ OK" || echo "❌ Échec"

echo ""
echo "=== FIN DU TEST ==="
