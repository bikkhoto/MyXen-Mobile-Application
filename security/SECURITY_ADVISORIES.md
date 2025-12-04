<p align="center">
  <img src="../assets/myxenpay-logo-dark.png" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">Security Advisories — MyXenPay</h1>

<p align="center">
  <strong>Operational Playbook for Vulnerability Management</strong>
</p>

---

## Purpose

Provide a secure, private, and auditable process for receiving, triaging, fixing, and publishing security advisories affecting MyXenPay mobile application code and related artifacts. Preserve user safety, coordinate responsible disclosure, and produce clear advisories for users and auditors.

---

## 1. How Reporters Should Submit Vulnerabilities

### Primary (Preferred)

Email `security@myxen.foundation` using PGP-encrypted message.

### Alternate

GitHub Security Advisory (private advisory) created by repository maintainers when reporter uses the repo's "Report vulnerability" flow.

### Emergency Contact

`security-oncall@myxen.foundation` (pager duty) — for active exploits.

---

## 2. Email / PGP Instructions for Reporters

Send to: `security@myxen.foundation`

**Subject format:** `Security report: MyXenPay - [short summary]`

For privacy, encrypt with our PGP key:

```
MyXen Foundation Security Team
PGP Key Fingerprint: [TO BE PUBLISHED]
Key available at: https://myxenpay.finance/.well-known/pgp-key.asc
```

### What to Include in Your Report

* Clear description of the vulnerability
* Steps to reproduce
* Affected versions / platforms (Android/iOS)
* Proof-of-concept code or screenshots (if available)
* Impact assessment (what could an attacker achieve?)
* Your contact information for follow-up
* Preferred attribution name (for public disclosure credit)

---

## 3. Response Timeline (SLA)

| Severity   | Initial Response | Triage Complete | Fix Target    | Public Advisory |
| ---------- | ---------------- | --------------- | ------------- | --------------- |
| Critical   | 4 hours          | 24 hours        | 48-72 hours   | After fix       |
| High       | 24 hours         | 48 hours        | 7 days        | After fix       |
| Medium     | 48 hours         | 5 days          | 14 days       | After fix       |
| Low        | 5 days           | 10 days         | 30 days       | After fix       |

---

## 4. Severity Classification

### Critical

* Remote code execution
* Private key extraction
* Unauthorized fund transfers
* Authentication bypass affecting all users
* Complete KYC data exposure

### High

* Significant data leakage (partial PII)
* Session hijacking
* Privilege escalation
* Denial of service affecting payments

### Medium

* Limited information disclosure
* Cross-site scripting (XSS)
* Insecure data storage (non-critical data)
* Logic flaws with limited impact

### Low

* Minor information leakage
* Best practice violations
* Theoretical attacks with high complexity
* UI/UX security concerns

---

## 5. Internal Triage Process

### Step 1: Acknowledge Receipt

* Confirm receipt within SLA
* Assign tracking ID: `MYXEN-SEC-YYYY-NNN`
* Notify Security Lead

### Step 2: Validate & Reproduce

* Attempt to reproduce the issue
* Assess impact and severity
* Determine affected components

### Step 3: Assign Response Team

| Role              | Responsibility                                    |
| ----------------- | ------------------------------------------------- |
| Security Lead     | Overall coordination, disclosure decisions        |
| Engineering Lead  | Fix development and review                        |
| Release Manager   | Hotfix release coordination                       |
| Communications    | User notifications, public advisory drafting      |
| Legal (if needed) | Compliance, regulatory notification requirements  |

### Step 4: Develop Fix

* Create private branch for fix
* Peer review by at least 2 engineers
* Security Lead sign-off required
* Regression testing mandatory

### Step 5: Release & Notify

* Deploy hotfix through expedited release process
* Notify reporter of fix
* Prepare public advisory (if applicable)

---

## 6. Coordinated Disclosure Policy

MyXen Foundation follows responsible disclosure principles:

1. **Private Period:** We request 90 days to address vulnerabilities before public disclosure
2. **Mutual Agreement:** Disclosure timeline may be adjusted based on severity and fix complexity
3. **Credit:** Reporters receive public credit unless they request anonymity
4. **No Legal Action:** We do not pursue legal action against good-faith security researchers

### Exceptions to 90-Day Window

