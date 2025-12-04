# Android Native Keystore Module

## Purpose

This module provides hardware-backed Ed25519 key generation and signing for the MyXen wallet application. It leverages Android's KeyStore system and StrongBox hardware security module (when available) to protect private keys from extraction, even on rooted devices.

---

## Features

- ✅ **Hardware-backed keys** using AndroidKeyStore
- ✅ **StrongBox support** on Android 9.0+ (API 28+) devices
- ✅ **Ed25519 signing** for Solana transactions
- ✅ **Biometric authentication** via BiometricPrompt API
- ✅ **Secure fallback** using scrypt + AES-256-GCM when hardware unavailable
- ✅ **Encrypted backup/restore** with user-provided passphrase
- ✅ **Zero-knowledge export** - only encrypted blobs leave device

---

## Architecture

```
KeystoreManager (Singleton)
├── HardwareKeystore Operations
│   ├── Detect StrongBox capability
│   ├── Generate Ed25519 keypair in AndroidKeyStore
│   ├── Sign messages (may prompt for biometric)
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

**In `android/settings.gradle`:**
```gradle
include ':native-keystore'
project(':native-keystore').projectDir = new File(rootProject.projectDir, 'native-keystore')
```

**In `android/app/build.gradle`:**
```gradle
dependencies {
    implementation project(':native-keystore')
}
```

### Step 2: Initialize in MainActivity

**In `android/app/src/main/kotlin/.../MainActivity.kt`:**
```kotlin
import com.myxen.keystore.BridgeModule
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        BridgeModule.register(flutterEngine.dartExecutor.binaryMessenger, this)
    }
}
```

---

## Dependencies

### Required in `build.gradle`

```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdkVersion 23  // Android 6.0 (Marshmallow)
        targetSdkVersion 34
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = '1.8'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.20"
    implementation "androidx.biometric:biometric:1.2.0-alpha05"
    implementation "org.bouncycastle:bcprov-jdk15on:1.70"  // For Ed25519
    implementation "com.google.crypto.tink:tink-android:1.12.0"  // For scrypt
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3"
    
    testImplementation "junit:junit:4.13.2"
    testImplementation "org.mockito.kotlin:mockito-kotlin:5.1.0"
    androidTestImplementation "androidx.test.ext:junit:1.1.5"
    androidTestImplementation "androidx.test:runner:1.5.2"
    androidTestImplementation "androidx.test:rules:1.5.0"
}
```

---

## Permissions

### Required in AndroidManifest.xml

```xml
<!-- Biometric authentication -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />

<!-- For KeyStore access (implicit, no declaration needed) -->

<!-- Optional: Hardware feature detection -->
<uses-feature 
    android:name="android.hardware.strongbox_keystore"
    android:required="false" />
```

---

## API Levels & Compatibility

| Feature | Minimum API | Optimal API | Fallback |
|---------|-------------|-------------|----------|
| AndroidKeyStore | 23 (6.0) | 23+ | Software scrypt |
| StrongBox | 28 (9.0) | 31+ | Regular KeyStore |
| BiometricPrompt | 28 (9.0) | 30+ | KeyguardManager |
| Ed25519 in KeyStore | 31 (12.0) | 31+ | BouncyCastle software |

---

## Building

### Debug Build
```bash
cd android/native-keystore
./gradlew assembleDebug
```

### Release Build
```bash
./gradlew assembleRelease
```

### Run Unit Tests
```bash
./gradlew test
```

### Run Instrumentation Tests
```bash
# Start emulator or connect device first
./gradlew connectedAndroidTest
```

---

## Testing

### Unit Tests (JVM)
Located in `src/test/java/com/myxen/keystore/`

```bash
./gradlew test --tests KeystoreUnitTest
./gradlew test --tests ScryptFallbackTest
```

### Integration Tests (Device/Emulator)
Located in `src/androidTest/java/com/myxen/keystore/`

```bash
# Test on standard KeyStore (any device)
./gradlew connectedAndroidTest

# Test StrongBox (requires physical device with StrongBox)
./gradlew connectedAndroidTest -Pandroid.testInstrumentationRunnerArguments.strongbox=true
```

---

## Configuration

### Feature Flags

Create `keystore.properties` in module root:

```properties
# Force software fallback (for testing)
keystore.force_fallback=false

# Enable verbose logging (debug builds only)
keystore.debug_logging=true

# Scrypt parameters for CI (fast)
keystore.scrypt.ci.N=16384
keystore.scrypt.ci.r=8
keystore.scrypt.ci.p=1

# Scrypt parameters for production (secure)
keystore.scrypt.prod.N=32768
keystore.scrypt.prod.r=8
keystore.scrypt.prod.p=1

