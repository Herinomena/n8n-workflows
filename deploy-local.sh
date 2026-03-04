!/bin/bash
# deploy-local.sh - Test d'import local

echo "🚀 Test d'import local..."

N8N_API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMWFmNWMxMy02YmRiLTRiZDItYTA5Yi05MjI4MTY5ZTY0ZmEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzcxODcyMzU3fQ.EFFx_2r4c7EGEDL9HQGfZolVAZYF4KIsZuWJOPDsWmo"

for file in exports/*.json; do
  echo "Import de $file..."
  curl -X POST http://localhost:5678/api/v1/workflows \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    -H "Content-Type: application/json" \
    -d @"$file"
  echo ""
done

echo "✅ Test terminé"
