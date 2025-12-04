# iOS Native Keystore Module

## Purpose

This module provides hardware-backed Ed25519 key generation and signing for the MyXen wallet application on iOS. It leverages Apple's Secure Enclave (when available) and Keychain for secure key storage, ensuring private keys are protected from extraction even on jailbroken devices.

---

## Features

- ✅ **Secure Enclave** hardware security module (iPhone 5s+)
- ✅ **Keychain Services** with maximum security attributes
- ✅ **Ed25519 signing** using CryptoKit (iOS 13+)
- ✅ **Face ID / Touch ID** authentication via LocalAuthentication
- ✅ **Secure fallback** using scrypt + AES-256-GCM when hardware unavailable
- ✅ **Encrypted backup/restore** with user-provided passphrase
- ✅ **Zero-knowledge export** - only encrypted blobs leave device

---

## Architecture

```
SecureKeystore (Class)
├── Secure Enclave Operations
│   ├── Detect Secure Enclave capability
│   ├── Generate Ed25519 keypair in Secure Enclave
│   ├── Sign messages (may prompt for Face ID/Touch ID)
│   └── Delete keys
├── ScryptFallback Operations
│   ├── Derive key from passphrase (scrypt KDF)
│   ├── Encrypt/decrypt key material (AES-256-GCM)
│   └── Secure memory zeroization
└── BridgeModule (Flutter Platform Channel)
    └── JSON-RPC style interface to Dart layer
```

---

## Integration

### Step 1: Add Module to Project

**In `ios/Podfile`:**

```ruby
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Add native keystore module
  pod 'NativeKeystore', :path => 'native-keystore'
end
```

### Step 2: Configure Entitlements

**In `ios/Runner/Runner.entitlements`:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Keychain Access -->
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.myxen.wallet</string>
    </array>
    
    <!-- App Groups (for shared container if needed) -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.myxen.wallet</string>
    </array>
</dict>
</plist>
```

### Step 3: Add Privacy Descriptions

**In `ios/Runner/Info.plist`:**

```xml
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to securely sign transactions with your wallet keys.</string>
```

### Step 4: Register in AppDelegate

**In `ios/Runner/AppDelegate.swift`:**

```swift
import UIKit
import Flutter
import NativeKeystore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    
    // Register native keystore bridge
    BridgeModule.register(with: controller.binaryMessenger)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## Dependencies

### Required Frameworks

- **CryptoKit** (iOS 13+) - For Ed25519 and AES-GCM
- **Security** - For Keychain and Secure Enclave
- **LocalAuthentication** - For biometric authentication

### Swift Packages (if needed)