# Telemetry opt-in
keystore.telemetry.enabled=false
```

---

## Security Considerations

### ✅ Hardware Mode (StrongBox/KeyStore)
- Private key generated inside HSM
- Key **never** leaves hardware boundary
- Protected against:
  - Root access
  - Memory dumps
  - Physical extraction
  - Side-channel attacks (StrongBox)

### ⚠️ Software Fallback Mode
- Private key encrypted with scrypt + AES-GCM
- Stored in Android KeyStore (software-backed)
- Protected against:
  - Offline brute-force (high scrypt cost)
  - Passive memory dumps
- **NOT** protected against:
  - Active root malware with memory inspection
  - Debugger attachment in runtime

### Memory Safety
- All sensitive byte arrays zeroized after use
- No sensitive data in log output
- Garbage collector cannot recover zeroized data

---

## Error Codes

| Code | Meaning | Recovery |
|------|---------|----------|
| `ERR_HW_NOT_AVAILABLE` | No hardware keystore | Use fallback |
| `ERR_HW_CREATION_FAILED` | Key creation failed | Check logs, retry |
| `ERR_SIGN_FAILED` | Signing operation failed | Verify key exists |
| `ERR_KEY_NOT_FOUND` | Key doesn't exist | Create or import |
| `ERR_USER_CANCELLED` | Biometric cancelled | Show retry UI |
| `ERR_DECRYPT_FAILED` | Wrong passphrase | Prompt again (rate limit!) |
| `ERR_INVALID_BACKUP` | Corrupted backup | Request new backup |
| `ERR_NOT_AUTHORIZED` | Biometric invalidated | Restore from backup |
| `ERR_UNKNOWN` | Unexpected error | Check logs |

---

## Performance Targets

### Hardware Mode
- Key generation: < 500ms (p95)
- Signature: < 200ms (p95)
- Public key retrieval: < 50ms (p95)

### Software Fallback
- Key derivation (scrypt): < 2000ms (N=32768, p95, Snapdragon 660)
- Encryption/Decryption: < 100ms (p95)
- Signature: < 50ms (p95)

---

## Debugging

### Enable Verbose Logging

```kotlin
// In KeystoreManager.kt
companion object {
    private const val DEBUG = BuildConfig.DEBUG
    private const val TAG = "MyXenKeystore"
}

// Use throughout code
if (DEBUG) {
    Log.d(TAG, "Operation completed: ${sanitize(result)}")
}
```

### Check Hardware Availability

```bash
adb shell pm list features | grep strongbox
# Output: feature:android.hardware.strongbox_keystore
```

### Inspect KeyStore Contents

```bash
# List all keys
adb shell pm list packages -f com.myxen

# Note: Cannot export private keys (by design)
```

---

## Common Issues

### Issue: StrongBox always returns false
**Cause:** Device doesn't have StrongBox chip.
**Solution:** Falls back to regular KeyStore automatically.

### Issue: BiometricPrompt not showing
**Cause:** No biometric enrolled or device lacks hardware.
**Solution:** Check `BiometricManager.canAuthenticate()` first.

### Issue: Keys lost after app reinstall
**Cause:** Android KeyStore clears on uninstall.
**Solution:** Use encrypted backup feature. Restore from backup after reinstall.

---

## File Structure

```
android/native-keystore/
├── build.gradle
├── src/
│   ├── main/
│   │   ├── AndroidManifest.xml
│   │   └── java/com/myxen/keystore/
│   │       ├── KeystoreManager.kt       # Main singleton
│   │       ├── BridgeModule.kt          # Flutter bridge
│   │       ├── ScryptFallback.kt        # Fallback crypto
│   │       └── Constants.kt             # Error codes, config
│   ├── test/
│   │   └── java/com/myxen/keystore/
│   │       ├── KeystoreUnitTest.kt      # JVM unit tests
│   │       └── ScryptFallbackTest.kt    # Crypto unit tests
│   └── androidTest/
│       └── java/com/myxen/keystore/
│           └── KeystoreIntegrationTest.kt  # Device tests
└── README.md  (this file)
```

---

## Next Steps

1. **Implement native code** using Copilot assistance (see `TODO` markers in each file)
2. **Run unit tests** to verify crypto operations
3. **Run integration tests** on physical device with StrongBox
4. **Benchmark performance** on low-end devices
5. **Security review** before production deployment

---

## License

Copyright (c) 2025 MyXen. See LICENSE file in repository root.

---

## Support

For issues specific to this module:
1. Check error logs (`adb logcat | grep MyXenKeystore`)
2. Verify device capabilities
3. Review this README's troubleshooting section
4. File issue with logs (sanitized!) and device info

---

**End of README**
