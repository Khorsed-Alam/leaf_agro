import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/prediction_history_model.dart';
import '../../../../shared/widgets/status_badge.dart';

class RecentScansWidget extends StatelessWidget {
  final AsyncValue<List<PredictionHistoryModel>> historyAsync;

  const RecentScansWidget({super.key, required this.historyAsync});

  @override
  Widget build(BuildContext context) {
    return historyAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.outline),
                SizedBox(height: 8),
                Text(
                  'No diagnosis logs yet',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                ),
                Text(
                  'Your scanned leaves will appear here.',
                  style: TextStyle(fontSize: 12, color: AppColors.outline),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.take(4).length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final scan = items[index];
            final parts = scan.predictedClass.split('___');
            final crop = parts[0];
            final disease = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
            final isHealthy = disease.toLowerCase().contains('healthy');

            return InkWell(
              onTap: () => context.push('/history/${scan.id}'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isHealthy ? AppColors.secondaryContainer : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isHealthy ? Icons.eco : Icons.bug_report_rounded,
                        color: isHealthy ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$crop · $disease',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.formatTimestamp(scan.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: '${(scan.confidence * 100).toStringAsFixed(0)}%',
                      isHealthy: isHealthy,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading scan history'),
    );
  }
}

