// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/database_provider.dart';
import '../send/send_screen.dart';
import '../receive/receive_screen.dart';
import '../settings/settings_screen.dart';
import '../../models/wallet_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WalletTab(),
    const HistoryTab(),
    const SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize wallet public key from KeyManager
    _initializeWallet();
  }

  Future<void> _initializeWallet() async {
    try {
      final keyManager = ref.read(keyManagerProvider);
      final publicKey = await keyManager.getPublicKeyBase58();
      if (publicKey != null) {
        ref.read(walletPublicKeyProvider.notifier).state = publicKey;
      }
    } catch (e) {
      debugPrint('Error initializing wallet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.account_balance_wallet, 'Wallet', 0),
                _buildNavItem(Icons.history, 'History', 1),
                _buildNavItem(Icons.settings, 'Settings', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryDark,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wallet Tab
class WalletTab extends ConsumerWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletBalance = ref.watch(walletBalanceProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'MyXen Wallet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(refreshWalletProvider)();
                      },
                      icon: const Icon(Icons.refresh),
                      color: AppTheme.primaryColor,
                      tooltip: 'Refresh Balance',
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  walletBalance.when(
                    data: (wallet) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${wallet?.formattedBalance ?? '0.00'} MYXN',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '≈ \$${((wallet?.myxnBalance ?? 0.0) * 0.1).toStringAsFixed(2)} USD',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    error: (_, __) => const Text(
                      '0.00 MYXN',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.arrow_upward,
                    'Send',
                    AppTheme.primaryColor,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SendScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.arrow_downward,
                    'Receive',
                    AppTheme.successColor,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReceiveScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.qr_code,
                    'QR Pay',
                    AppTheme.accentColor,
                    () {
                      // TODO: Navigate to QR scanner
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppTheme.textSecondaryDark.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// History Tab
class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicKey = ref.watch(walletPublicKeyProvider);

    if (publicKey == null) {
      return const Center(
        child: Text(
          'No wallet found',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.textSecondaryDark,
          ),
        ),
      );
    }

    final transactionsAsync = ref.watch(transactionHistoryProvider(publicKey));

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.invalidate(transactionHistoryProvider(publicKey));
                  },
                  icon: const Icon(Icons.refresh),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryDark.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppTheme.spacingLg),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondaryDark.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                  ),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isReceived = tx.toAddress == publicKey;

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                      color: AppTheme.surfaceDark,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            color: (isReceived
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor)
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isReceived
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isReceived
                                ? AppTheme.successColor
                                : AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          isReceived ? 'Received' : 'Sent',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                        subtitle: Text(
                          '${tx.amount.toStringAsFixed(2)} ${tx.token}',
                          style: TextStyle(
                            color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                          ),
                        ),
                        trailing: Text(
                          tx.status,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Center(
                child: Text(
                  'Error loading transactions',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Settings Tab
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Import and use the actual SettingsScreen
    return const SettingsScreen();
  }
}
