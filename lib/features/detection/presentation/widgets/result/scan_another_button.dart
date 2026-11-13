import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Prominent primary button allowing farmers to initiate another plant disease scan
class ScanAnotherButton extends StatelessWidget {
  final VoidCallback onScanAnother;
  final bool isBn;

  const ScanAnotherButton({
    super.key,
    required this.onScanAnother,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onScanAnother,
          icon: const Icon(Icons.document_scanner_rounded, size: 20),
          label: Text(
            isBn ? 'অন্য গাছ স্ক্যান করুন' : 'Scan Another Plant',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.freshGreen,
            foregroundColor: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
