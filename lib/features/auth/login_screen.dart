// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/session_provider.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _unlockWallet() async {
    if (_pinController.text.length != 6) {
      setState(() => _error = 'Please enter a 6-digit PIN');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final keyManager = ref.read(keyManagerProvider);
      
      // Verify login by attempting to derive public key
      final publicKey = await keyManager.getPublicKeyBase58(pin: _pinController.text);
      
      if (publicKey != null) {
        // Successful login
        if (!mounted) return;
        
        // Store PIN in session
        ref.read(sessionPinProvider.notifier).state = _pinController.text;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() => _error = 'Failed to unlock wallet');
      }
    } catch (e) {
      setState(() => _error = 'Incorrect PIN');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _forgotPin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Wallet?'),
        content: const Text(
          'If you forgot your PIN, you must reset the wallet and restore it using your 12-word recovery phrase.\n\nWARNING: Any funds in the current wallet will be lost if you do not have your recovery phrase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Reset & Delete Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(keyManagerProvider).clearKeys();
        
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting wallet: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Enter your PIN to unlock',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              
              // PIN Input
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  prefixIcon: const Icon(Icons.dialpad),
                  errorText: _error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                onSubmitted: (_) => _unlockWallet(),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              
              // Unlock Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _unlockWallet,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Unlock Wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              
              // Forgot PIN
              TextButton(
                onPressed: _forgotPin,
                child: Text(
                  'Forgot PIN?',
                  style: TextStyle(
                    color: AppTheme.errorColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
