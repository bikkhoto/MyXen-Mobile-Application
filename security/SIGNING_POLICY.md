<p align="center">
  <img src="../assets/myxenpay-logo-dark.png" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">SIGNING_POLICY.md</h1>

<p align="center">
  <strong>MyXen Foundation — Mobile Application (MyXenPay)</strong><br>
  <em>Application Signing, Key Management & Secure Release Policy</em>
</p>

---

# 1. Purpose

This policy defines the standards, controls, and operational procedures for the creation, protection, use, and rotation of cryptographic signing keys required for:

* Android application signing
* iOS application signing
* App Store Connect / Google Play uploads
* Code-signing used in CI/CD automation
* Artifact integrity validation
* Secure reproducible releases

This ensures MyXenPay remains **secure, trustworthy, and resistant to tampering**, supporting MyXen Foundation's mission of building a human-safe, privacy-preserving financial system.

---

# 2. Scope

This policy applies to:

| Signing Component                         | Platform | Description                                        |
| ----------------------------------------- | -------- | -------------------------------------------------- |
| **Android Upload Key**                    | Android  | Used to authenticate uploaded builds.              |
| **Android App Signing Key**               | Android  | Managed by Google Play App Signing.                |
| **iOS Distribution Certificate**          | iOS      | Used to sign IPA for App Store.                    |
| **Apple App Store Connect API Key (.p8)** | iOS      | Used to authenticate TestFlight/App Store uploads. |
| **CI/CD Signing Credentials**             | Both     | Ephemeral keys retrieved via OIDC/KMS.             |
| **Internal Testing Certificates**         | Both     | Used for QA/internal builds only.                  |

---

# 3. Security Objectives

1. Prevent unauthorized signing of APK/AAB/IPA artifacts.
2. Prevent tampering or substitution of signed build artifacts.
3. Ensure all signing operations are **auditable** and **traceable**.
4. Maintain key confidentiality using HSM/KMS and RBAC controls.
5. Maintain **reproducible builds** enabling artifact verification.
6. Rapid detection and response for any potential key compromise.

---

# 4. Roles & Responsibilities

| Role                  | Responsibility                                                      |
| --------------------- | ------------------------------------------------------------------- |
| **Release Manager**   | Initiates releases, approves signing. Cannot rotate keys alone.     |
| **Security Lead**     | Oversees key lifecycle, approves key access, reviews signing logs.  |
| **Build/CI Engineer** | Implements pipeline, integrates HSM/KMS, ensures reproducibility.   |
| **SRE/DevOps**        | Manages vault/KMS/HSM configuration and audit logs.                 |
| **Auditor**           | Reviews key usage logs, compliance, and rotation reports quarterly. |

**Separation of duties is mandatory.**
No single role may create, approve, and use signing keys.

---

# 5. Key Inventory

| Key Type                     | Storage                  | Responsible Team   | Rotation Frequency  | Revocation Method           |
| ---------------------------- | ------------------------ | ------------------ | ------------------- | --------------------------- |
| Android Upload Key           | Vault + encrypted backup | Security           | 12 months           | Keystore replacement        |
| Android App Signing Key      | Google Play              | Google             | Google-managed      | Through Play Console        |
| iOS Distribution Certificate | HSM / Vault              | Security + Release | 12 months           | Revoke in Developer Console |
| ASC API Key (.p8)            | Vault                    | Security           | 12 months           | Revoke in App Store Connect |
| CI Ephemeral Keys            | KMS via OIDC             | CI Engineering     | None (short-lived)  | TTL expiry                  |
| Debug/Test Keys              | Local Dev Machines       | Dev Leads          | Rotated per quarter | Regenerate                  |

A full machine-readable inventory is kept at:
`security/keys/key-inventory.csv`

---

# 6. Key Storage Requirements

## 6.1 Allowed storage methods

Signing keys **must** be stored using one of the following:

### **1. Cloud HSM (Preferred)**

* AWS CloudHSM
* Azure Dedicated HSM
* Google Cloud HSM

### **2. Cloud KMS**

* AWS KMS
* Azure Key Vault
* Google KMS

### **3. HashiCorp Vault Enterprise (with audit logs)**

### NOT allowed

* GitHub Secrets (for raw key files)
* Local machines
* Repo commits
* Third-party servers without attestation
* Slack/Drive/Email transmission

---

# 7. CI/CD Signing Architecture (Mandatory)

All signing must occur in one of the following ways:

## **Option A — CI retrieves short-lived credentials using GitHub OIDC**

* No static JSON keys
* CI job receives a **temporary token**
* Token is used to sign via KMS/HSM
* Token auto-expires in minutes

## **Option B — CI calls Remote Signing Service**

* Artifact → hash calculated
* Hash sent to signing service
* HSM signs → signature returned
* CI assembles signed package

