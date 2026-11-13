import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 30 – Verified AI Model Information Card
class AiModelInfoCard extends StatelessWidget {
  final bool isBn;

  const AiModelInfoCard({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final specs = [
      {
        'label': isBn ? 'মডেল আর্কিটেকচার' : 'Model Architecture',
        'value': 'MobileNetV2'
      },
      {
        'label': isBn ? 'এমএল ফ্রেমওয়ার্ক' : 'ML Framework',
        'value': 'TensorFlow Lite (TFLite)'
      },
      {
        'label': isBn ? 'মডেল সংস্করণ' : 'Model Version',
        'value': 'v1.0.0 (Quantized)'
      },
      {
        'label': isBn ? 'ইনপুট সাইজ' : 'Input Dimensions',
        'value': '224 × 224 × 3 (RGB)'
      },
      {
        'label': isBn ? 'স্বীকৃত শ্রেণি' : 'Output Classes',
        'value': '19 Classes (5 Crops)'
      },
      {
        'label': isBn ? 'ইনফারেন্স মোড' : 'Inference Mode',
        'value': isBn ? '১০০% অন-ডিভাইস (অফলাইন)' : '100% On-Device (Offline)'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGreen, width: 1),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isBn ? 'এআই মডেল স্পেসিফিকেশন' : 'AI Model Information',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Specs Grid/Table
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.softNaturalGreen,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGreen, width: 0.8),
            ),
            child: Column(
              children: specs.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label']!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        item['value']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Short farmer-friendly description
          Text(
            isBn
                ? 'এআই মডেলটি আপলোড করা পাতার ছবি বিশ্লেষণ করে প্রশিক্ষিত রোগ উপসর্গের সাথে মিলিয়ে সম্ভাব্য রোগ শনাক্ত করে।'
                : 'The AI model examines the leaf image and compares its visual patterns with the classes it has been trained to recognize.',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Clear Disclaimer Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9EE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF3D28E), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB45309),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'এআই ফলাফল একটি সম্ভাব্য পূর্বাভাস এবং এটি সবসময় শতভাগ সঠিক নাও হতে পারে। গুরুত্বপূর্ণ সিদ্ধান্তের ক্ষেত্রে অনুমোদিত কৃষি কর্মকর্তার পরামর্শ নিন।'
                        : 'AI predictions are estimates and may not always be correct. For uncertain plant-health problems, consult a qualified agricultural expert.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF78350F),
                      height: 1.35,
                    ),
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
