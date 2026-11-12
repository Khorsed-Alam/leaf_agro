import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/features/auth/presentation/register_screen.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

void main() {
  testWidgets('RegisterScreen renders all 5 fields, +880 prefix, and Create Account button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Header
    expect(find.text('AgriCare'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Create Your Account'), findsOneWidget);

    // Verify Fields
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('+880'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);

    // Verify Password requirements helper
    expect(find.text('At least 8 characters'), findsOneWidget);
    expect(find.text('At least one letter (A-Z, a-z)'), findsOneWidget);
    expect(find.text('At least one number (0-9)'), findsOneWidget);

    // Verify Create Account button
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Already have an account? '), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}

