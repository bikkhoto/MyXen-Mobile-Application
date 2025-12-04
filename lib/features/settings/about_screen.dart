// lib/features/settings/about_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('About MyXen'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // App Name
              const Text(
                'MyXen Mobile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),

              // Version
              Text(
                'Version $_version ($_buildNumber)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryDark.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Description
              Text(
                'A secure Solana-based mobile wallet and payments application with \$MYXN token support.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryDark.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Features
              _buildFeatureCard(
                icon: Icons.security,
                title: 'Secure',
                description: 'Hardware-backed encryption and biometric auth',
              ),
              _buildFeatureCard(
                icon: Icons.speed,
                title: 'Fast',
                description: 'Built on Solana for instant transactions',
              ),
              _buildFeatureCard(
                icon: Icons.verified_user,
                title: 'Verified',
                description: 'On-chain verification for all transactions',
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Links
              _buildLinkCard(
                icon: Icons.language,
                title: 'Website',
                subtitle: 'Visit our website',
                onTap: () => _launchUrl('https://myxen.io'),
              ),
              _buildLinkCard(
                icon: Icons.code,
                title: 'GitHub',
                subtitle: 'View source code',
                onTap: () => _launchUrl('https://github.com/myxen'),
              ),
              _buildLinkCard(
                icon: Icons.email,
                title: 'Support',
                subtitle: 'support@myxen.io',
                onTap: () => _launchUrl('mailto:support@myxen.io'),
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Copyright
              Text(
                '© 2025 MyXen. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryDark.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      color: AppTheme.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryDark.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCard({
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
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
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
          Icons.open_in_new,
          color: AppTheme.textSecondaryDark,
          size: 20,
        ),
      ),
    );
  }
}
