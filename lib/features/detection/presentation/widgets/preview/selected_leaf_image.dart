import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/leaf_image_view.dart';

/// Large Selected Leaf Photograph Display
/// High-fidelity viewport preserving aspect ratio for both landscape and portrait captures.
class SelectedLeafImage extends StatelessWidget {
  final String imagePath;
  final bool isBn;

  const SelectedLeafImage({
    super.key,
    required this.imagePath,
    required this.isBn,
  });

  bool _isReadable() {
    if (kIsWeb) return imagePath.isNotEmpty;
    try {
      final file = File(imagePath);
      return file.existsSync() && file.lengthSync() > 0;
    } catch (_) {
      return imagePath.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFileOk = _isReadable();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFileOk ? AppColors.freshGreen.withValues(alpha: 0.8) : Colors.red.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isFileOk
                ? AppColors.forestGreen.withValues(alpha: 0.08)
                : Colors.red.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: isFileOk
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Main leaf preview with contain to prevent distorting aspect ratios
                  LeafImageView(
                    imagePath: imagePath,
                    fit: BoxFit.contain,
                  ),

                  // Verified Corner Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.freshGreen,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.freshGreen,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isBn ? 'নমুনা প্রস্তুত' : 'Ready',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        color: Colors.red.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isBn
                            ? 'ছবিটি পড়তে ব্যর্থ হয়েছে'
                            : 'Unable to read this image file',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBn
                            ? 'ফাইলটি মুছে গেছে বা নষ্ট হয়েছে। নতুন ছবি তুলুন।'
                            : 'The file may be corrupted or missing. Please retake photo.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