* Active exploitation in the wild → immediate disclosure after fix
* Critical severity with simple fix → shorter window negotiated
* Third-party dependency issue → coordinate with upstream maintainers

---

## 7. Advisory Publication Format

### GitHub Security Advisory (GHSA)

All advisories published via GitHub Security Advisories for:
* CVE assignment
* Automated tooling integration
* Audit trail

### Advisory Template

```markdown
# Security Advisory: [Title]

## Summary
[Brief description of the vulnerability]

## Severity
[Critical / High / Medium / Low]

## Affected Versions
- MyXenPay iOS: x.y.z - a.b.c
- MyXenPay Android: x.y.z - a.b.c

## Patched Versions
- MyXenPay iOS: a.b.d+
- MyXenPay Android: a.b.d+

## Description
[Detailed technical description]

## Impact
[What could an attacker achieve?]

## Mitigation
[Steps users should take]

## Credit
[Reporter attribution]

## References
- CVE-YYYY-NNNNN
- Related PRs / commits
```

---

## 8. Communication Channels

### Internal

* Security Slack channel: `#security-incidents`
* Incident war room (for Critical/High)
* Security mailing list: `security-team@myxen.foundation`

### External

* Security advisory page: GitHub Security Advisories
* User notification: In-app banner + push notification (for critical issues)
* Email notification: Registered users (for critical issues affecting their data)
* Social media: @MyXenPay (after fix is available)

---

## 9. Post-Incident Review

After each security incident:

1. **Root Cause Analysis** — Document how the vulnerability was introduced
2. **Detection Gap Analysis** — Why wasn't this caught earlier?
3. **Process Improvements** — Update security practices, testing, or tooling
4. **Timeline Review** — Was SLA met? What caused delays?
5. **Documentation Update** — Update threat model, security docs

### Post-Incident Report Template

```markdown
# Post-Incident Report: MYXEN-SEC-YYYY-NNN

## Incident Summary
## Timeline of Events
## Root Cause
## Impact Assessment
## Response Effectiveness
## Lessons Learned
## Action Items
```

---

## 10. Bug Bounty Program

MyXen Foundation operates a bug bounty program for qualifying vulnerabilities.

### Rewards (Subject to Change)

| Severity | Reward Range        |
| -------- | ------------------- |
| Critical | $5,000 - $25,000    |
| High     | $1,000 - $5,000     |
| Medium   | $250 - $1,000       |
| Low      | Recognition only    |

### Qualifying Criteria

* First reporter of the issue
* Valid, reproducible vulnerability
* Not previously known or in-progress fix
* Reported through proper channels
* No exploitation of the vulnerability beyond proof-of-concept
* No disclosure before fix is available

### Out of Scope

* Social engineering attacks
* Physical attacks on infrastructure
* Denial of service attacks
* Issues in third-party services
* Issues requiring physical access to device
* Vulnerabilities in non-production environments

---

## 11. Record Keeping

All security incidents must be logged in:

* `security/advisories/` directory (sanitized public records)
* Internal security incident database (full details)
* Compliance reporting systems (as required)

Retention: Minimum 7 years for compliance purposes.

---

## 12. Regulatory Notification Requirements

Depending on jurisdiction and data affected:

| Regulation | Notification Requirement                        |
| ---------- | ----------------------------------------------- |
| GDPR       | 72 hours to supervisory authority (if PII)     |
| PDPA       | As soon as practicable to affected individuals |
| PCI-DSS    | Per card brand requirements                    |
| Local Laws | Per jurisdiction requirements                  |

Legal team must be consulted for any incident involving:
* Personal data breach
* Financial data exposure
* Cross-border data transfer issues

---

## 13. Contact Information

| Purpose                | Contact                              |
| ---------------------- | ------------------------------------ |
| Security Reports       | security@myxen.foundation            |
| Emergency (Active Exploit) | security-oncall@myxen.foundation |
| General Inquiries      | support@myxen.foundation             |
| Legal / Compliance     | legal@myxen.foundation               |

---

## 14. Document Revision

* **Version:** 1.0
* **Last Updated:** December 2025
* **Review Frequency:** Every 6 months or after significant incidents
* **Approval Required:** Security Lead + CTO

---

# End of SECURITY_ADVISORIES.md
