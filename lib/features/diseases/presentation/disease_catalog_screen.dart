import 'package:flutter/material.dart';
import 'plant_disease_categories_screen.dart';

/// Screen 09 – Plant Disease Categories Screen
/// Replaces the placeholder directory with the full premium disease catalog.
class DiseaseCatalogScreen extends StatelessWidget {
  final int? initialCropId;

  const DiseaseCatalogScreen({
    super.key,
    this.initialCropId,
  });

  @override
  Widget build(BuildContext context) {
    return PlantDiseaseCategoriesScreen(initialCropId: initialCropId);
  }
}
