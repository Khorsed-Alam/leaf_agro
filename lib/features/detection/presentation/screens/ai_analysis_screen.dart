import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/detection_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../providers/plant_disease_prediction_provider.dart';
import '../providers/selected_image_provider.dart';
import '../widgets/analyzing/analyzing_error_view.dart';
import '../widgets/analyzing/analyzing_header.dart';

/// Screen 15 – Production AI Analysis Screen for AgriCare AI.
/// Preprocesses the leaf image, executes offline MobileNetV2 inference,
/// provides reassuring visual feedback, and navigates to the diagnosis result.
class AiAnalysisScreen extends ConsumerStatefulWidget {
  final bool autoStart;

  const AiAnalysisScreen({
    super.key,
    this.autoStart = true,
  });

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerInference();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerInference() {
    ref.read(plantDiseasePredictionProvider.notifier).runInference();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final predictionState = ref.watch(plantDiseasePredictionProvider);
    final selectedImageState = ref.watch(selectedImageProvider);
    final detectionState = ref.watch(detectionProvider);

    final imagePath = selectedImageState.selectedImage?.imagePath ??
        detectionState.imagePath;

    // Listen for prediction success to trigger navigation
    ref.listen<PlantDiseasePredictionState>(
      plantDiseasePredictionProvider,
      (previous, next) {
        if (next.isSuccess && next.prediction != null) {
          try {
            context.go('/detect/result');
          } catch (_) {
            // Handled in headless test environments
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AnalyzingHeader(isBn: isBn),
            Expanded(
              child: predictionState.hasError
                  ? AnalyzingErrorView(
                      isBn: isBn,
                      errorMessage: predictionState.getLocalizedMessage(isBn),
                      onRetry: () {
                        ref.read(plantDiseasePredictionProvider.notifier).retry();
                      },
                      onReturnToPreview: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/detect/preview');
                        }
                      },
                    )
                  : _buildAnalyzingContent(isBn, imagePath, predictionState.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingContent(
    bool isBn,
    String? imagePath,
    PlantDiseasePredictionStatus status,
  ) {
    final String statusTitle;
    final String statusSubtitle;

    switch (status) {
      case PlantDiseasePredictionStatus.preprocessing:
        statusTitle = isBn ? 'ছবি প্রস্তুত করা হচ্ছে...' : 'Preprocessing Leaf Image...';
        statusSubtitle = isBn
            ? 'আকার রূপান্তর এবং অপ্টিমাইজেশন চলছে'
            : 'Resizing to 224x224 & validating input tensor';
        break;
      case PlantDiseasePredictionStatus.analyzing:
        statusTitle = isBn ? 'এআই রোগ নির্ণয় চলছে...' : 'Analyzing Plant Disease...';
        statusSubtitle = isBn
            ? 'অন-ডিভাইস মোবাইলনেট-ভি২ মডেল কাজ করছে'
            : 'Running offline MobileNetV2 neural network';
        break;
      case PlantDiseasePredictionStatus.success:
        statusTitle = isBn ? 'বিশ্লেষণ সম্পন্ন!' : 'Analysis Complete!';
        statusSubtitle = isBn ? 'ফলাফল লোড হচ্ছে...' : 'Loading diagnosis results...';
        break;
      case PlantDiseasePredictionStatus.idle:
      default:
        statusTitle = isBn ? 'প্রস্তুত হচ্ছে...' : 'Initializing AI engine...';
        statusSubtitle = isBn ? 'অফলাইনে রোগ নির্ণয় প্রস্তুত' : 'Ready for on-device inference';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Preview Card with Pulse Animation
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forestGreen.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.forestGreen.withValues(alpha: 0.3),
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imagePath != null && File(imagePath).existsSync())
                      Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        color: AppColors.surfaceContainer,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    // Scanning line overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.forestGreen.withValues(alpha: 0.1),
                            AppColors.forestGreen.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Genuine progress indicator (spinner)
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
            ),
          ),
          const SizedBox(height: 24),

          // Status title
          Text(
            statusTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),

          // Status subtitle
          Text(
            statusSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          // Offline privacy pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.softNaturalGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.offline_bolt_rounded,
                  size: 16,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  isBn ? '১০০% অফলাইন প্রসেসিং • নিরাপদ ও দ্রুত' : '100% On-Device • Private & Fast',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
