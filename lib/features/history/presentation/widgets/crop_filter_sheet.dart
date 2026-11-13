import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/ai_crop_catalog.dart';
import '../../../../data/models/crop_model.dart';

/// Bottom sheet dialog to select a crop filter for detection history
class CropFilterSheet extends StatelessWidget {
  final String selectedCrop;
  final List<CropModel> availableCrops;
  final bool isBn;
  final ValueChanged<String> onCropSelected;

  const CropFilterSheet({
    super.key,
    required this.selectedCrop,
    required this.availableCrops,
    required this.isBn,
    required this.onCropSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String selectedCrop,
    List<CropModel>? availableCrops,
    required bool isBn,
    required ValueChanged<String> onCropSelected,
  }) {
    final crops = availableCrops ?? AiCropCatalog.verifiedSupportedCrops;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CropFilterSheet(
        selectedCrop: selectedCrop,
        availableCrops: crops,
        isBn: isBn,
        onCropSelected: onCropSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'ফসল অনুযায়ী ফিল্টার' : 'Filter by Crop',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // "All Crops" Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                selectedCrop == 'All'
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selectedCrop == 'All'
                    ? AppColors.forestGreen
                    : AppColors.secondaryText,
              ),
              title: Text(
                isBn ? 'সকল ফসল (All Crops)' : 'All Crops',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selectedCrop == 'All'
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selectedCrop == 'All'
                      ? AppColors.forestGreen
                      : AppColors.primaryText,
                ),
              ),
              onTap: () {
                onCropSelected('All');
                Navigator.pop(context);
              },
            ),

            // Crop Options from Catalog
            ...availableCrops.map((crop) {
              final isSelected =
                  selectedCrop.toLowerCase() == crop.nameEn.toLowerCase();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? AppColors.forestGreen
                      : AppColors.secondaryText,
                ),
                title: Text(
                  '${crop.nameEn} (${crop.nameBn})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.forestGreen
                        : AppColors.primaryText,
                  ),
                ),
                onTap: () {
                  onCropSelected(crop.nameEn);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
