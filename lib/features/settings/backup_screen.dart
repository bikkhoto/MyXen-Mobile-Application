// lib/features/settings/backup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/auth/biometric_service.dart';
import '../../core/crypto/key_manager.dart';
import '../../providers/wallet_provider.dart';
import '../wallet/wallet_created_screen.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = false;

  Future<void> _exportRecoveryPhrase() async {
    // Require biometric authentication
    final authenticated = await _biometricService.authenticateForBackup();
    
    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Get recovery phrase from secure storage
      // For now, show placeholder
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recovery phrase export coming soon'),
            backgroundColor: AppTheme.infoColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Banner
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.warningColor,
                      size: 28,
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warningColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Never share your recovery phrase with anyone. Store it securely offline.',
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

              // Backup Section
              const Text(
                'Backup',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              
              _buildActionCard(
                icon: Icons.key,
                title: 'Export Recovery Phrase',
                subtitle: 'View and backup your 12-word phrase',
                onTap: _exportRecoveryPhrase,
                isLoading: _isLoading,
              ),
              
              _buildActionCard(
                icon: Icons.download,
                title: 'Export Encrypted Backup',
                subtitle: 'Download encrypted wallet file',
                onTap: () {
                  // TODO: Implement encrypted backup
                },
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Restore Section
              const Text(
                'Restore',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              
              _buildActionCard(
                icon: Icons.upload,
                title: 'Import Encrypted Backup',
                subtitle: 'Restore from backup file',
                onTap: () {
                  // TODO: Implement import
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      color: AppTheme.surfaceDark,
      child: ListTile(
        onTap: isLoading ? null : onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, color: AppTheme.primaryColor, size: 24),
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
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondaryDark,
        ),
      ),
    );
  }
}
