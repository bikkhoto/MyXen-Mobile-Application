// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _signatureMeta =
      const VerificationMeta('signature');
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
      'signature', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromAddressMeta =
      const VerificationMeta('fromAddress');
  @override
  late final GeneratedColumn<String> fromAddress = GeneratedColumn<String>(
      'from_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toAddressMeta =
      const VerificationMeta('toAddress');
  @override
  late final GeneratedColumn<String> toAddress = GeneratedColumn<String>(
      'to_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _blockTimeMeta =
      const VerificationMeta('blockTime');
  @override
  late final GeneratedColumn<int> blockTime = GeneratedColumn<int>(
      'block_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
      'slot', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<double> fee = GeneratedColumn<double>(
      'fee', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        signature,
        fromAddress,
        toAddress,
        amount,
        token,
        timestamp,
        status,
        memo,
        blockTime,
        slot,
        fee
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('signature')) {
      context.handle(_signatureMeta,
          signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta));
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('from_address')) {
      context.handle(
          _fromAddressMeta,
          fromAddress.isAcceptableOrUnknown(
              data['from_address']!, _fromAddressMeta));
    } else if (isInserting) {
      context.missing(_fromAddressMeta);
    }
    if (data.containsKey('to_address')) {
      context.handle(_toAddressMeta,
          toAddress.isAcceptableOrUnknown(data['to_address']!, _toAddressMeta));
    } else if (isInserting) {
      context.missing(_toAddressMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('block_time')) {
      context.handle(_blockTimeMeta,
          blockTime.isAcceptableOrUnknown(data['block_time']!, _blockTimeMeta));
    }
    if (data.containsKey('slot')) {
      context.handle(
          _slotMeta, slot.isAcceptableOrUnknown(data['slot']!, _slotMeta));
    }
    if (data.containsKey('fee')) {
      context.handle(
          _feeMeta, fee.isAcceptableOrUnknown(data['fee']!, _feeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {signature};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      signature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signature'])!,
      fromAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_address'])!,
      toAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_address'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      blockTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}block_time']),
      slot: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}slot']),
      fee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fee']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String signature;
  final String fromAddress;
  final String toAddress;
  final double amount;
  final String token;
  final DateTime timestamp;
  final String status;
  final String? memo;
  final int? blockTime;
  final int? slot;
  final double? fee;
  const Transaction(
      {required this.signature,
      required this.fromAddress,
      required this.toAddress,
      required this.amount,
      required this.token,
      required this.timestamp,
      required this.status,
      this.memo,
      this.blockTime,
      this.slot,
      this.fee});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['signature'] = Variable<String>(signature);
    map['from_address'] = Variable<String>(fromAddress);
    map['to_address'] = Variable<String>(toAddress);
    map['amount'] = Variable<double>(amount);
    map['token'] = Variable<String>(token);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || blockTime != null) {
      map['block_time'] = Variable<int>(blockTime);
    }
    if (!nullToAbsent || slot != null) {
      map['slot'] = Variable<int>(slot);
    }
    if (!nullToAbsent || fee != null) {
      map['fee'] = Variable<double>(fee);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      signature: Value(signature),
      fromAddress: Value(fromAddress),
      toAddress: Value(toAddress),
      amount: Value(amount),
      token: Value(token),
      timestamp: Value(timestamp),
      status: Value(status),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      blockTime: blockTime == null && nullToAbsent
          ? const Value.absent()
          : Value(blockTime),
      slot: slot == null && nullToAbsent ? const Value.absent() : Value(slot),
      fee: fee == null && nullToAbsent ? const Value.absent() : Value(fee),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      signature: serializer.fromJson<String>(json['signature']),
      fromAddress: serializer.fromJson<String>(json['fromAddress']),
      toAddress: serializer.fromJson<String>(json['toAddress']),
      amount: serializer.fromJson<double>(json['amount']),
      token: serializer.fromJson<String>(json['token']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      status: serializer.fromJson<String>(json['status']),
      memo: serializer.fromJson<String?>(json['memo']),
      blockTime: serializer.fromJson<int?>(json['blockTime']),
      slot: serializer.fromJson<int?>(json['slot']),
      fee: serializer.fromJson<double?>(json['fee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'signature': serializer.toJson<String>(signature),
      'fromAddress': serializer.toJson<String>(fromAddress),
      'toAddress': serializer.toJson<String>(toAddress),
      'amount': serializer.toJson<double>(amount),
      'token': serializer.toJson<String>(token),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'status': serializer.toJson<String>(status),
      'memo': serializer.toJson<String?>(memo),
      'blockTime': serializer.toJson<int?>(blockTime),
      'slot': serializer.toJson<int?>(slot),
      'fee': serializer.toJson<double?>(fee),
    };
  }

  Transaction copyWith(
          {String? signature,
          String? fromAddress,
          String? toAddress,
          double? amount,
          String? token,
          DateTime? timestamp,
          String? status,
          Value<String?> memo = const Value.absent(),
          Value<int?> blockTime = const Value.absent(),
          Value<int?> slot = const Value.absent(),
          Value<double?> fee = const Value.absent()}) =>
      Transaction(
        signature: signature ?? this.signature,
        fromAddress: fromAddress ?? this.fromAddress,
        toAddress: toAddress ?? this.toAddress,
        amount: amount ?? this.amount,
        token: token ?? this.token,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
        memo: memo.present ? memo.value : this.memo,
        blockTime: blockTime.present ? blockTime.value : this.blockTime,
        slot: slot.present ? slot.value : this.slot,
        fee: fee.present ? fee.value : this.fee,
      );
  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('signature: $signature, ')
          ..write('fromAddress: $fromAddress, ')
          ..write('toAddress: $toAddress, ')
          ..write('amount: $amount, ')
          ..write('token: $token, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('memo: $memo, ')
          ..write('blockTime: $blockTime, ')
          ..write('slot: $slot, ')
          ..write('fee: $fee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(signature, fromAddress, toAddress, amount,
      token, timestamp, status, memo, blockTime, slot, fee);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.signature == this.signature &&
          other.fromAddress == this.fromAddress &&
          other.toAddress == this.toAddress &&
          other.amount == this.amount &&
          other.token == this.token &&
          other.timestamp == this.timestamp &&
          other.status == this.status &&
          other.memo == this.memo &&
          other.blockTime == this.blockTime &&
          other.slot == this.slot &&
          other.fee == this.fee);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> signature;
  final Value<String> fromAddress;
  final Value<String> toAddress;
  final Value<double> amount;
  final Value<String> token;
  final Value<DateTime> timestamp;
  final Value<String> status;
  final Value<String?> memo;
  final Value<int?> blockTime;
  final Value<int?> slot;
  final Value<double?> fee;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.signature = const Value.absent(),
    this.fromAddress = const Value.absent(),
    this.toAddress = const Value.absent(),
    this.amount = const Value.absent(),
    this.token = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.status = const Value.absent(),
    this.memo = const Value.absent(),
    this.blockTime = const Value.absent(),
    this.slot = const Value.absent(),
    this.fee = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String signature,
    required String fromAddress,
    required String toAddress,
    required double amount,
    required String token,
    required DateTime timestamp,
    required String status,
    this.memo = const Value.absent(),
    this.blockTime = const Value.absent(),
    this.slot = const Value.absent(),
    this.fee = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : signature = Value(signature),
        fromAddress = Value(fromAddress),
        toAddress = Value(toAddress),
        amount = Value(amount),
        token = Value(token),
        timestamp = Value(timestamp),
        status = Value(status);
  static Insertable<Transaction> custom({
    Expression<String>? signature,
    Expression<String>? fromAddress,
    Expression<String>? toAddress,
    Expression<double>? amount,
    Expression<String>? token,
    Expression<DateTime>? timestamp,
    Expression<String>? status,
    Expression<String>? memo,
    Expression<int>? blockTime,
    Expression<int>? slot,
    Expression<double>? fee,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (signature != null) 'signature': signature,
      if (fromAddress != null) 'from_address': fromAddress,
      if (toAddress != null) 'to_address': toAddress,
      if (amount != null) 'amount': amount,
      if (token != null) 'token': token,
      if (timestamp != null) 'timestamp': timestamp,
      if (status != null) 'status': status,
      if (memo != null) 'memo': memo,
      if (blockTime != null) 'block_time': blockTime,
      if (slot != null) 'slot': slot,
      if (fee != null) 'fee': fee,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? signature,
      Value<String>? fromAddress,
      Value<String>? toAddress,
      Value<double>? amount,
      Value<String>? token,
      Value<DateTime>? timestamp,
      Value<String>? status,
      Value<String?>? memo,
      Value<int?>? blockTime,
      Value<int?>? slot,
      Value<double?>? fee,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      signature: signature ?? this.signature,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      amount: amount ?? this.amount,
      token: token ?? this.token,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      blockTime: blockTime ?? this.blockTime,
      slot: slot ?? this.slot,
      fee: fee ?? this.fee,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (fromAddress.present) {
      map['from_address'] = Variable<String>(fromAddress.value);
    }
    if (toAddress.present) {
      map['to_address'] = Variable<String>(toAddress.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (blockTime.present) {
      map['block_time'] = Variable<int>(blockTime.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (fee.present) {
      map['fee'] = Variable<double>(fee.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('signature: $signature, ')
          ..write('fromAddress: $fromAddress, ')
          ..write('toAddress: $toAddress, ')
          ..write('amount: $amount, ')
          ..write('token: $token, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('memo: $memo, ')
          ..write('blockTime: $blockTime, ')
          ..write('slot: $slot, ')
          ..write('fee: $fee, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletAccountsTable extends WalletAccounts
    with TableInfo<$WalletAccountsTable, WalletAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _publicKeyMeta =
      const VerificationMeta('publicKey');
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
      'public_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _myxnBalanceMeta =
      const VerificationMeta('myxnBalance');
  @override
  late final GeneratedColumn<double> myxnBalance = GeneratedColumn<double>(
      'myxn_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [publicKey, name, balance, myxnBalance, lastUpdated, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<WalletAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('public_key')) {
      context.handle(_publicKeyMeta,
          publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta));
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('myxn_balance')) {
      context.handle(
          _myxnBalanceMeta,
          myxnBalance.isAcceptableOrUnknown(
              data['myxn_balance']!, _myxnBalanceMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {publicKey};
  @override
  WalletAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletAccount(
      publicKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}public_key'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      myxnBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}myxn_balance'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $WalletAccountsTable createAlias(String alias) {
    return $WalletAccountsTable(attachedDatabase, alias);
  }
}

class WalletAccount extends DataClass implements Insertable<WalletAccount> {
  final String publicKey;
  final String name;
  final double balance;
  final double myxnBalance;
  final DateTime lastUpdated;
  final bool isActive;
  const WalletAccount(
      {required this.publicKey,
      required this.name,
      required this.balance,
      required this.myxnBalance,
      required this.lastUpdated,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['public_key'] = Variable<String>(publicKey);
    map['name'] = Variable<String>(name);
    map['balance'] = Variable<double>(balance);
    map['myxn_balance'] = Variable<double>(myxnBalance);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  WalletAccountsCompanion toCompanion(bool nullToAbsent) {
    return WalletAccountsCompanion(
      publicKey: Value(publicKey),
      name: Value(name),
      balance: Value(balance),
      myxnBalance: Value(myxnBalance),
      lastUpdated: Value(lastUpdated),
      isActive: Value(isActive),
    );
  }

  factory WalletAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletAccount(
      publicKey: serializer.fromJson<String>(json['publicKey']),
      name: serializer.fromJson<String>(json['name']),
      balance: serializer.fromJson<double>(json['balance']),
      myxnBalance: serializer.fromJson<double>(json['myxnBalance']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'publicKey': serializer.toJson<String>(publicKey),
      'name': serializer.toJson<String>(name),
      'balance': serializer.toJson<double>(balance),
      'myxnBalance': serializer.toJson<double>(myxnBalance),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  WalletAccount copyWith(
          {String? publicKey,
          String? name,
          double? balance,
          double? myxnBalance,
          DateTime? lastUpdated,
          bool? isActive}) =>
      WalletAccount(
        publicKey: publicKey ?? this.publicKey,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        myxnBalance: myxnBalance ?? this.myxnBalance,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isActive: isActive ?? this.isActive,
      );
  @override
  String toString() {
    return (StringBuffer('WalletAccount(')
          ..write('publicKey: $publicKey, ')
          ..write('name: $name, ')
          ..write('balance: $balance, ')
          ..write('myxnBalance: $myxnBalance, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(publicKey, name, balance, myxnBalance, lastUpdated, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletAccount &&
          other.publicKey == this.publicKey &&
          other.name == this.name &&
          other.balance == this.balance &&
          other.myxnBalance == this.myxnBalance &&
          other.lastUpdated == this.lastUpdated &&
          other.isActive == this.isActive);
}

class WalletAccountsCompanion extends UpdateCompanion<WalletAccount> {
  final Value<String> publicKey;
  final Value<String> name;
  final Value<double> balance;
  final Value<double> myxnBalance;
  final Value<DateTime> lastUpdated;
  final Value<bool> isActive;
  final Value<int> rowid;
  const WalletAccountsCompanion({
    this.publicKey = const Value.absent(),
    this.name = const Value.absent(),
    this.balance = const Value.absent(),
    this.myxnBalance = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletAccountsCompanion.insert({
    required String publicKey,
    required String name,
    this.balance = const Value.absent(),
    this.myxnBalance = const Value.absent(),
    required DateTime lastUpdated,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : publicKey = Value(publicKey),
        name = Value(name),
        lastUpdated = Value(lastUpdated);
  static Insertable<WalletAccount> custom({
    Expression<String>? publicKey,
    Expression<String>? name,
    Expression<double>? balance,
    Expression<double>? myxnBalance,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (publicKey != null) 'public_key': publicKey,
      if (name != null) 'name': name,
      if (balance != null) 'balance': balance,
      if (myxnBalance != null) 'myxn_balance': myxnBalance,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletAccountsCompanion copyWith(
      {Value<String>? publicKey,
      Value<String>? name,
      Value<double>? balance,
      Value<double>? myxnBalance,
      Value<DateTime>? lastUpdated,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return WalletAccountsCompanion(
      publicKey: publicKey ?? this.publicKey,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      myxnBalance: myxnBalance ?? this.myxnBalance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (myxnBalance.present) {
      map['myxn_balance'] = Variable<double>(myxnBalance.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletAccountsCompanion(')
          ..write('publicKey: $publicKey, ')
          ..write('name: $name, ')
          ..write('balance: $balance, ')
          ..write('myxnBalance: $myxnBalance, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $WalletAccountsTable walletAccounts = $WalletAccountsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [transactions, walletAccounts, settings];
}
