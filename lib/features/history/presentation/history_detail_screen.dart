import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/ai_crop_catalog.dart';
import '../../../data/models/crop_model.dart';
import '../../../data/models/disease_model.dart';
import '../../../data/models/prediction_history_model.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/disease_provider.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/details/confidence_score_card.dart';
import 'widgets/details/crop_information_card.dart';
import 'widgets/details/delete_history_confirmation_dialog.dart';
import 'widgets/details/disease_information_section.dart';
import 'widgets/details/historical_guidance_action_cards.dart';
import 'widgets/details/historical_prediction_card.dart';
import 'widgets/details/historical_record_banner.dart';
import 'widgets/details/original_scan_date_card.dart';
import 'widgets/details/original_scan_image_card.dart';

/// Screen 23 – History Details Screen for AgriCare AI (LeafAgro)
/// Displays the complete authentic details of a previously saved plant scan.
/// Strictly historical: Never triggers automatic AI inference or claims live scanning.
class HistoryDetailScreen extends ConsumerStatefulWidget {
  final String scanId;
  final PredictionHistoryModel? initialScan;

  const HistoryDetailScreen({
    super.key,
    required this.scanId,
    this.initialScan,
  });

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  CropModel? _resolveCrop(String cropName) {
    try {
      final normalized = cropName.toLowerCase().trim();
      return AiCropCatalog.verifiedSupportedCrops.firstWhere(
        (c) =>
            c.nameEn.toLowerCase() == normalized ||
            c.nameBn.toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleDelete(
      BuildContext context, PredictionHistoryModel scan, bool isBn) async {
    final confirmed = await DeleteHistoryConfirmationDialog.show(
      context: context,
      isBn: isBn,
      onConfirmDelete: () async {
        await ref.read(historyProvider.notifier).deleteScanRecord(scan.id);
      },
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'ইতিহাসের রেকর্ড সফলভাবে মুছে ফেলা হয়েছে।'
                : 'History record deleted.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/history');
      }
    }
  }

  void _handleScanAgain(
      BuildContext context, CropModel? crop, WidgetRef ref) {
    if (crop != null) {
      ref.read(selectedCropProvider.notifier).state = crop;
    }
    ref.read(detectionProvider.notifier).reset();

    try {
      context.push('/detect');
    } catch (_) {
      context.go('/detect');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final historyAsync = ref.watch(historyProvider);

    return historyAsync.when(
      data: (scans) {
        PredictionHistoryModel? scan = widget.initialScan;
        if (scan == null) {
          try {
            scan = scans.firstWhere((s) => s.id == widget.scanId);
          } catch (_) {
            scan = null;
          }
        }

        if (scan == null) {
          return _buildNotFoundScaffold(context, isBn);
        }

        final parts = scan.predictedClass.split('___');
        final rawCrop = parts[0];
        final rawDisease =
            parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
        final isHealthy = rawDisease.toLowerCase().contains('healthy') ||
            scan.predictedClass.toLowerCase().contains('healthy');

        final crop = _resolveCrop(rawCrop);

        // Fetch disease model details from catalogue or provider
        DiseaseModel? diseaseDetails;
        if (scan.diseaseId != null) {
          final diseaseAsync = ref.watch(diseaseByIdProvider(scan.diseaseId!));
          diseaseDetails = diseaseAsync.valueOrNull;
        }
        diseaseDetails ??=
            AiCropCatalog.getDiseaseByClassName(scan.predictedClass);

        final diseaseTitle = diseaseDetails != null
            ? (isBn
                ? diseaseDetails.diseaseNameBn
                : diseaseDetails.diseaseNameEn)
            : rawDisease;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceContainerLowest,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryText,
              ),
              tooltip: isBn ? 'ফিরে যান' : 'Back',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/history');
                }
              },
            ),
            title: Text(
              isBn ? 'ইতিহাসের বিস্তারিত' : 'History Details',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.forestGreen,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                tooltip: isBn ? 'মুছে ফেলুন' : 'Delete Record',
                onPressed: () => _handleDelete(context, scan!, isBn),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Historical Record Banner Indicator
                  HistoricalRecordBanner(isBn: isBn),

                  // 2. Original Leaf Photograph Card
                  OriginalScanImageCard(
                    imagePath: scan.imagePath,
                    isHealthy: isHealthy,
                    isBn: isBn,
                  ),

                  // 3. Crop Information Card
                  CropInformationCard(
                    cropName: rawCrop,
                    isBn: isBn,
                  ),

                  // 4. Historical Prediction Result Card
                  HistoricalPredictionCard(
                    predictedClass: scan.predictedClass,
                    diseaseName: diseaseTitle,
                    isHealthy: isHealthy,
                    isBn: isBn,
                  ),

                  // 5. Confidence Score Card
                  ConfidenceScoreCard(
                    confidence: scan.confidence,
                    isHealthy: isHealthy,
                    isBn: isBn,
                  ),

                  // 6. Original Scan Date & Time Card
                  OriginalScanDateCard(
                    createdAt: scan.createdAt,
                    isBn: isBn,
                  ),

                  // 7. Disease Information Summary (or Healthy Guidance)
                  DiseaseInformationSection(
                    disease: diseaseDetails,
                    isHealthy: isHealthy,
                    isBn: isBn,
                  ),

                  // 8. Treatment, Prevention & Follow-up Navigation Cards
                  HistoricalGuidanceActionCards(
                    scanId: scan.id,
                    diseaseId: scan.diseaseId ?? diseaseDetails?.id,
                    cropId: crop?.id,
                    isHealthy: isHealthy,
                    isBn: isBn,
                  ),

                  const SizedBox(height: 12),

                  // 9. Bottom Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Primary Scan Again Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _handleScanAgain(context, crop, ref),
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                            ),
                            label: Text(
                              isBn ? 'আবার স্ক্যান করুন' : 'Scan Again',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.forestGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Secondary Delete History Button
                        SizedBox(
                          height: 44,
                          child: TextButton.icon(
                            onPressed: () =>
                                _handleDelete(context, scan!, isBn),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            label: Text(
                              isBn ? 'ইতিহাস মুছে ফেলুন' : 'Delete History',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  AppColors.errorContainer.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isBn ? 'ইতিহাসের বিস্তারিত' : 'History Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.forestGreen),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isBn ? 'ইতিহাসের বিস্তারিত' : 'History Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 44,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  isBn
                      ? 'রেকর্ড লোড করা সম্ভব হয়নি'
                      : 'Failed to load historical record',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(historyProvider.notifier).refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isBn ? 'আবার চেষ্টা করুন' : 'Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundScaffold(BuildContext context, bool isBn) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isBn ? 'ইতিহাসের বিস্তারিত' : 'History Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isBn
                    ? 'রেকর্ডটি খুঁজে পাওয়া যায়নি'
                    : 'Historical Record Not Found',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isBn
                    ? 'অনুরোধকৃত স্ক্যান রেকর্ডটি মুছে ফেলা হয়েছে বা উপলব্ধ নেই।'
                    : 'The requested scan record has been removed or is no longer available.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/history');
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  isBn ? 'ইতিহাসে ফিরে যান' : 'Back to History',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
