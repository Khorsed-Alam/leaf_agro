import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Action buttons displayed when a disease is identified
class DiseaseActionsSection extends StatelessWidget {
  final int? diseaseId;
  final bool isBn;

  const DiseaseActionsSection({
    super.key,
    this.diseaseId,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final validId = diseaseId ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Treatment Recommendations (Highest agricultural priority)
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                try {
                  context.push('/recommendations/$validId');
                } catch (_) {}
              },
              icon: const Icon(Icons.healing_outlined, size: 19),
              label: Text(
                isBn ? 'চিকিৎসা ও প্রতিকার' : 'Treatment Recommendations',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. View Disease Details & Prevention Tips in Row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      try {
                        context.push('/diseases/$validId');
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.menu_book_outlined, size: 17),
                    label: Text(
                      isBn ? 'রোগের বিবরণ' : 'Disease Details',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forestGreen,
                      side: const BorderSide(
                        color: AppColors.borderGreen,
                        width: 1.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      try {
                        context.push('/prevention/$validId');
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.shield_outlined, size: 17),
                    label: Text(
                      isBn ? 'প্রতিরোধ টিপস' : 'Prevention Tips',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forestGreen,
                      side: const BorderSide(
                        color: AppColors.borderGreen,
                        width: 1.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Plant Recovery & Follow-up Log
          SizedBox(
            height: 44,
            child: TextButton.icon(
              onPressed: () {
                try {
                  context.push('/recovery');
                } catch (_) {}
              },
              icon: const Icon(Icons.track_changes_rounded, size: 18),
              label: Text(
                isBn ? 'পুনরুদ্ধার ও ফলো-আপ ট্র্যাকার' : 'Plant Recovery & Follow-up',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestGreen,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.freshGreen.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
