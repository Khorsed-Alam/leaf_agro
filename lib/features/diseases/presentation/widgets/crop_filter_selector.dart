import 'package:flutter/material.dart';
import '../../../../data/models/crop_model.dart';
import 'crop_filter_chip.dart';

class CropFilterSelector extends StatelessWidget {
  final List<CropModel> crops;
  final int? selectedCropId;
  final ValueChanged<int?> onCropSelected;
  final bool isBn;

  const CropFilterSelector({
    super.key,
    required this.crops,
    required this.selectedCropId,
    required this.onCropSelected,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All Crops" Filter Chip
          CropFilterChip(
            label: isBn ? 'সকল ফসল' : 'All Crops',
            isSelected: selectedCropId == null,
            icon: Icons.grid_view_rounded,
            onTap: () => onCropSelected(null),
          ),

          // Individual Crop Filter Chips
          ...crops.map((crop) {
            final isSelected = selectedCropId == crop.id;
            final label = isBn ? crop.nameBn : crop.nameEn;
            return CropFilterChip(
              label: label,
              isSelected: isSelected,
              icon: Icons.grass_rounded,
              onTap: () => onCropSelected(crop.id),
            );
          }),
        ],
      ),
    );
  }
}

