import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';

class CropQuickCard extends StatelessWidget {
  final CropModel crop;
  const CropQuickCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/crops/${crop.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: crop.imageUrl != null
                  ? Image.network(
                      crop.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.grass,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.grass, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              crop.nameEn,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              crop.nameBn,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
