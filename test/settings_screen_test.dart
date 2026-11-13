import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:leaf_agro/core/constants/app_constants.dart';
import 'package:leaf_agro/data/models/user_profile_model.dart';
import 'package:leaf_agro/features/profile/presentation/edit_profile_screen.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/language_selection_sheet.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:leaf_agro/features/settings/presentation/settings_screen.dart';
import 'package:leaf_agro/features/settings/presentation/widgets/ai_model_information_sheet.dart';
import 'package:leaf_agro/features/settings/presentation/widgets/change_password_dialog.dart';
import 'package:leaf_agro/features/settings/presentation/widgets/legal_document_dialog.dart';
import 'package:leaf_agro/features/settings/presentation/widgets/notification_preferences_sheet.dart';
import 'package:leaf_agro/features/settings/presentation/widgets/storage_cache_sheet.dart';
import 'package:leaf_agro/features/settings/presentation/widgets/theme_selection_sheet.dart';
import 'package:leaf_agro/providers/auth_provider.dart';
import 'package:leaf_agro/providers/profile_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:leaf_agro/services/auth_service.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final AuthState _initialState;
  bool signedOut = false;

  _FakeAuthNotifier(this._initialState);

  @override
  Future<AuthState> build() async => _initialState;

  @override
  Future<void> signOut() async {
    signedOut = true;
    state = const AsyncValue.data(AuthState(status: AuthStatus.unauthenticated));
  }
}

class _FakeAuthService extends AuthService {
  String? lastUpdatedPassword;

