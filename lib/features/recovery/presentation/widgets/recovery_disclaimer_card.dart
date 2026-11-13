import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 21 – Neutral Scientific Monitoring Disclaimer Card
/// Strictly transparent: No fake recovery percentage formulas or guarantees.
class RecoveryDisclaimerCard extends StatelessWidget {
  final bool isBn;

  const RecoveryDisclaimerCard({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              size: 16,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn
                      ? 'গাছ পর্যবেক্ষণ সংক্রান্ত নির্দেশনা'
                      : 'Monitoring Your Plant',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isBn
                      ? 'আপনার পর্যবেক্ষণ সময়ের সাথে পরিবর্তন ট্র্যাক করতে সাহায্য করে। নতুন এআই স্ক্যান একটি নতুন মূল্যায়ন দিতে পারে, তবে এআই পূর্বাভাস অনুমানমাত্র এবং গাছ সম্পূর্ণ সুস্থ হওয়ার নিশ্চয়তা দেয় না।'
                      : 'Your observations help you keep track of changes over time. A new AI scan can provide another assessment, but AI predictions are estimates and do not guarantee that a plant has recovered.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

