import 'package:flutter/material.dart';
import '../../../../data/models/crop_model.dart';
import 'crop_selection_card.dart';

class CropSelectionGrid extends StatelessWidget {
  final List<CropModel> crops;
  final CropModel? selectedCrop;
  final bool isBn;
  final ValueChanged<CropModel> onSelect;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const CropSelectionGrid({
    super.key,
    required this.crops,
    required this.selectedCrop,
    required this.isBn,
    required this.onSelect,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: crops.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final crop = crops[index];
        final isSelected = selectedCrop?.id == crop.id;

        return CropSelectionCard(
          crop: crop,
          isSelected: isSelected,
          isBn: isBn,
          onTap: () => onSelect(crop),
        );
      },
    );
  }
}

