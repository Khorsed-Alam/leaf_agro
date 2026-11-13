import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';

/// Screen 19 – Essential Prevention Practices Section
/// Six foundational agricultural prevention principles for Bangladeshi farmers.
class EssentialPracticesSection extends StatelessWidget {
  final bool isBn;

  const EssentialPracticesSection({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final practices = _getEssentialPractices();

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
                  Icons.verified_outlined,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn
                    ? 'প্রয়োজনীয় রোগ প্রতিরোধ অভ্যাস'
                    : 'Essential Prevention Practices',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            isBn
                ? 'মাঠ পর্যায়ের নিয়মিত ভালো চর্চা উদ্ভিদের প্রাকৃতিক রোগ প্রতিরোধ ক্ষমতা বহুগুণ বাড়িয়ে তোলে:'
                : 'Good on-farm cultural habits build natural crop resistance and reduce fungal/bacterial vectors:',
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.secondaryText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // 6 Essential Practice Cards
          Column(
            children: practices.map((item) {
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softNaturalGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 13,
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

  List<_EssentialPracticeItem> _getEssentialPractices() {
    return [
      _EssentialPracticeItem(
        icon: Icons.search_rounded,
        title: isBn
            ? 'নিয়মিত ফসল পর্যবেক্ষণ করুন'
            : 'Monitor Your Crops Regularly',
        description: isBn
            ? 'সপ্তাহে অন্তত দুইবার পাতার উভয় পিঠ ও কিনার পরীক্ষা করুন যাতে দাগ দেখা দেওয়া মাত্রই ব্যবস্থা নেওয়া যায়।'
            : 'Scout foliage at least twice weekly for initial spots or chlorosis before symptoms spread to neighboring plants.',
      ),
      _EssentialPracticeItem(
        icon: Icons.water_drop_outlined,
        title: isBn ? 'সঠিক মাত্রায় সেচ দিন' : 'Water Your Plants Properly',
        description: isBn
            ? 'গাছের গোড়ায় পানি দিন, পাতার ওপর অপ্রয়োজনীয় পানি ছিটাবেন না এবং বৃষ্টির পর নিকাশ নালা সচল রাখুন।'
            : 'Water at the root zone rather than spraying overhead. Maintain drainage furrows to avoid standing water.',
      ),
      _EssentialPracticeItem(
        icon: Icons.cleaning_services_rounded,
        title: isBn ? 'জমি ও আইল পরিষ্কার রাখুন' : 'Keep the Field Clean',
        description: isBn
            ? 'জমির আইল থেকে নিয়মিত আগাছা পরিষ্কার করুন যাতে ক্ষতিকর পোকা ও রোগজীবাণুর বিকল্প বাসস্থান ধ্বংস হয়।'
            : 'Clear border weeds and plant debris from field levees to remove alternative pathogen and insect hosts.',
      ),
      _EssentialPracticeItem(
        icon: Icons.sync_rounded,
        title: isBn
            ? 'উপযুক্ত ক্ষেত্রে শস্য পর্যায় অবলম্বন করুন'
            : 'Practice Crop Rotation When Suitable',
        description: isBn
            ? 'একই জমিতে পরপর একই গোত্রের ফসল চাষ না করে ডাল বা অন্য ফসল চাষ করলে মাটির জীবাণু চক্র ভেঙে যায়।'
            : 'Rotate with non-host legumes or cereals across seasons to break soil-borne bacterial and fungal cycles.',
      ),
      _EssentialPracticeItem(
        icon: Icons.air_rounded,
        title: isBn
            ? 'গাছের সঠিক দূরত্ব ও বায়ু চলাচল বজায় রাখুন'
            : 'Maintain Proper Plant Spacing',
        description: isBn
            ? 'চারা খুব ঘন করে রোপণ করবেন না। সঠিক দূরত্ব রাখলে পাতার ভেতর আলো-বাতাস চলে এবং ছত্রাক জন্মায় না।'
            : 'Adhere to recommended spacing for optimal air circulation and sun penetration, lowering canopy humidity.',
      ),
      _EssentialPracticeItem(
        icon: Icons.spa_rounded,
        title: isBn
            ? 'উন্নত ও রোগমুক্ত বীজ ব্যবহার করুন'
            : 'Use Healthy Seeds and Planting Materials',
        description: isBn
            ? 'বিশ্বস্ত বা সরকারি প্রত্যয়িত প্রতিষ্ঠান হতে রোগমুক্ত বীজ সংগ্রহ করুন এবং রোপণের আগে বীজ শোধন করুন।'
            : 'Source certified disease-free seeds and planting material from reliable agricultural agencies.',
      ),
    ];
  }
}

class _EssentialPracticeItem {
  final IconData icon;
  final String title;
  final String description;

  const _EssentialPracticeItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
