import 'dart:math';
// lib/core/services/token_service.dart
import 'package:flutter/foundation.dart';
import '../network/api_config.dart';
import '../network/solana_client.dart';

/// Service for MYXN token operations on Solana blockchain
class TokenService {
  final SolanaClient _client;
  
  TokenService({required SolanaClient client}) : _client = client;
  
  // ─────────────────────────────────────────────────────────────────────────────
  // BALANCE OPERATIONS
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Get MYXN token balance for a wallet address
  /// Returns the balance in display format (not raw token units)
  Future<double> getMyxnBalance(String walletAddress) async {
    try {
      final tokenAccounts = await _client.getTokenAccountsByOwner(
        walletAddress,
        ApiConfig.myxnTokenMint,
      );
      
      if (tokenAccounts.isEmpty) {
        debugPrint('No MYXN token account found for $walletAddress');
        return 0.0;
      }
      
      final tokenAccountAddress = tokenAccounts.first['pubkey'] as String;
      return await _client.getTokenBalance(tokenAccountAddress);
    } catch (e) {
      debugPrint('Error getting MYXN balance: $e');
      return 0.0;
    }
  }
  
  /// Get SOL balance for a wallet address
  /// Returns balance in SOL (not lamports)
  Future<double> getSolBalance(String walletAddress) async {
    try {
      final lamports = await _client.getBalance(walletAddress);
      return ApiConfig.lamportsToSol(lamports);
    } catch (e) {
      debugPrint('Error getting SOL balance: $e');
      return 0.0;
    }
  }
  
  /// Get combined wallet balances (SOL + MYXN)
  Future<WalletBalances> getWalletBalances(String walletAddress) async {
    try {
      final solBalance = await getSolBalance(walletAddress);
      final myxnBalance = await getMyxnBalance(walletAddress);
      final tokenAccountAddress = await getTokenAccountAddress(walletAddress);
      
      return WalletBalances(
        solBalance: solBalance,
        myxnBalance: myxnBalance,
        tokenAccountAddress: tokenAccountAddress,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting wallet balances: $e');
      rethrow;
    }
  }
  
  /// Get token account address for MYXN
  Future<String?> getTokenAccountAddress(String walletAddress) async {
    try {
      final tokenAccounts = await _client.getTokenAccountsByOwner(
        walletAddress,
        ApiConfig.myxnTokenMint,
      );
      
      if (tokenAccounts.isEmpty) return null;
      return tokenAccounts.first['pubkey'] as String;
    } catch (e) {
      debugPrint('Error getting token account address: $e');
      return null;
    }
  }
  
  /// Check if wallet has a MYXN token account
  Future<bool> hasTokenAccount(String walletAddress) async {
    final address = await getTokenAccountAddress(walletAddress);
    return address != null;
  }
  
  // ─────────────────────────────────────────────────────────────────────────────
  // TOKEN INFORMATION
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Get MYXN token supply information
  Future<TokenSupplyInfo> getTokenSupply() async {
    try {
      final accountInfo = await _client.getAccountInfo(ApiConfig.myxnTokenMint);
      
      if (accountInfo == null) {
        throw Exception('Token mint account not found');
      }
      
      // Parse token supply from account data
      final data = accountInfo['data'];
      if (data is Map && data['parsed'] != null) {
        final info = data['parsed']['info'];
        final supply = int.parse(info['supply'] as String);
        final decimals = info['decimals'] as int;
        
        return TokenSupplyInfo(
          rawSupply: supply,
          displaySupply: supply / pow(10, decimals),
          decimals: decimals,
          mintAuthority: info['mintAuthority'] as String?,
          freezeAuthority: info['freezeAuthority'] as String?,
        );
      }
      
      throw Exception('Invalid token account data');
    } catch (e) {
      debugPrint('Error getting token supply: $e');
      rethrow;
    }
  }
  
  // ─────────────────────────────────────────────────────────────────────────────
  // OFFICIAL WALLET OPERATIONS
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Get Treasury wallet MYXN balance
  Future<double> getTreasuryBalance() async {
    return getMyxnBalance(ApiConfig.treasuryWallet);
  }
  
  /// Get Burn wallet MYXN balance (burned tokens)
  Future<double> getBurnedTokens() async {
    return getMyxnBalance(ApiConfig.burnWallet);
  }
  
  /// Get Charity wallet MYXN balance
  Future<double> getCharityBalance() async {
    return getMyxnBalance(ApiConfig.charityWallet);
  }
  
  /// Get circulating supply (excluding burn wallet)
  Future<double> getCirculatingSupply() async {
    try {
      final supplyInfo = await getTokenSupply();
      final burnedTokens = await getBurnedTokens();
      return supplyInfo.displaySupply - burnedTokens;
    } catch (e) {
      debugPrint('Error calculating circulating supply: $e');
      return 0.0;
    }
  }
  
  // ─────────────────────────────────────────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Validate a Solana address format
  bool isValidAddress(String address) {
    // Basic validation: Base58 characters, 32-44 characters length
    if (address.length < 32 || address.length > 44) return false;
    
    // Check for valid Base58 characters
    final base58Regex = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
    return base58Regex.hasMatch(address);
  }
  
  /// Check if an address is an official MyXen wallet
  bool isOfficialWallet(String address) {
    return ApiConfig.isOfficialWallet(address);
  }
  
  /// Get label for official wallets
  String? getWalletLabel(String address) {
    return ApiConfig.getOfficialWalletLabel(address);
  }
}

/// Combined wallet balances
class WalletBalances {
  final double solBalance;
  final double myxnBalance;
  final String? tokenAccountAddress;
  final DateTime lastUpdated;
  
  const WalletBalances({
    required this.lastUpdated,
    required this.myxnBalance,
    required this.solBalance,
    this.tokenAccountAddress,
  });
  
  /// Check if wallet has SOL for transaction fees
  bool get hasSolForFees => solBalance >= 0.01;
  
  /// Check if wallet has any MYXN tokens
  bool get hasMyxn => myxnBalance > 0;
  
  /// Formatted SOL balance
  String get formattedSol => solBalance.toStringAsFixed(4);
  
  /// Formatted MYXN balance
  String get formattedMyxn => myxnBalance.toStringAsFixed(2);
  
  /// Display balance with symbol
  String get myxnDisplay => '$formattedMyxn MYXN';
  
  /// Display SOL balance with symbol
  String get solDisplay => '$formattedSol SOL';
}

/// Token supply information
class TokenSupplyInfo {
  final int rawSupply;
  final double displaySupply;
  final int decimals;
  final String? mintAuthority;
  final String? freezeAuthority;
  
  const TokenSupplyInfo({
    required this.displaySupply,
    required this.rawSupply,
    required this.decimals,
    this.mintAuthority,
    this.freezeAuthority,
  });
  
  /// Check if mint authority is revoked
  bool get isMintAuthorityRevoked => mintAuthority == null;
  
  /// Check if freeze authority is revoked
  bool get isFreezeAuthorityRevoked => freezeAuthority == null;
  
  /// Total supply in billions
  String get supplyInBillions => '${(displaySupply / 1000000000).toStringAsFixed(2)}B';
}
