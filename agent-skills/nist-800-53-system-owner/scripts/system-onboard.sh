#!/usr/bin/env bash
# system-onboard.sh — Register a system, create SSP, and scaffold implementations
# Usage: ./system-onboard.sh <base-url> <token> <name> <acronym> <impact> <org> <ao>
#
# Example:
#   ./system-onboard.sh http://localhost:8080/rest/... sandbox-token-hris-001 \
#     "Enterprise HRIS" "E-HRIS" moderate "Acme Corporation" "Jane Chen, CIO"

set -euo pipefail

BASE="${1:?Usage: $0 <base-url> <token> <name> <acronym> <impact> <org> <ao>}"
TOKEN="${2:?}"
NAME="${3:?}"
ACRONYM="${4:?}"
IMPACT="${5:?}"
ORG="${6:?}"
AO="${7:?}"

H_AUTH="Authorization: Bearer ${TOKEN}"
H_CT="Content-Type: application/json"

call() {
  local method=$1 path=$2 body="${3:-}"
  if [ -n "${body}" ]; then
    curl -s -X "${method}" "${BASE}${path}" -H "${H_AUTH}" -H "${H_CT}" -d "${body}"
  else
    curl -s -X "${method}" "${BASE}${path}" -H "${H_AUTH}" -H "${H_CT}"
  fi
}

jval() { python3 -c "import sys,json; print(json.load(sys.stdin)['$1'])" 2>/dev/null; }

echo "═══════════════════════════════════════════"
echo "  SP 800-53 — System Onboarding"
echo "═══════════════════════════════════════════"
echo "  System  : ${NAME} (${ACRONYM})"
echo "  Impact  : ${IMPACT}"
echo "  Org     : ${ORG}"
echo "  AO      : ${AO}"
echo "═══════════════════════════════════════════"

# ── Step 1: Register System ──
echo ""
echo "▶ Step 1: Registering information system..."
SYS_ID=$(call POST /systems "{
  \"name\": \"${NAME}\",
  \"acronym\": \"${ACRONYM}\",
  \"impactLevel\": \"${IMPACT}\",
  \"ownerOrganization\": \"${ORG}\",
  \"authorizingOfficial\": \"${AO}\",
  \"systemType\": \"major_application\",
  \"deploymentModel\": \"hybrid\"
}" | jval id)
echo "✓ System registered: ${SYS_ID}"

# ── Step 2: Pull baseline stats ──
echo ""
echo "▶ Step 2: Reviewing ${IMPACT} baseline..."
BASELINE=$(call GET "/baselines/${IMPACT}/controls" "")
CTRL_COUNT=$(echo "${BASELINE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('total','N/A'))")
echo "✓ ${IMPACT} baseline: ${CTRL_COUNT} controls"

# ── Step 3: Create SSP ──
echo ""
echo "▶ Step 3: Creating System Security Plan..."
SSP_ID=$(call POST "/systems/${SYS_ID}/ssp" "{
  \"title\": \"${NAME} System Security Plan v1.0\",
  \"baselineId\": \"${IMPACT}\",
  \"version\": \"1.0\",
  \"description\": \"SSP for ${NAME}. Covers all ${IMPACT}-baseline controls.\",
  \"preparedBy\": \"Automated Agent ISSO\"
}" | jval id)
echo "✓ SSP created: ${SSP_ID}"

# ── Step 4: Pull control families ──
echo ""
echo "▶ Step 4: Listing control families..."
FAMILIES=$(call GET /catalog/families "")
echo "${FAMILIES}" | python3 -c "
import sys, json
families = json.load(sys.stdin)
print(f'  {\"Family\":<6} {\"Name\":<45} {\"Controls\":>8}')
print(f'  {\"─\"*6} {\"─\"*45} {\"─\"*8}')
for f in families:
    print(f'  {f[\"id\"]:<6} {f[\"name\"]:<45} {f[\"controlCount\"]:>8}')
print(f'  {\"─\"*6} {\"─\"*45} {\"─\"*8}')
print(f'  {\"TOTAL\":<6} {\"\":<45} {sum(f[\"controlCount\"] for f in families):>8}')
"

# ── Summary ──
echo ""
echo "═══════════════════════════════════════════"
echo "  Onboarding Complete"
echo "═══════════════════════════════════════════"
echo "  System ID : ${SYS_ID}"
echo "  SSP ID    : ${SSP_ID}"
echo "  Baseline  : ${IMPACT} (${CTRL_COUNT} controls)"
echo ""
echo "  Next: Document control implementations"
echo "    POST /systems/${SYS_ID}/ssp/${SSP_ID}/implementations"
echo "═══════════════════════════════════════════"
