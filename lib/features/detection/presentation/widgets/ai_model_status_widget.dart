import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/ai_model_provider.dart';
import '../providers/ai_model_state.dart';

/// Reusable development and diagnostic status card displaying live AI model readiness,
/// architecture, class count, resolution contract, and error details.
class AiModelStatusWidget extends ConsumerWidget {
  final bool isBn;
  final bool compact;

  const AiModelStatusWidget({
    super.key,
    this.isBn = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiModelStateNotifierProvider);

    switch (aiState.status) {
      case AiModelStatus.initial:
      case AiModelStatus.loading:
        return _buildLoadingCard(context);

      case AiModelStatus.ready:
        return _buildReadyCard(context, aiState);

      case AiModelStatus.error:
        return _buildErrorCard(context, ref, aiState);
    }
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isBn
                  ? 'AI মডেল লোড হচ্ছে (মোবাইলনেট-ভি২)...'
                  : 'Initializing MobileNetV2 on-device AI...',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyCard(BuildContext context, AiModelState state) {
    if (compact) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGreen),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.forestGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isBn
                    ? 'AI মডেল প্রস্তুত (${state.architecture} • ১৯টি রোগ শ্রেণি)'
                    : 'AI Ready (${state.architecture} • ${state.classCount} classes)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestGreen,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 18,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.modelName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      isBn ? 'সম্পূর্ণ অফলাইন অন-ডিভাইস ইঞ্জিন' : 'Autonomous On-Device Inference',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded, size: 12, color: AppColors.forestGreen),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'প্রস্তুত' : 'Ready',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSpecPill(
                icon: Icons.layers_rounded,
                label: isBn ? 'আর্কিটেকচার' : 'Architecture',
                value: state.architecture,
              ),
              const SizedBox(width: 8),
              _buildSpecPill(
                icon: Icons.category_rounded,
                label: isBn ? 'শ্রেণি' : 'Classes',
                value: '${state.classCount}',
              ),
              const SizedBox(width: 8),
              _buildSpecPill(
                icon: Icons.aspect_ratio_rounded,
                label: isBn ? 'ইনপুট' : 'Input',
                value: state.resolutionDescription,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 11, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, AiModelState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 20, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn ? 'AI মডেল শুরু করতে ব্যর্থ হয়েছে' : 'AI Model Initialization Failed',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ref.read(aiModelStateNotifierProvider.notifier).retry(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isBn ? 'পুনরায় চেষ্টা' : 'Retry',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              state.errorMessage!,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF7F1D1D),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
