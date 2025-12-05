// lib/features/receive/receive_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../models/qr_payment_request.dart';

class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  bool _showQR = false;
  String? _qrData;

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _generateQR() {
    final publicKey = ref.read(walletPublicKeyProvider);
    if (publicKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet not initialized'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final paymentRequest = createPaymentRequest(
      publicKey: publicKey,
      amount: amount,
      memo: _memoController.text.isEmpty ? null : _memoController.text,
    );

    setState(() {
      _qrData = paymentRequest.toQrString();
      _showQR = true;
    });
  }

  void _copyAddress() {
    final publicKey = ref.read(walletPublicKeyProvider);
    if (publicKey != null) {
      Clipboard.setData(ClipboardData(text: publicKey));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address copied to clipboard'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _shareAddress() {
    final publicKey = ref.read(walletPublicKeyProvider);
    if (publicKey != null) {
      Share.share('My MYXN Address: $publicKey');
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicKey = ref.watch(walletPublicKeyProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Receive MYXN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAddress,
            tooltip: 'Share Address',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_showQR) ...[
                // Address Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Wallet Address',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      SelectableText(
                        publicKey ?? 'No wallet found',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryDark,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      ElevatedButton.icon(
                        onPressed: _copyAddress,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy Address'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          foregroundColor: AppTheme.primaryColor,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Amount Input (Optional)
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (Optional)',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'MYXN',
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Memo Input (Optional)
                TextField(
                  controller: _memoController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Memo (Optional)',
                    hintText: 'Add a note',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Generate QR Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _generateQR,
                    icon: const Icon(Icons.qr_code),
                    label: const Text(
                      'Generate QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // QR Code Display
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: QrImageView(
                    data: _qrData!,
                    version: QrVersions.auto,
                    size: 280,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Amount Display
                if (_amountController.text.isNotEmpty)
                  Text(
                    '${_amountController.text} MYXN',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                const SizedBox(height: AppTheme.spacingMd),

                // Instructions
                Text(
                  'Scan this QR code to receive payment',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showQR = false;
                        _qrData = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Generate New QR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingXl),

              // Info Card
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.infoColor.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.infoColor,
                      size: 20,
                    ),
                    SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Text(
                        'Only send MYXN tokens to this address. Sending other tokens may result in loss of funds.',
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
    );
  }
}
