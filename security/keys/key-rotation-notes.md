<p align="center">
  <img src="../../assets/myxenpay-logo-dark.png" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">Key Rotation Notes</h1>

<p align="center">
  <strong>MyXen Foundation — Mobile Application (MyXenPay)</strong>
</p>

---

Use this file to document each key rotation event. Store rotated key metadata here (never store private key material).

## Rotation entry template

- **Rotation ID:** ROT-YYYYMMDD-XXX
- **Date:** YYYY-MM-DD
- **Key ID / Alias:** kms-key-23-prod
- **Key Type:** Android Upload Key / iOS Distribution / ASC .p8 / CI Ephemeral
- **Platform:** Android / iOS / Both
- **Performed By:** <name> (<role>)
- **Approved By:** <name> (<role>)
- **Reason:** (scheduled rotation / suspected compromise / personnel change)
- **New Key Location:** (KMS path / HSM identifier)
- **Old Key Revoked:** Yes / No (date/time)
- **Migration Steps:**
  1. ...
  2. ...
- **Verification Steps (pass/fail):**
  - Signed test build verification: PASS/FAIL
  - Artifact install & run tests: PASS/FAIL
- **Notes:** (any special actions)
- **Artifacts / Proofs:** (links to manifests, artifact hashes)

---

## Rotation Log

| Rotation ID | Date | Key ID | Key Type | Platform | Performed By | Approved By | Reason | Status |
|-------------|------|--------|----------|----------|--------------|-------------|--------|--------|
| *No rotations recorded yet* | | | | | | | | |
