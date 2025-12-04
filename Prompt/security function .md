#security function:
Nice — Boss choice accepted. I’ll deliver the **full Emergency Flutter module** file scaffold with exact, copy-paste **Copilot comments/prompts** for each file so your developers can generate production-ready code fast. This includes the feature code, assets, platform notes, and unit/integration test skeletons.

I’m strict: each file prompt specifies responsibilities, constraints, security rules, and test expectations. Paste the comment at the top of a new file and trigger Copilot (or Gemini) to generate the implementation and tests.

---

# Emergency Module — Overview (what we will produce)

Purpose: discreet, privacy-first Emergency Quick-Dial & SOS feature for MyXenPay.
Default behavior: open platform dialer pre-filled with local emergency number.
Opt-in: Auto-call (CALL_PHONE) + encrypted SOS messaging + one-time location.
Storage: all sensitive data encrypted in `flutter_secure_storage`.
No background continuous location. One-time foreground location only when explicitly consented at activation.

Module path (recommended):

```
/lib/features/emergency/
  emergency_module.dart
  pages/
    emergency_settings_page.dart
    emergency_setup_page.dart
    trusted_contacts_page.dart
  services/
    emergency_trigger_service.dart
    emergency_handler.dart
    country_detector.dart
    sos_manager.dart
  data/
    emergency_numbers.json (asset)
    emergency_db.dart
  widgets/
    hidden_trigger_widget.dart
    activation_overlay.dart
  models/
    trusted_contact.dart
    sos_payload.dart
  providers/
    emergency_providers.dart
  tests/
    unit/
      country_detector_test.dart
      sos_manager_test.dart
    integration/
      trigger_activation_test.dart
```

---

# How to use these prompts

1. Create each file path in the scaffold.
2. Paste the exact Copilot comment (below) at the top of the file.
3. Trigger Copilot to generate the code.
4. For larger files, follow up with the comment: `// Now generate matching unit tests for this file in /lib/features/emergency/tests/unit/` to request tests.

---

# Exact Copilot comments (copy-paste each block at the top of the corresponding file)

---

## /lib/features/emergency/emergency_module.dart

```dart
// Copilot: Implement emergency_module.dart.
// Responsibilities:
// - Export the Emergency feature: pages, providers, and services for easy module import.
// - Register routes for settings, setup, trusted contacts, and hidden trigger overlay.
// - Provide a single entry point function `registerEmergencyModule()` that AppRouter can call.
// Constraints & Security:
// - Do not include app-level side effects; only registration and provider wiring.
// - Document required app permissions and platform notes at top of file comments.
```

---

## /lib/features/emergency/data/emergency_numbers.json

```text
// Asset: emergency_numbers.json
// Content: a compact JSON mapping of ISO country code -> emergency number(s).
// Example:
// { "US": ["911"], "GB": ["999","112"], "BD": ["999"], ... }
// Copilot: Generate a compact, validated JSON asset with top ~150 country entries and a small README comment at the top (do not include huge comments).
```

---

## /lib/features/emergency/data/emergency_db.dart

```dart
// Copilot: Implement EmergencyDB loader.
// Responsibilities:
// - Load emergency_numbers.json from assets and expose a lookup function:
//     String? getEmergencyNumberForCountryCode(String isoCountryCode)
// - Provide fallback behavior and caching in-memory for fast lookups.
// - Validate number format and return the primary emergency number as string or null if unknown.
// Tests:
// - Include simple loader tests to validate mapping for known ISO codes.
```

---

## /lib/features/emergency/models/trusted_contact.dart

```dart
// Copilot: Implement TrustedContact model.
// Responsibilities:
// - Data class containing: id (uuid), name (optional), phone (e164), publicKey (optional for encrypted app-to-app relay), createdAt.
// - Provide JSON serialization helpers.
// Security:
// - Note: contact storage must be encrypted via SecureStorageService; model itself is plain for runtime use.
```

---

## /lib/features/emergency/models/sos_payload.dart

```dart
// Copilot: Implement SosPayload model.
// Responsibilities:
// - Define fields: senderId (anonymous token), timestamp (ISO), country, optional coords {lat,lon} if allowed, message, activationMode (dialer|auto_call|silent), appState.
// - Provide serialization to JSON and helper to produce encryptedBlob bytes.
// Security:
// - Include docstring: serialize then encrypt client-side in SosManager; never send plaintext payload to relay.
```

---

## /lib/features/emergency/providers/emergency_providers.dart

