import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/disease_provider.dart';
import '../../../shared/widgets/status_badge.dart';

class DiseaseDetailScreen extends ConsumerWidget {
  final int diseaseId;
  const DiseaseDetailScreen({super.key, required this.diseaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseaseAsync = ref.watch(diseaseByIdProvider(diseaseId));
    final recsAsync = ref.watch(recommendationsByDiseaseProvider(diseaseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Disease Details')),
      body: diseaseAsync.when(
        data: (disease) {
          if (disease == null) return const Center(child: Text('Disease record not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        disease.diseaseNameEn,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusBadge(
                      label: disease.isHealthy ? 'Healthy' : 'Infected',
                      isHealthy: disease.isHealthy,
                    ),
                  ],
                ),
                Text(
                  disease.diseaseNameBn,
                  style: const TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Symptoms', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                Text(disease.symptomsEn.isNotEmpty ? disease.symptomsEn : 'No symptom record available.'),
                if (disease.symptomsBn.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(disease.symptomsBn, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                ],
                const SizedBox(height: 16),
                const Text('Causes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                Text(disease.causesEn.isNotEmpty ? disease.causesEn : 'No causal agent record available.'),
                if (disease.causesBn.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(disease.causesBn, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                ],
                const SizedBox(height: 24),
                const Text('Verified Solutions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                recsAsync.when(
                  data: (recs) {
                    if (recs.isEmpty) return const Text('No recommendations available.');
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final r = recs[idx];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      r.recommendationType == 'treatment'
                                          ? Icons.medical_services_outlined
                                          : Icons.shield_outlined,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      r.titleEn,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(r.contentEn, style: const TextStyle(fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(r.contentBn, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading recommendations: $e'),
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

