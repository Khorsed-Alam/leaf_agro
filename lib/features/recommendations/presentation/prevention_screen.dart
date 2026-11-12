import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/disease_provider.dart';

class PreventionScreen extends ConsumerWidget {
  final int diseaseId;
  const PreventionScreen({super.key, required this.diseaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsByDiseaseProvider(diseaseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Prevention & Care Protocols')),
      body: recsAsync.when(
        data: (recs) {
          final preventions = recs.where((r) => r.recommendationType == 'prevention' || r.recommendationType == 'care').toList();

          if (preventions.isEmpty) {
            return const Center(child: Text('No prevention guidelines listed.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: preventions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final p = preventions[idx];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(p.titleEn, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(p.titleBn, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                      const SizedBox(height: 12),
                      Text(p.contentEn, style: const TextStyle(fontSize: 14, height: 1.4)),
                      const SizedBox(height: 8),
                      Text(p.contentBn, style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

