import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';

class ContinueButton extends StatelessWidget {
  final CropModel? selectedCrop;
  final bool isBn;
  final VoidCallback? onContinue;

  const ContinueButton({
    super.key,
    required this.selectedCrop,
    required this.isBn,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = selectedCrop != null && onContinue != null;
    final cropDisplayName = selectedCrop != null
        ? (isBn ? '${selectedCrop!.nameBn} (${selectedCrop!.nameEn})' : '${selectedCrop!.nameEn} (${selectedCrop!.nameBn})')
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.borderGreen, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected Crop Summary Indicator
              if (selectedCrop != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.freshGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBn ? 'নির্বাচিত: ' : 'Selected: ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        cropDisplayName ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),

              // Full-Width CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isEnabled ? onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    elevation: isEnabled ? 4 : 0,
                    shadowColor: AppColors.forestGreen.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEnabled
                            ? (isBn ? 'রোগ পরীক্ষায় এগিয়ে যান' : 'Continue to Scan')
                            : (isBn ? 'একটি ফসল নির্বাচন করুন' : 'Select a Crop to Continue'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

