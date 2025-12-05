// lib/core/crypto/encryption/scrypt_wrapper.dart
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

/// scrypt key derivation wrapper
/// 
/// Default parameters (non-negotiable):
/// - N (cost): 16384
/// - r (block size): 8
/// - p (parallelization): 1
/// - dkLen (derived key length): 32 bytes
/// - salt: 16 bytes (random)
class ScryptWrapper {
  /// Derive a symmetric wrapping key from PIN/passphrase
  /// 
  /// [pin] - User PIN or passphrase
  /// [salt] - Random salt (16 bytes recommended)
  /// [N] - CPU/memory cost parameter (default: 16384)
  /// [r] - Block size parameter (default: 8)
  /// [p] - Parallelization parameter (default: 1)
  /// [dkLen] - Derived key length in bytes (default: 32)
  /// 
  /// Returns derived key bytes
  Future<Uint8List> deriveKey(
    String pin, {
    Uint8List? salt,
    int N = 16384,
    int r = 8,
    int p = 1,
    int dkLen = 32,
  }) async {
    final actualSalt = salt ?? generateSalt();
    
    if (actualSalt.length < 8) {
      throw ArgumentError('Salt must be at least 8 bytes');
    }

    // Prepare parameters for isolate
    final params = _ScryptParams(
      pin: pin,
      salt: actualSalt,
      N: N,
      r: r,
      p: p,
      dkLen: dkLen,
    );

    try {
      // Run scrypt in a background isolate to avoid blocking the UI thread
      final derivedKey = await compute(_runScrypt, params);
      return derivedKey;
    } catch (e) {
      throw Exception('scrypt key derivation failed: $e');
    }
  }

  /// Generate a random salt
  /// 
  /// [size] - Salt size in bytes (default: 16)
  Uint8List generateSalt({int size = 16}) {
    final rnd = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(size, (_) => rnd.nextInt(256)),
    );
  }

  /// Validate scrypt parameters
  bool validateParams({
    required int N,
    required int r,
    required int p,
  }) {
    // N must be power of 2 and > 1
    if (N <= 1 || (N & (N - 1)) != 0) return false;
    
    // r and p must be positive
    if (r <= 0 || p <= 0) return false;
    
    // Memory requirement check: 128 * N * r bytes
    // Ensure it doesn't exceed reasonable limits
    final memoryRequired = 128 * N * r;
    if (memoryRequired > 1024 * 1024 * 1024) return false; // 1GB limit
    
    return true;
  }

  /// Get default parameters as map
  Map<String, int> getDefaultParams() {
    return {
      'N': 16384,
      'r': 8,
      'p': 1,
      'dkLen': 32,
      'saltLen': 16,
    };
  }
}

/// Parameters container for passing to isolate
class _ScryptParams {
  final String pin;
  final Uint8List salt;
  final int N;
  final int r;
  final int p;
  final int dkLen;

  _ScryptParams({
    required this.pin,
    required this.salt,
    required this.N,
    required this.r,
    required this.p,
    required this.dkLen,
  });
}

/// Top-level function for isolate execution
Uint8List _runScrypt(_ScryptParams params) {
  final scrypt = Scrypt();
  scrypt.init(ScryptParameters(
    params.N,
    params.r,
    params.p,
    params.dkLen,
    params.salt,
  ));
  
  final pinBytes = Uint8List.fromList(params.pin.codeUnits);
  final key = scrypt.process(pinBytes);
  return Uint8List.fromList(key);
}
