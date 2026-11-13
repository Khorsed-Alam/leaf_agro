import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Primary Gallery Selection Area on Screen 13
/// Displayed when no image has been selected yet.
class GallerySelectionCard extends StatelessWidget {
  final VoidCallback? onBrowse;
  final bool isBusy;
  final bool isBn;

  const GallerySelectionCard({
    super.key,
    required this.onBrowse,
    this.isBusy = false,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: isBusy ? null : onBrowse,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Visual Icon Container
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.freshGreen.withValues(alpha: 0.18),
                        AppColors.limeGreen.withValues(alpha: 0.28),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.freshGreen.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isBusy
                        ? const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.2,
                              color: AppColors.forestGreen,
                            ),
                          )
                        : const Icon(
                            Icons.photo_library_rounded,
                            size: 44,
                            color: AppColors.forestGreen,
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Heading
                Text(
                  isBn ? 'গ্যালারি থেকে নির্বাচন করুন' : 'Select from Gallery',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Helper description
                Text(
                  isBn
                      ? 'আপনার ডিভাইসের ফটো লাইব্রেরি থেকে উদ্ভিদের পাতার স্পষ্ট ছবি বেছে নিন।'
                      : 'Choose an existing high-clarity plant leaf photo from your device storage.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Prominent "Browse Gallery" button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : onBrowse,
                    icon: isBusy
                        ? const SizedBox.shrink()
                        : const Icon(Icons.folder_open_rounded, size: 20),
                    label: Text(
                      isBusy
                          ? (isBn
                              ? 'গ্যালারি খোলা হচ্ছে...'
                              : 'Opening Gallery...')
                          : (isBn ? 'গ্যালারি ব্রাউজ করুন' : 'Browse Gallery'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.forestGreen.withValues(alpha: 0.6),
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
