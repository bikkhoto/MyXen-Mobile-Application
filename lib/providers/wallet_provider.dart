// lib/providers/wallet_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/crypto/key_manager.dart';
import '../core/network/solana_client.dart';
import '../core/network/api_config.dart';
import '../core/services/token_service.dart';
import '../models/wallet_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CORE PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Key Manager Provider - Secure key storage and retrieval
final keyManagerProvider = Provider<KeyManager>((ref) {
  return KeyManager();
});

/// Solana Client Provider - RPC client for blockchain operations
final solanaClientProvider = Provider<SolanaClient>((ref) {
  return SolanaClient(rpcUrl: ApiConfig.currentRpc);
});

/// Token Service Provider - MYXN token operations
final tokenServiceProvider = Provider<TokenService>((ref) {
  final client = ref.watch(solanaClientProvider);
  return TokenService(client: client);
});

// ─────────────────────────────────────────────────────────────────────────────
// WALLET STATE PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Current Wallet Public Key Provider
final walletPublicKeyProvider = StateProvider<String?>((ref) => null);

/// Wallet initialization state
final walletInitializedProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// BALANCE PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Wallet Balance Provider - Fetches SOL and MYXN balances
final walletBalanceProvider = FutureProvider<WalletModel?>((ref) async {
  final publicKey = ref.watch(walletPublicKeyProvider);
  if (publicKey == null) return null;

  final tokenService = ref.watch(tokenServiceProvider);

  try {
    // Get combined balances
    final balances = await tokenService.getWalletBalances(publicKey);

    return WalletModel(
      publicKey: publicKey,
      balance: ApiConfig.solToLamports(balances.solBalance).toDouble(),
      myxnBalance: balances.myxnBalance,
      lastUpdated: balances.lastUpdated,
      tokenAccountAddress: balances.tokenAccountAddress,
    );
  } catch (e) {
    debugPrint('Failed to fetch wallet balance: $e');
    throw Exception('Failed to fetch wallet balance: $e');
  }
});

/// SOL Balance Provider - Just SOL balance
final solBalanceProvider = FutureProvider<double>((ref) async {
  final publicKey = ref.watch(walletPublicKeyProvider);
  if (publicKey == null) return 0.0;

  final tokenService = ref.watch(tokenServiceProvider);
  return tokenService.getSolBalance(publicKey);
});

/// MYXN Balance Provider - Just MYXN token balance
final myxnBalanceProvider = FutureProvider<double>((ref) async {
  final publicKey = ref.watch(walletPublicKeyProvider);
  if (publicKey == null) return 0.0;

  final tokenService = ref.watch(tokenServiceProvider);
  return tokenService.getMyxnBalance(publicKey);
});

// ─────────────────────────────────────────────────────────────────────────────
// TOKEN INFORMATION PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// MYXN Token Supply Provider
final tokenSupplyProvider = FutureProvider<TokenSupplyInfo>((ref) async {
  final tokenService = ref.watch(tokenServiceProvider);
  return tokenService.getTokenSupply();
});

/// Circulating Supply Provider (excluding burned tokens)
final circulatingSupplyProvider = FutureProvider<double>((ref) async {
  final tokenService = ref.watch(tokenServiceProvider);
  return tokenService.getCirculatingSupply();
});

/// Burned Tokens Provider
final burnedTokensProvider = FutureProvider<double>((ref) async {
  final tokenService = ref.watch(tokenServiceProvider);
  return tokenService.getBurnedTokens();
});

// ─────────────────────────────────────────────────────────────────────────────
// OFFICIAL WALLET BALANCE PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Treasury Balance Provider
final treasuryBalanceProvider = FutureProvider<double>((ref) async {
  final tokenService = ref.watch(tokenServiceProvider);
  return tokenService.getTreasuryBalance();
});

/// Charity Balance Provider
final charityBalanceProvider = FutureProvider<double>((ref) async {
  final tokenService = ref.watch(tokenServiceProvider);
  return tokenService.getCharityBalance();
});

// ─────────────────────────────────────────────────────────────────────────────
// REFRESH PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Refresh wallet balance
final refreshWalletProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(walletBalanceProvider);
    ref.invalidate(solBalanceProvider);
    ref.invalidate(myxnBalanceProvider);
  };
});

/// Refresh all token data
final refreshAllTokenDataProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(walletBalanceProvider);
    ref.invalidate(solBalanceProvider);
    ref.invalidate(myxnBalanceProvider);
    ref.invalidate(tokenSupplyProvider);
    ref.invalidate(circulatingSupplyProvider);
    ref.invalidate(burnedTokensProvider);
    ref.invalidate(treasuryBalanceProvider);
    ref.invalidate(charityBalanceProvider);
  };
});

// ─────────────────────────────────────────────────────────────────────────────
// UTILITY PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Check if wallet has enough SOL for fees
final hasSolForFeesProvider = Provider<bool>((ref) {
  final balanceAsync = ref.watch(walletBalanceProvider);
  return balanceAsync.maybeWhen(
    data: (wallet) => wallet != null && wallet.solBalance >= 0.01,
    orElse: () => false,
  );
});

/// Check if wallet has MYXN tokens
final hasMyxnProvider = Provider<bool>((ref) {
  final balanceAsync = ref.watch(walletBalanceProvider);
  return balanceAsync.maybeWhen(
    data: (wallet) => wallet != null && wallet.myxnBalance > 0,
    orElse: () => false,
  );
});

/// Token account exists provider
final hasTokenAccountProvider = FutureProvider<bool>((ref) async {
  final publicKey = ref.watch(walletPublicKeyProvider);
  if (publicKey == null) return false;

  final tokenService = ref.watch(tokenServiceProvider);
  return tokenService.hasTokenAccount(publicKey);
});

// ─────────────────────────────────────────────────────────────────────────────
// NETWORK CONFIGURATION PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Current network provider (mainnet/devnet)
final currentNetworkProvider = Provider<String>((ref) {
  return ApiConfig.solanaCluster;
});

/// Is production network provider
final isProductionProvider = Provider<bool>((ref) {
  return ApiConfig.isProduction;
});

/// Current RPC URL provider
final currentRpcUrlProvider = Provider<String>((ref) {
  return ApiConfig.currentRpc;
});
