<p align="center">
  <img src="assets/myxenpay-logo-dark.png" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">MyXen Foundation — Mobile Application (MyXenPay)</h1>

<p align="center">
  <strong>Official release process for Android & iOS, designed for secure, auditable, and reproducible production rollouts.</strong>
</p>

---

# 1. Objective

Provide a single, authoritative procedure to produce, sign, test, publish, and monitor mobile releases (alpha → beta → production). Priorities: **security**, **reproducibility**, **auditability**, and **minimal blast radius** for defects.

---

# 2. Versioning & Branching

## Versioning

* Use **Semantic Versioning**: `MAJOR.MINOR.PATCH` (e.g., `2.3.1`).
* Reserve MAJOR bumps for breaking changes (migration required).
* Pre-release identifiers allowed (e.g., `2.4.0-rc.1`).

## Branching model

* `main` (protected) — production ready only. Tag releases here.
* `develop` — integration branch for completed features / QA.
* `feature/*` — short-lived feature branches.
* `hotfix/*` — urgent fixes created from `main` and merged back to `develop` & `main`.
* `release/*` — optional stabilization branches for major releases.

Protection rules for `main`:

* Require 2 approvers.
* Passing CI (lint, unit tests, security scans).
* Signed commits enforced (if feasible).
* No direct pushes — PR only.

---

# 3. Release types & risk model

* **Canary / Internal (Alpha)**: internal QA, fast cadence. Highly permissive rollouts.
* **Beta (Staged)**: limited external user groups (TestFlight / Play testing). Wider testing.
* **Production (Gradual Rollout)**: phased release (1% → 100%) with observability gates.
* **Hotfix**: emergency patch to production; follow expedited process, still requires audit and post-mortem.

Risk appetite:

* Canary: high
* Beta: medium
* Production: low — conservative rollouts

---

# 4. Pre-release Requirements (Checklist)

Every release MUST satisfy the checklist below before any artifact is signed:

1. **Issue & PRs**

   * All linked PRs merged to `release/*` or `main`.
   * All related issues closed or documented.

2. **CI / Tests**

   * Linting: pass
   * Unit tests: pass (minimum coverage per repo policy)
   * Integration/E2E tests: pass (critical flows)
   * Static analysis & SAST: pass
   * Dependency audit: no critical vulnerabilities

3. **Security**

   * Security review completed for cryptography changes.
   * Threat model updated if flow changed.
   * SBOM generated.
   * No secrets in code; verify via secret scanning.

4. **Build**

   * Deterministic / reproducible build verification run locally or in CI.
   * Build artifacts (APK / AAB / IPA) produced in ephemeral CI runner with ephemeral keys OR HSM-backed signing.

5. **Signing**

   * Android keystore & iOS signing keys in secure vault (HSM / cloud KMS / GitHub Secrets with restricted access).
   * Access control & audit logs enabled for signing key operations.

6. **Release Notes & Changelog**

   * Draft release notes and changelog entries prepared in PR.

7. **Compliance**

   * Legal review for copy changes (if any).
   * Privacy checklist: telemetry, opt-ins, GDPR/PDPA compliance verified.

8. **Distribution groups**

   * Define tester groups (alpha, beta, partner lists).

---

# 5. Build & Signing (detailed)

## Android

1. CI builds AAB (recommended) and APK (if needed) from `release/*` or `main`.
2. Signing:

   * Prefer server-side signing in CI with credentials from HSM/KMS / GitHub OIDC or ephemeral signing agents.
   * Use Google Play App Signing (Upload key + App signing key) for added resilience.
3. Generate ProGuard/R8 mapping file and store as release artifact (safely).
4. Generate SBOM and artifact hashes (SHA256).

## iOS

1. CI produces IPA via Xcode / Fastlane on macOS CI runners.
2. Use Apple App Store Connect API tokens stored in a secure vault for uploads.
3. Use Managed App Distribution (TestFlight) for betas.
4. Preserve dSYM files and symbolicate crash reports.

## Artifact handling

* All build artifacts, mapping files, SBOM, and dSYMs must be stored in tamper-evident artifact storage (e.g., artifact repository with access controls).
* Tag the commit used to produce the artifact (e.g., `v2.3.1`) and attach metadata.

---

# 6. Release Automation & CI/CD gates

Automate as much as practical but keep human approvals for production:

### CI pipeline stages (example)

1. PR validation: lint, unit tests
2. Merge to `develop`: integration, E2E
3. Release candidate build: produce unsigned artifacts
4. Security scans & SBOM creation
5. Manual `Release Manager` approval to sign
6. Sign & publish to internal distribution (Alpha)
7. QA passes → promote to Beta
8. Beta feedback → approve for production
9. Staged rollout to Play/App Store

### Human approvals

* Production sign/publish requires explicit approval from two roles:

  * Release Manager
  * Security Lead (or delegated)

---

# 7. Staged Rollout Strategy

Use progressive rollouts to detect regressions early.

Android (Play Console):

