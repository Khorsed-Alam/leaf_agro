import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/analyzing/analyzing_error_view.dart';
import 'widgets/analyzing/analyzing_header.dart';
import 'widgets/analyzing/analyzing_status_section.dart';
import 'widgets/analyzing/scanning_image_view.dart';

/// Screen 15 – AI Analysis Screen for AgriCare AI (LeafAgro)
/// Reassuring loading screen executing real on-device neural network inference
/// with laser scanning visual feedback and genuine offline status.
class AnalyzingScreen extends ConsumerStatefulWidget {
  final bool autoStart;
  final bool animateScanning;

  const AnalyzingScreen({
    super.key,
    this.autoStart = true,
    this.animateScanning = true,
  });

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  bool _isAnalyzing = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runInference();
      });
    }
  }

  Future<void> _runInference() async {
    if (_isAnalyzing || !mounted) return;

    final imagePath = ref.read(detectionProvider).imagePath;
    final isBn = ref.read(settingsProvider).language == 'bn';

    if (imagePath == null || imagePath.isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = isBn
              ? 'বিশ্লেষণের জন্য কোনো ছবি পাওয়া যায়নি।'
              : 'No leaf image found to analyze.';
        });
      }
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Execute genuine TFLite on-device inference
      await ref.read(detectionProvider.notifier).runDetection();

      if (!mounted) return;

      final currentState = ref.read(detectionProvider);

      if (currentState.status == DetectionStatus.success &&
          currentState.prediction != null) {
        // Navigate directly to Screen 16: Diagnosis Result Screen
        try {
          context.go('/detect/result');
        } catch (_) {
          // In test environments without GoRouter host
        }
      } else {
        setState(() {
          _isAnalyzing = false;
          _hasError = true;
          _errorMessage = currentState.errorMessage;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _handleReturnToPreview() {
    try {
      context.pop();
    } catch (_) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final detectionState = ref.watch(detectionProvider);
    final selectedCrop = ref.watch(selectedCropProvider);

    final imagePath = detectionState.imagePath ?? '';
    final cropName = selectedCrop != null
        ? (isBn ? selectedCrop.nameBn : selectedCrop.nameEn)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _hasError
            ? AnalyzingErrorView(
                onRetry: _runInference,
                onReturnToPreview: _handleReturnToPreview,
                errorMessage: _errorMessage,
                isBn: isBn,
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 1. Uncluttered Branding Header
                    AnalyzingHeader(isBn: isBn),

                    const SizedBox(height: 8),

                    // 2. Large Leaf Preview with Animated Green Laser Scanning Line
                    ScanningImageView(
                      imagePath: imagePath,
                      selectedCropName: cropName,
                      animate: widget.animateScanning && _isAnalyzing,
                      isBn: isBn,
                    ),

                    const SizedBox(height: 16),

                    // 3. Status Section (Heading, Subtitle, Progress, On-device Badge)
                    AnalyzingStatusSection(isBn: isBn),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
