import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/prediction_model.dart';

/// Main card displaying the disease name, confidence score, certainty note, and summary
class AiPredictionCard extends StatelessWidget {
  final PredictionModel prediction;
  final String? diseaseDescription;
  final bool isBn;

  const AiPredictionCard({
    super.key,
    required this.prediction,
    this.diseaseDescription,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = prediction.isHealthy;
    final confidencePct = (prediction.confidence * 100).toStringAsFixed(1);
    final confidenceScore = prediction.confidence.clamp(0.0, 1.0);

    final titleText = isHealthy
        ? (isBn ? 'সুস্থ উদ্ভিদ' : 'Healthy Plant')
        : (isBn ? prediction.diseaseNameBn : prediction.diseaseNameEn);

    final subtitleText = isHealthy
        ? (isBn ? 'কোনো রোগ শনাক্ত হয়নি' : 'No disease detected')
        : (isBn ? prediction.diseaseNameEn : prediction.diseaseNameBn);

    // Summary description
    final summaryText = isHealthy
        ? (isBn
            ? 'এই ছবিতে কোনো সমর্থিত রোগ শনাক্ত করা যায়নি। নিয়মিত পরিচর্যা চালিয়ে যান এবং ফসলের স্বাভাবিক যত্ন নিন।'
            : 'The AI model did not detect a supported disease in this image. Continue monitoring your plant and maintain good crop care.')
        : (diseaseDescription != null && diseaseDescription!.isNotEmpty
            ? diseaseDescription!
            : (isBn
                ? 'গাছের পাতায় ক্ষতিকর লক্ষণ চিহ্নিত হয়েছে। দ্রুত সঠিক প্রতিষেধক ও পরামর্শ গ্রহণ করুন।'
                : 'Potential disease pathology identified on leaf surface. Review recommended treatments below.'));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHealthy
              ? AppColors.freshGreen.withValues(alpha: 0.4)
              : Colors.amber.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isHealthy
                ? AppColors.forestGreen.withValues(alpha: 0.05)
                : Colors.amber.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'AI রোগ নির্ণয়' : 'AI Prediction',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.freshGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'v${prediction.modelVersion}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Primary Prediction Title
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 2),

          // Subtitle / Alternate Language Name
          Text(
            subtitleText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: 18),

          // Confidence Score Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'কনফিডেন্স স্কোর' : 'AI Confidence Score',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                '$confidencePct%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color:
                      isHealthy ? AppColors.forestGreen : Colors.amber.shade900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Visual Confidence Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: confidenceScore,
                backgroundColor: AppColors.background,
                color: isHealthy ? AppColors.freshGreen : Colors.amber.shade600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Confidence vs Certainty Explanatory Note (Requirement 6C)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderGreen,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'কনফিডেন্স স্কোর মডেলের সম্ভাব্যতার মাত্রা প্রকাশ করে। এটি ফলাফল নিশ্চিত করার একমাত্র প্রমাণ নয়।'
                        : 'Confidence represents the model score for this prediction. It does not guarantee that the result is correct.',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Short Result Summary (Requirement 6D)
          Text(
            isBn ? 'সারসংক্ষেপ:' : 'Summary:',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summaryText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
