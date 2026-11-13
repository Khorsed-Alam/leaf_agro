import 'package:go_router/go_router.dart';
import '../../data/models/prediction_model.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/crops/presentation/crop_list_screen.dart';
import '../../features/crops/presentation/crop_detail_screen.dart';
import '../../features/crops/presentation/crop_selection_screen.dart';
import '../../features/diseases/presentation/disease_catalog_screen.dart';
import '../../features/diseases/presentation/disease_detail_screen.dart';
import '../../features/detection/presentation/detection_start_screen.dart';
import '../../features/detection/presentation/camera_screen.dart';
import '../../features/detection/presentation/gallery_upload_screen.dart';
import '../../features/detection/presentation/image_preview_screen.dart';
import '../../features/detection/presentation/analyzing_screen.dart';
import '../../features/detection/presentation/detection_result_screen.dart';
import '../../features/recommendations/presentation/treatment_screen.dart';
import '../../features/recommendations/presentation/prevention_screen.dart';
import '../../features/recommendations/presentation/solutions_screen.dart';
import '../../features/recovery/presentation/recovery_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/history_detail_screen.dart';
import '../../features/history/presentation/filter_search_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/language_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/help/presentation/help_screen.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/search/presentation/global_search_screen.dart';

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
      path: '/crop-select',
      builder: (context, state) => const CropSelectionScreen(),
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
          path: 'gallery',
          builder: (context, state) => const GalleryUploadScreen(),
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
          builder: (context, state) {
            PredictionModel? prediction;
            String? imagePath;
            if (state.extra is PredictionModel) {
              prediction = state.extra as PredictionModel;
            } else if (state.extra is Map<String, dynamic>) {
              final map = state.extra as Map<String, dynamic>;
              prediction = map['prediction'] as PredictionModel?;
              imagePath = map['imagePath'] as String?;
            }
            return DetectionResultScreen(
              initialPrediction: prediction,
              initialImagePath: imagePath,
            );
          },
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
      path: '/prevention',
      builder: (context, state) {
        final cropIdStr = state.uri.queryParameters['cropId'];
        final cropId = cropIdStr != null ? int.tryParse(cropIdStr) : null;
        final diseaseIdStr = state.uri.queryParameters['diseaseId'];
        final diseaseId =
            diseaseIdStr != null ? int.tryParse(diseaseIdStr) : null;
        return PreventionScreen(
          cropId: cropId,
          diseaseId: diseaseId,
        );
      },
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            final cropIdStr = state.uri.queryParameters['cropId'];
            final cropId = cropIdStr != null ? int.tryParse(cropIdStr) : null;
            return PreventionScreen(
              diseaseId: id,
              cropId: cropId,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/solutions',
      builder: (context, state) {
        final cropIdStr = state.uri.queryParameters['cropId'];
        final cropId = cropIdStr != null ? int.tryParse(cropIdStr) : null;
        final diseaseIdStr = state.uri.queryParameters['diseaseId'];
        final diseaseId =
            diseaseIdStr != null ? int.tryParse(diseaseIdStr) : null;
        return SolutionsScreen(
          cropId: cropId,
          diseaseId: diseaseId,
        );
      },
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            final cropIdStr = state.uri.queryParameters['cropId'];
            final cropId = cropIdStr != null ? int.tryParse(cropIdStr) : null;
            return SolutionsScreen(
              diseaseId: id,
              cropId: cropId,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/products',
      redirect: (context, state) {
        final cropId = state.uri.queryParameters['cropId'];
        final diseaseId = state.uri.queryParameters['diseaseId'];
        final params = <String>[];
        if (cropId != null) params.add('cropId=$cropId');
        if (diseaseId != null) params.add('diseaseId=$diseaseId');
        final query = params.isNotEmpty ? '?${params.join('&')}' : '';
        return '/solutions$query';
      },
      routes: [
        GoRoute(
          path: ':id',
          redirect: (context, state) {
            final id = state.pathParameters['id'];
            return '/solutions/$id';
          },
        ),
      ],
    ),
    GoRoute(
      path: '/recovery',
      builder: (context, state) {
        final scanId = state.uri.queryParameters['scanId'];
        return RecoveryScreen(scanId: scanId);
      },
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id'];
            return RecoveryScreen(scanId: id);
          },
        ),
      ],
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
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
      ],
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
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'];
        return GlobalSearchScreen(initialQuery: query);
      },
    ),
  ],
);
