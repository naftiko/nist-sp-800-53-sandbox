#!/usr/bin/env bash
# rmf-lifecycle.sh — Run the complete RMF lifecycle
# Usage: ./rmf-lifecycle.sh <base-url> <token> <name> <acronym> <impact> <org> <ao>
#
# Example:
#   ./rmf-lifecycle.sh http://localhost:8080/rest/... sandbox-token-hris-001 \
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

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  NIST RMF — Full Lifecycle Orchestration                ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  System  : ${NAME} (${ACRONYM})"
echo "║  Impact  : ${IMPACT}"
echo "║  Org     : ${ORG}"
echo "║  AO      : ${AO}"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ── Phase 1: Categorize ──
echo "━━━ Phase 1/7: Categorize — Register System ━━━"
SYS_ID=$(call POST /systems "{
  \"name\":\"${NAME}\",
  \"acronym\":\"${ACRONYM}\",
  \"impactLevel\":\"${IMPACT}\",
  \"ownerOrganization\":\"${ORG}\",
  \"authorizingOfficial\":\"${AO}\",
  \"systemType\":\"major_application\",
  \"deploymentModel\":\"hybrid\",
  \"operatingEnvironment\":\"AWS GovCloud and on-premises data center.\"
}" | jval id)
echo "  ✓ System: ${SYS_ID}"

# ── Phase 2: Select ──
echo ""
echo "━━━ Phase 2/7: Select — Baseline and SSP ━━━"

# Pull baseline
BASELINE=$(call GET "/baselines/${IMPACT}/controls" "")
CTRL_COUNT=$(echo "${BASELINE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('total','N/A'))")
echo "  ✓ ${IMPACT} baseline: ${CTRL_COUNT} controls"

SSP_ID=$(call POST "/systems/${SYS_ID}/ssp" "{
  \"title\":\"${NAME} System Security Plan v1.0\",
  \"baselineId\":\"${IMPACT}\",
  \"version\":\"1.0\",
  \"description\":\"SSP for ${NAME}. Full ${IMPACT}-baseline coverage.\",
  \"preparedBy\":\"Automated RMF Agent\"
}" | jval id)
echo "  ✓ SSP: ${SSP_ID}"

# ── Phase 3: Implement ──
echo ""
echo "━━━ Phase 3/7: Implement — Control Statements ━━━"

# Implement key controls
declare -a CONTROLS=(
  "AC-2|Account Management|implemented|IAM Team|Okta provisioning with SCIM. Quarterly reviews via SailPoint.|system_specific"
  "AC-3|Access Enforcement|implemented|App Security|RBAC at application layer. OAuth 2.0 via API gateway.|system_specific"
  "AC-4|Information Flow Enforcement|partially_implemented|Network Security|VPC segmentation active. DLP on email only — cloud sharing not covered.|hybrid"
  "IA-2|Identification and Authentication|implemented|IAM Team|All users authenticate via Azure AD with FIDO2 MFA.|system_specific"
  "IR-4|Incident Handling|partially_implemented|IR Team|IR plan exists. Playbooks for 5 scenarios. Last tabletop: 14 months ago.|system_specific"
  "SI-2|Flaw Remediation|partially_implemented|Vuln Mgmt|Tenable scanning weekly. 23 critical CVEs beyond 30-day SLA.|system_specific"
  "SC-7|Boundary Protection|implemented|Network Security|AWS WAF + security groups. On-prem Palo Alto NGFW.|hybrid"
)

IMPL_COUNT=0
for ctrl_line in "${CONTROLS[@]}"; do
  IFS='|' read -r CID CTITLE CSTATUS CROLE CDESC CTYPE <<< "$ctrl_line"
  call POST "/systems/${SYS_ID}/ssp/${SSP_ID}/implementations" "{
    \"controlId\":\"${CID}\",
    \"status\":\"${CSTATUS}\",
    \"responsibleRole\":\"${CROLE}\",
    \"implementationDescription\":\"${CDESC}\",
    \"implementationType\":\"${CTYPE}\",
    \"satisfiedEnhancements\":[]
  }" > /dev/null
  IMPL_COUNT=$((IMPL_COUNT + 1))
  echo "  ✓ ${CID} (${CTITLE}) — ${CSTATUS}"
