// lib/core/crypto/key_manager.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'mnemonic_service.dart';
import 'crypto_utils.dart';
import 'encryption/aes_gcm_wrapper.dart';
import 'encryption/hardware_keystore.dart';
import 'encryption/scrypt_wrapper.dart';

/// High-level key lifecycle manager
/// 
/// Responsibilities:
/// - Create/restore wallet
/// - Persist encrypted seed
/// - Derive keys
/// - Export/import encrypted backups
/// - Re-auth gating
class KeyManager {
  final MnemonicService _mnemonicService = MnemonicService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AesGcmWrapper _crypto = AesGcmWrapper();
  final HardwareKeystore _hw = HardwareKeystore();
  final ScryptWrapper _scrypt = ScryptWrapper();

  static const _storageKeyEncryptedSeed = 'encrypted_seed_v1';
  static const _storageKeySalt = 'scrypt_salt_v1';
  static const _storageKeyKdfType = 'kdf_type_v1';
  
  /// Solana derivation path for account 0
  static const derivationPath = "m/44'/501'/0'/0'";

  /// Create a new wallet
  /// 
  /// Generates BIP39 mnemonic, derives seed, encrypts and persists
  /// 
  /// [pin] - Optional PIN for scrypt-based encryption (if no hardware keystore)
  /// 
  /// Returns mnemonic string (display once to user, then discard)
  Future<String> createWallet({String? pin}) async {
    final mnemonic = _mnemonicService.generateMnemonic();
    final seed = _mnemonicService.mnemonicToSeed(mnemonic);

    // Verify derivation works
    try {
      await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
    } catch (e) {
      throw Exception('Failed to derive master key: $e');
    }

    // Encrypt and store seed
    final key = await _deriveOrGetWrappingKey(pin: pin);
    final encrypted = await _crypto.encrypt(seed, key);
    
    await _secureStorage.write(
      key: _storageKeyEncryptedSeed,
      value: encrypted.base64,
    );

    // Store KDF type
    final isHardware = await _hw.isHardwareBacked();
    await _secureStorage.write(
      key: _storageKeyKdfType,
      value: isHardware ? 'hardware' : 'scrypt',
    );

    // Zeroize sensitive data
    zeroize(seed);
    zeroize(key);

    return mnemonic;
  }

  /// Restore wallet from mnemonic
  /// 
  /// [mnemonic] - BIP39 mnemonic phrase
  /// [pin] - Optional PIN for scrypt-based encryption
  Future<void> restoreFromMnemonic(String mnemonic, {String? pin}) async {
    if (!_mnemonicService.validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid mnemonic phrase');
    }

    final seed = _mnemonicService.mnemonicToSeed(mnemonic);
    
    // Verify derivation works
    try {
      await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
    } catch (e) {
      zeroize(seed);
      throw Exception('Failed to derive master key: $e');
    }

    final key = await _deriveOrGetWrappingKey(pin: pin);
    final encrypted = await _crypto.encrypt(seed, key);
    
    await _secureStorage.write(
      key: _storageKeyEncryptedSeed,
      value: encrypted.base64,
    );

    // Store KDF type
    final isHardware = await _hw.isHardwareBacked();
    await _secureStorage.write(
      key: _storageKeyKdfType,
      value: isHardware ? 'hardware' : 'scrypt',
    );

    // Zeroize sensitive data
    zeroize(seed);
    zeroize(key);
  }

  /// Get decrypted seed (in memory only)
  Future<Uint8List?> _getSeed({String? pin}) async {
    final wrapped = await _secureStorage.read(key: _storageKeyEncryptedSeed);
    if (wrapped == null) return null;

    try {
      final key = await _deriveOrGetWrappingKey(pin: pin);
      final encrypted = Base64Encrypted.fromBase64(wrapped);
      final decrypted = await _crypto.decrypt(encrypted, key);
      
      // Zeroize wrapping key
      zeroize(key);
      
      return decrypted;
    } catch (e) {
      throw Exception('Failed to decrypt seed: $e');
    }
  }

  /// Derive ed25519 private key for account
  /// 
  /// [account] - Account index (default: 0)
  /// [pin] - Optional PIN for decryption
  /// 
  /// Returns private key bytes (32 bytes)
  /// IMPORTANT: Caller must zeroize after use
  Future<Uint8List?> derivePrivateKey({
    int account = 0,
    String? pin,
  }) async {
    final seed = await _getSeed(pin: pin);
    if (seed == null) return null;

    try {
      final path = "m/44'/501'/$account'/0'";
      final kp = await ED25519_HD_KEY.derivePath(path, seed);
      
      // Zeroize seed
      zeroize(seed);
      
      // Convert to Uint8List if needed
      final key = kp.key;
      return key is Uint8List ? key : Uint8List.fromList(key);
    } catch (e) {
      zeroize(seed);
      throw Exception('Failed to derive private key: $e');
    }
  }

