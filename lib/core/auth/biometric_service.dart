// lib/core/auth/biometric_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

/// Biometric Authentication Service
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometric authentication is available
  Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate with biometrics
  /// 
  /// [reason] - Reason shown to user
  /// [useErrorDialogs] - Show error dialogs
  /// [stickyAuth] - Keep auth session alive
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'MyXen Authentication',
            cancelButton: 'Cancel',
            biometricHint: 'Verify your identity',
            biometricNotRecognized: 'Not recognized. Try again.',
            biometricSuccess: 'Success',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up biometric authentication.',
            lockOut: 'Biometric authentication is disabled. Please lock and unlock your screen to enable it.',
          ),
        ],
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow PIN/pattern fallback
        ),
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  /// Authenticate for transaction signing
  Future<bool> authenticateForTransaction({
    required double amount,
    required String token,
  }) async {
    return await authenticate(
      reason: 'Authenticate to send $amount $token',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for wallet access
  Future<bool> authenticateForWalletAccess() async {
    return await authenticate(
      reason: 'Authenticate to access your wallet',
      useErrorDialogs: true,
      stickyAuth: false,
    );
  }

  /// Authenticate for backup/restore
  Future<bool> authenticateForBackup() async {
    return await authenticate(
      reason: 'Authenticate to backup your wallet',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for settings change
  Future<bool> authenticateForSettings() async {
    return await authenticate(
      reason: 'Authenticate to change security settings',
      useErrorDialogs: true,
      stickyAuth: false,
    );
  }

  /// Stop authentication
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }

  /// Get biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Get primary biometric type
  Future<String> getPrimaryBiometricType() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) return 'None';
    
    // Prioritize face > fingerprint > others
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }
}
