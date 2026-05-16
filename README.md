# Mini Recon Pipeline (Bug Bounty / Attack Surface Research)

Este projeto mostra como montar um pipeline básico inspirado em ferramentas usadas por pesquisadores de segurança e plataformas como entity["company","Shodan","search engine for internet-connected devices"] e entity["company","Censys","internet intelligence company"].

> Objetivo: descobrir ativos autorizados, validar serviços expostos, identificar tecnologias e encontrar vulnerabilidades conhecidas.

---

## Stack usada

### entity["software","Subfinder","ProjectDiscovery subdomain enumerator"]

Enumera subdomínios.

```bash
subfinder -d target.com -silent
```

---

### entity["software","ZMap","network scanner"]

Escaneia portas em alta velocidade.

```bash
sudo zmap -p 443 1.1.1.0/24
```

Usado para:

* descobrir hosts vivos
* identificar superfícies expostas
* scan massivo

---

### entity["software","httpx","ProjectDiscovery HTTP toolkit"]

Fingerprint HTTP.

```bash
cat subs.txt | httpx -title -tech-detect -status-code
```

Detecta:

* tecnologias
* título da página
* status code
* redirecionamentos

---

### entity["software","Nuclei","ProjectDiscovery vulnerability scanner"]

Executa templates de CVE.

```bash
cat subs.txt | nuclei -severity critical,high,medium
```

Exemplo de vulnerabilidades históricas:

* entity["historical_event","Log4Shell","CVE-2021-44228 vulnerability"]
* entity["historical_event","Apache HTTP Server Path Traversal Vulnerability","CVE-2021-41773"]

---

### entity["software","Nmap","network scanner"]

Validação manual.

```bash
nmap -sV target.com
```

---

# Fluxo completo

```text
Subfinder
↓
ZMap
↓
httpx
↓
Nuclei
↓
Nmap manual
```

---

# Script automático

Crie um arquivo:

```bash
nano recon_pipeline.sh
```

Cole o código abaixo:

```bash
#!/bin/bash

TARGET=$1

if [ -z "$TARGET" ]; then
  echo "Uso: ./recon_pipeline.sh dominio.com"
  exit 1
fi

mkdir -p results/$TARGET


echo "[1] Enumerando subdomínios..."
subfinder -d $TARGET -silent -o results/$TARGET/subs.txt


echo "[2] HTTP fingerprint..."
cat results/$TARGET/subs.txt | httpx \
-title \
-tech-detect \
-status-code \
-o results/$TARGET/httpx.txt


echo "[3] Rodando nuclei..."
cat results/$TARGET/subs.txt | nuclei \
-severity critical,high,medium \
-o results/$TARGET/nuclei.txt


echo "[4] Validação manual com Nmap (top 10 hosts)..."
cat results/$TARGET/subs.txt | head -10 | while read host
 do
   nmap -sV $host >> results/$TARGET/nmap.txt
 done


echo "Recon finalizado."
echo "Resultados salvos em: results/$TARGET/"
```

---

# Permissão

```bash
chmod +x recon_pipeline.sh
```

---

# Executar

```bash
./recon_pipeline.sh example.com
```

---

# Estrutura de pastas

```text
project/
 ├── recon_pipeline.sh
 ├── README.md
 └── results/
```

---

# Exemplo real de uso

```bash
./recon_pipeline.sh hackerone.com
```

ou laboratórios:

* entity["software","OWASP Juice Shop","intentionally vulnerable web application"]
* entity["software","Metasploitable","intentionally vulnerable machine"]

---

# Como sistemas estilo Shodan funcionam

Pipeline parecido:

```text
ZMap → descobre IPs
ZGrab2 → coleta banners
Banco de dados
Motor de busca
```

Ferramenta relacionada:

entity["software","ZGrab2","application layer banner grabber"]

---

# Uso responsável

Use apenas em:

* laboratórios
* ativos próprios
* programas autorizados de bug bounty como entity["company","HackerOne","bug bounty platform"] e entity["company","Bugcrowd","bug bounty platform"]

Sempre confira escopo antes de escanear.

---

# Melhorias futuras

* integração com entity["software","dnsx","ProjectDiscovery DNS toolkit"]
* screenshots automáticos
* classificação por severidade
* export para JSON
* dashboard próprio estilo entity["company","Shodan","search engine for internet-connected devices"]
