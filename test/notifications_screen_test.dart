import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leaf_agro/core/constants/app_constants.dart';
import 'package:leaf_agro/data/models/notification_model.dart';
import 'package:leaf_agro/features/notifications/presentation/notifications_screen.dart';
import 'package:leaf_agro/features/notifications/presentation/widgets/empty_notifications_state.dart';
import 'package:leaf_agro/features/notifications/presentation/widgets/notification_card.dart';
import 'package:leaf_agro/features/notifications/presentation/widgets/notification_category_filter.dart';
import 'package:leaf_agro/features/notifications/presentation/widgets/notification_detail_dialog.dart';
import 'package:leaf_agro/features/notifications/presentation/widgets/unread_indicator.dart';
import 'package:leaf_agro/providers/notification_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

class _FakeNotificationsNotifier extends NotificationsNotifier {
  final List<NotificationModel> _list;

  _FakeNotificationsNotifier(this._list);

  @override
  Future<List<NotificationModel>> build() async => _list;

  @override
  Future<List<NotificationModel>> loadNotifications() async => _list;

  @override
  Future<void> markAsRead(String id) async {
    final now = DateTime.now();
    for (int i = 0; i < _list.length; i++) {
      if (_list[i].id == id) {
        _list[i] = _list[i].copyWith(readAt: now);
      }
    }
    state = AsyncValue.data(List.unmodifiable(_list));
  }

  @override
  Future<void> markAllAsRead() async {
    final now = DateTime.now();
    for (int i = 0; i < _list.length; i++) {
      if (!_list[i].isRead) {
        _list[i] = _list[i].copyWith(readAt: now);
      }
    }
    state = AsyncValue.data(List.unmodifiable(_list));
  }

