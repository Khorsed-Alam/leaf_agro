import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/crop_model.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/disease_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/common_diseases_section.dart';
import 'widgets/crop_care_tips_section.dart';
import 'widgets/crop_hero_section.dart';
import 'widgets/crop_information_section.dart';
import 'widgets/detect_crop_disease_button.dart';

/// Screen 08 – Crop Details Screen
/// Displays detailed agronomic information, verified AI-detectable diseases,
/// practical agricultural care tips, and prominent disease detection CTA.
class CropDetailScreen extends ConsumerStatefulWidget {
  final int cropId;

  const CropDetailScreen({
    super.key,
    required this.cropId,
  });

  @override
  ConsumerState<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends ConsumerState<CropDetailScreen> {
  bool _isBookmarked = false;

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    final isBn = ref.read(settingsProvider).language == 'bn';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? (isBn ? 'ফসল বুকমার্কে যুক্ত করা হয়েছে।' : 'Crop added to bookmarks.')
              : (isBn ? 'ফসল বুকমার্ক থেকে সরানো হয়েছে।' : 'Crop removed from bookmarks.'),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.forestGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final cropAsync = ref.watch(cropByIdProvider(widget.cropId));
    final diseasesAsync = ref.watch(diseasesByCropProvider(widget.cropId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/crop-select');
            }
          },
        ),
        title: cropAsync.maybeWhen(
          data: (crop) => Text(
            crop != null
                ? (isBn ? '${crop.nameBn}-এর বিবরণ' : '${crop.nameEn} Profile')
                : (isBn ? 'ফসলের বিবরণ' : 'Crop Details'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          orElse: () => Text(
            isBn ? 'ফসলের বিবরণ' : 'Crop Details',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.freshGreen : AppColors.secondaryText,
            ),
            tooltip: isBn ? 'বুকমার্ক' : 'Bookmark',
            onPressed: _toggleBookmark,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cropAsync.when(
        data: (crop) {
          if (crop == null) {
            return _buildNotFoundState(isBn);
          }

          return _buildLoadedContent(crop, diseasesAsync, isBn);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
        error: (err, _) => _buildErrorState(err.toString(), isBn),
      ),
    );
  }

  Widget _buildLoadedContent(
    CropModel crop,
    AsyncValue<dynamic> diseasesAsync,
    bool isBn,
  ) {
    return Column(
      children: [
        // Independently scrollable main content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Crop Hero Section
                CropHeroSection(
                  crop: crop,
                  isBn: isBn,
                ),

                // 2. Crop Information Section (Agronomic Attributes)
                CropInformationSection(
                  cropId: crop.id,
                  isBn: isBn,
                ),

                // 3. Common Diseases Section
                diseasesAsync.when(
                  data: (diseases) => CommonDiseasesSection(
                    diseases: diseases,
                    isBn: isBn,
                  ),
                  loading: () => CommonDiseasesSection(
                    diseases: const [],
                    isLoading: true,
                    isBn: isBn,
                  ),
                  error: (e, _) => CommonDiseasesSection(
                    diseases: const [],
                    errorMessage: e.toString(),
                    isBn: isBn,
                    onRetry: () => ref.invalidate(diseasesByCropProvider(crop.id)),
                  ),
                ),

                // 4. General Crop Care Tips Section
                CropCareTipsSection(
                  cropId: crop.id,
                  isBn: isBn,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // 5. Fixed Bottom Disease Detection CTA
        DetectCropDiseaseButton(
          crop: crop,
          isBn: isBn,
        ),
      ],
    );
  }

  Widget _buildNotFoundState(bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grass, size: 64, color: AppColors.secondaryText),
            const SizedBox(height: 16),
            Text(
              isBn ? 'ফসল খুঁজে পাওয়া যায়নি' : 'Crop Not Found',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isBn
                  ? 'অনুরোধকৃত ফসলের রেকর্ড সিস্টেমে পাওয়া যায়নি।'
                  : 'The requested crop could not be found in the catalog.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go('/crop-select'),
              icon: const Icon(Icons.arrow_back),
              label: Text(isBn ? 'ফসলের তালিকায় ফিরুন' : 'Back to Crop Selection'),
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
    );
  }

  Widget _buildErrorState(String error, bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              isBn ? 'তথ্য লোড করতে সমস্যা হয়েছে' : 'Failed to Load Crop Data',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.invalidate(cropByIdProvider(widget.cropId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
