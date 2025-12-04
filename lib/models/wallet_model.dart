// lib/models/wallet_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

@freezed
class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String publicKey,
    required double balance,
    required double myxnBalance,
    required DateTime lastUpdated,
    String? tokenAccountAddress,
  }) = _WalletModel;

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);
}

extension WalletModelX on WalletModel? {
  /// Convert lamports to SOL
  double get solBalance => (this?.balance ?? 0) / 1000000000;

  /// Get formatted balance
  String get formattedBalance => (this?.myxnBalance ?? 0.0).toStringAsFixed(2);

  /// Get formatted SOL balance
  String get formattedSolBalance => solBalance.toStringAsFixed(4);
}
