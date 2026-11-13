import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';

/// Screen 18 – Treatment Not Found State
/// Rendered when an unmapped or invalid disease ID is queried.
class TreatmentNotFoundView extends StatelessWidget {
  final bool isBn;
  final VoidCallback? onBack;

  const TreatmentNotFoundView({
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
                Icons.medical_information_outlined,
                size: 48,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isBn
                  ? 'কোনো চিকিৎসা তথ্য পাওয়া যায়নি'
                  : 'No Treatment Guidance Available',
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
                  ? 'অনুরোধকৃত রোগটির জন্য কোনো যাচাইকৃত চিকিৎসা নির্দেশিকা পাওয়া যায়নি। অনুগ্রহ করে নিকটস্থ উপজেলা কৃষি কর্মকর্তার সাথে যোগাযোগ করুন।'
                  : 'Verified treatment recommendations are currently unavailable for this disease. Please consult your local agricultural extension officer.',
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
                  context.go('/diseases');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
