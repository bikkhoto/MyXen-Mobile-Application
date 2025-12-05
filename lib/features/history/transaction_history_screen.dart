// lib/features/history/transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/storage/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/wallet_provider.dart';
import 'transaction_detail_screen.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicKey = ref.watch(walletPublicKeyProvider);

    if (publicKey == null) {
      return const Scaffold(
        body: Center(child: Text('No wallet found')),
      );
    }

    final transactionsAsync = ref.watch(transactionHistoryProvider(publicKey));

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transactionHistoryProvider(publicKey));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return _buildTransactionCard(context, tx, publicKey);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Transaction tx,
    String userPubkey,
  ) {
    final isReceived = tx.toAddress == userPubkey;
    final otherAddress = isReceived ? tx.fromAddress : tx.toAddress;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(transaction: tx),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: (isReceived
                          ? AppTheme.successColor
                          : AppTheme.primaryColor)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isReceived
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReceived ? 'Received' : 'Sent',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _shortenAddress(otherAddress),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(tx.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Amount and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isReceived ? '+' : '-'}${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isReceived
                          ? AppTheme.successColor
                          : AppTheme.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.token,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(tx.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'finalized':
      case 'confirmed':
        color = AppTheme.successColor;
        label = 'Confirmed';
        break;
      case 'pending':
        color = AppTheme.warningColor;
        label = 'Pending';
        break;
      case 'failed':
        color = AppTheme.errorColor;
        label = 'Failed';
        break;
      default:
        color = AppTheme.textSecondaryDark;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryDark.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
