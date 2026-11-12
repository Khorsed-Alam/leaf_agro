import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class FilterSearchScreen extends StatefulWidget {
  const FilterSearchScreen({super.key});

  @override
  State<FilterSearchScreen> createState() => _FilterSearchScreenState();
}

class _FilterSearchScreenState extends State<FilterSearchScreen> {
  String _selectedCrop = 'All';
  String _selectedHealth = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter & Search Logs')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Crop Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['All', 'Rice', 'Potato', 'Tomato', 'Mango', 'Jute'].map((crop) {
                final isSelected = _selectedCrop == crop;
                return ChoiceChip(
                  label: Text(crop),
                  selected: isSelected,
                  selectedColor: AppColors.secondaryContainer,
                  onSelected: (val) => setState(() => _selectedCrop = crop),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Plant Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['All', 'Healthy Only', 'Diseased Only'].map((status) {
                final isSelected = _selectedHealth == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: AppColors.secondaryContainer,
                  onSelected: (val) => setState(() => _selectedHealth = status),
                );
              }).toList(),
            ),
            const Spacer(),
            CustomButton(
              text: 'Apply Filters',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

