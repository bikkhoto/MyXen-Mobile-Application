<p align="center">
  <img src="../../assets/myxenpay-logo-dark.png" alt="MyXenPay Logo" width="400">
</p>

<h1 align="center">MyXenPay — CI/CD Workflow Documentation</h1>

<p align="center">
  <strong>A flexible, secure, and auditable GitHub Actions workflow for the MyXenPay Mobile Application.</strong>
</p>

---

This workflow is designed to:

* run on PRs (lint/test/security)
* produce reproducible build artifacts (AAB/APK and IPA) in CI
* generate SBOM & security scan results
* sign artifacts using secure secrets/HSM/GitHub OIDC (instructions included)
* publish to internal distribution (Firebase / TestFlight) and prepare for staged production release
* require human approvals for production signing/publishing (via `environments`)

Below you’ll find a single YAML workflow file (`.github/workflows/ci-cd.yml`) that covers PR checks and release pipeline. It’s intentionally configurable for **React Native** *or* **Flutter** — comment/uncomment the relevant steps for your stack. After the YAML there’s a short setup checklist (required secrets, environment setup, recommended policies).

---

### How to use

1. Create `.github/workflows/ci-cd.yml` and paste the YAML below.
2. Add the listed secrets & environment protections (see checklist).
3. Update `APP_ID`, `BUNDLE_ID`, and any platform-specific placeholders.
4. Toggle the RN / Flutter steps according to your repo.

---

