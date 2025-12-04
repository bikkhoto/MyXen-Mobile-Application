<p align="center">
  <img src="assets/myxenpay-logo-dark.png" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">MyXen Foundation — Mobile Application (MyXenPay)</h1>

<p align="center">
  <strong>Security & Privacy Guidelines</strong>
</p>

---

## **1. Security Philosophy**

MyXenPay follows a **security-first, privacy-by-design** approach.
Users retain full control over their private keys, KYC visibility, and sensitive data. No unencrypted private information is ever accessible to the MyXen Foundation or its operators.

Core values:

* **User Sovereignty** — keys never leave the device.
* **Zero Knowledge by Default** — servers store encrypted blobs, not raw user data.
* **Minimal Attack Surface** — limited permissions, strict sandboxing.
* **Reproducible & Auditable** — deterministic builds and transparent cryptography.

---

## **2. Threat Model Overview**

The app defends against threats in the following domains:

### ★ **Device-Level Threats**

* Malware or compromised OS
* Physical phone theft
* Memory scraping
* Screen recording attacks

Mitigations:

* Biometric/PIN gates
* Hardware-backed secure key storage
* Automatic lock
* Sensitive data masking
* No screenshots on sensitive screens (optional project setting)

---

### ★ **Network-Level Threats**

* Man-in-the-middle (MITM)
* Certificate spoofing
* Downgrade attacks

Mitigations:

* TLS 1.3 enforced
* Certificate pinning recommended
* Encrypted payloads using AES-GCM
* Strict version negotiation

---

### ★ **Backend-Level Threats**

* API abuse
* Replay attacks
* Brute-force login attempts
* Data exposure from server compromise

Mitigations:

* Nonces, timestamps, and request signing
* Rate limiting & WAF
* Only encrypted KYC data stored
* Token-bound authentication
* Logging without sensitive user data

---

### ★ **Blockchain-Level Threats**

* Private key extraction
* Signing without user intent
* Transaction spoofing

Mitigations:

* ed25519 keys stored in keystore/secure enclave
* Transaction parsing & human-readable confirmations
* Hardened QR scanning flow
* No program interaction without explicit user consent

---

## **3. Cryptography**

The app uses modern, industry-standard algorithms:

| Area                    | Method          | Purpose                   |
| ----------------------- | --------------- | ------------------------- |
| Mnemonic                | BIP39           | Seed phrase generation    |
| Keypair                 | ed25519         | Solana-compatible signing |
| KYC Storage             | AES-256-GCM     | Client-side encryption    |
| Password/Pin Derivation | PBKDF2 / Argon2 | Local secret derivation   |
| Transport               | TLS 1.3         | Network security          |

### **3.1 Client-side KYC Encryption**

* User enters KYC info → encrypted locally using AES-GCM
* Encryption key derived from user secret (pin/biometric-protected)
* Server receives **only ciphertext**, never raw PII
* Only the user can decrypt and view KYC data
* Post-verification, KYC remains encrypted at rest

This protects user privacy even if servers are compromised.

---

## **4. Key Management**

* Private keys **never leave the device**
* Stored in:

  * **Android:** BiometricPrompt + StrongBox/Keystore
  * **iOS:** Secure Enclave (where available)
* Debug builds **must NOT** allow exporting private keys
* No logs may contain seeds, mnemonics, or private keys

Backup:

* Wallet recovery relies **only** on BIP39 seed phrase
* The application does not sync mnemonics to servers

---

## **5. Secure Coding Guidelines**

* Follow OWASP MASVS & OWASP Mobile Top 10
* No hardcoded API keys or secrets
* Use dependency pinning to avoid supply-chain attacks
* Enable ProGuard / minification / symbol stripping
* No sensitive data in crash reports
* Avoid dynamic code execution
* Enforce strict TypeScript/Dart linting if using RN/Flutter

---

## **6. Dependency & Supply Chain Security**

* Use `npm audit`, `yarn audit`, or package scanner on every commit
* All third-party libraries reviewed before adoption
* Avoid abandoned or non-audited crypto libraries
* SBOM (Software Bill of Materials) generated per release
* CI blocks insecure dependencies

---

## **7. Build & Release Security**

* Reproducible builds required for public releases
* Build signing keys stored in secure hardware (HSM, GitHub OIDC, or encrypted secrets)
* Release artifacts must be hash-verified
* Only designated maintainers can trigger release workflows

---

## **8. Handling Security Vulnerabilities**

### **Report a vulnerability**

If you believe you have found a security issue, please contact:

📧 **[security@myxen.foundation](mailto:security@myxen.foundation)**
(PGP key available upon request)

**Please do not open public GitHub issues for security reports.**

---

### **Response timeline**

| Severity | Response | Fix Window  |
| -------- | -------- | ----------- |
| Critical | 24 hours | 48–72 hours |
| High     | 48 hours | 7 days      |
| Medium   | 3 days   | 14 days     |
| Low      | 5 days   | 30 days     |

---

## **9. Incident Response Policy**

If a security event is detected:

1. Immediate severity classification
2. Revoke/update API keys if needed
3. Hotfix mobile releases
4. Notify affected users if required
5. Conduct full post-mortem with transparent disclosure
6. Implement long-term corrective actions

---

## **10. Permissions & Data Policy**

The app requests permissions **only when required**, including:

* Camera (QR scanning)
* Biometrics (secure access)
* Notifications (transaction events)

The app **never**:

* Accesses contacts
* Reads SMS
* Collects location without explicit user enablement
* Stores unencrypted personal information

---

## **11. Third-Party Services**

All analytics and crash reporting:

* Are **opt-in**
* Exclude sensitive info
* Follow regional data compliance (GDPR, PDPA, etc.)

---

## **12. Audit & Compliance**

MyXen Foundation undergoes:

* Independent smart contract audits
* Independent mobile application penetration tests
* Annual security review
* Ongoing internal red-team testing

Reports (public or redacted) may be published depending on policy.

---

## **13. Responsible Disclosure Recognition**

Researchers who responsibly disclose valid vulnerabilities may receive acknowledgment and rewards under the official disclosure program.

---

## **14. Additional Security Documentation**

For more detailed security policies and procedures, see the `security/` directory:

* **[`security/SIGNING_POLICY.md`](security/SIGNING_POLICY.md)** — Application signing, key management, and secure release policy
* **[`security/SECURITY_ADVISORIES.md`](security/SECURITY_ADVISORIES.md)** — Operational playbook for vulnerability management
* **[`security/advisories/`](security/advisories/)** — Archive of published security advisories
* **[`security/keys/`](security/keys/)** — Key inventory and rotation documentation

---

# **End of SECURITY.md**
