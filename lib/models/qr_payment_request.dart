// lib/models/qr_payment_request.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'qr_payment_request.freezed.dart';
part 'qr_payment_request.g.dart';

/// QR Payment Request Model
/// Format: myxen:{base64url_encoded_json}
@freezed
class QrPaymentRequest with _$QrPaymentRequest {
  const QrPaymentRequest._(); // Add private constructor for custom getters
  
  const factory QrPaymentRequest({
    required String t, // type: pay_request | invoice
    required String amount,
    required String pubkey,
    required String ts, // ISO8601 timestamp
    @Default('1') String v, // version
    @Default('MYXN') String token,
    String? memo,
    String? sig, // optional signature (for invoices)
    // ignore: invalid_annotation_target
    @JsonKey(name: 'signer_pubkey') String? signerPubkey,
  }) = _QrPaymentRequest;

  factory QrPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$QrPaymentRequestFromJson(json);
}

extension QrPaymentRequestX on QrPaymentRequest {
  /// Encode to QR string with myxen: prefix
  String toQrString() {
    final json = {
      'v': v,
      't': t,
      'token': token,
      'amount': amount,
      'pubkey': pubkey,
      if (memo != null) 'memo': memo,
      'ts': ts,
      if (sig != null) 'sig': sig,
      if (signerPubkey != null) 'signer_pubkey': signerPubkey,
    };

    final jsonString = jsonEncode(json);
    final bytes = utf8.encode(jsonString);
    final base64url = base64UrlEncode(bytes).replaceAll('=', '');

    return 'myxen:$base64url';
  }

  /// Parse from QR string
  static QrPaymentRequest fromQrString(String qrString) {
    if (!qrString.startsWith('myxen:')) {
      throw const FormatException('Invalid QR format: must start with myxen:');
    }

    final base64url = qrString.substring(6);
    
    // Add padding if needed
    var padded = base64url;
    while (padded.length % 4 != 0) {
      padded += '=';
    }

    final bytes = base64Url.decode(padded);
    final jsonString = utf8.decode(bytes);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    return QrPaymentRequest.fromJson(json);
  }

  /// Check if this is a merchant invoice (requires signature)
  bool get isInvoice => t == 'invoice';

  /// Check if signature is present
  bool get isSigned => sig != null && signerPubkey != null;

  /// Get amount as double
  double get amountValue => double.tryParse(amount) ?? 0.0;
}

/// Create a payment request
QrPaymentRequest createPaymentRequest({
  required String publicKey,
  required double amount,
  String? memo,
}) {
  return QrPaymentRequest(
    t: 'pay_request',
    amount: amount.toString(),
    pubkey: publicKey,
    memo: memo,
    ts: DateTime.now().toIso8601String(),
  );
}

/// Create a merchant invoice (requires signing)
QrPaymentRequest createMerchantInvoice({
  required String publicKey,
  required double amount,
  required String signature,
  required String signerPublicKey,
  String? memo,
}) {
  return QrPaymentRequest(
    t: 'invoice',
    amount: amount.toString(),
    pubkey: publicKey,
    memo: memo,
    ts: DateTime.now().toIso8601String(),
    sig: signature,
    signerPubkey: signerPublicKey,
  );
}
