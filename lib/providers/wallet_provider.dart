// lib/providers/wallet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/crypto/key_manager.dart';
import '../core/network/solana_client.dart';
import '../core/network/api_config.dart';
import '../models/wallet_model.dart';

/// Key Manager Provider
final keyManagerProvider = Provider<KeyManager>((ref) {
  return KeyManager();
});

/// Solana Client Provider
final solanaClientProvider = Provider<SolanaClient>((ref) {
  return SolanaClient(rpcUrl: ApiConfig.rpcUrl);
});

/// Current Wallet Public Key Provider
final walletPublicKeyProvider = StateProvider<String?>((ref) => null);

/// Wallet Balance Provider
final walletBalanceProvider = FutureProvider<WalletModel?>((ref) async {
  final publicKey = ref.watch(walletPublicKeyProvider);
  if (publicKey == null) return null;

  final client = ref.watch(solanaClientProvider);

  try {
    // Get SOL balance
    final solBalance = await client.getBalance(publicKey);

    // Get MYXN token balance
    double myxnBalance = 0.0;
    try {
      final tokenAccounts = await client.getTokenAccountsByOwner(
        publicKey,
        ApiConfig.myxnTokenMint,
      );

      if (tokenAccounts.isNotEmpty) {
        final tokenAccount = tokenAccounts.first;
        final tokenAccountAddress = tokenAccount['pubkey'] as String;
        myxnBalance = await client.getTokenBalance(tokenAccountAddress);
      }
    } catch (e) {
      // Token account might not exist yet
      print('No MYXN token account: $e');
    }

    return WalletModel(
      publicKey: publicKey,
      balance: solBalance.toDouble(),
      myxnBalance: myxnBalance,
      lastUpdated: DateTime.now(),
    );
  } catch (e) {
    throw Exception('Failed to fetch wallet balance: $e');
  }
});

/// Refresh wallet balance
final refreshWalletProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(walletBalanceProvider);
  };
});
