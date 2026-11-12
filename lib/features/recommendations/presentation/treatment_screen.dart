import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/disease_provider.dart';

class TreatmentScreen extends ConsumerWidget {
  final int diseaseId;
  const TreatmentScreen({super.key, required this.diseaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsByDiseaseProvider(diseaseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Treatment & Recovery Guide')),
      body: recsAsync.when(
        data: (recs) {
          final treatments = recs.where((r) => r.recommendationType == 'treatment').toList();

          if (treatments.isEmpty) {
            return const Center(child: Text('No specific chemical or organic treatment listed.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: treatments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final t = treatments[idx];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medication_liquid_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(t.titleEn, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(t.titleBn, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                      const SizedBox(height: 12),
                      Text(t.contentEn, style: const TextStyle(fontSize: 14, height: 1.4)),
                      const SizedBox(height: 8),
                      Text(t.contentBn, style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.onSurfaceVariant)),
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

