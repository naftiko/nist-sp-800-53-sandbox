# Remediation Priorities and Cost Benchmarks

Estimated cost and effort ranges for remediating common control
deficiencies. Use these as starting points when building POA&M items.
Actual costs vary by organization size, complexity, and existing tooling.

## Priority Tiers

### Tier 1 — Immediate (0–30 days)
These weaknesses represent active exploitability or regulatory
non-compliance. Remediate before ATO or during emergency change window.

| Control | Common Weakness                          | Typical Fix                             | Cost Range     | Effort   |
|---------|------------------------------------------|-----------------------------------------|----------------|----------|
| AC-2    | Orphaned privileged accounts             | Access review + cleanup                 | $5K–$15K       | Low      |
| AC-7    | No account lockout                       | GPO/IdP configuration                   | $2K–$5K        | Low      |
| IA-2    | MFA not enforced                         | Enable MFA in IdP                       | $10K–$30K      | Medium   |
| IA-5    | Weak password policy                     | Update policy settings                  | $2K–$5K        | Low      |
| SI-2    | Critical CVEs unpatched                  | Emergency patching sprint               | $20K–$60K      | Medium   |
| SC-8    | TLS 1.0/1.1 in use                      | TLS upgrade and cert rotation           | $10K–$25K      | Medium   |

### Tier 2 — Short-Term (30–90 days)
Significant gaps that require tool procurement or process changes.

| Control | Common Weakness                          | Typical Fix                             | Cost Range     | Effort   |
|---------|------------------------------------------|-----------------------------------------|----------------|----------|
| AC-4    | No DLP on cloud channels                 | Deploy DLP solution                     | $40K–$120K     | High     |
| AU-6    | No automated log review                  | SIEM correlation rules + SOC process    | $30K–$80K      | High     |
| CM-2    | No baseline configuration                | Golden image + drift detection          | $25K–$60K      | Medium   |
| IR-4    | Untested IR plan                         | Tabletop exercise + playbook update     | $10K–$30K      | Medium   |
| SC-7    | Flat network, no segmentation            | Micro-segmentation deployment           | $50K–$150K     | High     |
| SI-4    | Gaps in monitoring coverage              | EDR/NDR deployment to uncovered hosts   | $30K–$80K      | Medium   |

### Tier 3 — Medium-Term (90–180 days)
Process maturity improvements and capability building.

| Control | Common Weakness                          | Typical Fix                             | Cost Range     | Effort   |
|---------|------------------------------------------|-----------------------------------------|----------------|----------|
| AT-2    | Insufficient security training           | Training program + phishing simulation  | $15K–$40K      | Medium   |
| CA-7    | No continuous monitoring program         | ConMon tooling + dashboards             | $40K–$100K     | High     |
| CM-3    | Informal change management               | Change management tool + process        | $20K–$50K      | Medium   |
| PE-3    | Inadequate physical access controls      | Badge system upgrade                    | $30K–$80K      | High     |
| RA-5    | Infrequent vulnerability scanning        | Automated scan pipeline                 | $20K–$50K      | Medium   |
| SR-3    | No vendor risk assessments               | TPRM program + questionnaire            | $25K–$60K      | Medium   |

### Tier 4 — Long-Term (180–365 days)
Organizational transformation and architecture changes.

| Control | Common Weakness                          | Typical Fix                             | Cost Range     | Effort   |
|---------|------------------------------------------|-----------------------------------------|----------------|----------|
| AC-6    | No PAM solution                          | PAM deployment (CyberArk, etc.)         | $80K–$250K     | High     |
| CP-2    | No disaster recovery capability          | DR site + runbooks + testing            | $100K–$500K    | High     |
| SA-11   | No DevSecOps pipeline                    | SAST/DAST integration + training        | $50K–$150K     | High     |
| SC-28   | No encryption at rest                    | Database/volume encryption rollout      | $40K–$120K     | High     |
| PM-9    | No formal risk management strategy       | ERM program + governance framework      | $60K–$200K     | High     |

## Cost Estimation Formula

When estimating POA&M costs, consider:

```
Total Cost = Tool License + Implementation Labor + Training + Ongoing Operations (Year 1)

Tool License:
  SaaS: Annual subscription × number of users/assets
  On-prem: License + support + infrastructure

Implementation Labor:
  Internal: Hours × blended rate ($150–$250/hr for federal contractors)
  External: SOW-based, typically 2–4× internal rate

Training:
  Awareness: $50–$100 per person
  Technical: $2,000–$5,000 per person
  Certification: $3,000–$8,000 per person

Ongoing Operations (Year 1):
  FTE allocation: % of FTE × loaded salary
  Managed service: Monthly fee × 12
```

## Risk Acceptance Thresholds

Guidelines for when risk acceptance may be appropriate:

| Condition | Acceptance Appropriate? |
|-----------|------------------------|
| Remediation cost > 10× annual loss expectancy | Consider acceptance |
| Control is inherited and provider has accepted | Document and accept |
| System is scheduled for decommission within 6 months | Accept with date constraint |
| Compensating controls reduce residual risk to low | Accept with monitoring |
| No compensating controls and risk is high/critical | Do NOT accept |
