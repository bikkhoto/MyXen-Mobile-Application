<p align="center">
  <img src="assets/myxenpay-logo-dark.png" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">MyXen Foundation — Mobile Application (MyXenPay)</h1>

<p align="center">
  <strong>Professional README for the MyXen Foundation mobile app repository.</strong><br>
  Purpose: a single-source, production-ready README to onboard engineers, auditors, partners, and app stores reviewers.
</p>

---

# Project overview

MyXenPay is the mobile wallet client for the MyXen Foundation ecosystem — a secure, privacy-first crypto payment app focused on merchant QR payments, university integrations, on-chain Solana transactions, and native token utility ($MYXN). This repo contains the mobile application source, CI/CD configs, and build/release instructions for Android and iOS.

Key principles:

* Security-first (end-to-end encryption, hardware-backed keys, minimal surface area)
* Privacy-preserving (user-controlled KYC encryption and visibility)
* Highly usable (fast QR flows, low-friction onboarding, offline resilience)
* Auditability & reproducibility (deterministic builds, signed artifacts)

---

# Features

* Wallet creation, restoration (BIP39 / ed25519)
* Solana on-chain integration (SPL tokens, program interactions)
* Send / Receive via QR code (merchant & peer flows)
* Transaction history with rich metadata & receipts
* Biometric & PIN protection, session management
* Encrypted KYC storage (user-visible only after consent)
* Notifications, in-app support, multi-account handling
* Emergency SOS / account recovery helpers
* Offline payment caching + network reconciliation

---

# Architecture (high level)

* Frontend: cross-platform mobile client (recommended: React Native / Flutter — repo contains chosen stack).
* Crypto layer: client-side key management using ed25519; AES-GCM for ephemeral data; sensitive KYC encrypted before leaving device.
* Network: REST / gRPC to backend gateway + optional websocket for realtime events.
* Backend: (separate) wallet / node services, KYC verification pipeline, multisig & treasury services.
* On-chain: Solana SPL token interactions for $MYXN and settlement.

> See the project ecosystem docs and whitepaper for complete token & allocation details. 

---

# Supported platforms & targets

* Android 11+ (ARM64 / x86_64 emulators)
* iOS 14+ (ARM64)
* CI: GitHub Actions (recommended), Fastlane for release automation

---

# Quick start — developer (local)

> These are example commands. Adjust for the repo's selected stack (React Native / Flutter / Native).

1. Clone

```bash
git clone git@github.com:<org>/myxenpay-mobile.git
cd myxenpay-mobile
```

2. Install dependencies

* Node / Yarn (if RN)

```bash
yarn install
```

* CocoaPods (iOS)

```bash
cd ios && pod install && cd ..
```

3. Environment

* Copy environment template and fill secrets (do **not** commit):

```bash
cp .env.example .env
# set API endpoints, feature flags, analytics keys, and signing configs
```

4. Run (debug)

* Android

```bash
yarn android
```

* iOS (simulator)

```bash
yarn ios
```

---

# Release builds

* Android (release)

  * Configure `android/keystore.properties` (signing key) — follow secure key storage guidance.
  * Build:

    ```bash
    cd android
    ./gradlew assembleRelease
    ```
* iOS (release)

  * Use Xcode or Fastlane. Ensure App Store provisioning / notarization is in place.
  * Example (Fastlane):

    ```bash
    bundle exec fastlane ios release
    ```

---

# Environment variables (common)

* `MYXEN_API_BASE_URL` — production backend gateway
* `MYXEN_RPC_URL` — Solana RPC endpoint (cluster-specific)
* `FEATURE_KYC_ENCRYPTION` — toggle for client-side KYC encryption flows
* `SENTRY_DSN` — crash reporting (optional)
* `ANALYTICS_KEY` — event telemetry (privacy-first: opt-in)

Never store private keys or unencrypted secrets in git.

---

# Security & privacy practices

* Client-side key generation and storage in secure enclave / keystore.
* KYC and PII are encrypted on-device with a user-derived key; server stores only ciphertext unless user transfers consent. This protects against accidental exposure and adheres to privacy-by-design goals.
* All network traffic TLS 1.3, certificate pinning where possible.
* Signed builds (deterministic pipelines) and reproducible artifact hashes.
* Regular third-party audits (smart contracts + mobile app).
* Minimal telemetry by default; user opt-in for analytics.

---

# Testing

* Unit tests: `yarn test`
* E2E: Detox / XCTest / Espresso (project-specific test runner)
* Security tests: static analysis, dependency scanning, dynamic binary analysis in CI

---

# CI / CD

Recommended pipeline:

1. Pull request linting & tests (Yarn lint, unit tests)
2. Build & artifact signing in ephemeral CI runners (use secrets manager)
3. Upload signed artifacts to internal distribution (Firebase App Distribution / TestFlight)
4. Release gating: security audit checklist + manual approvals before store release

---

# Configuration for auditors

* `SECURITY.md` contains threat model, key rotation, and cryptographic primitives used.
* Release artifacts include SBOM, reproducible build logs, and APK/IPA signatures.

---

# Token & ecosystem references

The mobile app integrates with the MyXen token ($MYXN) and the broader MyXenPay ecosystem — tokenomics, token metadata, deployment addresses, and allocation phases are documented in the project metadata and whitepaper. For the authoritative token metadata and presale allocations, refer to the project metadata and whitepaper. 

---

# Contribution

We welcome contributors under the following process:

1. Open an issue describing the change or bug.
2. Fork the repo, create a feature branch (`feature/<short-desc>`).
3. Use the coding standards and commit message template (see `CONTRIBUTING.md`).
4. Submit a pull request and request review from at least two maintainers.
5. All PRs must pass CI and security scans before merge.

---

# CODE OF CONDUCT

All contributors must follow the repository CODE_OF_CONDUCT. Respectful, inclusive behavior is required.

---

# Roadmap & future work

* On-device MPC / threshold signatures for multisig wallets
* Cross-chain bridging UX improvements
* University/merchant SDKs for seamless adoption
* Enhanced privacy modes and offline settlement primitives

---

# Troubleshooting / FAQ

* Q: App can't connect to RPC

  * A: Verify `MYXEN_RPC_URL` in `.env` and that you have network access; use a known-good cluster URL for testing.
* Q: I lost my seed phrase

  * A: Follow recovery flow (if configured) or contact support; if seed phrase lost and no recovery configured, funds cannot be recovered.

---

# Legal & License

* License: MIT (or repo-specific — change as appropriate).
* The app is not financial advice. See `LEGAL.md` for disclaimers and jurisdictional guidance.

---

# Contact

* Core team: MyXen Foundation — operations contact in repo `MAINTAINERS.md`
* Website & docs: [https://myxenpay.finance](https://myxenpay.finance). 

---

## Appendix: quick file map

* `src/` — mobile app source
* `docs/` — CI/CD documentation and other guides
* `security/` — signing policy, security advisories, and key management
* `SECURITY.md` — security practices & audit info
* `CONTRIBUTING.md` — how to contribute & commit rules
* `LEGAL.md` — disclaimers & privacy policy links
* `fastlane/` or `android/ios/` — native release automation

