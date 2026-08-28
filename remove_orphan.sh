#!/bin/bash
set -e
echo "Removendo arquivo orfao SwipeableRow.tsx (nao usado na versao atual)..."

rm -f src/components/SwipeableRow.tsx

npx tsc --noEmit
echo "TypeScript OK."

echo "Confirmando ausencia de imports nativos novos..."
if grep -rlE "from 'react-native-gesture-handler'|from 'react-native-purchases'|from \"react-native-gesture-handler\"|from \"react-native-purchases\"" app/ src/ 2>/dev/null; then
  echo "AVISO: ainda ha import nativo, revisar"
else
  echo "OK: seguro para o binario ja instalado"
fi

git add -A
git commit -m "Remove orphaned SwipeableRow.tsx (gesture-handler not available in current binary)"
git push

echo ""
echo "Pronto! Agora roda:"
echo "  npx expo start --dev-client --tunnel --clear"
