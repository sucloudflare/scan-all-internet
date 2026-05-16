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