For scrypt support (CryptoKit doesn't include scrypt):

```swift
// Package.swift or SPM
dependencies: [
    .package(url: "https://github.com/onevcat/CryptoSwift.git", from: "1.8.0")
]
```

---

## API Levels & Compatibility

| Feature | Minimum iOS | Optimal iOS | Fallback |
|---------|-------------|-------------|----------|
| Secure Enclave | iOS 9.0 (A7+) | iOS 13+ | Keychain |
| CryptoKit Ed25519 | iOS 13.0 | iOS 15+ | CommonCrypto |
| Face ID | iOS 11.0 | iOS 13+ | Touch ID / Passcode |
| LocalAuthentication | iOS 8.0 | iOS 13+ | Passcode only |

---

## Building

### Debug Build

```bash
cd ios
pod install
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug
```

### Release Build

```bash
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release
```

### Run Unit Tests

```bash
xcodebuild test -workspace NativeKeystore.xcworkspace -scheme NativeKeystore -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run on Device

```bash
xcodebuild test -workspace NativeKeystore.xcworkspace -scheme NativeKeystore -destination 'platform=iOS,name=Your iPhone'
```

---

## Testing

### Unit Tests (Simulator)

Located in `NativeKeystoreTests/`

```bash
xcodebuild test -scheme NativeKeystore -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Integration Tests (Device)

Located in `NativeKeystoreUITests/`

```bash
# Requires real device for Secure Enclave
xcodebuild test -scheme NativeKeystore -destination 'platform=iOS,name=Your iPhone'
```

---

## Configuration

### Build Settings

**In `NativeKeystore.xcconfig`:**

```
SWIFT_VERSION = 5.9
IPHONEOS_DEPLOYMENT_TARGET = 13.0
ENABLE_BITCODE = NO
SWIFT_OPTIMIZATION_LEVEL = -O
```

### Feature Flags

**In `Config.plist`:**

```xml
<dict>
    <key>ForceSecureEnclave</key>
    <false/>
    <key>DebugLogging</key>
    <true/>
    <key>ScryptCI_N</key>
    <integer>16384</integer>
    <key>ScryptProduction_N</key>
    <integer>32768</integer>
</dict>
```

---

## Security Considerations

### ✅ Secure Enclave Mode

- Private key generated inside Secure Enclave
- Key **never** leaves hardware boundary
- Protected against:
  - Jailbreak access
  - Memory dumps
  - Physical extraction
  - Side-channel attacks

### ⚠️ Keychain Fallback Mode

- Private key encrypted with scrypt + AES-GCM
- Stored in iOS Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Protected against:
  - Offline brute-force (high scrypt cost)
  - iCloud backup leakage (ThisDeviceOnly)
- **NOT** protected against:
  - Active jailbreak malware with keychain dump
  - Debugger attachment in runtime

### Memory Safety

- All sensitive byte arrays zeroized after use
- No sensitive data in console logs
- Swift's automatic reference counting clears memory predictably

---

## Error Codes

| Code | Meaning | Recovery |
|------|---------|----------|
| `ERR_HW_NOT_AVAILABLE` | Secure Enclave not available | Use Keychain fallback |
| `ERR_HW_CREATION_FAILED` | Key creation failed | Check logs, retry |
| `ERR_SIGN_FAILED` | Signing operation failed | Verify key exists |
| `ERR_KEY_NOT_FOUND` | Key doesn't exist | Create or import |
| `ERR_USER_CANCELLED` | Face ID/Touch ID cancelled | Show retry UI |
| `ERR_DECRYPT_FAILED` | Wrong passphrase | Prompt again (rate limit!) |
| `ERR_INVALID_BACKUP` | Corrupted backup | Request new backup |
| `ERR_NOT_AUTHORIZED` | Biometric changed | Restore from backup |
| `ERR_UNKNOWN` | Unexpected error | Check logs |

---

## Performance Targets

### Secure Enclave Mode

- Key generation: < 500ms (p95)
- Signature: < 300ms (p95)
- Public key retrieval: < 50ms (p95)

### Keychain Fallback

- Key derivation (scrypt): < 2000ms (N=32768, p95, iPhone 8)
- Encryption/Decryption: < 100ms (p95)
- Signature: < 50ms (p95)

---

## Debugging

### Enable Verbose Logging

```swift
// In SecureKeystore.swift
#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif

if isDebug {
    print("[MyXenKeystore] Operation completed: \(sanitize(result))")
}
```

### Check Secure Enclave Availability

```swift
let context = LAContext()
var error: NSError?
let hasBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
print("Biometric available: \(hasBiometrics)")
print("Secure Enclave support: \(SecureEnclave.isAvailable)")
```

---

## Common Issues

### Issue: Secure Enclave always returns false

**Cause:** Device is simulator or lacks A7+ chip.
**Solution:** Falls back to Keychain automatically.

### Issue: Face ID prompt not showing

**Cause:** Missing `NSFaceIDUsageDescription` in Info.plist.
**Solution:** Add privacy description as shown above.

### Issue: Keys lost after app reinstall

**Cause:** Keychain clears on uninstall.
**Solution:** Use encrypted backup feature. Restore from backup after reinstall.

---

## File Structure

```
ios/native-keystore/
├── NativeKeystore.podspec
├── Classes/
│   ├── SecureKeystore.swift        # Main class
│   ├── BridgeModule.swift          # Flutter bridge
│   ├── ScryptFallback.swift        # Fallback crypto
│   └── Constants.swift             # Error codes, config
├── NativeKeystoreTests/
│   ├── SecureKeystoreTests.swift   # Unit tests
│   └── ScryptFallbackTests.swift   # Crypto tests
└── README.md  (this file)
```

---

## Next Steps

1. **Implement Swift code** using Copilot assistance (see `TODO` markers in each file)
2. **Run unit tests** to verify crypto operations
3. **Run integration tests** on physical device with Secure Enclave
4. **Benchmark performance** on oldest supported device (iPhone 8)
5. **Security review** before production deployment

---

## License

Copyright (c) 2025 MyXen. See LICENSE file in repository root.

---

## Support

For issues specific to this module:

1. Check console logs (Xcode console or device logs)
2. Verify device capabilities
3. Review this README's troubleshooting section
4. File issue with logs (sanitized!) and device info

---

**End of README**
