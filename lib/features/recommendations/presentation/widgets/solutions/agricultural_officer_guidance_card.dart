import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/disease_model.dart';

/// Screen 20 – Agricultural Officer Guidance Card
/// Highlights the irreplaceable role of qualified local Upazila extension officers
/// and provides a direct CTA button to Treatment Recommendations (Screen 18).
class AgriculturalOfficerGuidanceCard extends StatelessWidget {
  final DiseaseModel? disease;
  final bool isBn;

  const AgriculturalOfficerGuidanceCard({
    super.key,
    this.disease,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF86EFAC)),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Officer Icon & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.forestGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'সঠিক সমাধান নির্বাচনে সাহায্য প্রয়োজন?'
                          : 'Need Help Choosing the Right Solution?',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'উপজেলা কৃষি সম্প্রসারণ অধিদপ্তর'
                          : 'Department of Agricultural Extension',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Message
          Text(
            isBn
                ? 'ফসল সুরক্ষা সামগ্রী নির্বাচন বা প্রয়োগের পূর্বে একজন যোগ্য কৃষি কর্মকর্তা বা স্থানীয় কৃষি সম্প্রসারণ অফিসের পরামর্শ নিন। তারা আপনার ফসলের অবস্থা পর্যবেক্ষণ করে সঠিক ব্যবস্থাপনা নিশ্চিত করতে এবং অনুমোদিত উপায় ব্যাখ্যা করতে পারবেন।'
                : 'Consult a qualified agricultural officer or local agricultural extension service before selecting or applying crop protection products. They can help assess your crop condition, confirm the appropriate management approach, and explain locally approved options.',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.primaryText,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Primary CTA: View Treatment Recommendations (Screen 18)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final targetDiseaseId = disease?.id ?? 101;
                try {
                  context.push('/recommendations/$targetDiseaseId');
                } catch (_) {}
              },
              icon: const Icon(
                Icons.medication_liquid_rounded,
                color: AppColors.limeGreen,
                size: 20,
              ),
              label: Text(
                isBn
                    ? 'চিকিৎসা সংক্রান্ত পরামর্শ দেখুন'
                    : 'View Treatment Recommendations',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
