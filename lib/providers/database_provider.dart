// lib/providers/database_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/database.dart';

/// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

/// Transaction History Stream Provider
final transactionHistoryProvider = StreamProvider.family<List<Transaction>, String>(
  (ref, address) {
    final database = ref.watch(databaseProvider);
    return database
        .select(database.transactions)
        .watch()
        .map((transactions) => transactions
            .where((t) => t.fromAddress == address || t.toAddress == address)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));
  },
);

/// Active Wallet Account Provider
final activeWalletProvider = FutureProvider<WalletAccount?>((ref) async {
  final database = ref.watch(databaseProvider);
  return await database.getActiveWalletAccount();
});
