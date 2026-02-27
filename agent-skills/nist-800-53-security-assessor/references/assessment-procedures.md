# Assessment Procedures by Control Family

Recommended assessment methods per SP 800-53A. Use the method(s) listed
for each control family. For high-impact systems, use all three methods.

## Method Selection Guide

| Impact Level | Primary Method | Secondary Methods |
|-------------|----------------|-------------------|
| Low         | Examine        | —                 |
| Moderate    | Examine + Test | Interview         |
| High        | Examine + Interview + Test | All required |

## AC — Access Control

| Control | Examine                          | Interview                    | Test                              |
|---------|----------------------------------|------------------------------|-----------------------------------|
| AC-1    | Policy document, review date     | Policy owner                 | —                                 |
| AC-2    | Account list, provisioning logs  | IAM team lead                | Create/disable test account       |
| AC-3    | RBAC matrix, authorization rules | App security lead            | Attempt unauthorized access       |
| AC-4    | DLP config, network diagrams     | Network security lead        | Exfiltration test via known channels |
| AC-5    | Duty separation matrix           | Compliance officer           | Test conflicting role assignment  |
| AC-6    | Privileged account inventory     | PAM administrator            | Verify JIT access expiration      |
| AC-7    | Lockout policy configuration     | Help desk lead               | Trigger account lockout           |
| AC-11   | Screen lock GPO / MDM config     | End-user sample              | Verify timeout on test workstation|
| AC-17   | VPN config, remote access policy | IT operations                | Connect via unauthorized method   |

## AU — Audit and Accountability

| Control | Examine                          | Interview                    | Test                              |
|---------|----------------------------------|------------------------------|-----------------------------------|
| AU-2    | Audit event list, SIEM config    | SOC analyst                  | Generate auditable event, verify log |
| AU-3    | Sample log entries for fields    | SIEM engineer                | Verify log content completeness   |
| AU-6    | Audit review schedule, reports   | SOC manager                  | Request ad-hoc report             |
| AU-9    | Log storage ACLs, retention      | Platform admin               | Attempt log modification          |
| AU-12   | Logging agent deployment status  | System administrator         | Verify agent on sample hosts      |

## CM — Configuration Management

| Control | Examine                          | Interview                    | Test                              |
|---------|----------------------------------|------------------------------|-----------------------------------|
| CM-2    | Golden image repo, baseline doc  | DevOps lead                  | Compare running config to baseline|
| CM-3    | Change management records        | Change advisory board member | Submit test change request        |
| CM-6    | CIS/STIG scan results            | Security engineer            | Run compliance scan               |
| CM-8    | Asset inventory, CMDB export     | IT asset manager             | Verify sample assets in inventory |

## IA — Identification and Authentication

| Control | Examine                          | Interview                    | Test                              |
|---------|----------------------------------|------------------------------|-----------------------------------|
| IA-2    | IdP configuration, MFA policy    | IAM engineer                 | Authenticate with and without MFA |
| IA-5    | Password policy settings         | Help desk lead               | Verify password complexity rules  |
| IA-8    | External user auth config        | Application owner            | Test external user authentication |

## IR — Incident Response

| Control | Examine                          | Interview                    | Test                              |
|---------|----------------------------------|------------------------------|-----------------------------------|
| IR-1    | IR policy, review date           | CISO / IR manager            | —                                 |
| IR-4    | IR plan, playbooks, exercise logs| IR team members              | Tabletop exercise or inject test  |
| IR-5    | Incident tracking system, metrics| IR manager                   | Review open/closed incident stats |
| IR-6    | Reporting procedures, POC list   | IR team members              | Simulate reportable incident      |

## SC — System and Communications Protection

| Control | Examine                          | Interview                    | Test                              |
|---------|----------------------------------|------------------------------|-----------------------------------|
| SC-7    | Firewall rules, network diagrams | Network engineer             | Port scan from external boundary  |
| SC-8    | TLS configuration, cert inventory| Platform engineer            | SSL Labs scan or equivalent       |
| SC-28   | Encryption-at-rest configuration | Database administrator       | Verify encrypted volumes/columns  |

## SI — System and Information Integrity

| Control | Examine                          | Interview                    | Test                              |
|---------|----------------------------------|------------------------------|-----------------------------------|
| SI-2    | Patch management reports, SLAs   | Vulnerability mgmt lead      | Run vulnerability scan            |
| SI-3    | Anti-malware configuration       | Endpoint security engineer   | EICAR test file deployment        |
| SI-4    | Monitoring tool dashboards       | SOC analyst                  | Generate test alert, verify detection |

## SR — Supply Chain Risk Management

| Control | Examine                          | Interview                    | Test                              |
|---------|----------------------------------|------------------------------|-----------------------------------|
| SR-1    | SCRM policy and plan             | Procurement officer          | —                                 |
| SR-3    | Vendor risk assessment records   | Third-party risk manager     | Review sample vendor assessment   |
| SR-5    | Supplier agreements, SBOMs       | Legal / procurement          | Verify SBOM for critical component|
