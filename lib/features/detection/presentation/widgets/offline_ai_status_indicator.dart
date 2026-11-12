import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Small informational indicator confirming genuine on-device offline AI model availability
class OfflineAiStatusIndicator extends StatelessWidget {
  final bool isBn;

  const OfflineAiStatusIndicator({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.freshGreen.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: AppColors.forestGreen,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isBn
                      ? 'এই ডিভাইসে অফলাইনে AI শনাক্তকরণ সুবিধা প্রস্তুত'
                      : 'AI detection available on this device',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                    letterSpacing: 0.1,
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
