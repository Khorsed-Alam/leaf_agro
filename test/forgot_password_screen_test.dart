import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/features/auth/presentation/forgot_password_screen.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

void main() {
  testWidgets('ForgotPasswordScreen renders hero, email input, and Send button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Heading & Description
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(
      find.text('Enter your registered email address. We will send you a password reset link.'),
      findsOneWidget,
    );

    // Verify Email field
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);

    // Verify Primary Send button
    expect(find.text('Send Reset Link'), findsOneWidget);

    // Verify Back to Login Link
    expect(find.text('Remember your password? '), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });
}

