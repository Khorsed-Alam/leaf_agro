import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'flash_toggle_button.dart';

/// Top bar overlay for Camera Screen
/// Features a Dismiss/Close button, optional Crop Badge, and Flash Mode cycle button.
class CameraTopControls extends StatelessWidget {
  final VoidCallback onClose;
  final FlashMode flashMode;
  final bool hasFlash;
  final ValueChanged<FlashMode> onFlashModeChanged;
  final String? selectedCropName;
  final bool isBn;

  const CameraTopControls({
    super.key,
    required this.onClose,
    required this.flashMode,
    required this.hasFlash,
    required this.onFlashModeChanged,
    this.selectedCropName,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.65),
            Colors.black.withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close / Cancel Button
            Semantics(
              button: true,
              label: isBn ? 'ক্যামেরা বন্ধ করুন' : 'Close camera',
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onClose,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white24,
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Active Crop Indicator (if any)
            if (selectedCropName != null && selectedCropName!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.freshGreen.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: AppColors.limeGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      selectedCropName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),

            // Flash Mode Toggle
            FlashToggleButton(
              currentMode: flashMode,
              hasFlash: hasFlash,
              onModeChanged: onFlashModeChanged,
              isBn: isBn,
            ),
          ],
        ),
      ),
    );
  }
}
