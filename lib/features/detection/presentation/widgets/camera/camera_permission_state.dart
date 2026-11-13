import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Displayed when Camera permissions are denied
class CameraPermissionState extends StatelessWidget {
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenGallery;
  final VoidCallback onClose;
  final bool isPermanentlyDenied;
  final bool isBn;

  const CameraPermissionState({
    super.key,
    required this.onRequestPermission,
    required this.onOpenGallery,
    required this.onClose,
    this.isPermanentlyDenied = false,
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
                color: Colors.amber.shade900.withValues(alpha: 0.25),
                border: Border.all(
                  color: Colors.amber.shade400,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.no_photography_rounded,
                color: Colors.amber,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isBn ? 'ক্যামেরা ব্যবহারের অনুমতি প্রয়োজন' : 'Camera Permission Required',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isBn
                  ? 'গাছের পাতার ছবি তুলে রোগ শনাক্ত করতে ক্যামেরার অ্যাক্সেস দিন।'
                  : 'AgriCare AI needs camera access to capture leaf photos for offline disease detection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            // Primary permission button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRequestPermission,
                icon: const Icon(Icons.lock_open_rounded, size: 20),
                label: Text(
                  isPermanentlyDenied
                      ? (isBn ? 'সেটিংস খুলুন' : 'Open Settings')
                      : (isBn ? 'অনুমতি দিন' : 'Grant Permission'),
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
                isBn ? 'বাতিল করুন' : 'Cancel',
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

