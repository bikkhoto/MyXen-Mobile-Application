// lib/features/wallet/wallet_created_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class WalletCreatedScreen extends StatefulWidget {
  final String mnemonic;

  const WalletCreatedScreen({
    required this.mnemonic, super.key,
  });

  @override
  State<WalletCreatedScreen> createState() => _WalletCreatedScreenState();
}

class _WalletCreatedScreenState extends State<WalletCreatedScreen> {
  bool _isBlurred = true;
  bool _confirmed = false;

  List<String> get _words => widget.mnemonic.split(' ');

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.mnemonic));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recovery phrase copied to clipboard'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _continue() {
    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm you have saved your recovery phrase'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Recovery Phrase'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning banner
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
                      size: 28,
                    ),
                    SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save Your Recovery Phrase',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warningColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Write it down and store it in a safe place. Never share it with anyone.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondaryDark,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Mnemonic grid
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: AppTheme.spacingSm,
                        mainAxisSpacing: AppTheme.spacingSm,
                      ),
                      itemCount: _words.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: AppTheme.spacingSm,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${index + 1}.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryDark
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _isBlurred ? '••••••' : _words[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _isBlurred
                                        ? AppTheme.textSecondaryDark
                                            .withValues(alpha: 0.4)
                                        : AppTheme.textPrimaryDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _isBlurred = !_isBlurred);
                          },
                          icon: Icon(
                            _isBlurred ? Icons.visibility : Icons.visibility_off,
                          ),
                          label: Text(_isBlurred ? 'Show' : 'Hide'),
                        ),
                        TextButton.icon(
                          onPressed: _isBlurred ? null : _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Security tips
              const Text(
                'Security Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _buildTip(
                Icons.edit_note,
                'Write it down on paper and store it securely',
              ),
              _buildTip(
                Icons.block,
                'Never share your recovery phrase with anyone',
              ),
              _buildTip(
                Icons.cloud_off,
                'Avoid storing it digitally (screenshots, cloud)',
              ),
              _buildTip(
                Icons.backup,
                'Make multiple copies and store them separately',
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Confirmation checkbox
              CheckboxListTile(
                value: _confirmed,
                onChanged: (value) {
                  setState(() => _confirmed = value ?? false);
                },
                title: const Text(
                  'I have saved my recovery phrase in a safe place',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Continue button
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
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
