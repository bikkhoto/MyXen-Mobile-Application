// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QrPaymentRequestImpl _$$QrPaymentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$QrPaymentRequestImpl(
      t: json['t'] as String,
      amount: json['amount'] as String,
      pubkey: json['pubkey'] as String,
      ts: json['ts'] as String,
      v: json['v'] as String? ?? '1',
      token: json['token'] as String? ?? 'MYXN',
      memo: json['memo'] as String?,
      sig: json['sig'] as String?,
      signerPubkey: json['signer_pubkey'] as String?,
    );

Map<String, dynamic> _$$QrPaymentRequestImplToJson(
        _$QrPaymentRequestImpl instance) =>
    <String, dynamic>{
      't': instance.t,
      'amount': instance.amount,
      'pubkey': instance.pubkey,
      'ts': instance.ts,
      'v': instance.v,
      'token': instance.token,
      'memo': instance.memo,
      'sig': instance.sig,
      'signer_pubkey': instance.signerPubkey,
    };