## **Option C — Upload Key is decrypted in ephemeral runner with strict controls**

Used only if HSM is not fully integrated yet.

Constraints:

* Runner must be **ephemeral**
* Memory must be wiped after execution
* Decryption allowed only inside protected GitHub Environment
* Logging must never include secrets

---

# 8. Key Rotation Procedures

## 8.1 Standard Rotation (12 months)

1. Create rotation issue with ID (tracked in `key-rotation-log.md`)
2. Generate new key in KMS/HSM
3. Test-signed builds verified on physical devices
4. Update CI pipeline to reference new key (staged rollout)
5. Perform release using new key
6. Revoke old key after 2-week overlap
7. Document rotation event & signatures

## 8.2 Automatic Rotation (ASC API keys, KMS ephemeral keys)

* Automatically handled by provider
* Audit logs must confirm rotation success
* Replace local references with new KEY_ID

## 8.3 High-Security Rotation (Compromise Suspected)

Triggered under these conditions:

* Sudden illegitimate signed build surfaces
* Key used unexpectedly outside release window
* Suspicious auth logs via KMS/HSM

Steps:

1. Immediate revocation via provider (Google/Apple/KMS)
2. Disable all deployments
3. Generate emergency key
4. Issue a hotfix release signed by emergency key
5. Conduct full incident investigation
6. Notify impacted users if required
7. Update internal postmortem within 72 hours

---

# 9. Artifact Integrity Controls

Every artifact must include:

| Check                | Required |
| -------------------- | -------- |
| SHA256 hash          | ✔        |
| Build ID             | ✔        |
| Commit SHA           | ✔        |
| CI Runner ID         | ✔        |
| Signer Key ID        | ✔        |
| Release Approver IDs | ✔        |

Store under:
`artifacts/<version>/manifest.json`

A sample manifest:

```json
{
  "artifact": "app-release.aab",
  "sha256": "f83b91cceb8e1bb...",
  "commit": "7ef9c1d",
  "ci_build": "github-run-88422",
  "key_id": "kms-key-23-prod",
  "approved_by": ["release_manager", "security_lead"],
  "signed_at": "2025-12-05T16:22:17Z"
}
```

---

# 10. Approval Workflow (Mandatory for Production)

Before any signing occurs:

1. Release Manager approves commit for release
2. Security Lead approves signing request
3. CI triggers job under protected GitHub Environment
4. Artifact gets signed
5. Signed artifact is uploaded to TestFlight/Play Internal

Production rollout requires:

* Second manual approval step
* Monitoring windows (1% → 10% → 50% → 100%)

---

# 11. Backup & Recovery Policy

## Backup Requirements

* Encrypted at-rest using AES-256-GCM
* Stored separately from the vault (geo redundancy)
* Access only via quorum (2-of-3 rule)

## Recovery Testing

* Annual dry-run
* Must validate:

  * Recovery of backup
  * Ability to re-sign a test build
  * Audit logging confirmed

---

# 12. Incident Response

Triggers:

* Unauthorized build appears
* Suspicious signing job
* Key exposure leak
* CI compromise

Immediate actions:

1. Revoke affected key
2. Disable CI publish workflows
3. Deploy forced application update (if needed)
4. Forensic review of CI logs, audit logs, commit history
5. Rotate all relevant credentials
6. Publish internal incident report within 48 hours

---

# 13. Compliance & Audit Requirements

This policy supports compliance with:

* ISO 27001 Annex A (Cryptographic Controls)
* SOC 2 Security & Integrity categories
* GDPR (data protection & privacy integrity)
* OWASP MASVS Level 2 (mobile security)

Quarterly:

* Audit logs reviewed
* Key inventory verified
* All keys validated against rotation schedule

---

# 14. Developer Guidelines (Critical)

Developers **must not:**

* Store keys in `.env`
* Store keystores in repo
* Store p12/.p8 files in repo
* Upload keys to Google Drive, Dropbox, Telegram, WhatsApp
* Email keys to team members

Developers **must:**

* Use dedicated debug keys for development
* Never sign local builds with production keys
* Report any suspicion of compromise immediately

---

# 15. Document Revision Process

* Policy must be reviewed every **6 months**
* Major revisions require approval from:

  1. Security Lead
  2. CTO / Foundation Board
  3. Compliance Officer (if applicable)

---

# 16. Appendix: Key Rotation Log Template

`security/keys/key-rotation-log.md`:

```markdown
# Key Rotation Log

| Date | Key ID | Platform | Performed By | Approved By | Reason | Notes |
|------|--------|----------|--------------|-------------|--------|-------|
| 2025-01-01 | kms-key-23-prod | Android | security_lead | release_manager | Annual rotation | Success |
```

---

# End of SIGNING_POLICY.md
