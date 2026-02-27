# Control Implementation Statement Templates

Use these templates when documenting how controls are satisfied in an SSP.
Replace placeholders with actual system-specific details.

## Writing Effective Implementation Statements

Every implementation statement should answer:
1. **What** — What mechanism, tool, or process satisfies the control?
2. **How** — How is it configured, enforced, or operated?
3. **Who** — Who is responsible for operating and monitoring it?
4. **When** — How often is it reviewed, tested, or updated?
5. **Where** — Where does it apply (all systems, specific boundary, etc.)?

## AC — Access Control

```
AC-1 (Policy and Procedures):
  Type: common
  Statement: Access control policy [document name] is maintained by
  [role/team]. Last reviewed and approved by [AO name] on [date].
  Procedures are published on [location] and reviewed [annually/quarterly].

AC-2 (Account Management):
  Type: system_specific
  Statement: User accounts are managed through [IdP tool, e.g. Okta,
  Azure AD]. Provisioning follows [process name] with approval from
  [role]. Accounts are reviewed [frequency] using [tool]. Inactive
  accounts disabled after [X] days. De-provisioning triggered within
  [X] hours of termination via [HR integration tool].

AC-3 (Access Enforcement):
  Type: system_specific
  Statement: [RBAC/ABAC] enforced at the [application/API/database]
  layer. [X] roles defined with least-privilege mapping. API gateway
  enforces [OAuth 2.0/SAML] scopes. Database row-level security
  applied to [PII/CUI] tables.

AC-4 (Information Flow Enforcement):
  Type: hybrid
  Statement: Network segmentation via [VPC/VLAN/firewall tool].
  East-west traffic controlled by [micro-segmentation tool].
  DLP policies applied to [email/endpoints/cloud storage] via
  [DLP tool name]. [Gap: describe any uncovered channels].

AC-6 (Least Privilege):
  Type: system_specific
  Statement: Privileged access limited to [X] accounts managed via
  [PAM tool, e.g. CyberArk]. Just-in-time access via [tool].
  Admin sessions recorded and reviewed [frequency].
```

## AU — Audit and Accountability

```
AU-2 (Event Logging):
  Type: system_specific
  Statement: Audit events defined per [policy document]. Logging
  enabled for: authentication, privilege escalation, data access,
  configuration changes, failed access attempts. Logs collected
  by [SIEM tool, e.g. Splunk, Sentinel].

AU-6 (Audit Record Review, Analysis, and Reporting):
  Type: system_specific
  Statement: [SIEM tool] correlates logs in real-time. SOC reviews
  alerts [frequency]. Monthly audit reports generated for [audience].
  Anomaly detection rules tuned [frequency].
```

## CM — Configuration Management

```
CM-2 (Baseline Configuration):
  Type: system_specific
  Statement: Golden images maintained in [repository/tool]. OS
  baselines aligned with [CIS/DISA STIG]. Container images scanned
  by [tool] before deployment. Drift detection via [tool] running
  [frequency].

CM-6 (Configuration Settings):
  Type: system_specific
  Statement: Security configuration settings documented in [location].
  Automated compliance scanning via [tool] against [benchmark name].
  Deviations require [exception process] with approval from [role].
```

## IA — Identification and Authentication

```
IA-2 (Identification and Authentication — Organizational Users):
  Type: system_specific
  Statement: All users authenticate via [IdP tool] with [MFA method].
  PIV/CAC required for [privileged/all] access. Service accounts
  use [certificate/API key] with rotation every [X] days.

IA-5 (Authenticator Management):
  Type: system_specific
  Statement: Password policy enforced: [minimum length], [complexity],
  [rotation period], [history depth]. MFA tokens managed via [tool].
  Compromised credential monitoring via [tool/service].
```

## IR — Incident Response

```
IR-4 (Incident Handling):
  Type: system_specific
  Statement: IR plan [document name] defines procedures for detection,
  analysis, containment, eradication, and recovery. IR team:
  [team name/size]. Playbooks exist for [X] incident types.
  Tabletop exercises conducted [frequency]. Last exercise: [date].
  MTTD target: [X] hours. MTTR target: [X] hours.
```

## SC — System and Communications Protection

```
SC-7 (Boundary Protection):
  Type: hybrid
  Statement: Network boundary protected by [firewall/WAF tool].
  Ingress filtering: [rules summary]. Egress filtering: [rules summary].
  DMZ architecture: [description]. Cloud boundary: [security groups/NACLs].
  Inherited controls from [cloud provider] per [FedRAMP package ID].

SC-8 (Transmission Confidentiality and Integrity):
  Type: system_specific
  Statement: All data in transit encrypted using TLS [version].
  Certificate management via [tool]. Internal service mesh uses
  [mTLS/service mesh tool]. VPN for remote access: [VPN tool/protocol].
```

## SI — System and Information Integrity

```
SI-2 (Flaw Remediation):
  Type: system_specific
  Statement: Vulnerability scanning via [tool] running [frequency].
  Patching SLAs: critical=[X] days, high=[X] days, moderate=[X] days.
  Automated patching for [OS/middleware] via [tool]. Application
  patches deployed through [CI/CD pipeline]. Current compliance
  rate: [X]%.

SI-4 (System Monitoring):
  Type: hybrid
  Statement: Host-based monitoring via [EDR tool]. Network monitoring
  via [NDR/IDS tool]. Cloud workload monitoring via [CSPM tool].
  Alerts triaged by SOC within [X] hours. Inherited monitoring
  from [cloud provider] for infrastructure layer.
```

## Common (Inherited) Control Template

```
[Control ID] ([Control Title]):
  Type: common
  Statement: This control is inherited from [provider/shared service
  name]. Provider's [FedRAMP/certification] package [ID] documents
  the implementation. Organization responsibility limited to:
  [describe any customer responsibilities]. Last provider assessment
  date: [date]. Provider POC: [name/email].
```

## Not Applicable Template

```
[Control ID] ([Control Title]):
  Type: not_applicable
  Statement: This control is not applicable to [system name] because
  [justification]. Example: "PE-13 (Fire Protection) is not applicable
  because the system is hosted entirely in [cloud provider]'s
  FedRAMP-authorized data centers. Physical fire protection is the
  responsibility of the cloud provider."
```
