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

## 1) How reporters should submit vulnerabilities (public + private)

**Primary (preferred):** Email `security@myxen.foundation` using PGP-encrypted message.  
**Alternate:** GitHub Security Advisory (private advisory) created by repository maintainers when reporter uses the repo's "Report vulnerability" flow.  
**Emergency contact:** `security-oncall@myxen.foundation` (pager / PagerDuty) — for active exploits.

### Email / PGP instructions for reporters

- Send to: `security@myxen.foundation`  
- Subject: `Security report: MyXenPay - [short summary]`  
- For privacy, encrypt with our PGP key:
  - **PGP fingerprint:** `<PASTE_REAL_FINGERPRINT_HERE>`
  - **Public key URL:** `https://myxenpay.finance/pgp.pub` (or other hosted location)
- If you cannot PGP-encrypt, send the report unencrypted but mark it "sensitive" — we will reply with a secure upload link.
- Include: affected component (Android/iOS/Backend/Contract), steps to reproduce, proof-of-concept (PoC), impact, affected versions, and any exploitability details.

---

## 2) Quick triage & acknowledgement (first 24 hours)

When a report arrives:

1. Acknowledge receipt within 24 hours to the reporter (automated + personalized).  
2. Create a **private Security Advisory** in GitHub (or private tracker).  
3. Assign initial severity using our classification.  
4. Start investigating — reproduce PoC in an isolated environment.  
5. If the issue has been publicly disclosed accidentally, move discussion to the private advisory and lock public threads.

**Acknowledgement template** (short):

```
Subject: [MyXenPay] Acknowledgement of security report

Hello <Researcher Name>,

Thank you — we received your report regarding MyXenPay and we take this seriously.

Ticket: MYXN-SEC-<XXXX>
Assigned triage lead: <name/email>

We will confirm next steps within 24 hours and provide an estimated timeline for remediation. If you provided a PGP-encrypted message, we will continue securely. If not, we can provide a secure upload link upon request.

Regards,
MyXen Foundation Security Team
security@myxen.foundation
```

---

## 3) Private triage checklist (do these immediately)

- [ ] Validate reporter identity (if needed).
- [ ] Reproduce PoC in isolated environment (no production data).
- [ ] Identify root cause and attack vectors.
- [ ] Determine affected versions and components.
- [ ] Evaluate exploitability and user safety risk.
- [ ] Classify severity (Critical/High/Medium/Low).
- [ ] Decide short-term mitigation (hotfix/rollback/permission block).
- [ ] Create private GitHub Security Advisory and internal ticket.
- [ ] Communicate estimated disclosure timeline to reporter.

---

## 4) Severity classification (quick scheme)

- **Critical** — Active exploit can drain user funds, exfiltrate keys, or allow arbitrary code execution in signing/keys scope; immediate hotfix required.
- **High** — Exploitable vulnerability enabling transaction forgery, account takeover without physical device, or server-side decryption of PII.
- **Medium** — Local escalations, privacy leaks without immediate financial loss.
- **Low** — Information disclosure with minimal impact or non-exploitable bugs.

Where possible, calculate and store a CVSS v3.1 score.

---

## 5) Fix plan & release approach

- **Critical / High**
  - Create `hotfix/SEC-xxxx` branch immediately.
  - Expedited security review (min. Security Lead + Senior Engineer).
  - Sign hotfix artifact via protected signing pipeline (HSM/KMS).
  - Deploy staged rollout (1% → 100%) or force upgrade if necessary.
  - Prepare public advisory and request CVE if applicable.
- **Medium / Low**
  - Schedule fix according to release cadence but keep advisory private until fix merged.
  - Coordinate disclosure timing with reporter.

---

## 6) GitHub Security Advisory workflow

1. Create a **Draft security advisory** in the repository (Security → Advisories → New draft advisory).
2. Populate: title, affected versions (introduced/fixed), severity, technical description, reproduction steps (private PoC), mitigation/fix (PR links).
3. Use the advisory's private discussion to communicate with the reporter and collaborators.
4. After fix verification, publish advisory and request CVE (optional).
5. Do **not** publish until fixes are available or coordinated with reporter and stakeholders.

---

## 7) Disclosure & CVE coordination

