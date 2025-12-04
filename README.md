# MyXen Mobile App

A secure, minimal, on-chain Solana wallet and payments app for Android (min API 26) and iOS (min iOS 12).

## Overview

**Token:** $MYXN (SPL, 9 decimals, total supply 1,000,000,000)

MyXen Mobile App is a secure mobile wallet that enables users to:

- Create and restore Solana wallets
- Send and receive $MYXN tokens
- Scan merchant QR codes for payments
- View transaction history with on-chain verification
- Secure wallet with biometric authentication
- Emergency SOS features
- Encrypted KYC and backup/restore

## Core Features

### Security & Key Management

- Hardware-backed keystore (when available)
- Biometric + 6-digit PIN fallback
- On-device signing (ed25519)
- BIP39 mnemonic (12 words)
- Derivation path: `m/44'/501'/0'/0'`
- AES-256-GCM encryption
- scrypt fallback (N=16384, r=8, p=1)

### Services (20 Locked Features)

1. **Wallet** - Create/restore wallet with secure key management
2. **MyXenPay** - Send/receive $MYXN tokens
3. **QR Pay** - Generate and scan QR codes for payments
4. **Transaction History** - View all transactions
5. **On-chain Explorer** - Link to blockchain explorer
6. **Biometric/PIN Lock** - Secure app access
7. **Emergency SOS** - Emergency contact features
8. **Backup & Restore** - Encrypted wallet backup
9. **Seed Vault** - Secure mnemonic storage
10. **KYC** - Client-side encrypted identity verification
11. **User Profile & Limits** - Account management
12. **Merchant Invoice Scan** - Scan and verify invoices
13. **Merchant Receipt Verification** - Verify payment receipts
14. **Trusted Merchant Indicator** - Merchant trust badges
15. **Notifications** - Transaction and security alerts
16. **Settings** - Theme, language, accessibility
17. **Support Center** - Help and documentation
18. **Female Empowerment** - Program information
19. **Scholarship Status** - Read-only scholarship info
20. **University Student Tools** - Zero-fee payments for students

## Tech Stack

- **Framework:** Flutter (single codebase for Android & iOS)
- **State Management:** Riverpod
- **Networking:** Dio
- **Secure Storage:** flutter_secure_storage
- **Local Database:** drift/sqflite
- **Biometrics:** local_auth
- **Cryptography:** ed25519 signing library
- **QR:** qr_flutter, mobile_scanner

## Project Structure

```
lib/
├── core/
│   ├── crypto/              # Key management, encryption
│   │   ├── mnemonic_service.dart
│   │   ├── key_manager.dart
│   │   ├── signer.dart
│   │   ├── crypto_utils.dart
│   │   └── encryption/
│   │       ├── aes_gcm_wrapper.dart
│   │       ├── hardware_keystore.dart
│   │       └── scrypt_wrapper.dart
│   ├── network/             # API clients
│   ├── storage/             # Local database
│   └── utils/               # Helpers
├── features/
│   ├── wallet/              # Wallet creation/restore
│   ├── send/                # Send transactions
│   ├── receive/             # Receive payments
│   ├── qr/                  # QR code features
│   ├── history/             # Transaction history
│   ├── settings/            # App settings
│   ├── kyc/                 # KYC features
│   ├── emergency/           # Emergency SOS
│   └── ...
├── providers/               # Riverpod providers
├── models/                  # Data models
├── widgets/                 # Reusable widgets
└── main.dart
```

## Security Principles

1. **Never send seed or private keys to any server** - Always sign on-device
2. **Minimize permissions** - Only Camera (QR), Biometric (optional), Notifications (opt-in)
3. **Client-side KYC encryption** - Server stores only encrypted blobs
4. **Show fees before confirmation** - Display MYXN + fiat equivalent
5. **On-chain transparency** - Every receipt shows txHash + "View on Chain"
6. **Offline-first** - Cached balance & transactions with sync state

## QR Format

**Prefix:** `myxen:`

**Payload JSON:**

```json
{
  "v": "1",
  "t": "pay_request|invoice",
  "token": "MYXN",
  "amount": "string (decimal)",
  "pubkey": "string",
  "memo": "optional",
  "ts": "ISO8601",
  "sig": "optional base64",
  "signer_pubkey": "optional"
}
```

**Encoding:** JSON → UTF-8 → base64url (no padding) → prefix `myxen:`

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Xcode
- Android SDK (API 26+) / iOS 12+

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd MyXen\ Mobile\ Application

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/key_manager_test.dart

# Run with coverage
flutter test --coverage
```

## Performance Targets

- Cold start: ≤2.5s on mid-range devices
- Memory usage: <200MB typical
- Animations: fade/scale ≤150ms
- Reduce Motion toggle available

## Accessibility

- Color contrast compliance
- Large tap targets (48x48dp minimum)
- Screen reader support
- Reduce Motion option

## License

[Add License Information]

## Support

For support, please visit the Support Center in the app or contact [support contact].

## Security Audit

Before release, a full mobile security audit must be completed covering:

- Key extraction attempts
- Replay attacks
- Signed transaction validation
- Emergency feature misuse
- KYC encryption correctness
