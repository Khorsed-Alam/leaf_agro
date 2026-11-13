import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/prediction_history_model.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/history_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/leaf_image_view.dart';
import '../../../shared/widgets/status_badge.dart';

class DetectionResultScreen extends ConsumerWidget {
  const DetectionResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detectionProvider);
    final prediction = state.prediction;

    if (prediction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.errorMessage ?? 'Diagnosis failed.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      );
    }

    final isHealthy = prediction.isHealthy;
    final confidencePct = (prediction.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LeafImageView(
                  imagePath: state.imagePath!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            // Diagnostic Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prediction.cropName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      StatusBadge(
                        label: isHealthy ? 'Healthy Plant' : 'Disease Detected',
                        isHealthy: isHealthy,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prediction.diseaseNameEn,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    prediction.diseaseNameBn,
                    style: const TextStyle(
                        fontSize: 16, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Confidence Level',
                          style: TextStyle(fontSize: 14)),
                      Text('$confidencePct%',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: prediction.confidence,
                    backgroundColor: AppColors.surfaceContainer,
                    color: isHealthy ? AppColors.secondary : AppColors.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            CustomButton(
              text: 'Save Diagnosis to Field Log',
              icon: Icons.bookmark_added_outlined,
              onPressed: () async {
                final historyRecord = PredictionHistoryModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: 'guest',
                  diseaseId: state.diseaseDetails?.id,
                  predictedClass: prediction.className,
                  confidence: prediction.confidence,
                  imagePath: state.imagePath,
                  modelVersion: prediction.modelVersion,
                  createdAt: DateTime.now(),
                  syncStatus: 'pending',
                );

                await ref
                    .read(historyProvider.notifier)
                    .addScanRecord(historyRecord);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Saved to offline field history!')),
                  );
                  context.go('/history');
                }
              },
            ),

            const SizedBox(height: 12),

            if (state.diseaseDetails != null) ...[
              CustomButton(
                text: 'View Treatment & Prevention Guide',
                icon: Icons.healing_outlined,
                isOutlined: true,
                onPressed: () => context
                    .push('/recommendations/${state.diseaseDetails!.id}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
