// lib/core/storage/database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

/// Transactions table
class Transactions extends Table {
  TextColumn get signature => text()();
  TextColumn get fromAddress => text()();
  TextColumn get toAddress => text()();
  RealColumn get amount => real()();
  TextColumn get token => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get status => text()();
  TextColumn get memo => text().nullable()();
  IntColumn get blockTime => integer().nullable()();
  IntColumn get slot => integer().nullable()();
  RealColumn get fee => real().nullable()();

  @override
  Set<Column> get primaryKey => {signature};
}

/// Wallet accounts table
class WalletAccounts extends Table {
  TextColumn get publicKey => text()();
  TextColumn get name => text()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  RealColumn get myxnBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {publicKey};
}

/// App settings table
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Transactions, WalletAccounts, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations
      },
    );
  }

  // Transaction queries
  Future<List<Transaction>> getAllTransactions() {
    return select(transactions).get();
  }

  Future<List<Transaction>> getTransactionsByAddress(String address) {
    return (select(transactions)
          ..where((t) =>
              t.fromAddress.equals(address) | t.toAddress.equals(address))
          ..orderBy([
            (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<Transaction?> getTransactionBySignature(String signature) {
    return (select(transactions)..where((t) => t.signature.equals(signature)))
        .getSingleOrNull();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  Future<bool> updateTransaction(TransactionsCompanion transaction) {
    return update(transactions).replace(transaction);
  }

  Future<int> deleteTransaction(String signature) {
    return (delete(transactions)..where((t) => t.signature.equals(signature)))
        .go();
  }

  // Wallet account queries
  Future<List<WalletAccount>> getAllWalletAccounts() {
    return select(walletAccounts).get();
  }

  Future<WalletAccount?> getActiveWalletAccount() {
    return (select(walletAccounts)..where((w) => w.isActive.equals(true)))
        .getSingleOrNull();
  }

  Future<WalletAccount?> getWalletAccountByPublicKey(String publicKey) {
    return (select(walletAccounts)
          ..where((w) => w.publicKey.equals(publicKey)))
        .getSingleOrNull();
  }

  Future<int> insertWalletAccount(WalletAccountsCompanion account) {
    return into(walletAccounts).insert(account);
  }

  Future<bool> updateWalletAccount(WalletAccountsCompanion account) {
    return update(walletAccounts).replace(account);
  }

  Future<int> updateWalletBalance({
    required String publicKey,
    required double balance,
    required double myxnBalance,
  }) {
    return (update(walletAccounts)
          ..where((w) => w.publicKey.equals(publicKey)))
        .write(
      WalletAccountsCompanion(
        balance: Value(balance),
        myxnBalance: Value(myxnBalance),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  // Settings queries
  Future<String?> getSetting(String key) async {
    final setting =
        await (select(settings)..where((s) => s.key.equals(key)))
            .getSingleOrNull();
    return setting?.value;
  }

  Future<void> setSetting(String key, String value) {
    return into(settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  Future<int> deleteSetting(String key) {
    return (delete(settings)..where((s) => s.key.equals(key))).go();
  }

  // Utility methods
  Future<void> clearAllData() async {
    await delete(transactions).go();
    await delete(walletAccounts).go();
    await delete(settings).go();
  }

  Future<void> clearTransactionHistory() async {
    await delete(transactions).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'myxen.db'));
    return NativeDatabase(file);
  });
}
