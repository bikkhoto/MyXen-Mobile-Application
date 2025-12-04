#!/usr/bin/env bash
set -euo pipefail

# REPO_INIT_SCRIPT.sh
# Bootstraps the MyXenPay mobile repo skeleton and populates essential files.
# WARNING: This script will create files and directories in the current working directory.
# Run from repository root.

ROOT_DIR="$(pwd)"
echo "Bootstrapping MyXenPay repository in ${ROOT_DIR}"

mkd() { mkdir -p "$1"; echo "created: $1"; }

echo "Creating core directories..."
mkd fastlane/metadata/android/en-US
mkd fastlane/metadata/ios/en-US
mkd .github/workflows
mkd docs security src assets scripts tests ios android
mkd security/keys signing-approvals
mkd .github/ISSUE_TEMPLATE
mkd .github/PULL_REQUEST_TEMPLATE
mkd .github/workflows
mkd scripts/build_helpers
mkd scripts/dev_tools

echo "Writing .gitignore..."
cat > .gitignore <<'EOF'
# Node / RN / Flutter
node_modules/
build/
android/app/build/
ios/Pods/
ios/build/
.env
*.jks
fastlane/report.xml
*.p12
.DS_Store
coverage/
*.xcarchive
.idea/
.vscode/
EOF

echo "Writing .env.example..."
cat > .env.example <<'EOF'
MYXEN_API_BASE_URL=https://api.myxenpay.finance
MYXEN_RPC_URL=https://rpc.myxenpay.finance
FEATURE_KYC_ENCRYPTION=true
SENTRY_DSN=
ANALYTICS_KEY=
EOF

echo "Adding SECURITY.md and SIGNING_POLICY.md placeholders..."
cat > security/SIGNING_POLICY.md <<'EOF'
# SIGNING_POLICY.md
(See security/SIGNING_POLICY.md in repo root for full policy.)
EOF

cat > SECURITY.md <<'EOF'
# SECURITY.md
(See repository documentation for full security policy.)
EOF

echo "Generating fastlane metadata placeholders..."
cat > fastlane/metadata/android/en-US/release_notes.txt <<'EOF'
Release notes (Android)
- Highlights:
- Bug fixes:
- Security notes:
EOF

cat > fastlane/metadata/android/en-US/title.txt <<'EOF'
MyXenPay
EOF

cat > fastlane/metadata/android/en-US/short_description.txt <<'EOF'
MyXenPay — Secure crypto payments and wallet for merchants & students.
EOF

cat > fastlane/metadata/android/en-US/full_description.txt <<'EOF'
MyXenPay is a secure, privacy-first mobile wallet for the MyXen Foundation ecosystem. It supports Solana-based transactions, QR merchant payments, and encrypted KYC flows.
EOF

cat > fastlane/metadata/ios/en-US/changelog.txt <<'EOF'
iOS changelog:
- New features:
- Fixes:
EOF

cat > fastlane/metadata/ios/en-US/description.txt <<'EOF'
MyXenPay is the official mobile wallet for the MyXen Foundation. Secure wallet, merchant QR payment, and student adoption features.
EOF

echo "Creating RELEASE_PR_TEMPLATE.md and RELEASE_NOTES_TEMPLATE.md..."
cat > RELEASE_PR_TEMPLATE.md <<'EOF'
# Release PR Template

## Release checklist
- [ ] Version bumped (semver)
- [ ] All linked PRs merged
- [ ] CI: lint and unit tests passed
- [ ] SAST/SCA checks completed
- [ ] SBOM attached
- [ ] Mapping/dSYM included
- [ ] Security Lead approval
- [ ] Release Manager approval

## Release metadata
- Release tag:
- Commit SHA:
- Build ID:
- Artifacts (paths):

## Release notes (short)
- Highlights:
- Migration notes:
EOF

cat > RELEASE_NOTES_TEMPLATE.md <<'EOF'
# Release Notes - vX.Y.Z

**Release Date:** YYYY-MM-DD
**Type:** (Feature / Bugfix / Security / Hotfix)

## Highlights
- Bullet summary for users

## Developer notes
- Important PRs / commits

## Security notes
- High-level: safe to mention a patch, not exploit details.

## Rollout plan
- Start at 1% (Android) → Monitor 24–72h → Ramp

EOF

echo "Writing RELEASE_PR_TEMPLATE.md and README.md skeleton..."
cat > README.md <<'EOF'
# MyXenPay Mobile — Repo Skeleton

This repository contains the mobile client for MyXen Foundation (MyXenPay).  
Run ./REPO_INIT_SCRIPT.sh to populate additional files and folders.

See docs/ and security/ for operational runbooks.
EOF

echo "Writing skeleton package.json (React Native) and pubspec.yaml (Flutter)..."

cat > package.json <<'EOF'
{
  "name": "myxenpay-mobile",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "start": "react-native start",
    "android": "react-native run-android",
    "ios": "react-native run-ios",
    "lint": "eslint 'src/**/*.{js,ts,tsx}'",
    "test": "jest --coverage",
    "build:android": "cd android && ./gradlew assembleRelease",
    "build:ios": "fastlane build_ios"
  },
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.71.11"
  },
  "devDependencies": {
    "@babel/core": "^7.22.0",
    "eslint": "^8.40.0",
    "jest": "^29.6.0"
  }
}
EOF

cat > pubspec.yaml <<'EOF'
name: myxenpay_mobile
description: MyXenPay — secure mobile wallet for MyXen Foundation
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=2.18.0 <3.0.0"
  flutter: ">=3.7.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
EOF

echo "Creating .github templates..."
cat > .github/ISSUE_TEMPLATE/bug_report.md <<'EOF'
---
name: Bug report
about: Create a report to help us improve
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. ...
2. ...
3. ...

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots/Logs**
(Ensure no sensitive data is included.)

EOF

cat > .github/ISSUE_TEMPLATE/feature_request.md <<'EOF'
---
name: Feature request
about: Suggest an idea for this project
---

**Describe the feature**
What and why? Provide user story if possible.

**Potential impact**
Design, security, roadmap considerations.

EOF

cat > .github/PULL_REQUEST_TEMPLATE.md <<'EOF'
## Summary
(Short description of changes)

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Chore

## Checklist
- [ ] Lint passed
- [ ] Unit tests added/updated
- [ ] Security considerations documented
- [ ] Changelog updated

## Linked issues
- Closes #
EOF

echo "Making script idempotent: setting executable and finishing..."
chmod +x REPO_INIT_SCRIPT.sh || true

echo "Bootstrap complete. Review created files and update secrets, fastlane configs, and CI settings."
