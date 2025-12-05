// lib/models/token_info.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_info.freezed.dart';
part 'token_info.g.dart';

/// Token information model for SPL tokens
@freezed
class TokenInfo with _$TokenInfo {
  const factory TokenInfo({
    required String mintAddress,
    required String symbol,
    required String name,
    required int decimals,
    String? iconUrl,
    String? description,
    String? externalUrl,
    String? metadataUri,
    int? totalSupply,
  }) = _TokenInfo;

  factory TokenInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenInfoFromJson(json);
}

/// Token balance model
@freezed
class TokenBalance with _$TokenBalance {
  const factory TokenBalance({
    required TokenInfo token,
    required double balance,
    required String tokenAccountAddress,
    DateTime? lastUpdated,
  }) = _TokenBalance;

  factory TokenBalance.fromJson(Map<String, dynamic> json) =>
      _$TokenBalanceFromJson(json);
}

/// Extension for formatting token balances
extension TokenBalanceX on TokenBalance {
  /// Get formatted balance string
  String get formattedBalance => balance.toStringAsFixed(2);
  
  /// Get balance with symbol
  String get displayBalance => '$formattedBalance ${token.symbol}';
  
  /// Check if balance is zero
  bool get isEmpty => balance <= 0;
  
  /// Check if balance is positive
  bool get hasBalance => balance > 0;
}

/// Official MYXN Token Information
class MyxnToken {
  static const TokenInfo info = TokenInfo(
    mintAddress: '3NVKYBqjuhLzk5FQNBhcExkruJ7qcaZizkD7Q7veyHGH',
    symbol: 'MYXN',
    name: 'MyXen',
    decimals: 9,
    iconUrl: 'https://ipfs.io/ipfs/bafkreiholwopitkccosr6ebn42frwmpwlzel2c4fcl6wdsvk6y7rwx337a',
    description: 'MYXN — The native decentralized utility token of the MyXenPay ecosystem, '
        'powering merchant settlements, university integrations, staking, burns, '
        'and cross-chain expansion.',
    externalUrl: 'https://myxenpay.finance',
    metadataUri: 'ipfs://bafkreiholwopitkccosr6ebn42frwmpwlzel2c4fcl6wdsvk6y7rwx337a',
    totalSupply: 1000000000,
  );
  
  /// Convert raw token amount to display amount
  static double rawToDisplay(int rawAmount) {
    return rawAmount / 1000000000; // 10^9 decimals
  }
  
  /// Convert display amount to raw token amount
  static int displayToRaw(double displayAmount) {
    return (displayAmount * 1000000000).round();
  }
}
