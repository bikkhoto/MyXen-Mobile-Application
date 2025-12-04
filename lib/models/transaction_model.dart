// lib/models/transaction_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String signature,
    required String from,
    required String to,
    required double amount,
    required String token,
    required DateTime timestamp,
    required TransactionStatus status,
    String? memo,
    int? blockTime,
    int? slot,
    double? fee,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

enum TransactionStatus {
  pending,
  confirmed,
  finalized,
  failed,
}

extension TransactionStatusX on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.confirmed:
        return 'Confirmed';
      case TransactionStatus.finalized:
        return 'Finalized';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  bool get isCompleted =>
      this == TransactionStatus.confirmed || this == TransactionStatus.finalized;

  bool get isFailed => this == TransactionStatus.failed;
}
