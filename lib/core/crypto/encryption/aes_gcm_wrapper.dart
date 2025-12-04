// lib/core/crypto/encryption/aes_gcm_wrapper.dart
import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/export.dart';
import '../crypto_utils.dart';

/// AES-256-GCM encryption wrapper
/// 
/// Security parameters:
/// - Key size: 256-bit (32 bytes)
/// - Nonce size: 96-bit (12 bytes)
/// - Tag size: 128-bit (16 bytes)
class AesGcmWrapper {
  static final _secureRandom = FortunaRandom();
  static bool _initialized = false;

  AesGcmWrapper() {
    if (!_initialized) {
      _initializeRandom();
      _initialized = true;
    }
  }

  /// Initialize secure random number generator
  void _initializeRandom() {
    final seed = Uint8List(32);
    final rng = Random.secure();
    for (int i = 0; i < seed.length; i++) {
      seed[i] = rng.nextInt(256);
    }
    _secureRandom.seed(KeyParameter(seed));
  }

  /// Encrypt plaintext with AES-256-GCM
  /// 
  /// [plaintext] - Data to encrypt
  /// [key] - 32-byte encryption key
  /// [associatedData] - Optional authenticated data (not encrypted)
  /// 
  /// Returns Base64Encrypted with nonce and ciphertext
  Future<Base64Encrypted> encrypt(
    Uint8List plaintext,
    Uint8List key, {
    Uint8List? associatedData,
  }) async {
    if (key.length != 32) {
      throw ArgumentError('Key must be 32 bytes for AES-256');
    }

    final nonce = _randomBytes(12);
    final cipher = _process(
      true,
      key,
      nonce,
      plaintext,
      associatedData: associatedData,
    );
    return Base64Encrypted(cipher, nonce);
  }

  /// Decrypt ciphertext with AES-256-GCM
  /// 
  /// [encrypted] - Base64Encrypted object with nonce and cipher
  /// [key] - 32-byte decryption key
  /// [associatedData] - Optional authenticated data (must match encryption)
  /// 
  /// Returns decrypted plaintext
  /// Throws if authentication fails
  Future<Uint8List> decrypt(
    Base64Encrypted encrypted,
    Uint8List key, {
    Uint8List? associatedData,
  }) async {
    if (key.length != 32) {
      throw ArgumentError('Key must be 32 bytes for AES-256');
    }

    final plain = _process(
      false,
      key,
      encrypted.nonce,
      encrypted.cipher,
      associatedData: associatedData,
    );
    return plain;
  }

  /// Process encryption/decryption
  Uint8List _process(
    bool forEncryption,
    Uint8List key,
    Uint8List nonce,
    Uint8List data, {
    Uint8List? associatedData,
  }) {
    final aad = associatedData ?? Uint8List(0);
    final params = AEADParameters(
      KeyParameter(key),
      128, // tag size in bits
      nonce,
      aad,
    );

    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(forEncryption, params);

    try {
      return cipher.process(data);
    } catch (e) {
      throw Exception('AES-GCM ${forEncryption ? 'encryption' : 'decryption'} failed: $e');
    }
  }

  /// Generate cryptographically secure random bytes
  Uint8List _randomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rnd.nextInt(256)),
    );
  }

  /// Get recommended nonce size (12 bytes for GCM)
  int recommendedNonceSize() => 12;

  /// Get recommended tag size (128 bits = 16 bytes)
  int recommendedTagSize() => 128;
}
