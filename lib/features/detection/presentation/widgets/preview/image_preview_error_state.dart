import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Clean error or empty state when no image is selected or file is unreadable
class ImagePreviewErrorState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final bool isBn;

  const ImagePreviewErrorState({
    super.key,
    required this.title,
    required this.description,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.amber.shade800,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onPickCamera,
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: Text(
                  isBn ? 'ক্যামেরা দিয়ে ছবি তুলুন' : 'Take Photo with Camera',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onPickGallery,
                icon: const Icon(Icons.photo_library_rounded, size: 20),
                label: Text(
                  isBn ? 'গ্যালারি থেকে ছবি বাছুন' : 'Choose from Gallery',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forestGreen,
                  side: const BorderSide(
                    color: AppColors.borderGreen,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
