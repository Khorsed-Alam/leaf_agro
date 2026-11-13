import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 20 – Solutions Not Found View
/// Fallback view when an invalid disease ID or missing crop record is accessed.
class SolutionsNotFoundView extends StatelessWidget {
  final bool isBn;
  final VoidCallback? onResetToDefault;

  const SolutionsNotFoundView({
    super.key,
    required this.isBn,
    this.onResetToDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGreen),
            boxShadow: [
              BoxShadow(
                color: AppColors.forestGreen.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderGreen),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  size: 36,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isBn
                    ? 'সমাধান সংক্রান্ত তথ্য পাওয়া যায়নি'
                    : 'Solution Information Not Found',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isBn
                    ? 'অনুরোধকৃত ফসল বা রোগের তথ্য ডাটাবেজে পাওয়া যায়নি। আপনি মূল ফসলের সাধারণ সুরক্ষা নির্দেশিকা দেখতে পারেন।'
                    : 'The requested crop or disease solution record could not be found in the catalog. You can explore standard crop care guidance instead.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onResetToDefault ??
                      () {
                        try {
                          context.go('/solutions?cropId=1');
                        } catch (_) {}
                      },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    isBn ? 'সাধারণ নির্দেশিকা দেখুন' : 'View General Solutions',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                child: Text(
                  isBn ? 'পূর্ববর্তী পেজে ফিরে যান' : 'Go Back',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

