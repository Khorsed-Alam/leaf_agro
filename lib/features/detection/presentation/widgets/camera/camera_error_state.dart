import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Displayed when Camera fails to initialize or hardware is unavailable
class CameraErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onOpenGallery;
  final VoidCallback onClose;
  final bool isBn;

  const CameraErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onOpenGallery,
    required this.onClose,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade900.withValues(alpha: 0.3),
                border: Border.all(
                  color: Colors.red.shade400,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isBn ? 'ক্যামেরা চালু করা যায়নি' : 'Camera Unavailable',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage.isNotEmpty
                  ? errorMessage
                  : (isBn
                      ? 'ক্যামেরা ডিভাইসে সংযোগ করতে সমস্যা হচ্ছে। আবার চেষ্টা করুন বা গ্যালারি ব্যবহার করুন।'
                      : 'Unable to connect to camera sensor. Please retry or pick from gallery.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            // Retry button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  isBn ? 'আবার চেষ্টা করুন' : 'Retry Camera',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.freshGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Gallery fallback button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onOpenGallery,
                icon: const Icon(Icons.photo_library_rounded, size: 20),
                label: Text(
                  isBn ? 'গ্যালারি থেকে বেছে নিন' : 'Choose from Gallery',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onClose,
              child: Text(
                isBn ? 'ফিরে যান' : 'Go Back',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