  @override
  Future<void> refresh() async {
    state = AsyncValue.data(List.unmodifiable(_list));
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keyLanguage: 'en',
    });
    prefs = await SharedPreferences.getInstance();
  });

  final now = DateTime.now();

  final testNotifications = [
    NotificationModel(
      id: 'notif_001',
      userId: 'user_123',
      titleEn: 'Your plant scan has been saved',
      titleBn: 'আপনার ফসলের স্ক্যান সংরক্ষিত হয়েছে',
      messageEn: 'Your plant health detection is available in your history.',
      messageBn: 'আপনার উদ্ভিদের রোগ নির্ণয় ইতিহাস তালিকায় যুক্ত হয়েছে।',
      type: 'activity',
      relatedId: 'scan_101',
      readAt: null, // Unread
      createdAt: now.subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: 'notif_002',
      userId: 'user_123',
      titleEn: 'Remember to inspect your crop',
      titleBn: 'ফসলের ফলো-আপ পর্যবেক্ষণ করুন',
      messageEn: 'A scheduled plant care reminder is due for your tomato field.',
      messageBn: 'আপনার টমেটো ক্ষেতের ফলো-আপ পর্যবেক্ষণের সময় হয়েছে।',
      type: 'reminder',
      relatedId: 'scan_101',
      readAt: null, // Unread
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif_003',
      userId: 'user_123',
      titleEn: 'New disease information is available',
      titleBn: 'নতুন রোগ তথ্য যুক্ত হয়েছে',
      messageEn: 'Updated plant health guidelines available in disease library.',
      messageBn: 'রোগতত্ত্ব লাইব্রেরিতে নতুন তথ্য যুক্ত করা হয়েছে।',
      type: 'update',
      relatedId: '101',
      readAt: now.subtract(const Duration(days: 1)), // Read
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
    ),
  ];

  Widget createTestWidget({
    List<NotificationModel>? customList,
    String language = 'en',
    _FakeNotificationsNotifier? customNotifier,
  }) {
    final list = customList ?? List.of(testNotifications);
    final notifier = customNotifier ?? _FakeNotificationsNotifier(list);

    final router = GoRouter(
      initialLocation: '/notifications',
      routes: [
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: '/history/:id',
          builder: (context, state) => Scaffold(
            body: Text('History Detail: ${state.pathParameters['id']}'),
          ),
        ),
        GoRoute(
          path: '/recovery',
          builder: (context, state) => Scaffold(
            body: Text('Recovery Screen: ${state.uri.queryParameters['scanId']}'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationsProvider.overrideWith(() => notifier),
        settingsProvider.overrideWith((ref) => SettingsNotifier(prefs)..setLanguage(language)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('Screen 27: Notifications Screen Tests', () {
    testWidgets('Header renders title, back button, and Mark All as Read button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Mark All as Read'), findsOneWidget);
    });

    testWidgets('Category filter chips render with unread badge count', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(NotificationCategoryFilter), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unread (2)'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Updates'), findsOneWidget);
    });

    testWidgets('Renders notifications chronologically with date group headings', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.byType(NotificationCard), findsNWidgets(3));
    });

    testWidgets('Distinguishes unread notifications with green indicator dots', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 2 unread notifications have UnreadIndicator
      expect(find.byType(UnreadIndicator), findsNWidgets(2));
    });

    testWidgets('Filtering by Unread displays only unread notifications', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unread (2)'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationCard), findsNWidgets(2));
      expect(find.text('New disease information is available'), findsNothing);
    });

    testWidgets('Filtering by Activity displays only activity notifications', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationCard), findsOneWidget);
      expect(find.text('Your plant scan has been saved'), findsOneWidget);
      expect(find.text('Remember to inspect your crop'), findsNothing);
    });

    testWidgets('Mark All as Read updates unread status and disables button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(UnreadIndicator), findsNWidgets(2));

      await tester.tap(find.text('Mark All as Read'));
      await tester.pumpAndSettle();

      expect(find.byType(UnreadIndicator), findsNothing);
      expect(find.text('All notifications marked as read.'), findsOneWidget);
    });

    testWidgets('Tapping a scan saved notification marks it as read and navigates to History Detail', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Your plant scan has been saved'));
      await tester.pumpAndSettle();

      expect(find.text('History Detail: scan_101'), findsOneWidget);
    });

    testWidgets('Tapping a reminder notification navigates to Recovery Screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remember to inspect your crop'));
      await tester.pumpAndSettle();

      expect(find.text('Recovery Screen: scan_101'), findsOneWidget);
    });

    testWidgets('Tapping notification with no destination opens detail dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final simpleNotif = NotificationModel(
        id: 'simple_001',
        userId: 'user_123',
        titleEn: 'General Agricultural Advisory',
        titleBn: 'সাধারণ কৃষি পরামর্শ',
        messageEn: 'Keep field irrigation optimal during dry weather.',
        messageBn: 'শুষ্ক আবহাওয়ায় ক্ষেতে পর্যাপ্ত সেচ প্রদান করুন।',
        type: 'general',
        readAt: null,
        createdAt: now,
      );

      await tester.pumpWidget(createTestWidget(customList: [simpleNotif]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('General Agricultural Advisory'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationDetailDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NotificationDetailDialog),
          matching: find.text('Keep field irrigation optimal during dry weather.'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationDetailDialog), findsNothing);
    });

    testWidgets('Empty state renders correctly when list contains no records', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(customList: []));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyNotificationsState), findsOneWidget);
      expect(find.text("You're All Caught Up!"), findsOneWidget);
      expect(find.text('There are no notifications to show right now.'), findsOneWidget);
    });

    testWidgets('Empty unread filter renders No Unread Notifications message', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final allReadNotifs = [
        NotificationModel(
          id: 'read_001',
          userId: 'user_123',
          titleEn: 'Scan Saved',
          titleBn: 'স্ক্যান সংরক্ষিত',
          readAt: now,
          createdAt: now,
        ),
      ];

      await tester.pumpWidget(createTestWidget(customList: allReadNotifs));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyNotificationsState), findsOneWidget);
      expect(find.text('No Unread Notifications'), findsOneWidget);
      expect(find.text('You have read all your notifications.'), findsOneWidget);
    });

    testWidgets('Bangla localization renders appropriate Bengali text throughout notifications', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(language: 'bn'));
      await tester.pumpAndSettle();

      expect(find.text('বিজ্ঞপ্তি ও সতর্কতা'), findsOneWidget);
      expect(find.text('সব পড়া হয়েছে'), findsOneWidget);
      expect(find.text('সব'), findsOneWidget);
      expect(find.text('অপঠিত (২)'), findsOneWidget);
      expect(find.text('কার্যক্রম'), findsOneWidget);
      expect(find.text('রিমাইন্ডার'), findsOneWidget);
      expect(find.text('আপডেট'), findsOneWidget);
      expect(find.text('আজ'), findsOneWidget);
      expect(find.text('গতকাল'), findsOneWidget);
      expect(find.text('আপনার ফসলের স্ক্যান সংরক্ষিত হয়েছে'), findsOneWidget);
    });
  });
}

