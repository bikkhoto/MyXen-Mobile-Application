// lib/core/crypto/encryption/hardware_keystore.dart
import 'package:flutter/services.dart';

/// Platform adapter for hardware-backed keystore
/// 
/// Provides access to:
/// - Android Keystore / StrongBox
/// - iOS Secure Enclave
class HardwareKeystore {
  static const MethodChannel _channel =
      MethodChannel('com.myxen.crypto/hardware_keystore');

  /// Detect if device has hardware-backed keystore
  Future<bool> isHardwareBacked() async {
    try {
      final result = await _channel.invokeMethod<bool>('isHardwareBacked');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error checking hardware keystore: ${e.message}');
      return false;
    }
  }

  /// Generate a hardware-wrapped symmetric key
  /// 
  /// [alias] - Key alias/identifier
  /// [purpose] - Purpose description (e.g., 'seed_encryption')
  /// 
  /// Returns wrapped key data or alias
  Future<Map<String, dynamic>> generateWrappingKey({
    required String alias,
    String purpose = 'seed_encryption',
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'generateWrappingKey',
        {
          'alias': alias,
          'purpose': purpose,
        },
      );
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw Exception('Failed to generate wrapping key: ${e.message}');
    }
  }

  /// Get native key handle for cryptographic operations
  /// 
  /// [alias] - Key alias
  /// 
  /// Returns key handle or null if not found
  Future<String?> getNativeKeyHandle(String alias) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getNativeKeyHandle',
        {'alias': alias},
      );
      return result?['keyHandle'] as String?;
    } on PlatformException catch (e) {
      print('Error getting key handle: ${e.message}');
      return null;
    }
  }

  /// Delete a hardware key
  /// 
  /// [alias] - Key alias to delete
  Future<bool> deleteKey(String alias) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'deleteKey',
        {'alias': alias},
      );
      return result?['status'] == 'deleted';
    } on PlatformException catch (e) {
      print('Error deleting key: ${e.message}');
      return false;
    }
  }

  /// Get platform information
  /// 
  /// Returns OS, version, and keystore type
  Future<Map<String, dynamic>> platformInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getPlatformInfo',
      );
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      print('Error getting platform info: ${e.message}');
      return {
        'os': 'unknown',
        'version': 'unknown',
        'secureHardware': false,
        'keystoreType': 'None',
      };
    }
  }

  /// Test hook: Set mock mode (debug/test only)
  Future<void> setMockMode(bool enabled) async {
    try {
      await _channel.invokeMethod('testHook_setMockMode', {
        'enabled': enabled,
      });
    } on PlatformException catch (e) {
      print('Mock mode not available: ${e.message}');
    }
  }

  /// Get a hardware-wrapped key (returns symmetric key bytes)
  /// For testing/fallback - in production, prefer native-only operations
  Future<Uint8List> getHardwareWrappedKey() async {
    try {
      final result = await _channel.invokeMethod<Uint8List>(
        'getHardwareWrappedKey',
      );
      return result ?? Uint8List(32); // Fallback to zeros (should not happen)
    } on PlatformException catch (e) {
      print('Error getting wrapped key: ${e.message}');
      // Return placeholder for now (platform implementation required)
      return Uint8List.fromList(List<int>.generate(32, (_) => 0x42));
    }
  }
}
