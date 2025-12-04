// lib/features/send/send_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import 'send_confirmation_screen.dart';
import '../qr/qr_scanner_screen.dart';

class SendScreen extends ConsumerStatefulWidget {
  final String? prefilledRecipient;
  final double? prefilledAmount;
  final String? prefilledMemo;

  const SendScreen({
    super.key,
    this.prefilledRecipient,
    this.prefilledAmount,
    this.prefilledMemo,
  });

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill from QR scan if available
    if (widget.prefilledRecipient != null) {
      _recipientController.text = widget.prefilledRecipient!;
    }
    if (widget.prefilledAmount != null) {
      _amountController.text = widget.prefilledAmount.toString();
    }
    if (widget.prefilledMemo != null) {
      _memoController.text = widget.prefilledMemo!;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _scanQR() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(),
      ),
    );
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SendConfirmationScreen(
          recipient: _recipientController.text,
          amount: amount,
          memo: _memoController.text.isEmpty ? null : _memoController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(walletBalanceProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Send MYXN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQR,
            tooltip: 'Scan QR Code',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.1),
                        AppTheme.secondaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryDark.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      walletBalance.when(
                        data: (wallet) => Text(
                          '${wallet?.formattedBalance ?? '0.00'} MYXN',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text(
                          '0.00 MYXN',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Recipient Address
                TextFormField(
                  controller: _recipientController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Address',
                    hintText: 'Enter Solana address',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter recipient address';
                    }
                    if (value.length < 32) {
                      return 'Invalid Solana address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,9}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.attach_money),
                    suffixText: 'MYXN',
                    suffixIcon: TextButton(
                      onPressed: () {
                        final balance = walletBalance.value?.myxnBalance ?? 0.0;
                        _amountController.text = balance.toString();
                      },
                      child: const Text('MAX'),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Invalid amount';
                    }
                    final balance = walletBalance.value?.myxnBalance ?? 0.0;
                    if (amount > balance) {
                      return 'Insufficient balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Memo (Optional)
                TextFormField(
                  controller: _memoController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Memo (Optional)',
                    hintText: 'Add a note',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Fee Info
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Network Fee',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryDark,
                        ),
                      ),
                      Text(
                        '~0.000005 SOL',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _continue,
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
