#!/bin/bash
set -e
echo "=== Limpeza do repositório: .env e node_modules ==="

# 1. Criar/atualizar .gitignore
cat > .gitignore << 'EOF'
# Environment variables (contains keys — never commit)
.env
.env.local
.env.*.local

# Dependencies
node_modules/

# Expo / native build output
.expo/
ios/
android/

# Logs
*.log
npm-debug.*

# OS
.DS_Store
EOF

# 2. Instalar o git-filter-repo (ferramenta oficial recomendada pelo GitHub)
pip install git-filter-repo --break-system-packages

# 3. Remover .env e node_modules de TODO o histórico do repositório
git filter-repo --path .env --path node_modules --invert-paths --force

# 4. O filter-repo remove o remote por segurança — readicionar
git remote add origin https://github.com/pattarogustavo/Valura.git

# 5. Commitar o .gitignore (o filter-repo já rodou, então isso é um commit novo em cima do histórico limpo)
git add .gitignore
git commit -m "Add .gitignore to prevent .env and node_modules from being tracked"

echo ""
echo "=== Histórico limpo localmente. Confirmando que sumiu: ==="
git log --all --full-history -- .env | head -5
echo "(vazio acima = .env não existe mais em nenhum commit)"
echo ""
echo "Proximo passo: rodar 'git push origin main --force' MANUALMENTE apos revisar."
