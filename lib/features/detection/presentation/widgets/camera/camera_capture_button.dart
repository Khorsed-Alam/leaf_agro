import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Camera Shutter Capture Button
/// 78px circular shutter with white outer ring, Fresh Green core, and loading state.
class CameraCaptureButton extends StatelessWidget {
  final VoidCallback? onCapture;
  final bool isCapturing;
  final bool isBn;

  const CameraCaptureButton({
    super.key,
    required this.onCapture,
    this.isCapturing = false,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onCapture != null && !isCapturing;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: isBn ? 'ছবি তুলুন' : 'Capture photo',
      child: GestureDetector(
        onTap: isEnabled ? onCapture : null,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isEnabled
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.freshGreen,
                        AppColors.forestGreen,
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.grey.shade600,
                        Colors.grey.shade800,
                      ],
                    ),
            ),
            child: Center(
              child: isCapturing
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
