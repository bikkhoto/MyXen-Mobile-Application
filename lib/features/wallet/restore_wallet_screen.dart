// lib/features/wallet/restore_wallet_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/crypto/key_manager.dart';
import '../home/home_screen.dart';

class RestoreWalletScreen extends StatefulWidget {
  const RestoreWalletScreen({super.key});

  @override
  State<RestoreWalletScreen> createState() => _RestoreWalletScreenState();
}

class _RestoreWalletScreenState extends State<RestoreWalletScreen> {
  final _mnemonicController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _mnemonicController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _restoreWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final keyManager = KeyManager();
      await keyManager.restoreFromMnemonic(
        _mnemonicController.text.trim(),
        pin: _pinController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet restored successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Failed to restore wallet: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Restore Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Enter Recovery Phrase',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Enter your 12-word recovery phrase to restore your wallet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Mnemonic Input
                TextFormField(
                  controller: _mnemonicController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Recovery Phrase',
                    hintText: 'word1 word2 word3 ...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your recovery phrase';
                    }
                    final words = value.trim().split(RegExp(r'\s+'));
                    if (words.length != 12) {
                      return 'Recovery phrase must be 12 words';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // PIN Input
                TextFormField(
                  controller: _pinController,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    hintText: 'Enter 6-digit PIN',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePin = !_obscurePin);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a PIN';
                    }
                    if (value.length != 6) {
                      return 'PIN must be 6 digits';
                    }
                    return null;
                  },
                ),
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
                        Icons.warning_amber_rounded,
                        color: AppTheme.warningColor,
                        size: 24,
                      ),
                      SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Text(
                          'Make sure you are in a private place. Never share your recovery phrase.',
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
                const SizedBox(height: AppTheme.spacingXl),

                // Restore button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _restoreWallet,
                    child: _isLoading
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
                            'Restore Wallet',
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
