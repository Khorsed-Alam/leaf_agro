import 'package:flutter/material.dart';

/// Gallery Shortcut Button on Camera Overlay
/// Allows farmers to switch to gallery picking directly from camera screen.
class GalleryShortcutButton extends StatelessWidget {
  final VoidCallback? onOpenGallery;
  final bool isBn;
  final bool isBusy;

  const GalleryShortcutButton({
    super.key,
    required this.onOpenGallery,
    required this.isBn,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onOpenGallery != null && !isBusy;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: isBn ? 'গ্যালারি থেকে ছবি বাছুন' : 'Pick image from gallery',
      child: GestureDetector(
        onTap: isEnabled ? onOpenGallery : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
                border: Border.all(
                  color: Colors.white30,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isBn ? 'গ্যালারি' : 'Gallery',
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