```dart
// Copilot: Implement emergency_providers.dart using Riverpod.
// Responsibilities:
// - Provide Riverpod providers for: EmergencyTriggerService, EmergencyHandler, CountryDetector, SosManager, EmergencySettings (StateNotifier).
// - Export typed providers for easy DI.
// Constraints:
// - Keep providers lazy and testable; avoid global side-effects on initialization.
```

---

## /lib/features/emergency/services/country_detector.dart

```dart
// Copilot: Implement CountryDetector.
// Responsibilities:
// - Determine user country via priority order:
//    1) SIM/Network country (TelephonyManager / CoreTelephony) where available
//    2) Device locale
//    3) User-provided phone country code (onboarding)
//    4) Optional IP geolocation fallback (server-assisted, coarse).
// - Expose async: Future<String?> detectCountryIso() returning ISO country code (uppercase).
// - Provide a public helper: String displayCountryForIso(String?) for UX.
// Security & privacy:
// - Do not persist any location info; only return coarse country iso. Document fallback behavior clearly.
```

---

## /lib/features/emergency/services/emergency_trigger_service.dart

```dart
// Copilot: Implement EmergencyTriggerService.
// Responsibilities:
// - Listen for configured triggers while app is in foreground:
//    * Hidden UI trigger (long-press, multi-tap) via HiddenTriggerWidget.
//    * Hardware combo (volume up + down x times) while app in foreground.
// - Provide API:
//    Stream<EmergencyActivation> get onActivation
//    Future<void> configureTrigger(TriggerConfig cfg)
//    Future<void> dispose()
// - Debounce, cooldown (configurable), and accidental-activation protection.
// - Emit Activation with metadata: activationType, timestamp, and userVisible (for overlay).
// Constraints:
// - Avoid background listeners when app is killed — document limitations.
// - For hardware combos, document platform-specific caveats and required permissions (none normally).
// Tests:
// - Unit test skeleton for long-press and multi-tap detection.
```

---

## /lib/features/emergency/widgets/hidden_trigger_widget.dart

```dart
// Copilot: Implement HiddenTriggerWidget.
// Responsibilities:
// - Invisible or minimally visible widget that can be placed anywhere in UI.
// - Detects user-configured gestures: long-press (3s default), multi-tap (5 taps in 2s default).
// - Visual feedback: optional short haptic vibration + invisible overlay when triggered (configurable in settings).
// Accessibility:
// - Provide an option to make the trigger visible and accessible in Settings for those who prefer explicit button.
```

---

## /lib/features/emergency/services/emergency_handler.dart

```dart
// Copilot: Implement EmergencyHandler.
// Responsibilities:
// - Core activation flow handler. On activation, perform steps depending on settings:
//    A) Default: open native dialer with local emergency number (tel:number) using platform-safe API.
//    B) If auto-call enabled & permission granted: attempt to place phone call (ACTION_CALL) with safe cancellation window.
//    C) If SOS opt-in: call SosManager.sendEncryptedSos(payload).
// - Provide cancelWindow (2-3s) to abort auto-call; implement local re-auth for enabling auto-call feature.
// - Public API: Future<void> handleActivation(EmergencyActivation activation).
// - Error handling & fallback: if no emergency number found, show a small UI to enter manual number and then open dialer.
// Security:
// - Do not persist unsent SOS payloads in plaintext. Encrypted queue only allowed; auto-delete after success.
```

---

## /lib/features/emergency/services/sos_manager.dart

```dart
// Copilot: Implement SosManager.
// Responsibilities:
// - Build SosPayload and encrypt client-side using user secrets (e.g., app key derived via SecureStorage / hardware keystore).
// - If trusted contact has app publicKey: encrypt per-recipient using hybrid encryption (ECDH + AES-GCM) and relay to backend as encrypted blobs.
// - If no recipient public key: encrypt with server public key for relay but ensure server cannot decrypt (recommend server stores only relayed blob and recipient decrypts client-side when possible).
// - Provide methods:
//     Future<EncryptedBlob> buildAndEncrypt(SosPayload payload, List<TrustedContact> recipients)
//     Future<void> sendEncryptedBlob(EncryptedBlob blob)
// - Retry/backoff for network; ensure encrypted queue persists only as encrypted and auto-deletes after successful send.
// Tests:
// - Unit tests for encryption/decryption using test keys and verifying server-relay cannot decrypt (mock server).
```

---

## /lib/features/emergency/pages/emergency_settings_page.dart

