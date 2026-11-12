import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/history_provider.dart';
import '../../../shared/widgets/status_badge.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Log & Diagnosis History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => context.push('/history/filter'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(historyProvider.notifier).refresh(),
        child: historyAsync.when(
          data: (scans) {
            if (scans.isEmpty) {
              return const Center(
                child: Text('No plant diagnosis records found.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: scans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final scan = scans[index];
                final parts = scan.predictedClass.split('___');
                final crop = parts[0];
                final disease = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
                final isHealthy = disease.toLowerCase().contains('healthy');

                return ListTile(
                  tileColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isHealthy ? AppColors.secondaryContainer : AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isHealthy ? Icons.eco : Icons.bug_report,
                      color: isHealthy ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
                    ),
                  ),
                  title: Text('$crop · $disease', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(DateFormatter.formatTimestamp(scan.createdAt)),
                  trailing: StatusBadge(
                    label: '${(scan.confidence * 100).toStringAsFixed(0)}%',
                    isHealthy: isHealthy,
                  ),
                  onTap: () => context.push('/history/${scan.id}'),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load history: $e')),
        ),
      ),
    );
  }
}

