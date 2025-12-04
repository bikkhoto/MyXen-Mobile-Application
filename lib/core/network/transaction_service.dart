// lib/core/network/transaction_service.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:convert/convert.dart';
import '../crypto/key_manager.dart';
import '../crypto/signer.dart';
import 'solana_client.dart';
import 'solana_transaction_builder.dart';
import 'api_config.dart';

/// Transaction Service
/// 
/// Handles transaction creation, signing, and broadcasting
class TransactionService {
  final SolanaClient _client;
  final KeyManager _keyManager;
  late final Signer _signer;

  TransactionService({
    required SolanaClient client,
    required KeyManager keyManager,
  })  : _client = client,
        _keyManager = keyManager {
    _signer = Signer(_keyManager);
  }

  /// Send SOL transfer
  Future<String> sendSol({
    required String fromPubkey,
    required String toPubkey,
    required double amount,
    String? pin,
  }) async {
    try {
      // Convert SOL to lamports
      final lamports = (amount * 1000000000).toInt();

      // Get recent blockhash
      final blockhash = await _client.getRecentBlockhash();

      // Build transaction
      final transaction = SolanaTransactionBuilder.buildSolTransfer(
        fromPubkey: fromPubkey,
        toPubkey: toPubkey,
        lamports: lamports,
        recentBlockhash: blockhash,
      );

      // Sign transaction
      final signature = await _signer.sign(transaction, pin: pin);
      if (signature == null) {
        throw Exception('Failed to sign transaction');
      }

      // Create signed transaction
      final signedTx = SolanaTransactionBuilder.signTransaction(
        transaction,
        signature,
      );

      // Encode to base64
      final encodedTx = base64Encode(signedTx);

      // Broadcast transaction
      final txSignature = await _client.sendTransaction(encodedTx);

      // Confirm transaction
      final confirmed = await _client.confirmTransaction(txSignature);
      if (!confirmed) {
        throw Exception('Transaction confirmation timeout');
      }

      return txSignature;
    } catch (e) {
      throw Exception('Failed to send SOL: $e');
    }
  }

  /// Send MYXN token transfer
  Future<String> sendMyxn({
    required String fromPubkey,
    required String toPubkey,
    required String fromTokenAccount,
    required String toTokenAccount,
    required double amount,
    String? pin,
  }) async {
    try {
      // Convert amount to smallest unit (9 decimals)
      final tokenAmount = (amount * 1000000000).toInt();

      // Get recent blockhash
      final blockhash = await _client.getRecentBlockhash();

      // Build token transfer transaction
      final transaction = SolanaTransactionBuilder.buildTokenTransfer(
        fromPubkey: fromPubkey,
        toPubkey: toPubkey,
        fromTokenAccount: fromTokenAccount,
        toTokenAccount: toTokenAccount,
        tokenProgramId: 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA', // SPL Token Program
        amount: tokenAmount,
        decimals: ApiConfig.myxnDecimals,
        recentBlockhash: blockhash,
      );

      // Sign transaction
      final signature = await _signer.sign(transaction, pin: pin);
      if (signature == null) {
        throw Exception('Failed to sign transaction');
      }

      // Create signed transaction
      final signedTx = SolanaTransactionBuilder.signTransaction(
        transaction,
        signature,
      );

      // Encode to base64
      final encodedTx = base64Encode(signedTx);

      // Broadcast transaction
      final txSignature = await _client.sendTransaction(encodedTx);

      // Confirm transaction
      final confirmed = await _client.confirmTransaction(
        txSignature,
        timeout: ApiConfig.confirmationTimeout,
      );

      if (!confirmed) {
        throw Exception('Transaction confirmation timeout');
      }

      return txSignature;
    } catch (e) {
      throw Exception('Failed to send MYXN: $e');
    }
  }

  /// Get or create token account for recipient
  Future<String> getOrCreateTokenAccount({
    required String ownerPubkey,
    required String tokenMint,
    String? pin,
  }) async {
    try {
      // Check if token account exists
      final accounts = await _client.getTokenAccountsByOwner(
        ownerPubkey,
        tokenMint,
      );

      if (accounts.isNotEmpty) {
        return accounts.first['pubkey'] as String;
      }

      // Token account doesn't exist - would need to create it
      // This requires additional transaction
      throw Exception('Recipient token account does not exist');
    } catch (e) {
      throw Exception('Failed to get token account: $e');
    }
  }

  /// Estimate transaction fee
  Future<int> estimateFee({
    required String fromPubkey,
    required String toPubkey,
    bool isTokenTransfer = false,
  }) async {
    try {
      // Get minimum rent exemption for account
      final rentExemption = await _client.getMinimumBalanceForRentExemption(
        isTokenTransfer ? 165 : 0, // Token account size
      );

      // Calculate transaction fee
      final txFee = SolanaTransactionBuilder.estimateFee(
        signatures: 1,
        accountKeys: isTokenTransfer ? 5 : 2,
        instructions: 1,
      );

      return txFee + (isTokenTransfer ? rentExemption : 0);
    } catch (e) {
      // Return default fee if estimation fails
      return ApiConfig.defaultPriorityFee;
    }
  }

  /// Validate transaction before sending
  Future<bool> validateTransaction({
    required String fromPubkey,
    required String toPubkey,
    required double amount,
    bool isTokenTransfer = false,
  }) async {
    try {
      // Check sender balance
      final balance = isTokenTransfer
          ? await _getTokenBalance(fromPubkey)
          : await _getSolBalance(fromPubkey);

      if (balance < amount) {
        throw Exception('Insufficient balance');
      }

      // Check recipient address validity
      if (toPubkey.length < 32) {
        throw Exception('Invalid recipient address');
      }

      // Estimate fee
      final fee = await estimateFee(
        fromPubkey: fromPubkey,
        toPubkey: toPubkey,
        isTokenTransfer: isTokenTransfer,
      );

      // Check if sender has enough for fee
      final solBalance = await _getSolBalance(fromPubkey);
      if (solBalance < fee / 1000000000) {
        throw Exception('Insufficient SOL for transaction fee');
      }

      return true;
    } catch (e) {
      throw Exception('Transaction validation failed: $e');
    }
  }

  /// Get SOL balance in SOL (not lamports)
  Future<double> _getSolBalance(String pubkey) async {
    final lamports = await _client.getBalance(pubkey);
    return lamports / 1000000000;
  }

  /// Get token balance
  Future<double> _getTokenBalance(String pubkey) async {
    try {
      final accounts = await _client.getTokenAccountsByOwner(
        pubkey,
        ApiConfig.myxnTokenMint,
      );

      if (accounts.isEmpty) return 0.0;

      final tokenAccount = accounts.first['pubkey'] as String;
      return await _client.getTokenBalance(tokenAccount);
    } catch (e) {
      return 0.0;
    }
  }
}
