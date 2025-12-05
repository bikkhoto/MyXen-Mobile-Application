// lib/core/network/solana_transaction_builder.dart
import 'dart:typed_data';

/// Solana Transaction Builder
/// 
/// Builds and serializes Solana transactions for SPL token transfers
class SolanaTransactionBuilder {
  /// Build a simple SOL transfer transaction
  static Uint8List buildSolTransfer({
    required String fromPubkey,
    required String toPubkey,
    required int lamports,
    required String recentBlockhash,
  }) {
    // This is a simplified version
    // In production, use a proper Solana SDK
    
    // Transaction structure:
    // - Header (3 bytes)
    // - Account addresses
    // - Recent blockhash
    // - Instructions
    
    final List<int> transaction = [];
    
    // Header: numRequiredSignatures, numReadonlySignedAccounts, numReadonlyUnsignedAccounts
    transaction.addAll([1, 0, 1]);
    
    // Account addresses (compact array)
    transaction.add(2); // Number of accounts
    transaction.addAll(_base58Decode(fromPubkey));
    transaction.addAll(_base58Decode(toPubkey));
    
    // Recent blockhash (32 bytes)
    transaction.addAll(_base58Decode(recentBlockhash));
    
    // Instructions (compact array)
    transaction.add(1); // Number of instructions
    
    // System Program Transfer instruction
    transaction.add(0); // Program ID index (System Program)
    transaction.add(2); // Number of accounts
    transaction.add(0); // From account index
    transaction.add(1); // To account index
    
    // Instruction data (transfer)
    final instructionData = _encodeTransferInstruction(lamports);
    transaction.add(instructionData.length);
    transaction.addAll(instructionData);
    
    return Uint8List.fromList(transaction);
  }

  /// Build an SPL token transfer transaction
  static Uint8List buildTokenTransfer({
    required String fromPubkey,
    required String toPubkey,
    required String fromTokenAccount,
    required String toTokenAccount,
    required String tokenProgramId,
    required int amount,
    required int decimals,
    required String recentBlockhash,
  }) {
    // Simplified SPL token transfer
    // In production, use @solana/spl-token
    
    final List<int> transaction = [];
    
    // Header
    transaction.addAll([1, 0, 2]);
    
    // Accounts
    transaction.add(5); // Number of accounts
    transaction.addAll(_base58Decode(fromPubkey)); // Payer/signer
    transaction.addAll(_base58Decode(fromTokenAccount)); // Source token account
    transaction.addAll(_base58Decode(toTokenAccount)); // Dest token account
    transaction.addAll(_base58Decode(toPubkey)); // Destination owner
    transaction.addAll(_base58Decode(tokenProgramId)); // Token program
    
    // Recent blockhash
    transaction.addAll(_base58Decode(recentBlockhash));
    
    // Instructions
    transaction.add(1);
    
    // Token Program Transfer instruction
    transaction.add(4); // Program ID index (Token Program)
    transaction.add(4); // Number of accounts
    transaction.add(1); // Source account
    transaction.add(2); // Destination account
    transaction.add(0); // Authority (signer)
    transaction.add(3); // Destination owner
    
    // Instruction data (transfer with amount)
    final instructionData = _encodeTokenTransferInstruction(amount);
    transaction.add(instructionData.length);
    transaction.addAll(instructionData);
    
    return Uint8List.fromList(transaction);
  }

  /// Sign transaction with private key
  static Uint8List signTransaction(
    Uint8List transaction,
    Uint8List signature,
  ) {
    final List<int> signedTx = [];
    
    // Add signature count
    signedTx.add(1);
    
    // Add signature (64 bytes)
    signedTx.addAll(signature);
    
    // Add transaction
    signedTx.addAll(transaction);
    
    return Uint8List.fromList(signedTx);
  }

  /// Encode transfer instruction data
  static List<int> _encodeTransferInstruction(int lamports) {
    // System Program Transfer instruction
    // Instruction index: 2 (Transfer)
    final data = <int>[2, 0, 0, 0]; // Instruction discriminator
    
    // Amount (little-endian u64)
    data.addAll(_encodeU64(lamports));
    
    return data;
  }

  /// Encode token transfer instruction data
  static List<int> _encodeTokenTransferInstruction(int amount) {
    // SPL Token Transfer instruction
    // Instruction index: 3 (Transfer)
    final data = <int>[3];
    
    // Amount (little-endian u64)
    data.addAll(_encodeU64(amount));
    
    return data;
  }

  /// Encode u64 as little-endian bytes
  static List<int> _encodeU64(int value) {
    final bytes = <int>[];
    for (int i = 0; i < 8; i++) {
      bytes.add((value >> (i * 8)) & 0xFF);
    }
    return bytes;
  }

  /// Simple Base58 decode (placeholder - use proper library in production)
  static List<int> _base58Decode(String input) {
    // This is a simplified version
    // In production, use a proper Base58 library
    const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    
    var num = BigInt.zero;
    for (var char in input.split('')) {
      final index = alphabet.indexOf(char);
      if (index == -1) {
        throw FormatException('Invalid Base58 character: $char');
      }
      num = num * BigInt.from(58) + BigInt.from(index);
    }
    
    // Convert to bytes (32 bytes for public keys)
    final bytes = <int>[];
    while (num > BigInt.zero) {
      bytes.insert(0, (num % BigInt.from(256)).toInt());
      num = num ~/ BigInt.from(256);
    }
    
    // Pad to 32 bytes
    while (bytes.length < 32) {
      bytes.insert(0, 0);
    }
    
    return bytes;
  }

  /// Calculate transaction size
  static int calculateTransactionSize(Uint8List transaction) {
    return transaction.length;
  }

  /// Estimate transaction fee (in lamports)
  static int estimateFee({
    int signatures = 1,
    int accountKeys = 2,
    int instructions = 1,
  }) {
    // Simplified fee calculation
    // Base fee: 5000 lamports per signature
    return 5000 * signatures;
  }
}
