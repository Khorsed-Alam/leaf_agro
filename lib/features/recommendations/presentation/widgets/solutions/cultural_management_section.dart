import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/datasources/ai_crop_catalog.dart';
import '../../../../../data/models/crop_model.dart';
import '../../../../../data/models/disease_model.dart';
import '../../../../../data/models/recommendation_model.dart';

/// Screen 20 – Cultural Management Section
/// Farmer-friendly agronomic practices that reduce disease pressure naturally
/// without reliance on chemical interventions.
class CulturalManagementSection extends StatelessWidget {
  final CropModel? crop;
  final DiseaseModel? disease;
  final List<RecommendationModel> recommendations;
  final bool isBn;

  const CulturalManagementSection({
    super.key,
    this.crop,
    this.disease,
    required this.recommendations,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    // Collect disease-specific care recommendations
    final careRecs = recommendations
        .where((r) => r.recommendationType.toLowerCase() == 'care')
        .toList();

    // Collect crop-specific care tips from catalog if available
    final cropTips =
        crop != null ? AiCropCatalog.getCareTips(crop!.id) : <CropCareTip>[];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Icon(
                  Icons.yard_outlined,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'কৃষিতাত্ত্বিক ব্যবস্থাপনা'
                          : 'Cultural Management',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'মাঠের কৃষি চর্চা যা রোগের চাপ কমাতে এবং ফসলের স্বাস্থ্য বজায় রাখতে সাহায্য করে।'
                          : 'Agricultural practices that may help reduce disease pressure and support crop health.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 1. Disease-Specific Cultural Practices (if available for active disease)
          if (careRecs.isNotEmpty) ...[
            ...careRecs.map((rec) => _buildCard(
                  icon: Icons.biotech_rounded,
                  iconColor: const Color(0xFF047857),
                  bgColor: const Color(0xFFF0FDF4),
                  borderColor: const Color(0xFFBBF7D0),
                  title: isBn ? rec.titleBn : rec.titleEn,
                  subtitle: isBn ? rec.contentBn : rec.contentEn,
                  badge: isBn
                      ? 'নির্দিষ্ট রোগ ব্যবস্থাপনা'
                      : 'Targeted Management',
                )),
          ],

          // 2. Verified Agronomic Practices for Target Crop or General Management
          _buildCard(
            icon: Icons.cleaning_services_outlined,
            iconColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFFF0F9FF),
            borderColor: const Color(0xFFBAE6FD),
            title:
                isBn ? 'আইল ও জমির পরিচ্ছন্নতা' : 'Field Hygiene & Sanitation',
            subtitle: isBn
                ? 'আইল ও সেচ নালার আগাছা নিয়মিত পরিষ্কার রাখুন যাতে রোগ সৃষ্টিকারী জীবাণু বিকল্প আশ্রয় না পায়।'
                : 'Keep field borders, bunds, and furrows clean of weeds and crop residues that harbor overwintering pathogens.',
            badge: isBn ? 'মৌলিক চর্চা' : 'Core Practice',
          ),

          _buildCard(
            icon: Icons.water_drop_outlined,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFBFDBFE),
            title: isBn
                ? 'সঠিক সেচ ও নিষ্কাশন ব্যবস্থাপনা'
                : 'Irrigation & Moisture Control',
            subtitle: isBn
                ? 'জমিতে অতিরিক্ত পানি জমে থাকতে দেবেন না। পাতার ওপর পানি না ছিটিয়ে মূলের কাছে পরিমিত সেচ দিন।'
                : 'Ensure adequate drainage trenches to avoid waterlogging. Water at the base of plants rather than wetting foliage excessively.',
            badge: isBn ? 'পানি ব্যবস্থাপনা' : 'Moisture Management',
          ),

          _buildCard(
            icon: Icons.grid_view_rounded,
            iconColor: const Color(0xFF059669),
            bgColor: const Color(0xFFECFDF5),
            borderColor: const Color(0xFFA7F3D0),
            title: isBn
                ? 'পর্যাপ্ত দূরত্ব ও আলো-বাতাস'
                : 'Plant Spacing & Canopy Airflow',
            subtitle: isBn
                ? 'চারা বা গাছ রোপণের সময় সঠিক দূরত্ব বজায় রাখুন যাতে পাতার ভেতর মুক্ত বাতাস চলাচল করে এবং শিশির দ্রুত শুকায়।'
                : 'Maintain recommended row-to-row spacing to promote air circulation and fast canopy drying after morning dew.',
            badge: isBn ? 'চারা রোপণ' : 'Canopy Airflow',
          ),

          _buildCard(
            icon: Icons.sync_rounded,
            iconColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFDE68A),
            title: isBn
                ? 'ফসল চক্র (Crop Rotation)'
                : 'Crop Rotation Where Suitable',
            subtitle: isBn
                ? 'একই জমিতে বারবার একই পরিবারের ফসল চাষ না করে পর্যায়ক্রমে ভিন্ন জাতের ফসল ফলিয়ে মাটির রোগচক্র ভাঙুন।'
                : 'Rotate non-host crops across alternating seasons to break the life cycle of soil-borne fungi and nematodes.',
            badge: isBn ? 'ফসল চক্র' : 'Crop Rotation',
          ),

          _buildCard(
            icon: Icons.verified_outlined,
            iconColor: const Color(0xFF15803D),
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            title: isBn
                ? 'বিশুদ্ধ ও রোগমুক্ত প্রত্যয়িত বীজ'
                : 'Healthy Seeds & Planting Materials',
            subtitle: isBn
                ? 'সর্বদা নির্ভরযোগ্য প্রতিষ্ঠান বা প্রত্যয়িত উৎস থেকে সুস্থ, রোগমুক্ত বীজ ও চারা সংগ্রহ করুন।'
                : 'Source certified disease-free seeds and inspected nursery seedlings from accredited agricultural authorities.',
            badge: isBn ? 'বীজ সুরক্ষা' : 'Seed Quality',
          ),

          _buildCard(
            icon: Icons.remove_circle_outline_rounded,
            iconColor: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            title: isBn
                ? 'আক্রান্ত অংশ ব্যবস্থাপনা'
                : 'Management of Affected Plant Material',
            subtitle: isBn
                ? 'স্থানীয় কৃষি কর্মকর্তার পরামর্শ মোতাবেক গুরুতর আক্রান্ত পাতা বা অংশ আলাদা করে স্বাস্থ্যবিধি মেনে অপসারণ করুন।'
                : 'Follow qualified local extension officer guidance when pruning or sanitizing severely affected plant tissue.',
            badge: isBn ? 'নিরাপদ অপসারণ' : 'Sanitation',
          ),

          // Additional crop-specific care tips
          if (cropTips.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...cropTips.take(2).map((tip) => _buildCard(
                  icon: tip.icon,
                  iconColor: AppColors.forestGreen,
                  bgColor: AppColors.softNaturalGreen,
                  borderColor: AppColors.borderGreen,
                  title: isBn ? tip.titleBn : tip.titleEn,
                  subtitle: isBn ? tip.descriptionBn : tip.descriptionEn,
                  badge: isBn
                      ? (crop != null ? crop!.nameBn : 'ফসল')
                      : (crop != null ? crop!.nameEn : 'Crop'),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
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
