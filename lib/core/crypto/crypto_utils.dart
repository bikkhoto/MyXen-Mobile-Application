// lib/core/crypto/crypto_utils.dart
import 'dart:typed_data';
import 'dart:convert';

/// Wrapper for encrypted data with nonce
class Base64Encrypted {
  final Uint8List cipher;
  final Uint8List nonce;

  Base64Encrypted(this.cipher, this.nonce);

  /// Convert to base64 string (nonce + cipher concatenated)
  String get base64 => base64Encode([...nonce, ...cipher]);

  /// Create from base64 string
  /// Expects format: [12-byte nonce][ciphertext]
  static Base64Encrypted fromBase64(String input) {
    final bytes = base64Decode(input);
    if (bytes.length < 12) {
      throw ArgumentError('Invalid encrypted data: too short');
    }
    final nonce = bytes.sublist(0, 12);
    final cipher = bytes.sublist(12);
    return Base64Encrypted(
      Uint8List.fromList(cipher),
      Uint8List.fromList(nonce),
    );
  }

  /// Get total length
  int get length => nonce.length + cipher.length;
}

/// Securely overwrite memory buffer with zeros
void zeroize(Uint8List bytes) {
  for (int i = 0; i < bytes.length; i++) {
    bytes[i] = 0;
  }
}

/// Securely overwrite list with zeros
void zeroizeList(List<int> bytes) {
  for (int i = 0; i < bytes.length; i++) {
    bytes[i] = 0;
  }
}

/// Convert hex string to Uint8List
Uint8List hexToBytes(String hex) {
  if (hex.length % 2 != 0) {
    throw ArgumentError('Hex string must have even length');
  }
  final result = Uint8List(hex.length ~/ 2);
  for (int i = 0; i < result.length; i++) {
    result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}

/// Convert Uint8List to hex string
String bytesToHex(Uint8List bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Constant-time comparison of two byte arrays
bool constantTimeCompare(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  int result = 0;
  for (int i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}