- Request CVE when publishing advisory for user-impacting vulnerabilities.
- Typical embargo window: 7–90 days depending on severity and remediation difficulty.
- Public advisory must include: impact summary, affected versions, fixed versions, mitigation steps, CVE (if assigned), and credits (if reporter consents).

---

## 8) Templates

### Reporter initial email (for your site)

```
Subject: Security report — MyXenPay

Hello MyXen Foundation Security Team,

I would like to report a security issue affecting the MyXenPay mobile application.

Summary:
* Component: (Android / iOS / Backend / Smart contract)
* Affected versions: (e.g., Android v1.2.3)
* Impact: (brief)

Steps to reproduce / PoC:
1. ...
2. ...
3. ...

Proof-of-concept artifacts:
* [attach encrypted PoC, logs]

I encrypted this message with your PGP key (fingerprint: <FINGERPRINT>) — public key here: https://myxenpay.finance/pgp.pub

Please acknowledge receipt and provide a ticket ID.

Regards,
<Name / Handle>
<Contact>
```

### Private advisory description (for GitHub draft)

```
Title: [short] - [component] - [brief impact]

Description:
* Summary: one paragraph describing the vulnerability and impact.
* Affected components: (list)
* Affected versions: (introduced in vX.Y.Z through vA.B.C)
* Root cause: (technical cause)
* Reproduction: (high-level steps; private PoC attached)
* Mitigation/fix: (PR link(s), commit hashes)
* Workarounds: (if any)
* CVSS: (score and vector if available)
* Reporter: [handle] (consent for credit: yes/no)
* Timeline: (reported / triaged / fixed / published)
```

### Public advisory publish template

```
Title: Security advisory — MyXenPay [short descriptor] (CVE-YYYY-NNNN)

Summary:
A vulnerability affecting MyXenPay mobile (Android/iOS) could allow <brief impact>. This has been fixed in versions <fixed-version>.

Affected Versions:
* Introduced: vX.Y.Z
* Fixed: vA.B.C and later

Impact:
* High-level description of what an attacker could do.

Mitigation:
* Upgrade to vA.B.C (Android: Play / iOS: App Store) immediately.
* If you cannot upgrade immediately: <workarounds>.

CVE: CVE-YYYY-NNNN (if assigned)

Credits:
* Researcher: <name/handle> (opt-in for credit)

Report & Contact:
If you have further details, contact security@myxen.foundation (PGP available).

Disclosure timeline:
* Reported: YYYY-MM-DD
* Fixed: YYYY-MM-DD
* Published: YYYY-MM-DD
```

---

## 9) SLAs & response times

- **Acknowledge report:** within 24 hours.
- **Initial triage:** within 72 hours.
- **Patch (Critical):** 48–72 hours (hotfix lane) or immediate mitigation.
- **Patch (High):** within 7 days.
- **Patch (Medium):** within 14 days.
- **Patch (Low):** within 30 days.

Always communicate timeline changes to the reporter.

---

## 10) Rewards & Recognition (optional)

- Offer public recognition if the reporter consents.
- Optionally run a bounty program (separate policy).

---

## 11) Tooling & integrations (recommended)

- GitHub Security Advisories (private discussions and CVE publishing).
- Dependabot and Snyk (SCA).
- Semgrep / CodeQL (SAST).
- Private tracker (Jira) for internal audit trail.
- PGP for secure email submissions.

---

## 12) Post-disclosure actions

- Publish advisory once coordinated and fix verified.
- Rotate secrets/keys if necessary.
- Run postmortem and update procedures.
- Protect findings by checking for similar code patterns.

---

## 13) Process summary (one line)

Receive → Acknowledge → Private Advisory → Triage → Fix (hotfix if necessary) → Sign & Release → Publish Advisory & CVE → Postmortem

---

## 14) Contact Information

| Purpose                    | Contact                              |
| -------------------------- | ------------------------------------ |
| Security Reports           | security@myxen.foundation            |
| Emergency (Active Exploit) | security-oncall@myxen.foundation     |
| General Inquiries          | support@myxen.foundation             |
| Legal / Compliance         | legal@myxen.foundation               |

---

## 15) Document Revision

* **Version:** 2.0
* **Last Updated:** December 2025
* **Review Frequency:** Every 6 months or after significant incidents
* **Approval Required:** Security Lead + CTO

---

# End of SECURITY_ADVISORIES.md