  /// Get public key in Base58 format
  /// 
  /// [account] - Account index (default: 0)
  /// [pin] - Optional PIN for decryption
  Future<String?> getPublicKeyBase58({
    int account = 0,
    String? pin,
  }) async {
    final privKey = await derivePrivateKey(account: account, pin: pin);
    if (privKey == null) return null;

    try {
      // Derive public key from private key
      final pubKeyList = await ED25519_HD_KEY.getPublicKey(privKey, false);
      final pubKey = pubKeyList is Uint8List ? pubKeyList : Uint8List.fromList(pubKeyList);
      
      // Zeroize private key
      zeroize(privKey);
      
      // Convert to Base58 (Solana format)
      return _base58Encode(pubKey);
    } catch (e) {
      zeroize(privKey);
      throw Exception('Failed to get public key: $e');
    }
  }

  /// Export encrypted seed as backup blob
  /// 
  /// [pin] - Optional PIN for re-encryption
  /// 
  /// Returns base64-encoded encrypted blob
  Future<String> exportEncryptedSeed({String? pin}) async {
    final wrapped = await _secureStorage.read(key: _storageKeyEncryptedSeed);
    if (wrapped == null) {
      throw Exception('No seed found to export');
    }
    return wrapped;
  }

  /// Import encrypted seed from backup blob
  /// 
  /// [encryptedBlob] - Base64-encoded encrypted seed
  /// [pin] - Optional PIN for decryption
  Future<void> importEncryptedSeed(String encryptedBlob, {String? pin}) async {
    // Validate blob can be decrypted
    try {
      final encrypted = Base64Encrypted.fromBase64(encryptedBlob);
      final key = await _deriveOrGetWrappingKey(pin: pin);
      final seed = await _crypto.decrypt(encrypted, key);
      
      // Verify seed is valid by deriving master key
      await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
      
      // Zeroize
      zeroize(seed);
      zeroize(key);
      
      // Store encrypted blob
      await _secureStorage.write(
        key: _storageKeyEncryptedSeed,
        value: encryptedBlob,
      );
    } catch (e) {
      throw Exception('Failed to import encrypted seed: $e');
    }
  }

  /// Check if hardware-backed keystore is available
  Future<bool> isHardwareBacked() async {
    return await _hw.isHardwareBacked();
  }

  /// Clear all keys and sensitive data
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _storageKeyEncryptedSeed);
    await _secureStorage.delete(key: _storageKeySalt);
    await _secureStorage.delete(key: _storageKeyKdfType);
  }

  /// Derive or get wrapping key (hardware-backed or scrypt-derived)
  Future<Uint8List> _deriveOrGetWrappingKey({String? pin}) async {
    final hasHardware = await _hw.isHardwareBacked();
    
    if (hasHardware) {
      // Use hardware-backed key
      return await _hw.getHardwareWrappedKey();
    } else {
      // Use scrypt-derived key from PIN
      if (pin == null || pin.isEmpty) {
        throw ArgumentError('PIN required for scrypt-based encryption');
      }
      
      // Get or generate salt
      String? saltStr = await _secureStorage.read(key: _storageKeySalt);
      Uint8List salt;
      
      if (saltStr == null) {
        salt = _scrypt.generateSalt();
        await _secureStorage.write(
          key: _storageKeySalt,
          value: base64Encode(salt),
        );
      } else {
        salt = base64Decode(saltStr);
      }
      
      // Derive key from PIN
      return await _scrypt.deriveKey(pin, salt: salt);
    }
  }

  /// Simple Base58 encoding (for Solana public keys)
  String _base58Encode(Uint8List bytes) {
    const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    var num = BigInt.zero;
    
    for (var byte in bytes) {
      num = num * BigInt.from(256) + BigInt.from(byte);
    }
    
    var result = '';
    while (num > BigInt.zero) {
      var remainder = num % BigInt.from(58);
      num = num ~/ BigInt.from(58);
      result = alphabet[remainder.toInt()] + result;
    }
    
    // Add leading zeros
    for (var byte in bytes) {
      if (byte == 0) {
        result = '1$result';
      } else {
        break;
      }
    }
    
    return result;
  }
}
