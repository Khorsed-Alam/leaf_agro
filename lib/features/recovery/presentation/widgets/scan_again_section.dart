import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../providers/crop_provider.dart';
import '../../../../providers/detection_provider.dart';

/// Screen 21 – Prominent "Scan Again" Action Section
/// Navigates the farmer to Screen 11 (Detection Start) to initiate a genuine
/// new AI assessment with a fresh leaf photograph without altering original scans.
class ScanAgainSection extends ConsumerWidget {
  final bool isBn;
  final CropModel? crop;
  final VoidCallback? onScanAgain;

  const ScanAgainSection({
    super.key,
    required this.isBn,
    this.crop,
    this.onScanAgain,
  });

  void _handleScanAgain(BuildContext context, WidgetRef ref) {
    if (onScanAgain != null) {
      onScanAgain!();
      return;
    }

    // 1. Preserve crop context if available
    if (crop != null) {
      ref.read(selectedCropProvider.notifier).state = crop;
    }

    // 2. Reset in-memory detection inference state to ensure fresh inference
    ref.read(detectionProvider.notifier).reset();

    // 3. Navigate to Detection Start (Screen 11)
    try {
      context.push('/detect');
    } catch (_) {
      context.go('/detect');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Scan Again Button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _handleScanAgain(context, ref),
              icon: const Icon(Icons.camera_alt_rounded, size: 22),
              label: Text(
                isBn ? 'আবার স্ক্যান করুন' : 'Scan Again',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Supporting Text
          Text(
            isBn
                ? 'নতুন এআই মূল্যায়নের জন্য গাছের নতুন ছবি তুলুন।'
                : 'Take a new plant photo to run another AI assessment.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

