import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';

/// Screen 19 – Prevention Not Found View
/// Rendered when requested crop or disease records cannot be resolved.
class PreventionNotFoundView extends StatelessWidget {
  final bool isBn;
  final VoidCallback? onBack;

  const PreventionNotFoundView({
    super.key,
    required this.isBn,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 48,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isBn
                  ? 'প্রতিরোধ তথ্য পাওয়া যায়নি'
                  : 'Prevention Guidance Unavailable',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isBn
                  ? 'অনুরোধকৃত ফসলের কোনো প্রতিরোধ নির্দেশিকা পাওয়া যায়নি। অনুগ্রহ করে অন্য ফসল নির্বাচন করুন।'
                  : 'Prevention guidance is currently unavailable for this record. Please select another verified crop.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                isBn ? 'ফিরে যান' : 'Go Back',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/crops');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
