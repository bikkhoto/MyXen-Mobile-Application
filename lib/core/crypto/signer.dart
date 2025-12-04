// lib/core/crypto/signer.dart
import 'dart:typed_data';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:convert/convert.dart';
import 'key_manager.dart';
import 'crypto_utils.dart';

/// Deterministic ed25519 signing service
/// 
/// Handles signing of messages and transactions using derived private keys
class Signer {
  final KeyManager _keyManager;

  Signer(this._keyManager);

  /// Sign a message using derived ed25519 private key
  /// 
  /// [message] - Message bytes to sign
  /// [pin] - Optional PIN for key decryption
  /// [account] - Account index (default: 0)
  /// 
  /// Returns 64-byte signature
  Future<Uint8List?> sign(
    Uint8List message, {
    String? pin,
    int account = 0,
  }) async {
    final privKey = await _keyManager.derivePrivateKey(
      account: account,
      pin: pin,
    );
    
    if (privKey == null) return null;

    try {
      // Sign message with ed25519
      final privateKey = ed25519.PrivateKey(privKey);
      final signature = ed25519.sign(privateKey, message);
      
      // Zeroize private key
      zeroize(privKey);
      
      return Uint8List.fromList(signature);
    } catch (e) {
      zeroize(privKey);
      throw Exception('Signing failed: $e');
    }
  }

  /// Sign transaction bytes
  /// 
  /// [txBytes] - Serialized transaction bytes
  /// [pin] - Optional PIN for key decryption
  /// [account] - Account index (default: 0)
  /// [requireUserConfirmation] - Whether to require user confirmation (default: true)
  /// 
  /// Returns signature bytes
  Future<Uint8List?> signTransactionBytes(
    Uint8List txBytes, {
    String? pin,
    int account = 0,
    bool requireUserConfirmation = true,
  }) async {
    // In production, this should show UI confirmation if requireUserConfirmation is true
    // For now, delegate to sign method
    return await sign(txBytes, pin: pin, account: account);
  }

  /// Verify a signature
  /// 
  /// [message] - Original message bytes
  /// [signature] - Signature to verify (64 bytes)
  /// [pubKey] - Public key bytes (32 bytes)
  /// 
  /// Returns true if signature is valid
  static bool verify(
    Uint8List message,
    Uint8List signature,
    Uint8List pubKey,
  ) {
    try {
      final publicKey = ed25519.PublicKey(pubKey);
      return ed25519.verify(publicKey, message, signature);
    } catch (e) {
      return false;
    }
  }

  /// Get public key for account
  /// 
  /// [account] - Account index (default: 0)
  /// [pin] - Optional PIN for decryption
  Future<Uint8List?> getPublicKey({
    int account = 0,
    String? pin,
  }) async {
    final privKey = await _keyManager.derivePrivateKey(
      account: account,
      pin: pin,
    );
    
    if (privKey == null) return null;

    try {
      final privateKey = ed25519.PrivateKey(privKey);
      final publicKey = ed25519.public(privateKey);
      
      // Zeroize private key
      zeroize(privKey);
      
      return Uint8List.fromList(publicKey);
    } catch (e) {
      zeroize(privKey);
      throw Exception('Failed to get public key: $e');
    }
  }
}

