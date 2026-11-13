import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 20 – Crop Protection Product Information Section
/// Purely educational, neutral guidance on approved crop protection principles.
/// Strictly non-commercial: no shopping carts, prices, brands, or affiliate links.
class CropProtectionProductsSection extends StatelessWidget {
  final bool isBn;

  const CropProtectionProductsSection({
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
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.forestGreen,
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
                          ? 'ফসল সুরক্ষা সামগ্রী (নীতিমালা)'
                          : 'Crop Protection Products',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'অনুমোদিত ও সঠিক ফসল সুরক্ষা সামগ্রী নির্বাচনের গুরুত্ব বুঝুন।'
                          : 'Understand the importance of selecting appropriate, approved crop protection products.',
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

          // 1. Approved Products
          _buildInfoCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF059669),
            title: isBn ? 'অনুমোদিত পণ্য ব্যবহার' : 'Approved Products Only',
            description: isBn
                ? 'ফসল সুরক্ষা সামগ্রী শুধুমাত্র তখনই বিবেচনা করা উচিত যখন তা প্রযোজ্য ফসল, নির্দিষ্ট রোগ বা পোকা এবং সরকারি নীতিমালার অধীনে আনুষ্ঠানিকভাবে নিবন্ধিত ও অনুমোদিত।'
                : 'Crop protection products should only be considered when officially approved for the relevant crop, target disease or pest, and intended use under applicable national regulations.',
          ),

          // 2. Product Labels
          _buildInfoCard(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF0284C7),
            title: isBn
                ? 'প্যাকেটের লেবেল ও নির্দেশিকা'
                : 'Mandatory Product Labels',
            description: isBn
                ? 'পণ্যের মোড়কের লেবেলে অনুমোদিত ব্যবহারের ক্ষেত্র, সঠিক প্রয়োগ পদ্ধতি, সময়সীমা এবং স্বাস্থ্য সুরক্ষার অত্যাবশ্যক তথ্য লিপিবদ্ধ থাকে। লেবেল অক্ষরে অক্ষরে অনুসরণ আবশ্যক।'
                : 'Product labels contain essential legal information about approved uses, application instructions, safety precautions, pre-harvest intervals, and environmental restrictions.',
          ),

          // 3. Qualified Guidance
          _buildInfoCard(
            icon: Icons.support_agent_rounded,
            iconColor: const Color(0xFF7C3AED),
            title: isBn
                ? 'যোগ্য কর্মকর্তার পরামর্শ'
                : 'Qualified Extension Guidance',
            description: isBn
                ? 'সঠিক বালাইনাশক নির্বাচন ফসল, জাত, রোগের তীব্রতা, আবহাওয়া ও স্থানীয় নিয়মাবলীর ওপর নির্ভর করে। নিজে থেকে আন্দাজে ওষুধ নির্বাচন করবেন না।'
                : 'The correct product depends heavily on crop variety, disease progression, growing stage, weather conditions, and local pest management advisories.',
          ),

          // 4. Integrated Management (IPM)
          _buildInfoCard(
            icon: Icons.alt_route_rounded,
            iconColor: const Color(0xFFD97706),
            title: isBn
                ? 'সমন্বিত বালাই ব্যবস্থাপনা (IPM)'
                : 'Integrated Management (IPM)',
            description: isBn
                ? 'রাসায়নিক বালাইনাশক কোনো একক সমাধান নয়। এটি সবসময় উন্নত কৃষিতাত্ত্বিক পরিচর্যা, পরিচ্ছন্নতা ও জৈবিক ব্যবস্থার সমন্বয়ে চূড়ান্ত বিকল্প হিসেবে বিবেচনা করতে হবে।'
                : 'Crop protection products should be considered as part of an integrated crop-management approach, never as a standalone substitute for good agricultural practices.',
          ),

          const SizedBox(height: 10),

          // Non-commercial educational notice badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.softNaturalGreen,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderGreen),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: AppColors.forestGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'AgriCare AI একটি শিক্ষামূলক প্ল্যাটফর্ম; এটি কোনো বাণিজ্যিক বালাইনাশক ব্র্যান্ড বিক্রি বা প্রচার করে না।'
                        : 'AgriCare AI provides educational agronomic guidance and does not sell or endorse commercial chemical brands.',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.forestGreen,
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

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
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
