import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myxen/features/kyc/kyc_screen.dart';
import 'package:myxen/features/emergency/emergency_screen.dart';
import 'package:myxen/features/wallet/create_wallet_screen.dart';
import 'package:myxen/features/settings/security_settings_screen.dart';

// Mock wrapper to provide necessary ancestors
class MockWrapper extends StatelessWidget {
  final Widget child;
  const MockWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

void main() {
  group('Checklist Smoke Tests', () {
    testWidgets('KYC Screen builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MockWrapper(child: KycScreen()));
      expect(find.byType(KycScreen), findsOneWidget);
      expect(find.text('KYC Verification'), findsOneWidget);
    });

    testWidgets('Emergency SOS Screen builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MockWrapper(child: EmergencyScreen()));
      expect(find.byType(EmergencyScreen), findsOneWidget);
      expect(find.text('Emergency SOS'), findsOneWidget);
    });

    testWidgets('Create Wallet Screen builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MockWrapper(child: CreateWalletScreen()));
      expect(find.byType(CreateWalletScreen), findsOneWidget);
    });

    testWidgets('Security Settings Screen builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MockWrapper(child: SecuritySettingsScreen()));
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    });
  });
}
