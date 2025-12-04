// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QrPaymentRequestImpl _$$QrPaymentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$QrPaymentRequestImpl(
      v: json['v'] as String? ?? '1',
      t: json['t'] as String,
      token: json['token'] as String? ?? 'MYXN',
      amount: json['amount'] as String,
      pubkey: json['pubkey'] as String,
      memo: json['memo'] as String?,
      ts: json['ts'] as String,
      sig: json['sig'] as String?,
      signerPubkey: json['signer_pubkey'] as String?,
    );

Map<String, dynamic> _$$QrPaymentRequestImplToJson(
        _$QrPaymentRequestImpl instance) =>
    <String, dynamic>{
      'v': instance.v,
      't': instance.t,
      'token': instance.token,
      'amount': instance.amount,
      'pubkey': instance.pubkey,
      'memo': instance.memo,
      'ts': instance.ts,
      'sig': instance.sig,
      'signer_pubkey': instance.signerPubkey,
    };
