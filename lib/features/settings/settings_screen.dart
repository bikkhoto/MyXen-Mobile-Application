// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/auth/biometric_service.dart';
import '../../providers/wallet_provider.dart';
import 'security_settings_screen.dart';
import 'backup_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  String _biometricType = 'Loading...';
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isAvailable();
    final type = await _biometricService.getPrimaryBiometricType();
    
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricType = type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Security Section
              _buildSectionTitle('Security'),
              _buildSettingCard(
                icon: Icons.fingerprint,
                title: 'Biometric Authentication',
                subtitle: _biometricAvailable
                    ? '$_biometricType enabled'
                    : 'Not available',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SecuritySettingsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                icon: Icons.backup,
                title: 'Backup & Restore',
                subtitle: 'Secure your wallet',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BackupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Preferences Section
              _buildSectionTitle('Preferences'),
              _buildSettingCard(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'Dark mode',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement theme toggle
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              _buildSettingCard(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  // TODO: Implement language selection
                },
              ),
              _buildSettingCard(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notifications',
                onTap: () {
                  // TODO: Implement notification settings
                },
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // About Section
              _buildSectionTitle('About'),
              _buildSettingCard(
                icon: Icons.info_outline,
                title: 'About MyXen',
                subtitle: 'Version & info',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                icon: Icons.description_outlined,
                title: 'Terms & Privacy',
                subtitle: 'Legal information',
                onTap: () {
                  // TODO: Show terms and privacy
                },
              ),
              _buildSettingCard(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help',
                onTap: () {
                  // TODO: Show help
                },
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Danger Zone
              _buildSectionTitle('Danger Zone'),
              _buildSettingCard(
                icon: Icons.delete_outline,
                title: 'Clear Transaction History',
                subtitle: 'Remove all local transactions',
                iconColor: AppTheme.warningColor,
                onTap: _confirmClearHistory,
              ),
              _buildSettingCard(
                icon: Icons.logout,
                title: 'Reset Wallet',
                subtitle: 'Remove wallet from device',
                iconColor: AppTheme.errorColor,
                onTap: _confirmResetWallet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
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

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: 24,
          ),
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
            color: AppTheme.textSecondaryDark.withOpacity(0.8),
          ),
        ),
        trailing: trailing ??
            (onTap != null
                ? const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondaryDark,
                  )
                : null),
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          'Clear Transaction History?',
          style: TextStyle(color: AppTheme.textPrimaryDark),
        ),
        content: const Text(
          'This will remove all local transaction history. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.warningColor),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Clear transaction history
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction history cleared'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Future<void> _confirmResetWallet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          'Reset Wallet?',
          style: TextStyle(color: AppTheme.errorColor),
        ),
        content: const Text(
          'This will remove your wallet from this device. Make sure you have backed up your recovery phrase!',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Reset wallet
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet reset'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
