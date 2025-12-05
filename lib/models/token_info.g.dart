// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenInfoImpl _$$TokenInfoImplFromJson(Map<String, dynamic> json) =>
    _$TokenInfoImpl(
      mintAddress: json['mintAddress'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      decimals: (json['decimals'] as num).toInt(),
      iconUrl: json['iconUrl'] as String?,
      description: json['description'] as String?,
      externalUrl: json['externalUrl'] as String?,
      metadataUri: json['metadataUri'] as String?,
      totalSupply: (json['totalSupply'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TokenInfoImplToJson(_$TokenInfoImpl instance) =>
    <String, dynamic>{
      'mintAddress': instance.mintAddress,
      'symbol': instance.symbol,
      'name': instance.name,
      'decimals': instance.decimals,
      'iconUrl': instance.iconUrl,
      'description': instance.description,
      'externalUrl': instance.externalUrl,
      'metadataUri': instance.metadataUri,
      'totalSupply': instance.totalSupply,
    };

_$TokenBalanceImpl _$$TokenBalanceImplFromJson(Map<String, dynamic> json) =>
    _$TokenBalanceImpl(
      token: TokenInfo.fromJson(json['token'] as Map<String, dynamic>),
      balance: (json['balance'] as num).toDouble(),
      tokenAccountAddress: json['tokenAccountAddress'] as String,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$TokenBalanceImplToJson(_$TokenBalanceImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'balance': instance.balance,
      'tokenAccountAddress': instance.tokenAccountAddress,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
