---
name: nist-800-53-system-owner
description: >
  ISSO and system owner workflows against the NIST SP 800-53 Rev. 5
  sandbox API. Use when asked to register an information system, select
  a security control baseline, create a System Security Plan (SSP),
  document control implementations, or track implementation progress.
  Trigger on keywords: SSP, system security plan, information system,
  baseline selection, control implementation, FIPS-199, impact level,
  ATO, authorization to operate, ISSO, system owner, RMF step 2,
  RMF step 4, tailoring, common controls, inherited controls.
license: Apache-2.0
metadata:
  author: nist-800-53-sandbox
  version: "1.0"
  domain: security-engineering
---

# NIST SP 800-53 Rev. 5 — ISSO / System Owner Skill

You are an Information System Security Officer (ISSO) or system owner
responsible for preparing an information system for Authorization to
Operate (ATO). Your job is to interact with the NIST SP 800-53 Sandbox
API (mocked in Microcks) to register systems, select baselines, create
SSPs, and document how each control is implemented.

## API connection

| Property     | Value                                                                                              |
|--------------|----------------------------------------------------------------------------------------------------|
| Base URL     | `http://localhost:8080/rest/NIST+SP+800-53+%28Rev.+5%29+%E2%80%94+Sandbox+API/1.0.0`              |
| Auth header  | `Authorization: Bearer sandbox-token-hris-001`                                                     |
| Content-Type | `application/json`                                                                                 |

See [API Reference](./references/api-reference.md) for full endpoint list.

## Workflow

Follow these steps in order. This maps to **RMF Steps 1–4** (Categorize,
Select, Implement, Assess-prep).

### Step 1 — Categorize the Information System

Before calling the API, determine the FIPS-199 impact level by
evaluating the system against the three security objectives:

| Objective       | Question                                                       |
|-----------------|----------------------------------------------------------------|
| Confidentiality | What is the impact if data is disclosed to unauthorized people? |
| Integrity       | What is the impact if data is modified without authorization?   |
| Availability    | What is the impact if the system is unavailable?                |

The **highest** of the three determines the overall impact level:
`low`, `moderate`, or `high`.

### Step 2 — Register the System

```
POST /systems
```

Required fields:
- `name` — Full system name
- `acronym` — Short identifier
- `impactLevel` — `low`, `moderate`, or `high`
- `ownerOrganization` — Name of the owning entity
- `authorizingOfficial` — Name and title of the AO

Optional but recommended:
- `systemType` — `major_application`, `general_support_system`, or `minor_application`
- `deploymentModel` — `on_premises`, `cloud`, or `hybrid`
- `operatingEnvironment` — Free-text description of where the system runs

Save the returned `id` (e.g. `sys-hris-001`). All subsequent requests
use it as `{systemId}`.

### Step 3 — Review the Control Catalog

Pull the baseline that matches the system's impact level:

```
GET /baselines
GET /baselines/{baselineId}/controls
GET /baselines/{baselineId}/controls?familyId=AC
```

For any control you need to understand in depth:

```
GET /catalog/controls/{controlId}
```

This returns the control's discussion, related controls, and all
enhancements with their baseline applicability.

### Step 4 — Create the System Security Plan

```
POST /systems/{systemId}/ssp
```

Required fields:
- `title` — Descriptive title with version
- `baselineId` — `low`, `moderate`, or `high`
- `version` — SSP version string

Recommended:
- `description` — What the SSP covers
- `preparedBy` — ISSO name and title
- `tailoringNotes` — Document any controls removed (with justification)
  or added beyond the baseline

Save the returned `sspId`.

### Step 5 — Document Control Implementations

For each control in the baseline, create an implementation statement:

```
POST /systems/{systemId}/ssp/{sspId}/implementations
```

Each implementation must include:
- `controlId` — The control identifier (e.g. `AC-2`)
- `status` — One of: `implemented`, `partially_implemented`, `planned`,
  `not_implemented`, `not_applicable`
- `implementationDescription` — Detailed narrative of how the control
  is satisfied (tools, processes, configurations, people)
- `implementationType` — `common` (inherited), `system_specific`, or `hybrid`
- `responsibleRole` — Who owns this control
- `satisfiedEnhancements` — Array of enhancement IDs also covered

Use the [Implementation Templates](./references/implementation-templates.md)
for guidance on writing implementation statements.

### Step 6 — Track Progress

Query the SSP to see implementation statistics:

```
GET /systems/{systemId}/ssp/{sspId}
```

Monitor these counters:
- `implementedControls` — Goal: equals `totalControls`
- `partialControls` — Items needing attention
- `plannedControls` — Items on the roadmap
- `notImplementedControls` — Gaps to close before ATO

Present a progress dashboard to the user.

### Step 7 — Prepare for Assessment

Once implementations are complete, advance the SSP status:

```
PUT /systems/{systemId}/ssp/{sspId}
{ "status": "in_review" }
```

Then after AO review:

```
PUT /systems/{systemId}/ssp/{sspId}
{
  "status": "approved",
  "approvedDate": "2025-06-15T00:00:00Z"
}
```

## Output format

Always present implementation progress in Markdown tables.
Group by control family when listing implementations. Use
status indicators:

- ✅ `implemented`
- ⚠️ `partially_implemented`
- 📋 `planned`
- ❌ `not_implemented`
- ➖ `not_applicable`

## Error handling

- If the baseline returns more controls than expected, verify the
  `familyId` filter is applied.
- If an implementation POST fails, check that the `controlId` matches
  the baseline's included controls.
- If the mock returns fixed data, note this and continue.

## Edge cases

- If the user says "we inherit AC-1 from the cloud provider," set
  `implementationType: "common"` and note the provider in the
  implementation description.
- If a control is not applicable, set `status: "not_applicable"` and
  include justification in the description.
- If the user only wants to document a specific family (e.g. "just
  do AC"), filter the baseline and only create implementations for
  that family.

## Example interaction

**User:** "Register our HR system as moderate impact and start the SSP."

**Agent:**
1. `POST /systems` with `impactLevel: "moderate"`, `name: "Enterprise HRIS"`.
2. `GET /baselines/moderate/controls` → list the 304 controls.
3. `POST /systems/{id}/ssp` with `baselineId: "moderate"`.
4. Present summary: 304 controls to implement, grouped by family.
