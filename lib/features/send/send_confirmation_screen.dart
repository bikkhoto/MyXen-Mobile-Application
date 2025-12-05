// lib/features/send/send_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class SendConfirmationScreen extends ConsumerStatefulWidget {
  final String recipient;
  final double amount;
  final String? memo;

  const SendConfirmationScreen({
    required this.recipient, required this.amount, super.key,
    this.memo,
  });

  @override
  ConsumerState<SendConfirmationScreen> createState() =>
      _SendConfirmationScreenState();
}

class _SendConfirmationScreenState
    extends ConsumerState<SendConfirmationScreen> {
  bool _isProcessing = false;

  Future<void> _confirmAndSend() async {
    setState(() => _isProcessing = true);

    try {
      // TODO: Implement actual transaction signing and sending
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Show success
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            const Text(
              'Transaction Sent!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Your transaction is being processed',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Confirm Transaction'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'You are sending',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            '${widget.amount.toStringAsFixed(2)} MYXN',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            '≈ \$${(widget.amount * 0.1).toStringAsFixed(2)} USD',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondaryDark.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Transaction Details
                    _buildDetailCard(),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Warning
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: AppTheme.warningColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.warningColor,
                            size: 20,
                          ),
                          SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Text(
                              'Double-check the recipient address. Transactions cannot be reversed.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondaryDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmAndSend,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirm & Send',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          _buildDetailRow('To', _shortenAddress(widget.recipient)),
          const Divider(height: AppTheme.spacingLg),
          _buildDetailRow('Amount', '${widget.amount.toStringAsFixed(2)} MYXN'),
          const Divider(height: AppTheme.spacingLg),
          _buildDetailRow('Network Fee', '~0.000005 SOL'),
          if (widget.memo != null) ...[
            const Divider(height: AppTheme.spacingLg),
            _buildDetailRow('Memo', widget.memo!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryDark,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}