  @override
  Future<UserResponse> updatePassword(String newPassword) async {
    lastUpdatedPassword = newPassword;
    return UserResponse.fromJson({'user': null});
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keyLanguage: 'en',
      AppConstants.keyThemeMode: 'system',
      AppConstants.keyNotificationsEnabled: true,
      AppConstants.keyPlantCareReminders: true,
      AppConstants.keyDetectionAlerts: true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  final testUser = UserProfileModel(
    id: 'user_settings_101',
    fullName: 'Kamal Hossain',
    email: 'kamal@agricare.ai',
    phoneNumber: '01812345678',
    district: 'Dinajpur',
    preferredLanguage: 'en',
    role: 'farmer',
    createdAt: DateTime(2026, 11, 1),
  );

  Widget createTestWidget({
    String language = 'en',
    _FakeAuthNotifier? customAuthNotifier,
    _FakeAuthService? customAuthService,
  }) {
    final authNotifier = customAuthNotifier ??
        _FakeAuthNotifier(
          AuthState(status: AuthStatus.authenticated, user: testUser),
        );

    final fakeAuthService = customAuthService ?? _FakeAuthService();

    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const Scaffold(body: Text('Profile Screen')),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => const EditProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authProvider.overrideWith(() => authNotifier),
        authServiceProvider.overrideWithValue(fakeAuthService),
        profileProvider.overrideWith((ref) => Future.value(testUser)),
        settingsProvider.overrideWith((ref) => SettingsNotifier(prefs)..setLanguage(language)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('Screen 25: Settings Screen Tests', () {
    testWidgets('Header renders title and back navigation button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('Account Section renders Edit Profile, Change Password, and Logout tiles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('Tapping Edit Profile navigates to EditProfileScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.text('Save Profile'), findsOneWidget);
    });

    testWidgets('Change Password dialog opens, validates matching passwords, and updates securely', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuthService = _FakeAuthService();
      await tester.pumpWidget(createTestWidget(customAuthService: fakeAuthService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordDialog), findsOneWidget);
      expect(find.text('Enter your new password (minimum 8 characters):'), findsOneWidget);

      // Enter mismatched passwords
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'secret123');
      await tester.enterText(textFields.at(1), 'mismatch456');

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(fakeAuthService.lastUpdatedPassword, isNull);

      // Enter matching passwords
      await tester.enterText(textFields.at(1), 'secret123');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(fakeAuthService.lastUpdatedPassword, 'secret123');
      expect(find.text('Password updated successfully!'), findsOneWidget);
    });

    testWidgets('Tapping Log Out opens LogoutConfirmationDialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.byType(LogoutConfirmationDialog), findsOneWidget);
      expect(find.text('Log Out?'), findsOneWidget);

      // Cancel preserves session
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(LogoutConfirmationDialog), findsNothing);
    });

    testWidgets('Preferences Section renders Language, Notifications, and Appearance tiles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('Tapping Language opens LanguageSelectionSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectionSheet), findsOneWidget);
      expect(find.text('Select Language'), findsOneWidget);
    });

    testWidgets('Tapping Notifications opens NotificationPreferencesSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationPreferencesSheet), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Allow Notifications'), findsOneWidget);
      expect(find.text('Plant Care Reminders'), findsOneWidget);
      expect(find.text('Detection & Disease Alerts'), findsOneWidget);
    });

    testWidgets('Tapping Appearance opens ThemeSelectionSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(find.byType(ThemeSelectionSheet), findsOneWidget);
      expect(find.text('Choose Appearance'), findsOneWidget);
      expect(find.text('System Default'), findsWidgets);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('Application Section renders Offline AI Model, Storage & Cache, Privacy Policy, and Terms & Conditions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Application'), findsOneWidget);
      expect(find.text('Offline AI Model'), findsOneWidget);
      expect(find.text('Storage & Cache'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
    });

    testWidgets('Tapping Offline AI Model opens verified specifications sheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Offline AI Model'));
      await tester.tap(find.text('Offline AI Model'));
      await tester.pumpAndSettle();

      expect(find.byType(AiModelInformationSheet), findsOneWidget);
      expect(find.text('Offline AI Model Information'), findsOneWidget);
      expect(find.text('AgriCare AI Leaf Disease Detector'), findsOneWidget);
      expect(find.text('MobileNetV2 (Edge Quantized)'), findsOneWidget);
      expect(find.text('Rice, Potato, Tomato, Mango, Jute'), findsOneWidget);
    });

    testWidgets('Tapping Storage & Cache opens cache management sheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Storage & Cache'));
      await tester.tap(find.text('Storage & Cache'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StorageCacheSheet), findsOneWidget);
      expect(find.text('Storage & Cache Management'), findsOneWidget);
      expect(find.text('Clear Temporary Cache'), findsOneWidget);
    });

    testWidgets('Tapping Privacy Policy opens verified legal document dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Privacy Policy'));
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalDocumentDialog), findsOneWidget);
      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.textContaining('Your privacy is paramount'), findsOneWidget);
    });

    testWidgets('Tapping Terms & Conditions opens verified terms dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Terms & Conditions'));
      await tester.tap(find.text('Terms & Conditions'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalDocumentDialog), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsWidgets);
      expect(find.textContaining('Welcome to AgriCare AI'), findsOneWidget);
    });

    testWidgets('App Version footer renders authentic app name and build number', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(AppConstants.appName));
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
      expect(find.text('Dedicated to Bangladeshi Farmers'), findsOneWidget);
    });

    testWidgets('Bangla localization renders appropriate Bengali text throughout settings', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(language: 'bn'));
      await tester.pumpAndSettle();

      expect(find.text('সেটিংস'), findsOneWidget);
      expect(find.text('অ্যাকাউন্ট'), findsOneWidget);
      expect(find.text('প্রোফাইল সম্পাদনা'), findsOneWidget);
      expect(find.text('পাসওয়ার্ড পরিবর্তন'), findsOneWidget);
      expect(find.text('লগআউট'), findsOneWidget);
      expect(find.text('পছন্দসমূহ'), findsOneWidget);
      expect(find.text('ভাষা'), findsOneWidget);
      expect(find.text('নোটিফিকেশন'), findsOneWidget);
      expect(find.text('থিম ও ডিসপ্লে'), findsOneWidget);
      expect(find.text('অ্যাপ্লিকেশন'), findsOneWidget);
      expect(find.text('অফলাইন এআই মডেল'), findsOneWidget);
      expect(find.text('স্টোরেজ ও ক্যাশ'), findsOneWidget);
      expect(find.text('গোপনীয়তা নীতি'), findsOneWidget);
      expect(find.text('শর্তাবলী ও নীতিমালা'), findsOneWidget);
      expect(find.text('সংস্করণ 1.0.0 (বিল্ড ১)'), findsOneWidget);
      expect(find.text('বাংলাদেশি কৃষকদের জন্য নিবেদিত'), findsOneWidget);
    });
  });
}
