<p align="center">
  <img src="../assets/logo.svg" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">SIGNING_POLICY.md</h1>

<p align="center">
  <strong>MyXen Foundation — Mobile Application (MyXenPay)</strong>
</p>

---

## Purpose
This document defines policies and procedures for creation, storage, usage, rotation, and emergency handling of cryptographic signing keys used to sign mobile application artifacts (Android keystore / iOS signing certificates), related code signing assets, and any signing keys used for release automation.

It enforces strong controls to protect user funds and reputation by ensuring signing keys are tightly guarded, auditable, and recoverable.

---

## Scope
Applies to:
- Android upload/signing keys (keystore.jks, key alias/passwords)
- iOS distribution certificates & provisioning profiles (P12, mobileprovision)
- App Store Connect API keys
- CI signing tokens (HSM/KMS connectors, short-lived tokens)
- Any custom signing service

---

## Key Principles
1. **Least Privilege** — Only named roles may access signing materials.
2. **Separation of Duties** — Build, sign, and approval responsibilities separated across roles.
3. **Short-lived Credentials** — Prefer OIDC / ephemeral tokens; avoid long-lived secrets.
4. **Tamper-evident Storage** — Use HSM or cloud KMS with audit logging.
5. **Reproducibility & Audit Trail** — Every signed artifact must be traceable to:
   - commit SHA
   - CI build ID
   - approver identities and timestamps
6. **Automated Rotation & Emergency Procedures** — Scheduled rotation and documented emergency revocation.

---

## Roles & Permissions
- **Release Manager**
  - Initiates releases; approves production signing.
  - Cannot perform emergency rotation alone.
- **Security Lead**
  - Reviews cryptographic posture; approves key creation/rotation.
- **Build Engineer (CI Owner)**
  - Maintains CI signing pipeline, integrates HSM/KMS connectors.
- **Operations / SRE**
  - Manages secrets store (vault) and HSM/KMS infrastructure.
- **Auditor**
  - Periodically reviews logs, accesses, and rotation records.

Access Controls:
- Require MFA on all accounts with signing permissions.
- Use RBAC in cloud KMS and secrets manager (least privilege).
- Approvals for production signing must include at least Release Manager + Security Lead.

---

## Storage & Tooling Standards
Preferred storage:
1. **HSM** (Hardware Security Module) — On-prem HSM or cloud HSM (CloudHSM/Azure KeyVault HSM/Google Cloud HSM) for private keys used to sign critical artifacts.
2. **KMS** (Cloud Key Management Service) — Use for lower-risk signing operations and to issue ephemeral signing credentials.
3. **Secrets Manager / Vault** — Use HashiCorp Vault / AWS Secrets Manager / GCP Secret Manager for storing wrapper secrets (e.g., keystore file encrypted blob) with strict access policy and audit enabled.

**Do NOT** store raw keystores / p12 files in plain text in repo or general shared drives.

---

## CI Integration Guidelines
- Prefer GitHub OIDC with cloud provider IAM roles to retrieve short-lived signing credentials (avoid long-lived JSON or password secrets in CI).
- If using a JSON key (Google Play) or App Store Connect key, store the key as an encrypted secret in Vault and provide the CI job scoped, time-limited access to a transient file.
- Signing in CI must run inside ephemeral runners or dedicated, hardened signing agents with network controls and restricted access.

Example safe flow:
1. PR pipeline produces unsigned artifacts in ephemeral storage.
2. Artifacts are uploaded to a secure artifact store (access controlled).
3. A protected environment (GitHub Environment) step with required reviewers triggers a signing job.
4. Signing job fetches ephemeral credentials via OIDC or Vault, signs artifacts, records hashes and metadata, then pushes to distribution.

---

## Key Generation & Format
- **Android**: RSA or EC keystore — use a 4096-bit RSA or >= 3072 ECC key (store in PKCS12/JKS as required).
- **iOS**: Use Apple recommended certificate chain and store p12 with a strong passphrase.
- **App Store Connect API**: Prefer `.p8` API key with `KEY_ID` and `ISSUER_ID`, store in vault.

Key metadata to record upon creation:
- Key ID / alias
- Purpose (upload, app-signing, release)
- Creator and approvers
- Creation date & expiry/rotation date
- Location (KMS/HSM path)
- Thumbprint / public fingerprint (SHA256)

---

## Rotation Policy
### Regular Rotation
- **Upload/Signing Keys (non-revocation-critical)**: rotate annually.
- **High-sensitivity keys (HSM-protected production keys)**: rotate every 6 months.
- **App Store Connect API keys**: rotate annually or on personnel change.
- **Google Play JSON keys**: rotate annually; prefer OIDC where rotation is implicit.

### Rotation Procedure
1. Plan rotation (create `rotation/` ticket, schedule low-traffic time).
2. Generate new key in KMS/HSM (or request new certificate).
3. Stage new key in test environment; verify signing & installability.
4. Update CI to reference new key (with a switch-over window).
5. Revoke old key after verification and confirm no dependent artifacts remain signed only with the old key (if required).
6. Record rotation details in the `key-rotation-log.md`.

### Emergency Rotation
- Triggered on suspected key compromise.
- Immediate actions:
  1. Revoke compromised key in KMS/HSM if possible.
  2. Generate new key with higher privilege and push critical hotfix using emergency lane (hotfix release).
  3. Notify platform providers (Google Play / Apple) and follow their key re-provisioning instructions (this can be time-consuming; pre-document provider procedures).
  4. Run full post-incident review and update rotation cadence if needed.

---

## Backup & Recovery
- Maintain an encrypted backup of key material in at least two geographically separated secure vaults (only for keys that cannot be recovered from HSM).
- Backups must be encrypted with a separate key stored in HSM and only accessible by a quorum of designated officers (e.g., 2-of-3).
- Test key recovery annually in a controlled exercise and document the results.

---

## Audit & Logging
- Enable and retain audit logging for:
  - Key creation, access, rotation, and deletion events (HSM/KMS logs)
  - CI job requests for signing credentials (include CI run ID)
  - Manual export actions
- Retain logs for minimum 2 years (or per compliance requirements).
- Perform quarterly access reviews to revoke stale access.

---

## Developer / Debug Builds
- Developer builds may use separate debug keys that are NOT used for distribution.
- Ensure debug keys are clearly labeled and excluded from release automation.
- Never publish artifacts signed with debug keys to production channels.

---

## Provider-specific Notes
- **Google Play**: use Google Play App Signing. Keep a secure copy of the upload key; protect the app signing key via Google.
- **Apple**: prefer App Store Connect API keys (p8). Keep P12 only when APNs or other flows require it.
- Maintain documented contact points with Google & Apple for key revocation and support cases.

---

## Documentation & Recordkeeping
- Maintain `security/keys/` directory (metadata only — never the secret material) with:
  - `key-inventory.csv` or equivalent
  - `key-rotation-log.md`
  - `signing-approvals/` (signed approval artifacts for each release)
- Each release record must include:
  - Commit SHA
  - CI build ID
  - Artifact SHA256
  - Signer key ID and vault path
  - Approver identities (Release Manager, Security Lead) with timestamps

---

## Final Notes
- Periodically test the whole release pipeline including sign, upload, and install on devices as part of the release cadence.
- Reassess provider capabilities and new best practices every 12 months.

*Adopt these policies and update them when infrastructure or compliance requirements change.*
