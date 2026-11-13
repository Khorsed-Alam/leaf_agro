import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Secondary action buttons: Retake Photo and Choose Another Image
class ImagePreviewActions extends StatelessWidget {
  final VoidCallback onRetakePhoto;
  final VoidCallback onChooseAnotherImage;
  final bool isBusy;
  final bool isBn;

  const ImagePreviewActions({
    super.key,
    required this.onRetakePhoto,
    required this.onChooseAnotherImage,
    this.isBusy = false,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 1. Retake Photo
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isBusy ? null : onRetakePhoto,
              icon: const Icon(Icons.photo_camera_rounded, size: 18),
              label: Text(
                isBn ? 'আবার তুলুন' : 'Retake Photo',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.forestGreen,
                side: const BorderSide(
                  color: AppColors.borderGreen,
                  width: 1.4,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 2. Choose Another Image
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isBusy ? null : onChooseAnotherImage,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(
                isBn ? 'অন্য ছবি দিন' : 'Change Image',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.forestGreen,
                side: const BorderSide(
                  color: AppColors.borderGreen,
                  width: 1.4,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
