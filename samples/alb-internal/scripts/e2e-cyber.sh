#!/usr/bin/env bash
# Runs ON the client VM (piped over the IAP SSH tunnel by Taskfile.yml's
# e2e-cyber task, as `bash -s -- "$HOST"` - see there for why: a real script
# avoids the nested-quoting hell of embedding this inline in a --command
# string). No JWT: Cloud Armor is evaluated before IAP, on purpose.
set -euo pipefail

HOST="$1"

BOLD=$'\033[1m'
RESET=$'\033[0m'
GREEN=$'\033[32m'
RED=$'\033[31m'
CYAN=$'\033[36m'

section() {
    echo
    echo "${BOLD}${CYAN}──────────────────────────────────────────────────${RESET}"
    echo "${BOLD}${CYAN}  $1${RESET}"
    echo "${BOLD}${CYAN}──────────────────────────────────────────────────${RESET}"
}

# Fetches $2, prints its full response (status line + headers), and reports
# PASS/FAIL against the expected status code $3.
check() {
    local label="$1" url="$2" expected="$3" resp code
    echo
    echo "${BOLD}▶ ${label}${RESET}"
    echo "  GET ${url}"
    echo
    resp="$(curl -sk -D - -o /dev/null "$url")"
    echo "$resp" | sed 's/^/  /'
    code="$(echo "$resp" | head -n1 | grep -oE '[0-9]{3}')"
    echo
    if [ "$code" = "$expected" ]; then
        echo "  ${GREEN}✅ PASS${RESET} — reçu ${code} (attendu ${expected})"
    else
        echo "  ${RED}❌ FAIL${RESET} — reçu ${code} (attendu ${expected})"
    fi
}

# Comme check(), mais en POST avec un corps JSON. C'est la surface que
# `json_parsing = "STANDARD"` (armor.tf) rend réellement inspectable par le
# WAF : avec le défaut de GCP (DISABLED), Cloud Armor évalue le corps comme
# une chaîne plate uniforme.
check_post() {
    local label="$1" url="$2" payload="$3" expected="$4" resp code
    echo
    echo "${BOLD}▶ ${label}${RESET}"
    echo "  POST ${url}"
    echo "  Content-Type: application/json"
    echo "  Body: ${payload}"
    echo
    resp="$(curl -sk -D - -o /dev/null -X POST \
        -H 'Content-Type: application/json' \
        --data "$payload" "$url")"
    echo "$resp" | sed 's/^/  /'
    code="$(echo "$resp" | head -n1 | grep -oE '[0-9]{3}')"
    echo
    if [ "$code" = "$expected" ]; then
        echo "  ${GREEN}✅ PASS${RESET} — reçu ${code} (attendu ${expected})"
    else
        echo "  ${RED}❌ FAIL${RESET} — reçu ${code} (attendu ${expected})"
    fi
}

section "🛡️  TEST 1/3 — WAF Cloud Armor, query string (SQLi + XSS)"
check "Injection SQL" "https://${HOST}/api/items?id=1'%20OR%20'1'='1" 403
check "Cross-Site Scripting" "https://${HOST}/api/items?q=<script>alert(1)</script>" 403

section "🧬 TEST 2/3 — WAF Cloud Armor, corps JSON (POST)"
echo
echo "  Le test 1 n'exerce que la query string. Cette surface-ci n'est"
echo "  inspectable que parce que la policy déclare json_parsing = STANDARD."

# Le guillemet simple est isolé dans une variable : l'imbriquer directement
# dans la chaîne JSON demanderait un échappement bash illisible.
SQ="'"
check_post "Injection SQL dans le corps JSON" \
    "https://${HOST}/api/items" \
    "{\"name\":\"x${SQ} OR ${SQ}1${SQ}=${SQ}1\"}" \
    403

section "🚦 TEST 3/3 — Rate limiting Cloud Armor (120 requêtes rapides)"
echo
echo "  Envoi de 120 requêtes vers ${HOST}..."
echo "  (seuil de ban : 600 req / 5 min — soit 5 exécutions consécutives de"
echo "   ce test avant bannissement de 10 min par rate_based_ban)"
echo

count_302=0
count_429=0
count_other=0
sample_429=""
for _ in $(seq 1 120); do
    resp="$(curl -sk -D - -o /dev/null "https://${HOST}/api/items")"
    code="$(echo "$resp" | head -n1 | grep -oE '[0-9]{3}')"
    case "$code" in
        302) count_302=$((count_302 + 1)) ;;
        429)
            count_429=$((count_429 + 1))
            [ -z "$sample_429" ] && sample_429="$resp"
            ;;
        *) count_other=$((count_other + 1)) ;;
    esac
done

[ "$count_302" -gt 0 ] && echo "  ${count_302} × 302 — sous le seuil, laissé passer par Cloud Armor"
[ "$count_429" -gt 0 ] && echo "  ${count_429} × 429 — seuil de 100 req/min dépassé, throttlé par Cloud Armor"
[ "$count_other" -gt 0 ] && echo "  ${count_other} × autre — inattendu"

echo
if [ -n "$sample_429" ]; then
    echo "  ${GREEN}✅ PASS${RESET} — le rate-limit Cloud Armor s'est déclenché"
    echo
    echo "  Exemple de réponse 429 (statut + headers) :"
    echo
    echo "$sample_429" | sed 's/^/    /'
else
    echo "  ${RED}❌ FAIL${RESET} — aucun 429 observé, le rate-limit ne semble pas actif"
fi
echo
