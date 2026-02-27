---
name: nist-800-53-rmf-lifecycle
description: >
  End-to-end NIST Risk Management Framework lifecycle against the
  SP 800-53 Rev. 5 sandbox API. Combines system registration, baseline
  selection, SSP creation, control implementation, security assessment,
  POA&M management, and ATO recommendation into a single orchestrated
  workflow. Use when asked to perform a complete RMF evaluation, prepare
  a system for ATO, run the full security lifecycle, or produce a
  comprehensive authorization package. Trigger on keywords: RMF,
  full lifecycle, end-to-end, ATO package, authorization, complete
  evaluation, security lifecycle, comprehensive assessment, RMF steps.
license: Apache-2.0
metadata:
  author: nist-800-53-sandbox
  version: "1.0"
  domain: rmf-lifecycle
---

# NIST SP 800-53 Rev. 5 — Full RMF Lifecycle Skill

You are a program manager orchestrating a complete Risk Management
Framework (RMF) lifecycle per NIST SP 800-37. This skill chains
together all six RMF steps against the SP 800-53 Sandbox API (mocked
in Microcks) to produce a complete authorization package.

## API connection

| Property     | Value                                                                                              |
|--------------|----------------------------------------------------------------------------------------------------|
| Base URL     | `http://localhost:8080/rest/NIST+SP+800-53+%28Rev.+5%29+%E2%80%94+Sandbox+API/1.0.0`              |
| Auth header  | `Authorization: Bearer sandbox-token-hris-001`                                                     |
| Content-Type | `application/json`                                                                                 |

See [API Reference](./references/api-reference.md) for full endpoint list.

## RMF Steps Mapped to API

| RMF Step | Name        | API Operations                          |
|----------|-------------|------------------------------------------|
| Step 1   | Categorize  | `POST /systems`                          |
| Step 2   | Select      | `GET /baselines`, `POST /ssp`            |
| Step 3   | Implement   | `POST /implementations`                  |
| Step 4   | Assess      | `POST /assessments`                      |
| Step 5   | Authorize   | `GET /poam` → AO decision               |
| Step 6   | Monitor     | `GET /assessments`, `GET /poam`          |

## State Tracking

Maintain this resource table throughout the workflow:

```
| Resource        | ID             | Status          |
|-----------------|----------------|-----------------|
| System          | <pending>      |                 |
| SSP             | <pending>      |                 |
| Assessment      | <pending>      |                 |
| POA&M Count     | <pending>      |                 |
| ATO Decision    | <pending>      |                 |
```

---

## Phase 1 — Categorize (RMF Step 1)

**Goal:** Register the information system with its FIPS-199 impact level.

```
POST /systems
```

**Inputs needed from user:**
- System name and acronym
- Impact level (`low`, `moderate`, `high`)
- Owner organization
- Authorizing Official (name and title)
- System type, deployment model, operating environment (recommended)

**Validation:** Confirm 201 response with a valid `id`.

---

## Phase 2 — Select Controls (RMF Step 2)

**Goal:** Choose a baseline, create the SSP, and review the control set.

### 2a — Review the baseline

```
GET /baselines/{impactLevel}/controls
```

Present summary of control count by family.

### 2b — Create the SSP

```
POST /systems/{systemId}/ssp
```

Include:
- Baseline selection matching the system's impact level
- Tailoring notes (controls removed with justification, controls added)
- Version string and prepared-by name

### 2c — Pull the control catalog for reference

For any family the user wants to understand in depth:

```
GET /catalog/families/{familyId}/controls
GET /catalog/controls/{controlId}
```

---

## Phase 3 — Implement Controls (RMF Step 3)

**Goal:** Document how each control is satisfied.

```
POST /systems/{systemId}/ssp/{sspId}/implementations
```

For each control in the baseline, create an implementation statement.
Use [Implementation Templates](./references/implementation-templates.md)
for writing guidance.

**Priority order for implementation:**
1. P1 identity controls (IA-2, AC-2, AC-3) — most critical
2. P1 boundary controls (SC-7, SC-8, AC-4) — network exposure
3. P1 detection controls (AU-2, SI-2, SI-4) — visibility
4. P1 response controls (IR-4, IR-6, CP-2) — resilience
5. P2 and P3 controls in remaining families

For demonstration purposes, implement at least 2–3 controls per
high-priority family (AC, AU, CM, IA, IR, SC, SI) with realistic
descriptions. Mark remaining controls as `planned` or `not_implemented`.

### Track progress

```
GET /systems/{systemId}/ssp/{sspId}
```

Present the implementation counters as a progress dashboard.

---

## Phase 4 — Assess Controls (RMF Step 4)

**Goal:** Evaluate control effectiveness per SP 800-53A.

```
POST /systems/{systemId}/assessments
```

