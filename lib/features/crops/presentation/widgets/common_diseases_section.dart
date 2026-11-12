import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/disease_model.dart';
import 'disease_thumbnail_card.dart';

class CommonDiseasesSection extends StatelessWidget {
  final List<DiseaseModel> diseases;
  final bool isLoading;
  final String? errorMessage;
  final bool isBn;
  final VoidCallback? onRetry;

  const CommonDiseasesSection({
    super.key,
    required this.diseases,
    this.isLoading = false,
    this.errorMessage,
    required this.isBn,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.freshGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBn ? 'পরিচিত রোগসমূহ' : 'Common Diseases',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.softNaturalGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isBn ? '${diseases.length}টি রোগ' : '${diseases.length} mapped',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isBn
                      ? 'AI মডেল দ্বারা সমর্থিত রোগ ও ক্ষতির লক্ষণসমূহ জানুন।'
                      : 'Learn about diseases associated with this crop.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Content States
          if (isLoading)
            const SizedBox(
              height: 175,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else if (errorMessage != null)
            _buildErrorState()
          else if (diseases.isEmpty)
            _buildEmptyState()
          else
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: diseases.length,
                itemBuilder: (context, index) {
                  return DiseaseThumbnailCard(
                    disease: diseases[index],
                    isBn: isBn,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 36, color: AppColors.secondaryText),
            const SizedBox(height: 8),
            Text(
              isBn
                  ? 'এই ফসলের জন্য কোনো রোগ তথ্য বর্তমানে উপলব্ধ নেই।'
                  : 'No disease information is currently available for this crop.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage ?? 'Failed to load disease catalog.',
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(isBn ? 'পুনরায় চেষ্টা' : 'Retry'),
            ),
        ],
      ),
    );
  }
}
