import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Disclaimer note displayed at the bottom of the result screen
class DetectionDisclaimer extends StatelessWidget {
  final bool isBn;

  const DetectionDisclaimer({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 15,
            color: AppColors.secondaryText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBn
                  ? 'AI রোগ নির্ণয় একটি সম্ভাব্য অনুমান এবং প্রয়োজনে কৃষি বিশেষজ্ঞ দ্বারা যাচাই করা উচিত।'
                  : 'AI predictions are estimates and should be verified when necessary.',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
