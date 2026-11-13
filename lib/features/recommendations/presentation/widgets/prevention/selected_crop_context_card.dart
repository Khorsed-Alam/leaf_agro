import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/disease_model.dart';

/// Screen 19 – Selected Crop & Disease Context Card
/// Displays active crop details, optional disease context, and a crop switcher.
class SelectedCropContextCard extends StatelessWidget {
  final CropModel? selectedCrop;
  final DiseaseModel? selectedDisease;
  final bool isBn;
  final ValueChanged<CropModel>? onCropChanged;

  const SelectedCropContextCard({
    super.key,
    required this.selectedCrop,
    this.selectedDisease,
    required this.isBn,
    this.onCropChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cropName = selectedCrop != null
        ? (isBn ? selectedCrop!.nameBn : selectedCrop!.nameEn)
        : (isBn ? 'ফসল নির্বাচন করুন' : 'Select a Crop');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Crop Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.grass_rounded,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'নির্বাচিত ফসল' : 'Selected Crop',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      cropName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedDisease != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.coronavirus_outlined,
                        size: 13,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBn
                            ? selectedDisease!.diseaseNameBn
                            : selectedDisease!.diseaseNameEn,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Crop Switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AiCropCatalog.verifiedSupportedCrops.map((crop) {
                final isSelected = selectedCrop?.id == crop.id;
                final name = isBn ? crop.nameBn : crop.nameEn;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected && onCropChanged != null) {
                        onCropChanged!(crop);
                      }
                    },
                    selectedColor: AppColors.forestGreen,
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primaryText,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.forestGreen
                            : AppColors.border,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
