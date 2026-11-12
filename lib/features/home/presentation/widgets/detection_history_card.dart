import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/prediction_history_model.dart';

class DetectionHistoryCard extends StatelessWidget {
  final PredictionHistoryModel scan;
  final bool isBn;
  final VoidCallback onTap;

  const DetectionHistoryCard({
    super.key,
    required this.scan,
    required this.isBn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse crop and disease from predictedClass format e.g. "Rice___Brown_Spot"
    final parts = scan.predictedClass.split('___');
    final cropName = parts[0].replaceAll('_', ' ');
    final diseaseName = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
    final isHealthy = diseaseName.toLowerCase().contains('healthy');
    final confidencePct = (scan.confidence * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreen),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail or Status Icon Badge
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 58,
                    height: 58,
                    child: _buildThumbnail(isHealthy),
                  ),
                ),

                const SizedBox(width: 14),

                // Center Column: Crop, Disease, Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cropName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Disease Status Indicator Pill
                          _buildStatusPill(isHealthy),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        diseaseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isHealthy ? AppColors.forestGreen : const Color(0xFFB91C1C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatTimestamp(scan.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (scan.confidence > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•  ${isBn ? "নির্ভুলতা" : "Confidence"}: $confidencePct%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Right Arrow
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isHealthy) {
    final bgColor = isHealthy ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final textColor = isHealthy ? AppColors.forestGreen : const Color(0xFFDC2626);
    final text = isHealthy
        ? (isBn ? 'সুস্থ' : 'Healthy')
        : (isBn ? 'আক্রান্ত' : 'Disease');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isHealthy) {
    if (scan.imagePath != null && scan.imagePath!.isNotEmpty) {
      if (scan.imagePath!.startsWith('http')) {
        return Image.network(
          scan.imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(isHealthy),
        );
      } else if (!kIsWeb) {
        try {
          final file = File(scan.imagePath!);
          if (file.existsSync()) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(isHealthy),
            );
          }
        } catch (_) {}
      }
    }
    return _buildPlaceholderIcon(isHealthy);
  }

  Widget _buildPlaceholderIcon(bool isHealthy) {
    final bgColor = isHealthy ? AppColors.softNaturalGreen : const Color(0xFFFEF2F2);
    final iconColor = isHealthy ? AppColors.forestGreen : const Color(0xFFEF4444);

    return Container(
      color: bgColor,
      child: Center(
        child: Icon(
          isHealthy ? Icons.eco_rounded : Icons.coronavirus_outlined,
          color: iconColor,
          size: 28,
        ),
      ),
    );
  }
}
