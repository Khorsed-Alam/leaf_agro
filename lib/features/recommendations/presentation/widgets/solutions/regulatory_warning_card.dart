import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 20 – Important Regulatory Warning Card
/// Mandatory regulatory compliance disclaimer reminding farmers to adhere
/// strictly to approved packaging labels and local extension mandates.
class RegulatoryWarningCard extends StatelessWidget {
  final bool isBn;

  const RegulatoryWarningCard({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: AppColors.secondaryText,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'গুরুত্বপূর্ণ বিজ্ঞপ্তি' : 'Important Notice',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isBn
                      ? 'সর্বদা অনুমোদিত পণ্যের লেবেল ও প্রযোজ্য স্থানীয় নীতিমালা মেনে চলুন। ফসল, রোগ ও এলাকার ভিত্তিতে পণ্যের উপযোগিতা ভিন্ন হতে পারে। কোনো ফসল সুরক্ষা সামগ্রী ব্যবহারের পূর্বে সংশ্লিষ্ট কৃষি কর্মকর্তার পরামর্শ গ্রহণ করুন।'
                      : 'Always follow approved product labels and applicable local regulations. Product suitability and permitted uses can vary by crop, disease, and location. Consult a qualified agricultural officer before applying crop protection products.',
                  style: const TextStyle(
                    fontSize: 11.5,
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

