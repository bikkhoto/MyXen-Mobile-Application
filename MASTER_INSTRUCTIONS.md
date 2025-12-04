# Master Instructions: Native Hardware Keystore Integration

## Purpose

This document provides complete instructions for integrating the hardware-backed native keystore module into your Flutter/ReactNative application. The module provides secure Ed25519 key generation, signing, and backup with automatic fallback to scrypt-encrypted software keys when hardware keystore is unavailable.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter/ReactNative App                   │
│                  (Dart/JavaScript UI Layer)                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                  Platform Channel / Bridge
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
┌───────▼──────────┐               ┌─────────▼────────┐
│  Android Module  │               │   iOS Module     │
│  (Kotlin/Java)   │               │   (Swift)        │
├──────────────────┤               ├──────────────────┤
│ • KeystoreManager│               │ • SecureKeystore │
│ • BridgeModule   │               │ • BridgeModule   │
│ • ScryptFallback │               │ • ScryptFallback │
└────────┬─────────┘               └────────┬─────────┘
         │                                  │
         │                                  │
┌────────▼─────────┐               ┌───────▼──────────┐
│ AndroidKeyStore  │               │ Secure Enclave   │
│ StrongBox (API28+│               │ Keychain         │
└──────────────────┘               └──────────────────┘
```

---

## Platform Support

### Android
- **Minimum API Level:** 23 (Android 6.0)
- **Hardware Keystore:** API 23+
- **StrongBox:** API 28+ (Android 9.0)
- **Ed25519:** Supported via BouncyCastle or AndroidKeyStore (API 31+)

### iOS
- **Minimum Version:** iOS 13.0
- **Secure Enclave:** iPhone 5s+ (A7 chip and later)
- **Ed25519:** Supported via CryptoKit (iOS 13+)

---

## Security Model

### Hardware Mode (Preferred)
- Private key generated inside hardware security module (HSM)
- Key is **non-exportable** and bound to device
- Signing operations occur inside HSM
- Protected against:
  - Malware extracting keys
  - Root/jailbreak attacks
  - Physical extraction
  - Cold boot attacks

### Software Fallback Mode
- Used when hardware keystore unavailable or unsupported
- Private key encrypted with scrypt + AES-256-GCM
- Passphrase-derived encryption (user PIN/password)
- Protected against:
  - Offline brute force (high scrypt cost)
  - Memory dumps (key zeroized after use)
- **Not protected against:**
  - Root/jailbreak with memory inspection
  - Runtime key extraction by privileged malware

### Threat Model
**In Scope:**
- Protect keys from app-level malware
- Protect keys from device theft (when locked)
- Protect backups from offline attacks
- Protect against side-channel attacks (via hardware)

**Out of Scope:**
- Protection against physical device access while unlocked
- Protection against OS-level vulnerabilities
- Protection against sophisticated state-level actors with hardware access

---

## Bridge API Specification

### Method Signatures

All methods return promises/futures with JSON-serializable results.

#### 1. `generateKey(label: String) -> KeyGenerationResult`

**Purpose:** Generate new Ed25519 keypair in hardware or fallback.

**Input:**
```json
{
  "label": "wallet-key-001"
}
```

**Output:**
```json
{
  "status": "OK",
  "mode": "HARDWARE",
  "publicKey": "a3f5e1b2c8d4a6f9e7b3c1d5a8f2e6b9c4d7a1f8e3b6c9d2a5f1e8b4c7d3a6f9",
  "algorithm": "Ed25519"
}
```

**Errors:** `ERR_HW_CREATION_FAILED`, `ERR_UNKNOWN`

---

#### 2. `hasKey(label: String) -> KeyExistenceResult`

**Purpose:** Check if key exists and its mode.

**Input:**
```json
{
  "label": "wallet-key-001"
}
```

**Output:**
```json
{
  "exists": true,
  "mode": "HARDWARE"
}
```

---

#### 3. `getPublicKey(label: String) -> PublicKeyResult`

**Purpose:** Retrieve public key for existing keypair.

**Input:**
```json
{
  "label": "wallet-key-001"
}
```

**Output:**
```json
{
  "publicKey": "a3f5e1b2c8d4a6f9e7b3c1d5a8f2e6b9c4d7a1f8e3b6c9d2a5f1e8b4c7d3a6f9"
}
```

**Errors:** `ERR_KEY_NOT_FOUND`

---

#### 4. `sign(label: String, message: String) -> SignatureResult`

**Purpose:** Sign message with private key. May trigger biometric prompt.

**Input:**
```json
{
  "label": "wallet-key-001",
  "message": "SGVsbG8gV29ybGQh"  // base64 encoded
}
```

**Output:**
```json
{
  "signature": "b4c6d8a2f5e9c1b7d3a8f4e2c6b9d5a1f7e3c8b4d9a6f2e5c1b8d4a7f3e9c6b2d5"
}
```

**Errors:** `ERR_KEY_NOT_FOUND`, `ERR_SIGN_FAILED`, `ERR_USER_CANCELLED`, `ERR_NOT_AUTHORIZED`

---

#### 5. `deleteKey(label: String) -> DeleteResult`

**Purpose:** Delete keypair from keystore.

**Input:**
```json
{
  "label": "wallet-key-001"
}
```

**Output:**
```json
{
  "status": "OK"
}
```

**Errors:** `ERR_KEY_NOT_FOUND`

---

#### 6. `exportEncryptedBackup(label: String, passphrase: String, scryptParams?: ScryptParams) -> BackupResult`

**Purpose:** Export encrypted backup of key material.

**Input:**
```json
{
  "label": "wallet-key-001",
  "passphrase": "user-secure-password-123",
  "scryptParams": {
    "N": 32768,
    "r": 8,
    "p": 1
  }
}
```

**Output:**
```json
{
  "blob": "eyJ2ZXJzaW9uIjoxLCJhbGdvcml0aG0iOiJFZDI1NTE5Iiwic2NyeXB0UGFyYW1zIjp7Ik4iOjMyNzY4LCJyIjo4LCJwIjoxfSwic2FsdCI6IjRhNWY2YjdjOGQzZTlmMmEiLCJub25jZSI6IjdhM2Y4YjJjNWQ5ZTZmMWEiLCJjaXBoZXJ0ZXh0IjoiLi4uIiwibWFjIjoiLi4uIn0=",
  "metadata": {
    "version": 1,
    "algorithm": "Ed25519",
    "scryptParams": { "N": 32768, "r": 8, "p": 1 },
    "salt": "4a5f6b7c8d3e9f2a",
    "nonce": "7a3f8b2c5d9e6f1a"
  }
}
```

**Errors:** `ERR_KEY_NOT_FOUND`, `ERR_UNKNOWN`

---

#### 7. `importEncryptedBackup(blob: String, passphrase: String) -> ImportResult`

**Purpose:** Import encrypted backup and optionally migrate to hardware.

**Input:**
```json
{
  "blob": "eyJ2ZXJzaW9uIjoxLCJhbGdvcml0aG0iOiJFZDI1NTE5Iiwic2NyeXB0UGFyYW1zIjp7Ik4iOjMyNzY4LCJyIjo4LCJwIjoxfSwic2FsdCI6IjRhNWY2YjdjOGQzZTlmMmEiLCJub25jZSI6IjdhM2Y4YjJjNWQ5ZTZmMWEiLCJjaXBoZXJ0ZXh0IjoiLi4uIiwibWFjIjoiLi4uIn0=",
  "passphrase": "user-secure-password-123"
}
```

**Output:**
```json
{
  "success": true,
  "migratedTo": "HARDWARE",
  "publicKey": "a3f5e1b2c8d4a6f9e7b3c1d5a8f2e6b9c4d7a1f8e3b6c9d2a5f1e8b4c7d3a6f9",
  "label": "wallet-key-001"
}
```

**Errors:** `ERR_DECRYPT_FAILED`, `ERR_INVALID_BACKUP`, `ERR_UNKNOWN`

---

#### 8. `isHardwareBacked() -> HardwareCapabilityResult`

**Purpose:** Check device hardware keystore capabilities.

**Output:**
```json
{
  "hardwareAvailable": true,
  "details": {
    "android": {
      "strongboxAvailable": true,
      "keystoreAvailable": true
    },
    "ios": {
      "secureEnclaveAvailable": true
    }
  }
}
```

---

#### 9. `migrateKey(label: String) -> MigrationResult`

**Purpose:** Migrate software fallback key to hardware (requires user consent).

**Input:**
```json
{
  "label": "wallet-key-001"
}
```

**Output:**
```json
{
  "status": "OK",
  "fromMode": "SOFTWARE_FALLBACK",
  "toMode": "HARDWARE",
  "publicKey": "a3f5e1b2c8d4a6f9e7b3c1d5a8f2e6b9c4d7a1f8e3b6c9d2a5f1e8b4c7d3a6f9"
}
```

**Errors:** `ERR_HW_NOT_AVAILABLE`, `ERR_KEY_NOT_FOUND`, `ERR_UNKNOWN`

---

## Error Codes

| Code | Description | Recovery Action |
|------|-------------|-----------------|
| `ERR_HW_NOT_AVAILABLE` | Hardware keystore not available on device | Use software fallback, show user warning |
| `ERR_HW_CREATION_FAILED` | Failed to create key in hardware | Retry or fall back to software mode |
| `ERR_SIGN_FAILED` | Signing operation failed | Check key exists, retry |
| `ERR_KEY_NOT_FOUND` | Requested key doesn't exist | Create new key or restore from backup |
| `ERR_USER_CANCELLED` | User cancelled biometric prompt | Show retry UI |
| `ERR_DECRYPT_FAILED` | Failed to decrypt backup | Check passphrase, show error to user |
| `ERR_INVALID_BACKUP` | Backup blob corrupted or invalid | Request valid backup file |
| `ERR_NOT_AUTHORIZED` | App not authorized to use key | Re-authenticate user |
| `ERR_UNKNOWN` | Unexpected error | Log details, show generic error |

---

## Integration Steps

### Step 1: Add Native Modules to Project

#### Flutter (Method Channel)

**Add to `android/app/build.gradle`:**
```gradle
dependencies {
    implementation project(':native-keystore')
}
```

**Add to `android/settings.gradle`:**
```gradle
include ':native-keystore'
project(':native-keystore').projectDir = new File(rootProject.projectDir, '../android/native-keystore')
```

**iOS: Add to Podfile:**
```ruby
pod 'NativeKeystore', :path => '../ios/native-keystore'
```

---

### Step 2: Create Platform Channel (Flutter)

**File: `lib/core/crypto/hardware_keystore.dart`**

```dart
import 'package:flutter/services.dart';
import 'dart:convert';

class HardwareKeystore {
  static const MethodChannel _channel = MethodChannel('com.myxen.crypto/hardware_keystore');

  /// Generate new Ed25519 keypair
  static Future<Map<String, dynamic>> generateKey(String label) async {
    try {
      final result = await _channel.invokeMethod('generateKey', {'label': label});
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Check if key exists
  static Future<Map<String, dynamic>> hasKey(String label) async {
    try {
      final result = await _channel.invokeMethod('hasKey', {'label': label});
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Get public key
  static Future<String> getPublicKey(String label) async {
    try {
      final result = await _channel.invokeMethod('getPublicKey', {'label': label});
      return result['publicKey'];
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Sign message
  static Future<String> sign(String label, String message) async {
    try {
      final result = await _channel.invokeMethod('sign', {
        'label': label,
        'message': message
      });
      return result['signature'];
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Delete key
  static Future<void> deleteKey(String label) async {
    try {
      await _channel.invokeMethod('deleteKey', {'label': label});
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Export encrypted backup
  static Future<Map<String, dynamic>> exportEncryptedBackup(
    String label,
    String passphrase, {
    Map<String, int>? scryptParams,
  }) async {
    try {
      final result = await _channel.invokeMethod('exportEncryptedBackup', {
        'label': label,
        'passphrase': passphrase,
        'scryptParams': scryptParams,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Import encrypted backup
  static Future<Map<String, dynamic>> importEncryptedBackup(
    String blob,
    String passphrase,
  ) async {
    try {
      final result = await _channel.invokeMethod('importEncryptedBackup', {
        'blob': blob,
        'passphrase': passphrase,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Check hardware availability
  static Future<Map<String, dynamic>> isHardwareBacked() async {
    try {
      final result = await _channel.invokeMethod('isHardwareBacked');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Migrate key from software to hardware
  static Future<Map<String, dynamic>> migrateKey(String label) async {
    try {
      final result = await _channel.invokeMethod('migrateKey', {'label': label});
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw KeystoreException(e.code, e.message ?? 'Unknown error');
    }
  }
}

class KeystoreException implements Exception {
  final String code;
  final String message;

  KeystoreException(this.code, this.message);

  @override
  String toString() => 'KeystoreException($code): $message';
}
```

---

### Step 3: Update Existing Key Manager

**Modify: `lib/core/crypto/key_manager.dart`**

Replace the existing `HardwareKeystore` stub calls with actual `HardwareKeystore` method channel calls:

```dart
// Before (stub):
final hwResult = await HardwareKeystore.generateKey(keyId);

// After (real):
final hwResult = await HardwareKeystore.generateKey(keyId);
// Now this actually calls native code!
```

---

### Step 4: Handle User Flows

#### Flow 1: First-Time Key Generation

```dart
Future<void> createWallet() async {
  // Check hardware availability
  final hwInfo = await HardwareKeystore.isHardwareBacked();
  final isHardware = hwInfo['hardwareAvailable'] == true;
  
  // Show user appropriate messaging
  if (isHardware) {
    showDialog('Creating hardware-backed wallet keys...');
  } else {
    showDialog('Hardware not available. Using secure software encryption...');
  }
  
  // Generate key
  final result = await HardwareKeystore.generateKey('wallet-main');
  
  // Store metadata
  await _storeKeyMetadata(result);
  
  // Show success
  showSuccess('Wallet created with ${result['mode']} security');
}
```

#### Flow 2: Signing Transaction

```dart
Future<String> signTransaction(Uint8List txData) async {
  try {
    // Convert to base64
    final message = base64.encode(txData);
    
    // Sign (may trigger biometric prompt)
    final signature = await HardwareKeystore.sign('wallet-main', message);
    
    return signature;
  } on KeystoreException catch (e) {
    if (e.code == 'ERR_USER_CANCELLED') {
      showError('Authentication cancelled');
    } else {
      showError('Signing failed: ${e.message}');
    }
    rethrow;
  }
}
```

#### Flow 3: Backup Export

```dart
Future<String> exportBackup(String passphrase) async {
  // Validate passphrase strength
  if (passphrase.length < 8) {
    throw Exception('Passphrase too weak');
  }
  
  // Export with production scrypt params
  final backup = await HardwareKeystore.exportEncryptedBackup(
    'wallet-main',
    passphrase,
    scryptParams: {'N': 32768, 'r': 8, 'p': 1},
  );
  
  // Save to file or display to user
  return backup['blob'];
}
```

#### Flow 4: Backup Import

```dart
Future<void> importBackup(String blob, String passphrase) async {
  try {
    final result = await HardwareKeystore.importEncryptedBackup(blob, passphrase);
    
    if (result['success'] == true) {
      showSuccess('Wallet restored with ${result['migratedTo']} security');
    }
  } on KeystoreException catch (e) {
    if (e.code == 'ERR_DECRYPT_FAILED') {
      showError('Incorrect passphrase');
    } else {
      showError('Import failed: ${e.message}');
    }
  }
}
```

---

## Testing Instructions

### Unit Tests
```bash
# Android
cd android/native-keystore
./gradlew test

# iOS
cd ios/native-keystore
xcodebuild test -scheme NativeKeystore
```

### Integration Tests
```bash
# Android (requires emulator or device)
cd android/native-keystore
./gradlew connectedAndroidTest

# iOS (requires simulator or device)
cd ios/native-keystore
xcodebuild test -scheme NativeKeystore -destination 'platform=iOS Simulator,name=iPhone 15'
```

### End-to-End Testing
```bash
# Flutter
flutter test
flutter test integration_test/keystore_test.dart
```

---

## Telemetry (Opt-In)

### Metrics Collected (if enabled)
- `keystore.mode.hardware` - Count of hardware key creations
- `keystore.mode.fallback` - Count of fallback key creations
- `keystore.sign.success` - Successful sign operations
- `keystore.sign.failure` - Failed sign operations (error code only, no data)
- `keystore.migration.attempted` - Migration attempts
- `keystore.migration.success` - Successful migrations

### Privacy
- **No private keys, signatures, or messages logged**
- **No personally identifiable information**
- Error codes sanitized to prevent data leakage
- Telemetry opt-in required in app settings

---

## Migration Path: Existing Users

### Scenario: App Update Adds Hardware Support

1. **Detect existing software-encrypted keys**
2. **Show migration prompt to user:**
   ```
   "Enhanced security available! Migrate your wallet keys to 
   hardware-protected storage for better security?"
   
   [Migrate Now] [Later]
   ```
3. **If user accepts:**
   - Export existing key as encrypted backup
   - Generate new hardware key
   - Re-encrypt backup with hardware-protected key
   - Delete old software key after confirmation
4. **If user declines:**
   - Continue with software fallback
   - Show reminder in settings

### Code Example
```dart
Future<void> promptMigration() async {
  final hwInfo = await HardwareKeystore.isHardwareBacked();
  
  if (hwInfo['hardwareAvailable'] == true) {
    final hasExistingKey = await HardwareKeystore.hasKey('wallet-main');
    
    if (hasExistingKey['exists'] == true && 
        hasExistingKey['mode'] == 'SOFTWARE_FALLBACK') {
      
      final userConsent = await showMigrationDialog();
      
      if (userConsent) {
        final result = await HardwareKeystore.migrateKey('wallet-main');
        showSuccess('Migration complete!');
      }
    }
  }
}
```

---

## Troubleshooting

### Issue: `ERR_HW_NOT_AVAILABLE` on Real Device

**Cause:** Device may not support hardware keystore or feature disabled.

**Solution:**
1. Check device specifications
2. Verify API level (Android 23+)
3. Check for device manufacturer restrictions
4. Fall back to software mode gracefully

---

### Issue: `ERR_USER_CANCELLED` During Signing

**Cause:** User cancelled biometric prompt.

**Solution:**
1. Show retry UI
2. Offer fallback authentication (PIN/password)
3. Don't auto-retry to avoid annoyance

---

### Issue: Biometric Changed, Key Inaccessible

**Cause:** User enrolled new fingerprint/face, invalidating hardware key.

**Solution:**
1. Detect `ERR_NOT_AUTHORIZED` error
2. Prompt user to restore from backup
3. Import backup with passphrase
4. Re-create hardware key

---

### Issue: Device Restore/Clone, Keys Missing

**Cause:** Hardware keys are device-bound and don't transfer.

**Solution:**
1. Always prompt user to back up keys during onboarding
2. Store backup blob in cloud (encrypted!)
3. Restore from backup on new device

---

## Performance Benchmarks

### Target Latencies (95th percentile)

| Operation | Hardware Mode | Fallback Mode |
|-----------|---------------|---------------|
| Key Generation | < 500ms | < 3000ms |
| Sign Transaction | < 200ms | < 100ms |
| Export Backup | N/A | < 5000ms |
| Import Backup | < 500ms | < 5000ms |

### Scrypt Parameters Impact

| N | r | p | Time (Low-End) | Time (High-End) |
|---|---|---|----------------|-----------------|
| 16384 | 8 | 1 | ~1s | ~200ms |
| 32768 | 8 | 1 | ~2s | ~400ms |
| 65536 | 8 | 1 | ~4s | ~800ms |

**Recommendation:** Use N=32768 for production; test on lowest-spec target device.

---

## Security Checklist

Before deploying to production, verify:

- [ ] All private keys created in hardware are non-exportable
- [ ] No private key material appears in logs (checked with `adb logcat` / Xcode console)
- [ ] Backup exports use scrypt + AES-256-GCM with proper parameters
- [ ] All random bytes sourced from `SecureRandom` (Android) / `SecRandomCopyBytes` (iOS)
- [ ] Error messages sanitized (no key material, message content, or PII)
- [ ] User explicit consent required for migration and export operations
- [ ] Rate-limiting implemented for passphrase attempts (max 5 per minute)
- [ ] Clear UI warnings shown for fallback vs hardware mode
- [ ] Unit tests cover all documented failure modes
- [ ] Integration tests run on real hardware (StrongBox, Secure Enclave)
- [ ] Penetration testing performed on backup encryption
- [ ] Code review completed with security focus

---

## Support & Maintenance

### Logging Best Practices

```kotlin
// Good: Sanitized logging
Log.d(TAG, "Key generation completed: mode=${result.mode}, keyId=${keyId.hashCode()}")

// Bad: Leaking sensitive data
Log.d(TAG, "Generated key: ${privateKey.toString()}") // NEVER DO THIS
```

### Memory Management

```kotlin
// Always zero out sensitive data
private fun zeroize(data: ByteArray) {
    data.fill(0)
}

// Use try-finally
val sensitiveData = decryptKey(...)
try {
    // Use data
} finally {
    zeroize(sensitiveData)
}
```

---

## FAQ

**Q: Can hardware keys be backed up?**
A: No, hardware private keys are non-exportable. However, you can back up the seed/mnemonic in encrypted form.

**Q: What happens if user loses device?**
A: Hardware keys are lost. User must restore from encrypted backup on new device.

**Q: Can I migrate from software to hardware without user action?**
A: No, explicit user consent required for security and transparency.

**Q: Does this work on emulators?**
A: Emulators typically don't have hardware keystore. Fallback mode is used automatically.

**Q: How do I test StrongBox/Secure Enclave in CI?**
A: Use device farm services (Firebase Test Lab, AWS Device Farm) with real hardware.

---

## License

This native module is part of the MyXen Mobile Application.
See LICENSE file in repository root.

---

## Contributors

Maintain security-first mindset. All PRs must include:
1. Security impact assessment
2. Test coverage report
3. Performance benchmarks
4. Documentation updates

---

**End of Master Instructions**
