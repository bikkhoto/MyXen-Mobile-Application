// lib/providers/transaction_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import 'wallet_provider.dart';

/// Transaction History Provider
final transactionHistoryProvider =
    FutureProvider.family<List<TransactionModel>, String>((ref, publicKey) async {
  final client = ref.watch(solanaClientProvider);

  try {
    final signatures = await client.getSignaturesForAddress(
      publicKey,
      limit: 50,
    );

    final transactions = <TransactionModel>[];

    for (final sig in signatures) {
      try {
        final signature = sig['signature'] as String;
        final blockTime = sig['blockTime'] as int?;
        final slot = sig['slot'] as int?;
        final err = sig['err'];

        // Get transaction details
        final txDetails = await client.getTransaction(signature);

        if (txDetails != null) {
          // Parse transaction (simplified - needs proper parsing)
          final meta = txDetails['meta'] as Map<String, dynamic>?;
          final transaction = txDetails['transaction'] as Map<String, dynamic>?;

          if (meta != null && transaction != null) {
            final fee = meta['fee'] as int?;
            final status = err == null
                ? TransactionStatus.finalized
                : TransactionStatus.failed;

            // Extract from/to/amount (simplified)
            final message = transaction['message'] as Map<String, dynamic>?;
            final accountKeys = message?['accountKeys'] as List?;

            final from = accountKeys?.isNotEmpty == true
                ? accountKeys![0] as String
                : publicKey;
            final to = (accountKeys?.length ?? 0) > 1
                ? accountKeys![1] as String
                : publicKey;

            transactions.add(
              TransactionModel(
                signature: signature,
                from: from,
                to: to,
                amount: 0.0, // TODO: Parse actual amount
                token: 'MYXN',
                timestamp: blockTime != null
                    ? DateTime.fromMillisecondsSinceEpoch(blockTime * 1000)
                    : DateTime.now(),
                status: status,
                blockTime: blockTime,
                slot: slot,
                fee: fee?.toDouble(),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error parsing transaction: $e');
      }
    }

    return transactions;
  } catch (e) {
    throw Exception('Failed to fetch transaction history: $e');
  }
});

/// Refresh transaction history
final refreshTransactionsProvider = Provider<void Function(String)>((ref) {
  return (String publicKey) {
    ref.invalidate(transactionHistoryProvider(publicKey));
  };
});
