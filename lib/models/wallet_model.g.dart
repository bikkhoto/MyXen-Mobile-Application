// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletModelImpl _$$WalletModelImplFromJson(Map<String, dynamic> json) =>
    _$WalletModelImpl(
      publicKey: json['publicKey'] as String,
      balance: (json['balance'] as num).toDouble(),
      myxnBalance: (json['myxnBalance'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      tokenAccountAddress: json['tokenAccountAddress'] as String?,
    );

Map<String, dynamic> _$$WalletModelImplToJson(_$WalletModelImpl instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'balance': instance.balance,
      'myxnBalance': instance.myxnBalance,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'tokenAccountAddress': instance.tokenAccountAddress,
    };
