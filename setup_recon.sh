#!/bin/bash

set -e

echo "=============================="
echo " RECON STACK INSTALLER"
echo "=============================="

# ----------------------------
# Atualizar sistema
# ----------------------------
echo "[1] Atualizando pacotes..."
sudo apt update

# ----------------------------
# Pacotes base
# ----------------------------
echo "[2] Instalando dependências base..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-full \
    python3.12-venv \
    golang-go \
    git \
    curl \
    wget \
    unzip \
    jq \
    nmap \
    build-essential

# ----------------------------
# Criar ambiente virtual python
# ----------------------------
echo "[3] Criando virtualenv..."
python3 -m venv ~/bb-env

source ~/bb-env/bin/activate

echo "[4] Instalando libs Python..."
pip install --upgrade pip
pip install requests httpx aiohttp pandas

# ----------------------------
# Configurar Go PATH
# ----------------------------
echo "[5] Configurando PATH do Go..."

if ! grep -q "GOPATH" ~/.bashrc; then
    echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
fi

export PATH=$PATH:$(go env GOPATH)/bin

# ----------------------------
# Instalar ferramentas ProjectDiscovery
# ----------------------------
echo "[6] Instalando ferramentas Go..."

go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# ----------------------------
# Atualizar templates do nuclei
# ----------------------------
echo "[7] Atualizando templates do nuclei..."
~/go/bin/nuclei -update-templates || true

# ----------------------------
# Verificar ZMap
# ----------------------------
echo "[8] Verificando ZMap..."

if command -v zmap &> /dev/null
then
    echo "ZMap já instalado:"
    zmap --version
else
    echo "ZMap não encontrado."
    echo "Repositório oficial:"
    echo ":contentReference[oaicite:9]{index=9}"
fi

# ----------------------------
# Estrutura de pastas
# ----------------------------
echo "[9] Criando estrutura..."

mkdir -p ~/recon-lab/{targets,results,scripts,wordlists}

# ----------------------------
# Arquivo exemplo
# ----------------------------
cat > ~/recon-lab/targets/targets.txt <<EOF
example.com
EOF

# ----------------------------
# Testes finais
# ----------------------------
echo "[10] Testando instalações..."

echo "Nmap:"
nmap --version | head -n 1

echo "httpx:"
~/go/bin/httpx -version || true

echo "nuclei:"
~/go/bin/nuclei -version || true

echo "subfinder:"
~/go/bin/subfinder -version || true

echo ""
echo "========================================"
echo "INSTALAÇÃO FINALIZADA"
echo "========================================"
echo ""
echo "Ative seu ambiente Python com:"
echo "source ~/bb-env/bin/activate"
echo ""
echo "Se necessário recarregue shell:"
echo "source ~/.bashrc"
echo ""
echo "Targets:"
echo "~/recon-lab/targets/targets.txt"
echo ""
echo "Resultados:"
echo "~/recon-lab/results/"
