<p align="center">
  <img src="assets/myxenpay-logo-dark.png" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">MyXen Foundation — Mobile Application (MyXenPay)</h1>

<p align="center">
  <strong>Guidelines for Contributors</strong>
</p>

---

## **1. Introduction**

Thank you for your interest in contributing to the MyXen Foundation Mobile Application.
We welcome high-quality contributions that improve security, performance, accessibility, usability, and reliability of the MyXenPay ecosystem.

To maintain professional engineering standards, all contributors must follow this guideline.

---

## **2. Code of Conduct**

By participating in this project, you agree to uphold:

* Respectful communication
* Constructive technical debate
* Zero tolerance for harassment or discriminatory behavior

See `CODE_OF_CONDUCT.md` for details.

---

## **3. How to Contribute**

### **3.1 Reporting Issues**

Before opening a new issue:

1. Check the existing issues.
2. Ensure it hasn't already been reported or resolved.
3. Include:

   * Clear description of the problem
   * Steps to reproduce
   * Expected vs actual behavior
   * Screenshots or logs (ensure no sensitive info included)

**Security issues must NOT be filed publicly.**
Email: **[security@myxen.foundation](mailto:security@myxen.foundation)**

---

### **3.2 Feature Requests**

When proposing a feature:

* Explain **why** this feature benefits the ecosystem
* Provide mockups, flows, or diagrams if possible
* Describe potential risks or dependencies
* Keep scope reasonable and focused

Foundation leadership will review proposals for alignment with roadmap and security policies.

---

### **3.3 Submitting Pull Requests (PRs)**

PRs must follow the workflow:

#### **Step 1: Fork the repository**

```bash
git clone git@github.com:<your-username>/myxenpay-mobile.git
```

#### **Step 2: Create a branch**

Branches must follow naming rules:

| Type          | Format                         |
| ------------- | ------------------------------ |
| Feature       | `feature/<short-description>`  |
| Bugfix        | `fix/<short-description>`      |
| Security      | `security/<short-description>` |
| Documentation | `docs/<short-description>`     |

Example:

```
feature/qr-payment-upgrade
```

#### **Step 3: Make changes**

Follow the coding standards:

* Strict TypeScript/Dart linting
* No unused dependencies
* No console logs or debug prints
* Never commit secrets or keys
* Follow security best practices (see `SECURITY.md`)

#### **Step 4: Add or update tests**

Every PR that changes logic must include:

* Unit tests
* Integration tests (when relevant)

Security-sensitive PRs should include:

* Threat analysis
* Validation that cryptographic flows are intact

#### **Step 5: Commit message rules**

We follow **Conventional Commits**:

```
feat: add biometric unlock support
fix: resolve crash in qr scanner
docs: update readme
refactor: optimize solana rpc calls
test: add unit tests for kyc encryption
chore: update dependencies
```

#### **Step 6: Push & Open PR**

Upon submitting:

* Fill out PR template
* Provide clear summary and checklist
* Link related issues

All PRs must pass:

* Linting
* Unit tests
* Type checks
* Security scans
* CI build

---

## **4. Review Process**

Each pull request requires approval from **at least two maintainers**.

Evaluated criteria:

* Security impact
* Code clarity
* Architectural consistency
* Performance implications
* Backward compatibility
* UX alignment
* Testing coverage

PRs failing security requirements will be rejected.

---

## **5. Style Guidelines**

### **5.1 Code Style**

* Follow official React Native / Flutter style guides
* Use meaningful variable and function names
* Avoid deep nested logic
* Prefer pure functions where possible
* Keep components small and focused

### **5.2 Folder Structure**

Use the predefined repo structure (e.g., for RN):

```
src/
  components/
  screens/
  hooks/
  services/
  crypto/
  utils/
  types/
```

Do not introduce new top-level folders without discussion.

---

## **6. Dependencies Policy**

* New dependencies must be justified
* Avoid heavy libraries when native solutions exist
* No unreviewed cryptographic or network packages
* All dependencies must pass security audits
* Remove unused packages immediately

---

## **7. Documentation Requirements**

Every functional change must include:

* Updated README sections
* Inline code comments
* API documentation if applicable
* Migration notes (if it affects user data or workflows)

PRs lacking documentation will not be merged.

---

## **8. Testing Requirements**

Testing is mandatory:

### **8.1 Unit Tests**

* Must cover at least 80% of new logic
* Crypto functions require deterministic test vectors

### **8.2 E2E Tests**

Required for:

* Login/onboarding
* Wallet creation and restore
* QR sending/receiving
* KYC submissions
* Encryption/decryption flows

### **8.3 Manual QA Checklist**

Required before merge:

* Build installable
* No console logs
* No warnings
* No crash paths

---

## **9. Security Requirements**

Every contributor must follow the high-security standards:

* Never log sensitive data
* Never store unencrypted keys or PII
* Ensure all PRs align with encryption rules
* Validate input strictly
* Avoid any dynamic code execution
* Use secure random number generation

If a PR introduces a cryptographic change:

* Mandatory security review
* Formal reasoning required
* Additional test vectors must be included

---

## **10. Communication Channels**

* **GitHub Issues** → bugs, feature requests
* **GitHub Discussions** → architecture talk, proposals
* **Private Email (security)** → vulnerabilities
* **Internal Slack/Discord (team only)** → real-time coordination

---

## **11. Contributor Recognition**

Meaningful contributors may receive:

* Special roles (Maintainer, Reviewer, Security Advisor)
* Early access to internal documentation
* Public recognition on the Foundation website

---

## **12. License Agreement**

By contributing, you agree that:

* Contributions become part of the project’s open-source license
* You have the legal right to contribute the code
* No proprietary code or confidential material is included

---

# **End of CONTRIBUTING.md**

---