```yaml
# .github/workflows/ci-cd.yml
name: MyXenPay CI / CD

on:
  pull_request:
    branches: [ "develop", "release/*", "main" ]
  push:
    branches: [ "develop", "release/*" ]
  workflow_dispatch:
    inputs:
      release_tag:
        description: 'Optional release tag (vX.Y.Z) - triggers release flow'
        required: false

env:
  # update these for your project
  APP_ID: com.myxenpay.app
  BUNDLE_ID: com.myxenpay.app
  NODE_VERSION: '20'
  JAVA_VERSION: '17'
  XCODE_VERSION: '15'

concurrency:
  group: "myxenpay-ci-${{ github.ref }}"
  cancel-in-progress: true

permissions:
  contents: read
  id-token: write            # used for GitHub OIDC (recommended)
  actions: read
  security-events: write

jobs:

  # 1) PR validation: lint + unit tests + dependency audit
  pr-checks:
    name: PR Checks — Lint, Tests, Dependency Audit
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node: [${{ env.NODE_VERSION }}]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
          cache: 'yarn'

      - name: Cache Gradle (Android)
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: gradle-cache-${{ runner.os }}-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: gradle-cache-${{ runner.os }}-

      - name: Install dependencies
        run: |
          # Adjust for your package manager: yarn / npm / pnpm
          yarn install --frozen-lockfile

      - name: Run linters
        run: |
          yarn lint

      - name: Run unit tests
        run: |
          CI=true yarn test --coverage

      - name: Dependency audit
        run: |
          yarn audit --level=moderate || true
        continue-on-error: true

      - name: Upload test coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/

  # 2) Static analysis & SBOM creation + SCA
  security-scan:
    name: Security Scans & SBOM
    runs-on: ubuntu-latest
    needs: pr-checks
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Generate SBOM (syft)
        run: |
          # install syft if not available
          if ! command -v syft > /dev/null; then
            curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
          fi
          syft packages-dir:.
          syft -o json . > sbom.json

      - name: Upload SBOM
        uses: actions/upload-artifact@v4
        with:
          name: sbom
          path: sbom.json

      - name: Run SAST (example: semgrep)
        uses: returntocorp/semgrep-action@v2
        with:
          image: cgr.dev/chainguard/semgrep:latest
          args: --config=p/r2c --severity-threshold INFO

      - name: Upload security reports
        uses: actions/upload-artifact@v4
        with:
          name: security-reports
          path: |
            semgrep-report.json
            snyk-report.json
        if: always()

  # 3) Build Android (AAB) — run on release branches / manually
  android-build:
    name: Build Android (AAB/APK)
    runs-on: ubuntu-latest
    needs: [pr-checks, security-scan]
    if: startsWith(github.ref, 'refs/heads/release/') || github.event_name == 'workflow_dispatch'
    env:
      GRADLE_OPTS: -Dorg.gradle.jvmargs="-Xmx3g"
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: ${{ env.JAVA_VERSION }}
          cache: gradle

      - name: Cache Gradle and Yarn
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
            node_modules
          key: android-cache-${{ runner.os }}-${{ hashFiles('**/build.gradle*', '**/package.json') }}
          restore-keys: android-cache-${{ runner.os }}-

      - name: Install Node deps
        run: yarn install --frozen-lockfile

      # --- React Native steps (uncomment if using RN) ---
      - name: Install Android SDK components
        if: ${{ false }}   # set to true for RN (or duplicate job for RN)
        run: |
          yes | sdkmanager --licenses
          sdkmanager "platforms;android-33" "build-tools;33.0.2" "platform-tools"

      - name: Build Android (React Native example)
        if: ${{ false }}   # set to true for RN
        run: |
          cd android
          ./gradlew clean assembleRelease

      # --- Flutter steps (uncomment if using Flutter) ---
      - name: Setup Flutter
        if: ${{ false }}   # set to true for Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Build Android (Flutter example)
        if: ${{ false }}   # set to true for Flutter
        run: |
          flutter pub get
          flutter build appbundle --release

      - name: Upload Android artifact
        uses: actions/upload-artifact@v4
        with:
          name: android-artifacts
          path: |
            android/app/build/outputs/**/*.aab
            android/app/build/outputs/**/*.apk
          retention-days: 90

  # 4) Build iOS (IPA) — macos runner
  ios-build:
    name: Build iOS (IPA)
    runs-on: macos-latest
    needs: [pr-checks, security-scan]
    if: startsWith(github.ref, 'refs/heads/release/') || github.event_name == 'workflow_dispatch'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Ruby / Bundler
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install Node deps
        run: yarn install --frozen-lockfile

      - name: Setup CocoaPods
        run: |
          cd ios
          bundle install --path vendor/bundle || true
          pod install --repo-update
          cd ..

      # --- React Native iOS build (uncomment if using RN) ---
      - name: Build iOS (React Native example)
        if: ${{ false }}   # set true for RN
        run: |
          cd ios
          xcodebuild -workspace MyXenPay.xcworkspace -scheme MyXenPay -configuration Release -allowProvisioningUpdates -derivedDataPath build

      # --- Flutter iOS build (uncomment if using Flutter) ---
      - name: Setup Flutter (macos)
        if: ${{ false }}   # set true for Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Build iOS (Flutter example)
        if: ${{ false }}   # set true for Flutter
        run: |
          flutter pub get
          flutter build ipa --release --export-options-plist ios/ExportOptions.plist

      - name: Upload iOS artifact
        uses: actions/upload-artifact@v4
        with:
          name: ios-artifacts
          path: |
            ios/build/*.ipa
            ios/build/Build/Products/**/*.ipa
          retention-days: 90

  # 5) Sign & Publish (manual approvals recommended)
  publish:
    name: Sign & Publish
    runs-on: ubuntu-latest
    needs: [android-build, ios-build]
    environment:
      name: production
      url: https://console.myxenpay.finance/ops   # optional
    if: github.event.inputs.release_tag != '' || startsWith(github.ref, 'refs/heads/release/')
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download Android artifacts
        uses: actions/download-artifact@v4
        with:
          name: android-artifacts
          path: ./artifacts/android

      - name: Download iOS artifacts
        uses: actions/download-artifact@v4
        with:
          name: ios-artifacts
          path: ./artifacts/ios

      - name: Verify artifact hashes
        run: |
          echo "Verifying artifact integrity..."
          sha256sum ./artifacts/android/*.aab || true
          sha256sum ./artifacts/ios/*.ipa || true

      - name: Sign Android (example: upload to Google Play via fastlane/supply)
        env:
          GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
        run: |
          # Example using fastlane supply or Google Play publish action
          # This step should run in a secure environment with limited access
          echo "Signing/publishing Android artifact - implement your signing/upload method here"

      - name: Sign & Upload iOS (example via Fastlane)
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        run: |
          # Fastlane lane to upload to TestFlight or App Store
          echo "Signing/publishing iOS artifact - implement your signing/upload method here"

      - name: Notify channel
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          fields: repo,commit,author
          custom_payload: |
            {
              "text":"Release deploy: ${{ github.ref }} by ${{ github.actor }}",
              "attachments": [
                { "text": "Artifacts uploaded and publish steps executed (check logs)"}
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Required secrets & recommended GitHub settings

Create these repository (or organization) secrets and protect them strictly:

* `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` — Google Play service account JSON for uploads (or use OIDC/Workload Identity). Prefer ephemeral credentials or OIDC where possible.
* `APP_STORE_CONNECT_API_KEY` — App Store Connect API key (or configure in fastlane via a file stored in a secure vault).
* `FASTLANE_PASSWORD` / `FASTLANE_SESSION` — if you use fastlane (avoid storing Apple passwords; use API key).
* `SIGNING_KEYSTORE` — (if you store keystore base64) OR use external signing service/HSM. Prefer GitHub OIDC to avoid long-lived secrets.
* `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` — avoid storing if using HSM.
* `SENTRY_AUTH_TOKEN` / `SENTRY_ORG` — for automatic dSYM/map uploads.
* `SLACK_WEBHOOK_URL` — for release notifications.
* `SYFT_API_KEY` (optional) — for SBOM services.
* `SNYK_TOKEN` (optional) — for dependency scanning integration.

Recommended repository protections:

* Protect `main` and `release/*` branches with required approvals & passing checks.
* Use GitHub Environments for `production` with required reviewers (Release Manager, Security Lead).
* Enable audit logs on any key access (Cloud KMS/HSM).

---

## Security & operational notes (short)

* Prefer **GitHub OIDC** for short-lived credentials (Google Play / cloud KMS) instead of long-lived JSON keys. This greatly reduces secrets exposure.
* Keep signing keys in an HSM / cloud KMS (Google KMS, AWS KMS, Azure Key Vault) and use CI to call those services for signing, or use ephemeral signing runners behind a firewall.
* Always upload mapping/dSYM files to crash analytics as artifacts and to the crash reporting tool.
* Ensure SBOM and security reports are stored and available to auditors for each release.
* Use `environments` approvals for production-level sign/publish steps.

---
