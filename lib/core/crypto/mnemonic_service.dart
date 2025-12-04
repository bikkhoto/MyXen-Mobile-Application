// lib/core/crypto/mnemonic_service.dart
import 'package:bip39/bip39.dart' as bip39;
import 'dart:typed_data';

/// Service for generating and validating BIP39 mnemonics and converting to seed
class MnemonicService {
  /// Generate a 12-word mnemonic (128-bit strength)
  String generateMnemonic({int strength = 128}) {
    return bip39.generateMnemonic(strength: strength);
  }

  /// Validate a mnemonic phrase
  bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  /// Convert mnemonic to seed bytes (Uint8List)
  /// 
  /// [mnemonic] - The BIP39 mnemonic phrase
  /// [passphrase] - Optional passphrase for additional security
  /// 
  /// Returns 64-byte seed
  Uint8List mnemonicToSeed(String mnemonic, {String passphrase = ''}) {
    final seed = bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
    return Uint8List.fromList(seed);
  }

  /// Get word count from mnemonic
  int getWordCount(String mnemonic) {
    return mnemonic.trim().split(RegExp(r'\s+')).length;
  }

  /// Validate word count (should be 12, 15, 18, 21, or 24)
  bool isValidWordCount(String mnemonic) {
    final count = getWordCount(mnemonic);
    return [12, 15, 18, 21, 24].contains(count);
  }
}
