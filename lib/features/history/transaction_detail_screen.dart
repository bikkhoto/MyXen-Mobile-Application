// lib/features/history/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/storage/database.dart';
import '../../core/network/api_config.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    required this.transaction, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInExplorer,
            tooltip: 'View in Explorer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: AppTheme.spacingXl),

            // Amount
            Center(
              child: Column(
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    '${transaction.amount.toStringAsFixed(2)} ${transaction.token}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  if (transaction.fee != null) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Fee: ${transaction.fee!.toStringAsFixed(6)} SOL',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // Details
            _buildDetailSection('Transaction Details', [
              _buildDetailRow('Signature', transaction.signature, copyable: true),
              _buildDetailRow('From', transaction.fromAddress, copyable: true),
              _buildDetailRow('To', transaction.toAddress, copyable: true),
              _buildDetailRow(
                'Date',
                DateFormat('MMM d, yyyy • HH:mm:ss').format(transaction.timestamp),
              ),
              if (transaction.blockTime != null)
                _buildDetailRow(
                  'Block Time',
                  transaction.blockTime.toString(),
                ),
              if (transaction.slot != null)
                _buildDetailRow('Slot', transaction.slot.toString()),
              if (transaction.memo != null)
                _buildDetailRow('Memo', transaction.memo!),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color color;
    IconData icon;
    String message;

    switch (transaction.status.toLowerCase()) {
      case 'finalized':
      case 'confirmed':
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        message = 'Transaction Confirmed';
        break;
      case 'pending':
        color = AppTheme.warningColor;
        icon = Icons.pending;
        message = 'Transaction Pending';
        break;
      case 'failed':
        color = AppTheme.errorColor;
        icon = Icons.error;
        message = 'Transaction Failed';
        break;
      default:
        color = AppTheme.textSecondaryDark;
        icon = Icons.info;
        message = 'Transaction ${transaction.status}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimaryDark,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: AppTheme.spacingSm),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => _copyToClipboard(value),
                    color: AppTheme.primaryColor,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDescription() {
    switch (transaction.status.toLowerCase()) {
      case 'finalized':
      case 'confirmed':
        return 'This transaction has been confirmed on the blockchain';
      case 'pending':
        return 'Waiting for network confirmation';
      case 'failed':
        return 'This transaction failed to process';
      default:
        return 'Transaction status: ${transaction.status}';
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _openInExplorer() async {
    final url = ApiConfig.getTransactionUrl(transaction.signature);
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
