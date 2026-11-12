import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/history_provider.dart';
import '../../../shared/widgets/leaf_image_view.dart';
import '../../../shared/widgets/status_badge.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final String scanId;
  const HistoryDetailScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Record Details')),
      body: historyAsync.when(
        data: (scans) {
          final scan = scans.firstWhere(
            (s) => s.id == scanId,
            orElse: () => scans.first,
          );

          final parts = scan.predictedClass.split('___');
          final crop = parts[0];
          final disease = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
          final isHealthy = disease.toLowerCase().contains('healthy');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scan.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LeafImageView(
                      imagePath: scan.imagePath!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.outline),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(crop, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    StatusBadge(label: isHealthy ? 'Healthy' : 'Diseased', isHealthy: isHealthy),
                  ],
                ),
                const SizedBox(height: 6),
                Text(disease, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatTimestamp(scan.createdAt),
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text('Confidence: ${(scan.confidence * 100).toStringAsFixed(1)}%'),
                Text('Model Version: ${scan.modelVersion}'),
                Text('Sync Status: ${scan.syncStatus.toUpperCase()}'),
                const SizedBox(height: 24),
                if (scan.diseaseId != null)
                  ElevatedButton(
                    onPressed: () => context.push('/recommendations/${scan.diseaseId}'),
                    child: const Text('View Recommended Treatment & Care'),
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
