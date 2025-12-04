// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_payment_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QrPaymentRequest _$QrPaymentRequestFromJson(Map<String, dynamic> json) {
  return _QrPaymentRequest.fromJson(json);
}

/// @nodoc
mixin _$QrPaymentRequest {
  String get v => throw _privateConstructorUsedError; // version
  String get t =>
      throw _privateConstructorUsedError; // type: pay_request | invoice
  String get token => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;
  String get pubkey => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  String get ts => throw _privateConstructorUsedError; // ISO8601 timestamp
  String? get sig =>
      throw _privateConstructorUsedError; // optional signature (for invoices)
  @JsonKey(name: 'signer_pubkey')
  String? get signerPubkey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QrPaymentRequestCopyWith<QrPaymentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrPaymentRequestCopyWith<$Res> {
  factory $QrPaymentRequestCopyWith(
          QrPaymentRequest value, $Res Function(QrPaymentRequest) then) =
      _$QrPaymentRequestCopyWithImpl<$Res, QrPaymentRequest>;
  @useResult
  $Res call(
      {String v,
      String t,
      String token,
      String amount,
      String pubkey,
      String? memo,
      String ts,
      String? sig,
      @JsonKey(name: 'signer_pubkey') String? signerPubkey});
}

/// @nodoc
class _$QrPaymentRequestCopyWithImpl<$Res, $Val extends QrPaymentRequest>
    implements $QrPaymentRequestCopyWith<$Res> {
  _$QrPaymentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? v = null,
    Object? t = null,
    Object? token = null,
    Object? amount = null,
    Object? pubkey = null,
    Object? memo = freezed,
    Object? ts = null,
    Object? sig = freezed,
    Object? signerPubkey = freezed,
  }) {
    return _then(_value.copyWith(
      v: null == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as String,
      t: null == t
          ? _value.t
          : t // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      pubkey: null == pubkey
          ? _value.pubkey
          : pubkey // ignore: cast_nullable_to_non_nullable
              as String,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      ts: null == ts
          ? _value.ts
          : ts // ignore: cast_nullable_to_non_nullable
              as String,
      sig: freezed == sig
          ? _value.sig
          : sig // ignore: cast_nullable_to_non_nullable
              as String?,
      signerPubkey: freezed == signerPubkey
          ? _value.signerPubkey
          : signerPubkey // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QrPaymentRequestImplCopyWith<$Res>
    implements $QrPaymentRequestCopyWith<$Res> {
  factory _$$QrPaymentRequestImplCopyWith(_$QrPaymentRequestImpl value,
          $Res Function(_$QrPaymentRequestImpl) then) =
      __$$QrPaymentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String v,
      String t,
      String token,
      String amount,
      String pubkey,
      String? memo,
      String ts,
      String? sig,
      @JsonKey(name: 'signer_pubkey') String? signerPubkey});
}

/// @nodoc
class __$$QrPaymentRequestImplCopyWithImpl<$Res>
    extends _$QrPaymentRequestCopyWithImpl<$Res, _$QrPaymentRequestImpl>
    implements _$$QrPaymentRequestImplCopyWith<$Res> {
  __$$QrPaymentRequestImplCopyWithImpl(_$QrPaymentRequestImpl _value,
      $Res Function(_$QrPaymentRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? v = null,
    Object? t = null,
    Object? token = null,
    Object? amount = null,
    Object? pubkey = null,
    Object? memo = freezed,
    Object? ts = null,
    Object? sig = freezed,
    Object? signerPubkey = freezed,
  }) {
    return _then(_$QrPaymentRequestImpl(
      v: null == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as String,
      t: null == t
          ? _value.t
          : t // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      pubkey: null == pubkey
          ? _value.pubkey
          : pubkey // ignore: cast_nullable_to_non_nullable
              as String,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      ts: null == ts
          ? _value.ts
          : ts // ignore: cast_nullable_to_non_nullable
              as String,
      sig: freezed == sig
          ? _value.sig
          : sig // ignore: cast_nullable_to_non_nullable
              as String?,
      signerPubkey: freezed == signerPubkey
          ? _value.signerPubkey
          : signerPubkey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QrPaymentRequestImpl implements _QrPaymentRequest {
  const _$QrPaymentRequestImpl(
      {this.v = '1',
      required this.t,
      this.token = 'MYXN',
      required this.amount,
      required this.pubkey,
      this.memo,
      required this.ts,
      this.sig,
      @JsonKey(name: 'signer_pubkey') this.signerPubkey});

  factory _$QrPaymentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$QrPaymentRequestImplFromJson(json);

  @override
  @JsonKey()
  final String v;
// version
  @override
  final String t;
// type: pay_request | invoice
  @override
  @JsonKey()
  final String token;
  @override
  final String amount;
  @override
  final String pubkey;
  @override
  final String? memo;
  @override
  final String ts;
// ISO8601 timestamp
  @override
  final String? sig;
// optional signature (for invoices)
  @override
  @JsonKey(name: 'signer_pubkey')
  final String? signerPubkey;

  @override
  String toString() {
    return 'QrPaymentRequest(v: $v, t: $t, token: $token, amount: $amount, pubkey: $pubkey, memo: $memo, ts: $ts, sig: $sig, signerPubkey: $signerPubkey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrPaymentRequestImpl &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.t, t) || other.t == t) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.pubkey, pubkey) || other.pubkey == pubkey) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.ts, ts) || other.ts == ts) &&
            (identical(other.sig, sig) || other.sig == sig) &&
            (identical(other.signerPubkey, signerPubkey) ||
                other.signerPubkey == signerPubkey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, v, t, token, amount, pubkey, memo, ts, sig, signerPubkey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QrPaymentRequestImplCopyWith<_$QrPaymentRequestImpl> get copyWith =>
      __$$QrPaymentRequestImplCopyWithImpl<_$QrPaymentRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QrPaymentRequestImplToJson(
      this,
    );
  }
}

abstract class _QrPaymentRequest implements QrPaymentRequest {
  const factory _QrPaymentRequest(
          {final String v,
          required final String t,
          final String token,
          required final String amount,
          required final String pubkey,
          final String? memo,
          required final String ts,
          final String? sig,
          @JsonKey(name: 'signer_pubkey') final String? signerPubkey}) =
      _$QrPaymentRequestImpl;

  factory _QrPaymentRequest.fromJson(Map<String, dynamic> json) =
      _$QrPaymentRequestImpl.fromJson;

  @override
  String get v;
  @override // version
  String get t;
  @override // type: pay_request | invoice
  String get token;
  @override
  String get amount;
  @override
  String get pubkey;
  @override
  String? get memo;
  @override
  String get ts;
  @override // ISO8601 timestamp
  String? get sig;
  @override // optional signature (for invoices)
  @JsonKey(name: 'signer_pubkey')
  String? get signerPubkey;
  @override
  @JsonKey(ignore: true)
  _$$QrPaymentRequestImplCopyWith<_$QrPaymentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
