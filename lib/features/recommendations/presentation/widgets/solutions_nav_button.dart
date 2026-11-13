import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/disease_model.dart';

/// Screen 18 – Solutions Navigation Button
/// Educational CTA directing farmers to Screen 20: Product & Solution Information.
class SolutionsNavButton extends StatelessWidget {
  final DiseaseModel disease;
  final bool isBn;

  const SolutionsNavButton({
    super.key,
    required this.disease,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreen),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            try {
              context.push('/solutions/${disease.id}');
            } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.softNaturalGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderGreen),
                  ),
                  child: const Icon(
                    Icons.science_outlined,
                    color: AppColors.forestGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn
                            ? 'পণ্য ও সমাধান সংক্রান্ত তথ্য'
                            : 'Product & Solution Information',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isBn
                            ? 'জৈবিক, কৃষিতাত্ত্বিক ও সুরক্ষা নীতিমালা জানুন'
                            : 'Biological, cultural & safety guidelines',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.forestGreen,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

