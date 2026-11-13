import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 20 – Agricultural Safety Information Section
/// Restrained, authoritative educational cards on agricultural chemical safety,
/// personal protection equipment (PPE), storage, disposal, and pre-harvest intervals.
class AgriculturalSafetySection extends StatelessWidget {
  final bool isBn;

  const AgriculturalSafetySection({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFED7AA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.04),
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
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Color(0xFFEA580C),
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
                          ? 'গুরুত্বপূর্ণ নিরাপত্তা তথ্য'
                          : 'Important Safety Information',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'কৃষি সামগ্রী নিরাপদে ব্যবহারের জন্য প্রয়োজনীয় সাধারণ সতর্কতা।'
                          : 'Essential precautions for handling agricultural products safely.',
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

          // 1. Follow the Product Label
          _buildSafetyCard(
            number: '1',
            icon: Icons.menu_book_rounded,
            title: isBn ? 'পণ্যের লেবেল মেনে চলুন' : 'Follow the Product Label',
            description: isBn
                ? 'সর্বদা আপনার নির্দিষ্ট ফসল ও ব্যবহারের জন্য অনুমোদিত পণ্যের মোড়কের লেবেল ও সরকারি নির্দেশনা যত্নসহকারে পড়ুন এবং মেনে চলুন।'
                : 'Always read and follow the approved product label and instructions for the intended crop and use.',
          ),

          // 2. Use Appropriate Protection
          _buildSafetyCard(
            number: '2',
            icon: Icons.masks_outlined,
            title: isBn
                ? 'ব্যক্তিগত সুরক্ষা সামগ্রী (PPE) ব্যবহার'
                : 'Use Appropriate Protection',
            description: isBn
                ? 'পণ্যের লেবেলে উল্লিখিত সুরক্ষামূলক সরঞ্জাম (যেমন মাস্ক, গ্লাভস, চশমা ও লম্বা পোশাক) পরিধান করে পণ্য পরিচালনা করুন।'
                : 'Follow the protective equipment and handling precautions specified on the approved label.',
          ),

          // 3. Protect People and Animals
          _buildSafetyCard(
            number: '3',
            icon: Icons.family_restroom_rounded,
            title: isBn
                ? 'মানুষ ও প্রাণিসম্পদের সুরক্ষা'
                : 'Protect People and Animals',
            description: isBn
                ? 'কৃষি রাসায়নিক দ্রব্য শিশু, গৃহপালিত পশু, খাদ্যদ্রব্য ও খাবার পানির উৎস থেকে সম্পূর্ণ নিরাপদ দূরত্বে রাখুন।'
                : 'Keep agricultural chemicals away from children, animals, food, and drinking water as directed by the label.',
          ),

          // 4. Safe Storage and Disposal
          _buildSafetyCard(
            number: '4',
            icon: Icons.lock_outline_rounded,
            title: isBn
                ? 'নিরাপদ সংরক্ষণ ও খালি পাত্র ধ্বংস'
                : 'Safe Storage and Disposal',
            description: isBn
                ? 'তালাবদ্ধ স্থানে মূল মোড়কে সংরক্ষণ করুন। খালি বোতল বা প্যাকেট কখনোই ঘরোয়া কাজে ব্যবহার করবেন না; নিয়মানুযায়ী মাটিতে পুঁতে ফেলুন।'
                : 'Follow local regulations and product-label instructions for storage, empty containers, and safe disposal.',
          ),

          // 5. Observe Harvest and Re-entry Restrictions
          _buildSafetyCard(
            number: '5',
            icon: Icons.hourglass_top_rounded,
            title: isBn
                ? 'ফসল তোলার সময়সীমা (PHI) রক্ষা'
                : 'Observe Harvest Restrictions',
            description: isBn
                ? 'স্প্রে করার পর ফসল তোলার পূর্ববর্তী নির্ধারিত অপেক্ষমাণ সময় (PHI) এবং জমিতে প্রবেশের সময়সীমা কঠোরভাবে মেনে চলুন।'
                : 'Follow any applicable pre-harvest interval (PHI) and restricted-entry requirements stated on the approved label.',
          ),

          // 6. Avoid Unapproved Mixing
          _buildSafetyCard(
            number: '6',
            icon: Icons.science_outlined,
            title: isBn
                ? 'অননুমোদিত মিশ্রণ পরিহার করুন'
                : 'Avoid Unapproved Mixing',
            description: isBn
                ? 'অনুমোদিত লেবেল বা যোগ্য কৃষি কর্মকর্তা স্পষ্টভাবে অনুমতি না দেওয়া পর্যন্ত কখনোই একাধিক বালাইনাশক বা রাসায়নিক একসাথে মেশাবেন না।'
                : 'Never mix products unless the approved label or qualified agricultural guidance explicitly permits it.',
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFEA580C),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: const Color(0xFFC2410C)),
                    const SizedBox(width: 6),
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
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
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
