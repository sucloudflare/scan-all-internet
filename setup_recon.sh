#!/bin/bash
set -e

echo "=============================="
echo " RECON STACK INSTALLER"
echo "=============================="

# Atualização
sudo apt update && sudo apt upgrade -y

# Dependências base
sudo apt install -y \
  python3 python3-pip python3-full python3.12-venv \
  golang-go git curl wget unzip jq nmap build-essential

# Virtualenv Python
if [ ! -d "$HOME/bb-env" ]; then
  python3 -m venv ~/bb-env
fi

source ~/bb-env/bin/activate

pip install --upgrade pip
pip install requests httpx aiohttp pandas

# PATH Go
if ! grep -q "go/bin" ~/.bashrc; then
  echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
fi

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# Ferramentas Go
GO111MODULE=on go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
GO111MODULE=on go install github.com/projectdiscovery/httpx/cmd/httpx@latest
GO111MODULE=on go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
GO111MODULE=on go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# Templates nuclei
~/go/bin/nuclei -update-templates

# Estrutura do projeto
mkdir -p ~/recon-lab/{targets,results,scripts}

echo "example.com" > ~/recon-lab/targets/targets.txt

echo "=============================="
echo " INSTALAÇÃO FINALIZADA"
echo "=============================="
echo "Ative o ambiente: source ~/bb-env/bin/activate"