done
echo "  ✓ ${IMPL_COUNT} implementations documented"

# ── Phase 4: Assess ──
echo ""
echo "━━━ Phase 4/7: Assess — Security Evaluation ━━━"
ASSESS_ID=$(call POST "/systems/${SYS_ID}/assessments" "{
  \"sspId\":\"${SSP_ID}\",
  \"title\":\"${NAME} Initial Security Assessment\",
  \"assessor\":\"Automated Security Assessor\",
  \"assessmentType\":\"comprehensive\",
  \"scope\":\"All implemented controls in ${IMPACT} baseline.\",
  \"methodology\":\"SP 800-53A examine, interview, and test procedures.\",
  \"controlFindings\":[
    {\"controlId\":\"AC-2\",\"determination\":\"satisfied\",\"assessmentMethod\":\"test\",\"evidence\":\"Okta logs verified. SCIM provisioning confirmed.\"},
    {\"controlId\":\"AC-3\",\"determination\":\"satisfied\",\"assessmentMethod\":\"test\",\"evidence\":\"RBAC tested with 5 role profiles. No unauthorized access.\"},
    {\"controlId\":\"AC-4\",\"determination\":\"other_than_satisfied\",\"assessmentMethod\":\"examine\",\"evidence\":\"DLP on email only. Cloud file sharing unmonitored.\",\"weaknessDescription\":\"Information flow enforcement does not extend to cloud collaboration platforms.\",\"riskLevel\":\"moderate\"},
    {\"controlId\":\"IA-2\",\"determination\":\"satisfied\",\"assessmentMethod\":\"test\",\"evidence\":\"FIDO2 MFA enforced for all users. Tested bypass — blocked.\"},
    {\"controlId\":\"IR-4\",\"determination\":\"other_than_satisfied\",\"assessmentMethod\":\"interview\",\"evidence\":\"IR plan exists but last tabletop was 14 months ago. No MTTD/MTTR metrics.\",\"weaknessDescription\":\"Incident response procedures not regularly tested and lack performance metrics.\",\"riskLevel\":\"moderate\"},
    {\"controlId\":\"SI-2\",\"determination\":\"other_than_satisfied\",\"assessmentMethod\":\"test\",\"evidence\":\"23 critical CVEs unpatched beyond 30-day SLA. Oldest: 97 days.\",\"weaknessDescription\":\"Flaw remediation does not meet the 30-day SLA for critical vulnerabilities.\",\"riskLevel\":\"high\"},
    {\"controlId\":\"SC-7\",\"determination\":\"satisfied\",\"assessmentMethod\":\"test\",\"evidence\":\"External port scan clean. WAF rules validated.\"}
  ]
}" | jval id)
echo "  ✓ Assessment: ${ASSESS_ID}"

call PATCH "/systems/${SYS_ID}/assessments/${ASSESS_ID}" '{"status":"completed"}' > /dev/null
echo "  ✓ Assessment completed (4 satisfied, 3 deficient)"

# ── Phase 5: Authorize — POA&M ──
echo ""
echo "━━━ Phase 5/7: Authorize — POA&M Creation ━━━"

POAM1_ID=$(call POST "/systems/${SYS_ID}/poam" "{
  \"assessmentId\":\"${ASSESS_ID}\",
  \"controlId\":\"AC-4\",
  \"weaknessDescription\":\"Information flow enforcement does not extend to cloud collaboration platforms.\",
  \"riskLevel\":\"moderate\",
  \"milestone\":\"Deploy Microsoft Purview DLP to SharePoint Online and Box.\",
  \"scheduledCompletionDate\":\"2025-09-30T00:00:00Z\",
  \"responsiblePoc\":\"Mike Torres, Network Security Lead\",
  \"estimatedCostUsd\":45000,
  \"remediationPlan\":\"Phase 1: Procure Purview license. Phase 2: Configure DLP policies. Phase 3: Test and tune.\"
}" | jval id)
echo "  ✓ POA&M ${POAM1_ID}: AC-4 (moderate) — \$45,000"

POAM2_ID=$(call POST "/systems/${SYS_ID}/poam" "{
  \"assessmentId\":\"${ASSESS_ID}\",
  \"controlId\":\"IR-4\",
  \"weaknessDescription\":\"Incident response procedures not regularly tested.\",
  \"riskLevel\":\"moderate\",
  \"milestone\":\"Conduct tabletop exercise and establish MTTD/MTTR metrics.\",
  \"scheduledCompletionDate\":\"2025-08-31T00:00:00Z\",
  \"responsiblePoc\":\"Lisa Park, IR Manager\",
  \"estimatedCostUsd\":15000,
  \"remediationPlan\":\"Phase 1: Schedule tabletop. Phase 2: Define KPIs. Phase 3: Instrument SIEM dashboards.\"
}" | jval id)
echo "  ✓ POA&M ${POAM2_ID}: IR-4 (moderate) — \$15,000"

POAM3_ID=$(call POST "/systems/${SYS_ID}/poam" "{
  \"assessmentId\":\"${ASSESS_ID}\",
  \"controlId\":\"SI-2\",
  \"weaknessDescription\":\"Flaw remediation does not meet 30-day SLA for critical vulnerabilities.\",
  \"riskLevel\":\"high\",
  \"milestone\":\"Patch 23 critical CVEs; deploy automated patching pipeline.\",
  \"scheduledCompletionDate\":\"2025-08-15T00:00:00Z\",
  \"responsiblePoc\":\"David Nguyen, Vulnerability Management Lead\",
  \"estimatedCostUsd\":60000,
  \"remediationPlan\":\"Phase 1: Emergency patching (2 weeks). Phase 2: WSUS/SCCM pipeline (6 weeks). Phase 3: Tenable integration.\"
}" | jval id)
echo "  ✓ POA&M ${POAM3_ID}: SI-2 (high) — \$60,000"

TOTAL_COST=$((45000 + 15000 + 60000))

# ── Phase 6: Monitor ──
echo ""
echo "━━━ Phase 6/7: Monitor — Continuous Monitoring Setup ━━━"
echo "  ✓ Monitoring cadence: quarterly reassessment"
echo "  ✓ POA&M review: monthly status updates"
echo "  ✓ Next delta assessment due: 90 days"

# ── Phase 7: Summary ──
echo ""
echo "━━━ Phase 7/7: Authorization Package ━━━"
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  RMF LIFECYCLE COMPLETE                                 ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Resource          │ ID                                 ║"
echo "╠════════════════════╪════════════════════════════════════╣"
printf "║  %-18s │ %-36s║\n" "System" "${SYS_ID}"
printf "║  %-18s │ %-36s║\n" "SSP" "${SSP_ID}"
printf "║  %-18s │ %-36s║\n" "Assessment" "${ASSESS_ID}"
printf "║  %-18s │ %-36s║\n" "POA&M Items" "3 (1 high, 2 moderate)"
echo "╠══════════════════════════════════════════════════════════╣"
printf "║  %-18s │ %-36s║\n" "Remediation Cost" "\$${TOTAL_COST}"
printf "║  %-18s │ %-36s║\n" "Satisfied" "4 / 7 controls"
printf "║  %-18s │ %-36s║\n" "Deficient" "3 / 7 controls"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  ATO RECOMMENDATION: AUTHORIZE WITH CONDITIONS          ║"
echo "║  Condition: Complete SI-2 POA&M by 2025-08-15           ║"
echo "╚══════════════════════════════════════════════════════════╝"
