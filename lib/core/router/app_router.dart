import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/crops/presentation/crop_list_screen.dart';
import '../../features/crops/presentation/crop_detail_screen.dart';
import '../../features/diseases/presentation/disease_catalog_screen.dart';
import '../../features/diseases/presentation/disease_detail_screen.dart';
import '../../features/detection/presentation/detection_start_screen.dart';
import '../../features/detection/presentation/camera_screen.dart';
import '../../features/detection/presentation/image_preview_screen.dart';
import '../../features/detection/presentation/analyzing_screen.dart';
import '../../features/detection/presentation/detection_result_screen.dart';
import '../../features/recommendations/presentation/treatment_screen.dart';
import '../../features/recommendations/presentation/prevention_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/history_detail_screen.dart';
import '../../features/history/presentation/filter_search_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/language_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/help/presentation/help_screen.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/about/presentation/about_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/crops',
      builder: (context, state) => const CropListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            return CropDetailScreen(cropId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/diseases',
      builder: (context, state) => const DiseaseCatalogScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            return DiseaseDetailScreen(diseaseId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/detect',
      builder: (context, state) => const DetectionStartScreen(),
      routes: [
        GoRoute(
          path: 'camera',
          builder: (context, state) => const CameraScreen(),
        ),
        GoRoute(
          path: 'preview',
          builder: (context, state) => const ImagePreviewScreen(),
        ),
        GoRoute(
          path: 'analyzing',
          builder: (context, state) => const AnalyzingScreen(),
        ),
        GoRoute(
          path: 'result',
          builder: (context, state) => const DetectionResultScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/recommendations/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
        return TreatmentScreen(diseaseId: id);
      },
    ),
    GoRoute(
      path: '/prevention/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
        return PreventionScreen(diseaseId: id);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
      routes: [
        GoRoute(
          path: 'filter',
          builder: (context, state) => const FilterSearchScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return HistoryDetailScreen(scanId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'language',
          builder: (context, state) => const LanguageScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);

