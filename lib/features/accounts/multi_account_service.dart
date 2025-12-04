// lib/features/accounts/multi_account_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/storage/database.dart';

/// Multi-Account Service
/// 
/// Manages multiple wallet accounts within the same app
class MultiAccountService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AppDatabase _database;

  MultiAccountService(this._database);

  static const String _activeAccountKey = 'active_account_index';
  static const String _accountCountKey = 'account_count';

  /// Get active account index
  Future<int> getActiveAccountIndex() async {
    final index = await _secureStorage.read(key: _activeAccountKey);
    return int.tryParse(index ?? '0') ?? 0;
  }

  /// Set active account
  Future<void> setActiveAccount(int index) async {
    await _secureStorage.write(
      key: _activeAccountKey,
      value: index.toString(),
    );
  }

  /// Get account count
  Future<int> getAccountCount() async {
    final count = await _secureStorage.read(key: _accountCountKey);
    return int.tryParse(count ?? '1') ?? 1;
  }

  /// Create new account
  Future<void> createAccount(String name) async {
    final count = await getAccountCount();
    final newIndex = count;

    // Store account info in database
    await _database.insertWalletAccount(
      WalletAccountsCompanion.insert(
        publicKey: 'account_$newIndex', // TODO: Derive actual key
        name: name,
        lastUpdated: DateTime.now(),
      ),
    );

    await _secureStorage.write(
      key: _accountCountKey,
      value: (count + 1).toString(),
    );
  }

  /// Get all accounts
  Future<List<WalletAccount>> getAllAccounts() async {
    return await _database.getAllWalletAccounts();
  }

  /// Switch account
  Future<void> switchAccount(int index) async {
    await setActiveAccount(index);
    
    // Update active status in database
    final accounts = await getAllAccounts();
    for (var i = 0; i < accounts.length; i++) {
      await _database.updateWalletAccount(
        WalletAccountsCompanion(
          publicKey: accounts[i].publicKey,
          isActive: i == index,
        ),
      );
    }
  }

  /// Delete account
  Future<void> deleteAccount(int index) async {
    final accounts = await getAllAccounts();
    if (index < accounts.length) {
      // Delete from database
      await _database.delete(_database.walletAccounts)
        ..where((t) => t.publicKey.equals(accounts[index].publicKey))
        ..go();

      // Update count
      final count = await getAccountCount();
      await _secureStorage.write(
        key: _accountCountKey,
        value: (count - 1).toString(),
      );

      // If deleted active account, switch to first
      final activeIndex = await getActiveAccountIndex();
      if (activeIndex == index) {
        await setActiveAccount(0);
      }
    }
  }
}
