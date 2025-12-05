// lib/features/settings/security_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/auth/biometric_service.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _biometricEnabled = true;
  bool _requireForTransactions = true;
  bool _requireForWalletAccess = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final type = await _biometricService.getPrimaryBiometricType();
    if (mounted) {
      setState(() {
        _biometricType = type;
      });
    }
  }

  Future<void> _testBiometric() async {
    final authenticated = await _biometricService.authenticate(
      reason: 'Test biometric authentication',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authenticated
                ? 'Authentication successful!'
                : 'Authentication failed',
          ),
          backgroundColor:
              authenticated ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          children: [
            // Biometric Authentication
            _buildSectionTitle('Biometric Authentication'),
            _buildSettingTile(
              title: 'Enable $_biometricType',
              subtitle: 'Use biometric for authentication',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() => _biometricEnabled = value);
              },
            ),
            if (_biometricEnabled) ...[
              _buildSettingTile(
                title: 'Require for Transactions',
                subtitle: 'Authenticate before sending',
                value: _requireForTransactions,
                onChanged: (value) {
                  setState(() => _requireForTransactions = value);
                },
              ),
              _buildSettingTile(
                title: 'Require for Wallet Access',
                subtitle: 'Authenticate when opening app',
                value: _requireForWalletAccess,
                onChanged: (value) {
                  setState(() => _requireForWalletAccess = value);
                },
              ),
              _buildActionTile(
                icon: Icons.fingerprint,
                title: 'Test Authentication',
                subtitle: 'Test your biometric setup',
                onTap: _testBiometric,
              ),
            ],
            const SizedBox(height: AppTheme.spacingLg),

            // PIN Settings
            _buildSectionTitle('PIN Security'),
            _buildActionTile(
              icon: Icons.lock_outline,
              title: 'Change PIN',
              subtitle: 'Update your wallet PIN',
              onTap: () {
                // TODO: Implement change PIN
              },
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Auto-Lock
            _buildSectionTitle('Auto-Lock'),
            _buildActionTile(
              icon: Icons.timer_outlined,
              title: 'Auto-Lock Timer',
              subtitle: '5 minutes',
              onTap: () {
                // TODO: Implement auto-lock timer
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppTheme.spacingMd,
        top: AppTheme.spacingSm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimaryDark,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      color: AppTheme.surfaceDark,
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      color: AppTheme.surfaceDark,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondaryDark,
        ),
      ),
    );
  }
}