Use [Assessment Procedures](./references/assessment-procedures.md) to
determine the appropriate method (examine, interview, test) per control.

Build `controlFindings` for all implemented controls:
- `satisfied` — Control works as documented
- `other_than_satisfied` — Deficiency found, with `weaknessDescription`
  and `riskLevel`

For a realistic assessment, include:
- At least 70–80% of controls as `satisfied`
- 2–4 `other_than_satisfied` findings across different families
- At least one `high` or `critical` finding
- Evidence strings that reference specific tools, dates, and observations

Complete the assessment:

```
PATCH /systems/{systemId}/assessments/{assessmentId}
{ "status": "completed" }
```

Use [Findings Analyzer](./scripts/findings-analyzer.py) to produce
the SAR statistics:

```bash
echo '<assessment-json>' | python3 scripts/findings-analyzer.py
```

---

## Phase 5 — Authorize (RMF Step 5)

**Goal:** Create POA&M items and produce the ATO recommendation.

### 5a — Create POA&M items

For each `other_than_satisfied` finding:

```
POST /systems/{systemId}/poam
```

Include a concrete milestone, responsible POC, cost estimate, and
phased remediation plan. Use [Remediation Priorities](./references/remediation-priorities.md)
for cost benchmarks.

### 5b — Review POA&M dashboard

```
GET /systems/{systemId}/poam
```

Use [POA&M Dashboard](./scripts/poam-dashboard.py):

```bash
echo '<poam-json>' | python3 scripts/poam-dashboard.py
```

### 5c — ATO Recommendation

Based on findings and POA&M status, recommend one of:

| Decision                   | Criteria                                                         |
|----------------------------|------------------------------------------------------------------|
| **Authorize**              | No critical/high findings, or all high findings have credible POA&M milestones within 90 days |
| **Authorize with conditions** | High findings exist with POA&M milestones. Conditions: complete POA&M items by specified dates |
| **Deny authorization**     | Critical findings with no credible remediation plan              |

---

## Phase 6 — Monitor (RMF Step 6)

**Goal:** Continuous monitoring posture.

### 6a — Track POA&M closure

```
GET /systems/{systemId}/poam?status=in_progress
```

Update items as they complete:

```
PATCH /systems/{systemId}/poam/{poamId}
{
  "status": "completed",
  "actualCompletionDate": "...",
  "completionNotes": "..."
}
```

### 6b — Periodic re-assessment

On a defined cadence (quarterly for high-impact, annually for low),
run a delta assessment:

```
POST /systems/{systemId}/assessments
```

With `assessmentType: "delta"` targeting previously deficient controls.

---

## Phase 7 — Executive Authorization Package

**Goal:** Compile all outputs into a single deliverable.

### 7.1 — Executive Summary
- System name, impact level, baseline
- ATO recommendation and justification
- Total findings, POA&M items, estimated remediation cost

### 7.2 — System Description
- Name, acronym, type, deployment model
- Owner, AO, ISSO
- Operating environment

### 7.3 — Control Selection
- Baseline selected, control count
- Tailoring decisions (removed/added controls)

### 7.4 — Implementation Status
Table: Family | Total | Implemented | Partial | Planned | N/A

### 7.5 — Assessment Results
Table: Control | Method | Determination | Risk | Evidence Summary

### 7.6 — Findings Detail
Grouped by risk level, each with full evidence and weakness description.

### 7.7 — POA&M Register
Table: # | Control | Weakness | Risk | POC | Cost | Milestone | Due Date

### 7.8 — Budget Summary
| Metric                  | Value        |
|-------------------------|--------------|
| Total Remediation Cost  | $XXX,XXX     |
| POA&M Items             | X            |
| Critical Findings       | X            |
| High Findings           | X            |
| Target Closure Date     | YYYY-MM-DD   |

### 7.9 — ATO Recommendation
Formal recommendation with conditions (if any), signature block for AO.

## Error handling

- If any API call fails, log the error and offer to retry or skip.
- If a dependency is missing (e.g. no SSP for assessment), automatically
  execute the required prerequisite phase.
- If the Microcks mock returns fixed data, acknowledge and proceed.

## Edge cases

- If the user wants to skip phases, check prerequisites and either
  fetch existing resources or create them.
- If the system already exists, skip Phase 1 and use the existing ID.
- If budget constraints are specified, filter POA&M items accordingly.

## Example interaction

**User:** "Run a complete RMF lifecycle for our HR system. It's
moderate impact, owned by Acme, AO is Jane Chen."

**Agent executes all 7 phases:**
1. Registers the system at moderate impact.
2. Selects the moderate baseline (304 controls), creates SSP.
3. Documents implementations for priority controls.
4. Runs assessment with realistic findings.
5. Creates POA&M items, produces ATO recommendation.
6. Sets up monitoring cadence.
7. Delivers the complete authorization package.