```dart
// Copilot: Implement EmergencySettingsPage.
// Responsibilities:
// - UI to configure:
//    * Enable/disable hidden trigger (and choose gesture type)
//    * Toggle auto-call (with strong consent modal requiring re-auth)
//    * Toggle SOS messaging (and configure trusted contacts)
//    * Manage trusted contacts (link to TrustedContactsPage)
//    * Manually override emergency number and preview detected country
//    * Reduce motion / overlay visibility toggle
// - All sensitive settings changes require re-auth (biometric/PIN).
// - Show small help text explaining privacy model: location usage, encryption, and server relay behavior.
```

---

## /lib/features/emergency/pages/trusted_contacts_page.dart

```dart
// Copilot: Implement TrustedContactsPage.
// Responsibilities:
// - UI to add/remove/list trusted contacts (name + phone + optional app public key).
// - Validate phone in E.164 format; guide user to add contact via manual entry only.
// - Contacts saved encrypted using flutter_secure_storage; provide export encrypted option.
// - Provide UI to test-send an encrypted "hello" to ensure relay working (mock test).
// Security:
// - Prevent paste of large plaintext lists; one contact per entry.
```

---

## /lib/features/emergency/widgets/activation_overlay.dart

```dart
// Copilot: Implement ActivationOverlay widget.
// Responsibilities:
// - Brief, minimal overlay shown on activation (if user wants visible feedback) with haptic feedback.
// - Shows a short timer for cancellation (e.g., "Emergency triggered — cancel in 3s") with Cancel button.
// - If user opts for silent activation, overlay can be disabled in settings.
```

---

## /lib/features/emergency/tests/unit/country_detector_test.dart

```dart
// Copilot: Implement unit tests for CountryDetector.
// Responsibilities:
// - Test detection fallback order: SIM -> locale -> phone code -> IP fallback (mock).
// - Use mocks for platform services to simulate missing SIM or no telephony.
// - Assert that detectCountryIso() returns uppercase ISO codes and falls back to known defaults.
```

---

## /lib/features/emergency/tests/unit/sos_manager_test.dart

```dart
// Copilot: Implement unit tests for SosManager encryption logic.
// Responsibilities:
// - Generate test keypairs, build SosPayload, encrypt for recipient key, and decrypt to verify content matches.
// - Test encrypted queue persistence (encrypted only) and auto-delete after success (mock network).
```

---

## /lib/features/emergency/tests/integration/trigger_activation_test.dart

```dart
// Copilot: Implement integration test skeleton for trigger activation.
// Responsibilities:
// - Simulate hidden trigger long-press / multi-tap and ensure EmergencyTriggerService emits activation and EmergencyHandler opens dialer (mock platform call).
// - Simulate auto-call enabled flows with permission granted/denied and verify correct fallback to dialer.
// - Simulate SOS opt-in flows with mock SosManager to ensure encrypted payload send called.
```

---

# Platform & manifest quick notes (copy into app docs)

* **AndroidManifest**: add `android.permission.CALL_PHONE` only if you implement auto-call; do NOT request at install — request at runtime on opt-in. Add camera permission elsewhere for QR. No background location or SMS.
* **iOS Info.plist**: do not include sensitive usage strings unless necessary. Add `NSLocationWhenInUseUsageDescription` only if you implement one-time location request and show clear runtime prompt.
* **Privacy**: include emergency feature privacy text in onboarding & settings and require explicit consent for auto-call and location sharing.

---

# Example small code snippets (for dev reference — paste after generating files)

Open dialer (Android/iOS compatible):

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openDialer(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri); // opens native dialer, no CALL_PHONE permission
  } else {
    throw Exception('Cannot open dialer');
  }
}
```

Request CALL_PHONE (Android runtime flow — show only when opt-in enabled):

* Use `permission_handler` plugin. Request `Permission.phone` (but note: `CALL_PHONE` is in manifest; handle platform nuance).

Encrypt SOS payload (high-level pseudocode):

```dart
// Use flutter_secure_storage to keep app symmetric key (wrapped by hardware keystore when possible).
final key = await secureStorage.read(key: 'sos_master_key'); // generated, hardware-backed if available
final cipherText = await aesGcmEncrypt(plainJsonBytes, key, associatedData: ...)
```

---

# Handoff checklist for security review & QA

* Provide threat model doc for Emergency module (include misuse & false activation scenarios).
* Provide key rotation plan for SosManager keys.
* Ensure tests cover accidental activations and permission-denied flows.
* External security audit before releasing auto-call feature.

---


