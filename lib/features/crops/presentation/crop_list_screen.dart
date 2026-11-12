import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';

class CropListScreen extends ConsumerWidget {
  const CropListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(cropProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Encyclopedia')),
      body: cropsAsync.when(
        data: (crops) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              return InkWell(
                onTap: () => context.push('/crops/${crop.id}'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: crop.imageUrl != null
                              ? Image.network(
                                  crop.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.grass, size: 48, color: AppColors.primary),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.grass, size: 48, color: AppColors.primary),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop.nameEn,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            Text(
                              crop.nameBn,
                              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load crops: $e')),
      ),
    );
  }
}

