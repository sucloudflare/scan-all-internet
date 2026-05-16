# setup_recon.sh

```bash
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
```

---

# recon_pipeline.sh

```bash
#!/bin/bash
set -e

TARGET_FILE="$HOME/recon-lab/targets/targets.txt"
RESULT_DIR="$HOME/recon-lab/results/$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "$RESULT_DIR"

echo "[1] Enumerando subdomínios..."
subfinder -dL "$TARGET_FILE" -silent -o "$RESULT_DIR/subdomains.txt"

echo "[2] Resolvendo DNS..."
dnsx -l "$RESULT_DIR/subdomains.txt" -silent -resp-only > "$RESULT_DIR/resolved.txt"

echo "[3] Fingerprint HTTP..."
httpx -l "$RESULT_DIR/resolved.txt" \
  -title \
  -tech-detect \
  -status-code \
  -follow-redirects \
  -silent > "$RESULT_DIR/httpx.txt"

echo "[4] Scan CVEs..."
nuclei -l "$RESULT_DIR/resolved.txt" \
  -severity low,medium,high,critical \
  -o "$RESULT_DIR/nuclei.txt"

echo "[5] Validação Nmap..."
head -20 "$RESULT_DIR/resolved.txt" > "$RESULT_DIR/top20.txt"
nmap -iL "$RESULT_DIR/top20.txt" -sV -Pn -oN "$RESULT_DIR/nmap.txt"

echo "[6] Resumo final"
echo "Subdomínios encontrados: $(wc -l < $RESULT_DIR/subdomains.txt)"
echo "IPs resolvidos: $(wc -l < $RESULT_DIR/resolved.txt)"
echo "Hosts HTTP ativos: $(wc -l < $RESULT_DIR/httpx.txt)"
echo "Possíveis vulnerabilidades: $(wc -l < $RESULT_DIR/nuclei.txt)"

echo "Resultados salvos em: $RESULT_DIR"
```

---

# README.md

````markdown
# Mini Recon Pipeline

Pipeline automatizado para:

- Descobrir subdomínios
- Resolver IPs
- Fazer fingerprint HTTP
- Detectar possíveis CVEs
- Validar portas e serviços

Fluxo:

Subfinder -> DNSX -> HTTPX -> Nuclei -> Nmap

---

## Instalação

```bash
chmod +x setup_recon.sh
./setup_recon.sh
````

---

## Adicionar alvos

Edite:

```bash
nano ~/recon-lab/targets/targets.txt
```

Exemplo:

```txt
example.com
hackerone.com
bugcrowd.com
```

---

## Executar pipeline

```bash
chmod +x recon_pipeline.sh
./recon_pipeline.sh
```

---

## Estrutura

```bash
recon-lab/
 ├── targets/
 ├── results/
 └── scripts/
```

---

## Exemplo de uso real

1. Descobrir subdomínios de um programa bug bounty
2. Filtrar quais estão ativos
3. Identificar tecnologias
4. Detectar CVEs conhecidas
5. Validar manualmente

---

## Observação

Use apenas em ambientes autorizados.
Não escaneie infraestrutura sem permissão.

```
```
