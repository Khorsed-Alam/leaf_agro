import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leaf_agro/data/models/user_profile_model.dart';
import 'package:leaf_agro/features/profile/presentation/edit_profile_screen.dart';
import 'package:leaf_agro/features/profile/presentation/profile_screen.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/account_information_card.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/detection_activity_card.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/language_selection_sheet.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/personal_information_card.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:leaf_agro/features/profile/presentation/widgets/profile_header.dart';
import 'package:leaf_agro/providers/auth_provider.dart';
import 'package:leaf_agro/providers/profile_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

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

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
    prefs = await SharedPreferences.getInstance();
  });

  final testUser = UserProfileModel(
    id: 'user_123',
    fullName: 'Mohammad Rahim',
    email: 'rahim.farmer@example.com',
    phoneNumber: '01712345678',
    district: 'Bogura',
    avatarUrl: null,
    preferredLanguage: 'en',
    role: 'farmer',
    createdAt: DateTime(2026, 11, 10, 14, 30),
  );

  final testUserIncomplete = UserProfileModel(
    id: 'user_456',
    fullName: 'Karim Mia',
    email: 'karim@example.com',
    phoneNumber: null,
    district: null,
    avatarUrl: null,
    preferredLanguage: 'en',
    role: 'farmer',
    createdAt: DateTime(2026, 5, 20),
  );

  Widget createTestWidget({
    UserProfileModel? profile,
    int detectionCount = 14,
    String language = 'en',
    _FakeAuthNotifier? customAuthNotifier,
  }) {
    final authNotifier = customAuthNotifier ??
        _FakeAuthNotifier(
          AuthState(status: AuthStatus.authenticated, user: profile ?? testUser),
        );

    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => const EditProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const Scaffold(body: Text('History Destination Screen')),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Text('Settings Destination Screen')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Destination Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authProvider.overrideWith(() => authNotifier),
        profileProvider.overrideWith((ref) => Future.value(profile ?? testUser)),
        userDetectionCountProvider.overrideWith((ref) => Future.value(detectionCount)),
        settingsProvider.overrideWith((ref) => SettingsNotifier(prefs)..setLanguage(language)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('Screen 24: User Profile Screen Tests', () {
    testWidgets('Header renders user name, email, avatar, and account status', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Mohammad Rahim'), findsWidgets);
      expect(find.text('rahim.farmer@example.com'), findsWidgets);
      expect(find.text('Your AgriCare Account'), findsOneWidget);
    });

    testWidgets('ProfileAvatar renders initials when avatarUrl is null', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ProfileAvatar), findsOneWidget);
      // "Mohammad Rahim" -> "MR"
      expect(find.text('MR'), findsOneWidget);
    });

    testWidgets('PersonalInformationCard renders full personal details', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PersonalInformationCard), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Mohammad Rahim'), findsWidgets);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('rahim.farmer@example.com'), findsWidgets);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('01712345678'), findsOneWidget);
      expect(find.text('Location / District'), findsOneWidget);
      expect(find.text('Bogura'), findsOneWidget);
    });

    testWidgets('PersonalInformationCard handles missing optional fields with localized fallback', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(profile: testUserIncomplete));
      await tester.pumpAndSettle();

      // Phone and District are missing
      expect(find.text('Not added'), findsNWidgets(2));
    });

    testWidgets('DetectionActivityCard displays authentic detection count and navigates to History', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(detectionCount: 28));
      await tester.pumpAndSettle();

      expect(find.byType(DetectionActivityCard), findsOneWidget);
      expect(find.text('Your Plant Health Activity'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
      expect(find.text('Total Detections'), findsOneWidget);
      expect(find.text('Your saved plant health scans'), findsOneWidget);

      // Tap on card -> navigates to Screen 22 History
      await tester.tap(find.byType(DetectionActivityCard));
      await tester.pumpAndSettle();

      expect(find.text('History Destination Screen'), findsOneWidget);
    });

    testWidgets('AccountInformationCard formats member since timestamp correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AccountInformationCard), findsOneWidget);
      expect(find.text('Account Information'), findsOneWidget);
      expect(find.text('Member Since'), findsOneWidget);
      expect(find.text('Member since November 2026'), findsOneWidget);
    });

    testWidgets('Preferences section renders Edit Profile, Settings, and Language tiles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('Tapping Settings navigates to Settings screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings Destination Screen'), findsOneWidget);
    });

    testWidgets('Tapping Edit Profile navigates to Edit Profile screen', (tester) async {
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
      expect(find.text('বাংলা (Bangla)'), findsOneWidget);
    });

    testWidgets('Logout confirmation dialog opens and can be cancelled', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = _FakeAuthNotifier(
        AuthState(status: AuthStatus.authenticated, user: testUser),
      );

      await tester.pumpWidget(createTestWidget(customAuthNotifier: fakeAuth));
      await tester.pumpAndSettle();

      // Tap Log Out button near bottom
      await tester.ensureVisible(find.byType(OutlinedButton));
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(find.byType(LogoutConfirmationDialog), findsOneWidget);
      expect(find.text('Log Out?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to log out of your AgriCare AI account?'),
        findsOneWidget,
      );

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(LogoutConfirmationDialog), findsNothing);
      expect(fakeAuth.signedOut, isFalse);
    });

    testWidgets('Confirming logout calls sign out and routes to login', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = _FakeAuthNotifier(
        AuthState(status: AuthStatus.authenticated, user: testUser),
      );

      await tester.pumpWidget(createTestWidget(customAuthNotifier: fakeAuth));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(OutlinedButton));
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Tap Log Out inside dialog
      final logoutDialogButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Log Out'),
      );
      await tester.tap(logoutDialogButton);
      await tester.pumpAndSettle();

      expect(fakeAuth.signedOut, isTrue);
      expect(find.text('Login Destination Screen'), findsOneWidget);
    });

    testWidgets('Bangla localization renders appropriate Bengali text and numerals', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(language: 'bn', detectionCount: 15));
      await tester.pumpAndSettle();

      expect(find.text('আমার প্রোফাইল'), findsOneWidget);
      expect(find.text('আপনার অ্যাগ্রিকেয়ার অ্যাকাউন্ট'), findsOneWidget);
      expect(find.text('ব্যক্তিগত তথ্য'), findsOneWidget);
      expect(find.text('পুরো নাম'), findsOneWidget);
      expect(find.text('আপনার ফসলের স্বাস্থ্য কার্যক্রম'), findsOneWidget);
      expect(find.text('১৫'), findsOneWidget); // 15 in Bengali
      expect(find.text('মোট স্ক্যান ও শনাক্তকরণ'), findsOneWidget);
      expect(find.text('অ্যাকাউন্টের তথ্য'), findsOneWidget);
      expect(find.text('যোগদানের তারিখ'), findsOneWidget);
      expect(find.text('প্রোফাইল সম্পাদনা'), findsOneWidget);
      expect(find.text('সেটিংস'), findsOneWidget);
      expect(find.text('লগআউট'), findsOneWidget);
    });
  });
}