* Start at 1% — monitor for 24–72 hours
* If metrics healthy, increase to 10% → 25% → 50% → 100%

iOS (App Store):

* Use phased release / internal canary groups and TestFlight groups.
* Apply same monitor-and-promote strategy.

Monitoring windows:

* For critical flows (payments, login), monitor for 24–72 hours after each ramp.

Rollback rules:

* Any critical crash increase, payment flow failure, or security incident: initiate rollback.
* Rollbacks must be communicated to stakeholders and followed by hotfix plan.

---

# 8. Hotfix & Emergency Releases

When an urgent fix is required:

1. Create `hotfix/<short-desc>` from `main`.
2. Implement fix, include minimal test coverage & security review.
3. Bypass standard wait-times but still:

   * Run CI tests and security scan (fast mode).
   * Get 1 maintainer + security on-call approval.
4. Build → Sign → Release with immediate small staged rollout.
5. Post-incident: full post-mortem within 72 hours. Merge hotfix back to `develop`.

---

# 9. Release Notes & Changelog

Provide concise, user-friendly release notes and a detailed changelog for auditors.

### Release Notes Template

* **Version**: `vX.Y.Z`
* **Date**: `YYYY-MM-DD`
* **Type**: Bugfix / Feature / Security / Hotfix
* **Highlights**:

  * Short bullet summary (user-facing)
* **Security notes**:

  * If applicable, a high-level note about fixes (do not disclose exploit details)
* **Upgrade notes**:

  * Any user actions needed
* **Acknowledgments**:

  * Contributors or security researchers (opt-in)

Attach full developer changelog for auditors with PR links and issue IDs.

---

# 10. Post-release Monitoring & Telemetry

Immediately after release monitor:

* Crash rates (Sentry / Crashlytics)
* Key business metrics (successful payments, tx failures)
* API error rates and latency
* Authentication/KYC flows error rates
* User feedback channels (support, app reviews)

Gates:

* If crash rate > threshold (predefined) → pause rollout.
* If payment success rate declines → rollback and investigate.

---

# 11. Rollbacks & Remediation

Rollback steps:

1. Pause the staged rollout or remove the release in Play Console.
2. Re-publish previous stable artifact or hotfix depending on cause.
3. Notify users (if necessary) and provide mitigation steps.
4. Run a postmortem and create remediation tickets.

Records:

* Keep chronological log of actions (who, when, why) for audits.

---

# 12. Artifact & Audit Trail

For every release store:

* Artifact(s) (AAB/APK/IPA)
* Build logs
* Mapping/proguard and dSYM files
* SBOM
* Release notes & changelog
* Security scan reports
* Sign-off approvals with timestamps & identities

Retention: keep production release artifacts and metadata for **minimum 2 years** (or project-specific compliance timeframe).

---

# 13. Legal & Compliance

* Include export control, sanctions checks for builds if enabling crypto features in restricted jurisdictions.
* Ensure release complies with App Store & Play Store policies and local laws (e.g., financial services regulations).
* Maintain legal sign-off for the release when features touch compliance surface (KYC, payments).

---

# 14. Roles & Responsibilities

* **Release Manager** — orchestrates release, ensures checklist complete.
* **Security Lead** — approves security posture, reviews cryptographic changes.
* **Build Engineer / CI Owner** — manages signing & artifact pipeline.
* **QA Lead** — certifies functional tests and E2E flows.
* **Product Owner** — approves user-facing release notes and gating.
* **Support/Operations** — prepares support scripts & monitoring dashboards.

Define escalation paths and on-call rotations in `OPERATIONS.md`.

---

# 15. Example release flow (concise)

1. Branch `release/2.3.0` created from `develop`.
2. QA completes full test matrix.
3. CI produces unsigned artifacts; SBoM & scans created.
4. Release Manager + Security approve.
5. CI signs artifacts using HSM/KMS → upload to internal alpha.
6. Alpha testing → Beta group in TestFlight/Play.
7. After meeting KPI gates, initiate staged production rollout (1% → 100%).
8. Monitor; if ok, mark release complete and merge `release/2.3.0` to `main` and tag `v2.3.0`.

---

# 16. Helpful commands & tips

* Always run `yarn lint && yarn test` (or platform equivalent) before opening release PR.
* Validate reproducible builds by comparing artifact hashes from CI vs local (if allowed).
* Keep mapping/dSYM upload tasks automated in CI to avoid lost crash symbols.

---

# 17. Templates & Attachments (Suggested files)

* `RELEASE_PR_TEMPLATE.md` — checklist in PR for release.
* `RELEASE_NOTES_TEMPLATE.md` — user-facing note skeleton.
* `SIGNING_POLICY.md` — where keys are stored, rotation policy.
* `OPERATIONS.md` — monitoring dashboards & on-call contacts.
* `SBOM/` — keep generated SBOM artifacts per release.

---

# 18. Continuous improvement

* After each major release or incident, perform a release retrospective and update this document.
* Maintain a lessons-learned log and track metrics (time-to-release, rollback frequency, mean-time-to-detect).

---
