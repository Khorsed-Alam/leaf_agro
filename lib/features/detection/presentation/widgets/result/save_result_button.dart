import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

enum SaveState { initial, saving, saved, error }

/// Action button to save the genuine diagnosis to local/remote scan history
class SaveResultButton extends StatelessWidget {
  final VoidCallback? onSave;
  final SaveState state;
  final bool isBn;

  const SaveResultButton({
    super.key,
    required this.onSave,
    this.state = SaveState.initial,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final isSaved = state == SaveState.saved;
    final isSaving = state == SaveState.saving;

    String labelText() {
      switch (state) {
        case SaveState.saving:
          return isBn ? 'সংরক্ষণ করা হচ্ছে...' : 'Saving to Field History...';
        case SaveState.saved:
          return isBn ? 'সংরক্ষিত হয়েছে ✓' : 'Saved to Field History ✓';
        case SaveState.error:
          return isBn
              ? 'সংরক্ষণ ব্যর্থ, আবার চেষ্টা করুন'
              : 'Save Failed, Tap to Retry';
        case SaveState.initial:
          return isBn ? 'ফলাফল সংরক্ষণ করুন' : 'Save Result to Field Log';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: (isSaved || isSaving) ? null : onSave,
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.forestGreen,
                  ),
                )
              : Icon(
                  isSaved
                      ? Icons.check_circle_rounded
                      : Icons.bookmark_add_outlined,
                  size: 19,
                  color:
                      isSaved ? AppColors.forestGreen : AppColors.forestGreen,
                ),
          label: Text(
            labelText(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSaved ? AppColors.forestGreen : AppColors.forestGreen,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSaved
                ? AppColors.freshGreen.withValues(alpha: 0.1)
                : Colors.white,
            side: BorderSide(
              color: isSaved ? AppColors.freshGreen : AppColors.borderGreen,
              width: 1.4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
