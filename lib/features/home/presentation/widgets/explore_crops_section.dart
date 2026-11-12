import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../providers/crop_provider.dart';
import '../../../../providers/settings_provider.dart';
import 'crop_card.dart';

class ExploreCropsSection extends ConsumerWidget {
  const ExploreCropsSection({super.key});

  /// Guaranteed catalog for Rice, Mango, Potato, Tomato, Jute
  static const List<CropModel> _defaultCrops = [
    CropModel(
      id: 1,
      nameEn: 'Rice',
      nameBn: 'ধান',
      descriptionEn: 'Staple grain of Bangladesh, cultivated in Aus, Aman, and Boro seasons.',
      descriptionBn: 'বাংলাদেশের প্রধান খাদ্যশস্য, আউশ, আমন ও বোরো মৌসুমে চাষ হয়।',
      imageUrl: 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6',
    ),
    CropModel(
      id: 4,
      nameEn: 'Mango',
      nameBn: 'আম',
      descriptionEn: 'The King of Fruits, extensively grown in Rajshahi and Chapainawabganj.',
      descriptionBn: 'ফলের রাজা, রাজশাহী ও চাঁপাইনবাবগঞ্জ অঞ্চলে প্রধান অর্থকরী ফল।',
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078',
    ),
    CropModel(
      id: 2,
      nameEn: 'Potato',
      nameBn: 'আলু',
      descriptionEn: 'High yield tuber crop heavily grown in Munshiganj and Bogura.',
      descriptionBn: 'মুন্সীগঞ্জ ও বগুড়া অঞ্চলে প্রধান কন্দজাতীয় ফসল।',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655',
    ),
    CropModel(
      id: 3,
      nameEn: 'Tomato',
      nameBn: 'টমেটো',
      descriptionEn: 'Popular vegetable widely cultivated throughout winter and summer.',
      descriptionBn: 'শীত ও গ্রীষ্মকালীন মৌসুমে সারা দেশে ব্যাপকভাবে চাষকৃত সবজি।',
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea',
    ),
    CropModel(
      id: 5,
      nameEn: 'Jute',
      nameBn: 'পাট',
      descriptionEn: 'The Golden Fibre of Bangladesh, crucial commercial cash crop.',
      descriptionBn: 'বাংলাদেশের সোনালী আঁশ, অন্যতম প্রধান ঐতিহ্যবাহী অর্থকরী ফসল।',
      imageUrl: 'https://images.unsplash.com/photo-1600681932179-c32278da47f9',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';
    final cropsAsync = ref.watch(cropProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'ফসলের তথ্য' : 'Explore Crops',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBn
                      ? 'বিভিন্ন ফসলের পরিচর্যা ও রোগ তথ্য জানুন'
                      : 'Discover useful crop information',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/crops'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.forestGreen,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBn ? 'সবগুলো দেখুন' : 'View All',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontal List View
        SizedBox(
          height: 154,
          child: cropsAsync.when(
            data: (crops) {
              final displayList = crops.isNotEmpty ? crops : _defaultCrops;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displayList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final crop = displayList[index];
                  return CropCard(
                    crop: crop,
                    isBn: isBn,
                    onTap: () => context.push('/crops/${crop.id}'),
                  );
                },
              );
            },
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildSkeletonCard(),
            ),
            error: (_, __) {
              // Fallback to default 5 crops on network / Supabase cold start error
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _defaultCrops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final crop = _defaultCrops[index];
                  return CropCard(
                    crop: crop,
                    isBn: isBn,
                    onTap: () => context.push('/crops/${crop.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: 135,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 95,
            decoration: const BoxDecoration(
              color: AppColors.softNaturalGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.borderGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 45,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.softNaturalGreen,
                    borderRadius: BorderRadius.circular(4),
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
