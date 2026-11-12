import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/disease_provider.dart';

class CropDetailScreen extends ConsumerWidget {
  final int cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropAsync = ref.watch(cropByIdProvider(cropId));
    final diseasesAsync = ref.watch(diseasesByCropProvider(cropId));

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Profile')),
      body: cropAsync.when(
        data: (crop) {
          if (crop == null) return const Center(child: Text('Crop not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: crop.imageUrl != null
                      ? Image.network(
                          crop.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: AppColors.surfaceContainer,
                            child: const Icon(Icons.grass, size: 64, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: AppColors.surfaceContainer,
                          child: const Icon(Icons.grass, size: 64, color: AppColors.primary),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      crop.nameEn,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${crop.nameBn})',
                      style: const TextStyle(fontSize: 18, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  crop.descriptionEn,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  crop.descriptionBn,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Associated Plant Diseases',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                diseasesAsync.when(
                  data: (diseases) {
                    if (diseases.isEmpty) {
                      return const Text('No diseases cataloged for this crop yet.');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: diseases.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final d = diseases[idx];
                        return ListTile(
                          tileColor: AppColors.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          title: Text(d.diseaseNameEn, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(d.diseaseNameBn),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/diseases/${d.id}'),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading diseases: $e'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

