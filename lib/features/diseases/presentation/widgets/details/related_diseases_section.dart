import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/disease_model.dart';
import '../../../../../providers/disease_provider.dart';

/// Screen 17 – Related Diseases Section
/// Displays genuine verified diseases associated with the same host crop.
/// Tapping any related disease navigates directly to its details.
class RelatedDiseasesSection extends ConsumerWidget {
  final DiseaseModel currentDisease;
  final bool isBn;

  const RelatedDiseasesSection({
    super.key,
    required this.currentDisease,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseasesAsync =
        ref.watch(diseasesByCropProvider(currentDisease.cropId));

    return diseasesAsync.when(
      data: (diseases) {
        final relatedList = diseases
            .where((d) => d.id != currentDisease.id && !d.isHealthy)
            .toList();

        if (relatedList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.softNaturalGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hub_outlined,
                      size: 18,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'একই ফসলের অন্যান্য রোগ' : 'Related Crop Diseases',
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal Carousel
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = relatedList[index];
                    final name = isBn ? item.diseaseNameBn : item.diseaseNameEn;

                    return Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.1),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.forestGreen.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            try {
                              context.push('/diseases/${item.id}');
                            } catch (_) {}
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.coronavirus_outlined,
                                        size: 16,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.secondaryText,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isBn ? 'বিস্তারিত দেখুন' : 'View Details',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.forestGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
