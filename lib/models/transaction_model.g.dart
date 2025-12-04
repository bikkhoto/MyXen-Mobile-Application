// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionModelImpl(
      signature: json['signature'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      amount: (json['amount'] as num).toDouble(),
      token: json['token'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      memo: json['memo'] as String?,
      blockTime: (json['blockTime'] as num?)?.toInt(),
      slot: (json['slot'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TransactionModelImplToJson(
        _$TransactionModelImpl instance) =>
    <String, dynamic>{
      'signature': instance.signature,
      'from': instance.from,
      'to': instance.to,
      'amount': instance.amount,
      'token': instance.token,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'memo': instance.memo,
      'blockTime': instance.blockTime,
      'slot': instance.slot,
      'fee': instance.fee,
    };

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.confirmed: 'confirmed',
  TransactionStatus.finalized: 'finalized',
  TransactionStatus.failed: 'failed',
};
