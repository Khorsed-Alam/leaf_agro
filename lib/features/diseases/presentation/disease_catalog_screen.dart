import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/disease_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final allDiseasesProvider = FutureProvider<List<DiseaseModel>>((ref) async {
  final res = await Supabase.instance.client
      .from('disease_catalog')
      .select()
      .order('disease_name_en');
  return (res as List).map((row) => DiseaseModel.fromJson(row)).toList();
});

class DiseaseCatalogScreen extends ConsumerWidget {
  const DiseaseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseasesAsync = ref.watch(allDiseasesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Disease Directory')),
      body: diseasesAsync.when(
        data: (diseases) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: diseases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final d = diseases[index];
              return ListTile(
                tileColor: AppColors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: d.isHealthy ? AppColors.secondaryContainer : AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    d.isHealthy ? Icons.check_circle : Icons.warning_rounded,
                    color: d.isHealthy ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
                  ),
                ),
                title: Text(d.diseaseNameEn, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(d.diseaseNameBn),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => context.push('/diseases/${d.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load diseases: $e')),
      ),
    );
  }
}

