# NIST SP 800-53 (Rev. 5) Sandbox API — Quick Reference

## Base URL

```
https://sandbox.nist-800-53.example.com/api/v1
```

Local Microcks mock:

```
http://localhost:8080/rest/NIST+SP+800-53+%28Rev.+5%29+%E2%80%94+Sandbox+API/1.0.0
```

## Authentication

All requests require a bearer token:

```
Authorization: Bearer sandbox-token-hris-001
```

## 20 Control Families

| ID | Name                                     | Controls |
|----|------------------------------------------|----------|
| AC | Access Control                           | 25       |
| AT | Awareness and Training                   | 6        |
| AU | Audit and Accountability                 | 16       |
| CA | Assessment, Authorization, and Monitoring| 9        |
| CM | Configuration Management                 | 14       |
| CP | Contingency Planning                     | 13       |
| IA | Identification and Authentication        | 12       |
| IR | Incident Response                        | 10       |
| MA | Maintenance                              | 7        |
| MP | Media Protection                         | 8        |
| PE | Physical and Environmental Protection    | 23       |
| PL | Planning                                 | 11       |
| PM | Program Management                       | 32       |
| PS | Personnel Security                       | 9        |
| PT | PII Processing and Transparency          | 8        |
| RA | Risk Assessment                          | 10       |
| SA | System and Services Acquisition          | 23       |
| SC | System and Communications Protection     | 51       |
| SI | System and Information Integrity         | 23       |
| SR | Supply Chain Risk Management             | 12       |

## Baselines (per SP 800-53B)

| Baseline | Impact Level | Control Count |
|----------|-------------|---------------|
| Low      | Low         | 150           |
| Moderate | Moderate    | 304           |
| High     | High        | 392           |

## Control Priority Codes

| Code | Meaning                             |
|------|-------------------------------------|
| P1   | Highest priority — implement first  |
| P2   | Moderate priority                   |
| P3   | Lower priority                      |
| P0   | Not assigned / not applicable       |

## Control Implementation Types

- `common` — Inherited from a shared service or provider (e.g. FedRAMP)
- `system_specific` — Implemented locally within the system boundary
- `hybrid` — Combination of inherited and local implementation

## Control Implementation Statuses

- `implemented` — Fully operational and documented
- `partially_implemented` — Some aspects in place, gaps remain
- `planned` — Scheduled for implementation, not yet active
- `not_implemented` — No controls in place
- `not_applicable` — Control does not apply (with justification)

## Assessment Methods (per SP 800-53A)

| Method    | Description                                    |
|-----------|------------------------------------------------|
| examine   | Review documentation, records, configurations  |
| interview | Question personnel about practices              |
| test      | Exercise mechanisms and validate behavior       |

## Assessment Determinations

- `satisfied` — Control is effective as implemented
- `other_than_satisfied` — Control has deficiencies

## SSP Statuses

`draft` → `in_review` → `approved` → `revoked`

## Assessment Statuses

`in_progress` → `in_review` → `completed` | `cancelled`

## POA&M Statuses

`open` → `in_progress` → `completed` | `accepted_risk` | `cancelled`

## POA&M Risk Levels

`low` | `moderate` | `high` | `critical`

## System Statuses

`under_development` → `operational` → `undergoing_major_modification` → `disposition`

## Endpoints Summary

### Control Catalog (read-only)
- `GET /catalog/families` — List all 20 control families
- `GET /catalog/families/{familyId}/controls` — Controls in a family
- `GET /catalog/controls/{controlId}` — Full control detail with enhancements

### Baselines (read-only)
- `GET /baselines` — List Low, Moderate, High baselines
- `GET /baselines/{baselineId}/controls` — Controls in a baseline (filter by family)

### Information Systems
- `GET /systems` — List registered systems
- `POST /systems` — Register a new system
- `GET /systems/{systemId}` — Get system details

### System Security Plans
- `GET /systems/{systemId}/ssp` — List SSPs
- `POST /systems/{systemId}/ssp` — Create SSP
- `GET /systems/{systemId}/ssp/{sspId}` — Get SSP detail
- `PUT /systems/{systemId}/ssp/{sspId}` — Update SSP

### Control Implementations
- `GET /systems/{systemId}/ssp/{sspId}/implementations` — List implementations
- `POST /systems/{systemId}/ssp/{sspId}/implementations` — Add implementation

### Assessments
- `GET /systems/{systemId}/assessments` — List assessments
- `POST /systems/{systemId}/assessments` — Create assessment
- `GET /systems/{systemId}/assessments/{assessmentId}` — Get assessment detail
- `PATCH /systems/{systemId}/assessments/{assessmentId}` — Update assessment status

### POA&M
- `GET /systems/{systemId}/poam` — List POA&M items
- `POST /systems/{systemId}/poam` — Create POA&M item
- `GET /systems/{systemId}/poam/{poamId}` — Get POA&M detail
- `PATCH /systems/{systemId}/poam/{poamId}` — Update POA&M item
