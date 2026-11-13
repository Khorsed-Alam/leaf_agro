import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/disease_model.dart';

/// Screen 17 – Visible Signs on Leaves Card
/// Educational guide for field recognition of leaf manifestations
/// (e.g., spots, halos, mold, concentric rings, marginal desiccation).
class DiseaseVisibleSignsCard extends StatelessWidget {
  final DiseaseModel disease;
  final bool isBn;

  const DiseaseVisibleSignsCard({
    super.key,
    required this.disease,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final signs = _extractVisibleSigns();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn ? 'পাতার দৃশ্যমান লক্ষণ' : 'Visible Signs on Leaves',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subtitle / Inspection Advice
          Text(
            isBn
                ? 'মাঠ পরিদর্শনের সময় পাতার নিম্নলিখিত দৃশ্যমান লক্ষণগুলো গুরুত্ব সহকারে খেয়াল করুন:'
                : 'Pay careful attention to these observable visual manifestations when scouting your field:',
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.secondaryText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Signs Grid / Cards
          Column(
            children: signs.map((sign) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: sign.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        sign.icon,
                        size: 20,
                        color: sign.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sign.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sign.description,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.secondaryText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<_LeafSignItem> _extractVisibleSigns() {
    if (disease.isHealthy) {
      return [
        _LeafSignItem(
          icon: Icons.eco_rounded,
          accentColor: AppColors.forestGreen,
          title: isBn ? 'সতেজ ও সমরূপ রঙ' : 'Uniform Green Color',
          description: isBn
              ? 'পাতায় কোনো ক্লোরোসিস (হলুদাভ ভাব) বা অসম দাগ নেই, সম্পূর্ণ পাতা সমান সবুজ।'
              : 'The foliage displays a consistent, healthy green coloration with no chlorosis or patchy yellowing.',
        ),
        _LeafSignItem(
          icon: Icons.check_circle_outline_rounded,
          accentColor: AppColors.freshGreen,
          title: isBn ? 'ক্ষতমুক্ত মসৃণ কিনার' : 'Intact Leaf Margins',
          description: isBn
              ? 'পাতার কিনারায় কোনো পোড়া বা কুঁচকানো দাগ নেই, ফলক স্বাভাবিকভাবে প্রসারিত।'
              : 'Leaf margins and blade edges are intact without necrosis, curling, or tip-burn.',
        ),
      ];
    }

    final lower = disease.className.toLowerCase();

    if (lower.contains('bacterial_leaf_blight')) {
      return [
        _LeafSignItem(
          icon: Icons.water_drop_outlined,
          accentColor: const Color(0xFFD97706),
          title: isBn ? 'ঢেউ খেলানো কিনারার দাগ' : 'Wavy Margin Lesions',
          description: isBn
              ? 'পাতার ডগা বা কিনার থেকে হলুদ বা সাদাটে তরঙ্গায়িত দাগ ধীরে ধীরে নিচের দিকে নামে।'
              : 'Water-soaked translucent stripes initiate at leaf tips/margins turning wavy yellowish-white.',
        ),
        _LeafSignItem(
          icon: Icons.grass_rounded,
          accentColor: const Color(0xFFB45309),
          title: isBn ? 'খড়ের মতো বিবর্ণতা' : 'Straw-like Desiccation',
          description: isBn
              ? 'তীব্র আক্রমণে পাতা শুকিয়ে খড়ের মতো আকার ধারণ করে এবং কুঁকড়ে যায়।'
              : 'Severely affected leaves curl, dry out rapidly, and assume a bleached straw appearance.',
        ),
      ];
    } else if (lower.contains('brown_spot')) {
      return [
        _LeafSignItem(
          icon: Icons.lens_rounded,
          accentColor: const Color(0xFF92400E),
          title: isBn ? 'ছোট ডিম্বাকৃতি দাগ' : 'Oval Necrotic Lesions',
          description: isBn
              ? 'পাতার ওপর গোল বা ডিম্বাকৃতির ছোট ছোট গাঢ় বাদামী রঙের ক্ষত সৃষ্টি হয়।'
              : 'Scattered circular to oval dark brown spots across the leaf lamina.',
        ),
        _LeafSignItem(
          icon: Icons.center_focus_strong_rounded,
          accentColor: const Color(0xFF78350F),
          title: isBn ? 'ধূসর কেন্দ্রস্থল' : 'Grayish Lesion Centers',
          description: isBn
              ? 'পরিপক্ব দাগগুলোর মাঝখানে ধূসর বর্ণ এবং চারপাশে কালচে বাদামী বলয় দেখা যায়।'
              : 'Older spots develop light brown or gray centers surrounded by dark reddish-brown margins.',
        ),
      ];
    } else if (lower.contains('late_blight')) {
      return [
        _LeafSignItem(
          icon: Icons.water_rounded,
          accentColor: const Color(0xFFDC2626),
          title: isBn ? 'পানিভেজা কালো দাগ' : 'Water-soaked Dark Lesions',
          description: isBn
              ? 'পাতায় অনিয়মিত আকারের কালচে পানিভেজা পচা দাগ দেখা দেয় যা খুব দ্রুত ছড়িয়ে পড়ে।'
              : 'Rapidly expanding irregular water-soaked lesions turning dark brown to purplish-black.',
        ),
        _LeafSignItem(
          icon: Icons.cloud_outlined,
          accentColor: const Color(0xFF475569),
          title:
              isBn ? 'সাদাটে ছত্রাকের আস্তরণ' : 'White Downy Mildew Underside',
          description: isBn
              ? 'কুয়াশাচ্ছন্ন ভেজা সকালে পাতার উল্টো পিঠে ক্ষতস্থানের চারপাশে সাদা তুলার মতো ছত্রাক দেখা যায়।'
              : 'Under humid conditions, a delicate whitish fuzzy fungal growth appears on the leaf underside.',
        ),
      ];
    } else if (lower.contains('early_blight')) {
      return [
        _LeafSignItem(
          icon: Icons.adjust_rounded,
          accentColor: const Color(0xFFEA580C),
          title: isBn ? 'টার্গেট বোর্ডের বলয়' : 'Concentric Ring Patterns',
          description: isBn
              ? 'দাগের ভেতরে একের পর এক গোল রিং বা চক্রাকার বলয় লক্ষ্য করা যায়।'
              : 'Characteristic "target-board" concentric rings inside dark brown necrotic patches.',
        ),
        _LeafSignItem(
          icon: Icons.wb_sunny_outlined,
          accentColor: const Color(0xFFCA8A04),
          title: isBn ? 'হলুদ বলয় (Chlorotic Halo)' : 'Yellow Chlorotic Halos',
          description: isBn
              ? 'বাদামী ক্ষতের চারপাশে উজ্জ্বল হলুদ রঙের বলয় সুস্পষ্টভাবে ফোটে ওঠে।'
              : 'Narrow yellow rings surrounding dark lesions on mature lower foliage.',
        ),
      ];
    } else if (lower.contains('anthracnose')) {
      return [
        _LeafSignItem(
          icon: Icons.interests_outlined,
          accentColor: const Color(0xFFB45309),
          title: isBn ? 'কৌণিক বাদামী ক্ষত' : 'Angular Sunken Spots',
          description: isBn
              ? 'পাতার শিরা বরাবর কোণাকৃতি গাঢ় বাদামী বা কালো দাগ সৃষ্টি হয়।'
              : 'Angular to irregular dark brown lesions adhering closely to vein junctions.',
        ),
        _LeafSignItem(
          icon: Icons.flare_rounded,
          accentColor: const Color(0xFFDC2626),
          title:
              isBn ? 'পত্রক্ষয় ও ছিদ্র (Shot-hole)' : 'Leaf Perforation / Drop',
          description: isBn
              ? 'ক্ষতস্থান শুকিয়ে পাতা ফেটে যেতে পারে অথবা পাতায় ছিদ্র হয়ে অকালে ঝরে পড়ে।'
              : 'Brittle necrotic centres may dry out and fall away, causing perforated foliage.',
        ),
      ];
    } else {
      return [
        _LeafSignItem(
          icon: Icons.fiber_manual_record_rounded,
          accentColor: const Color(0xFFD97706),
          title: isBn ? 'অস্বাভাবিক পত্রক্ষত' : 'Characteristic Foliar Lesions',
          description: isBn
              ? (disease.symptomsBn.isNotEmpty
                  ? disease.symptomsBn
                  : 'পাতায় বর্ণহীন বা বাদামী দাগ লক্ষণীয়।')
              : (disease.symptomsEn.isNotEmpty
                  ? disease.symptomsEn
                  : 'Notable discoloration and spotting on leaves.'),
        ),
      ];
    }
  }
}

class _LeafSignItem {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;

  const _LeafSignItem({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
  });
}
