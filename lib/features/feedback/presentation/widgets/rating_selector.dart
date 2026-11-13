import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 29 – Interactive Five-Star Rating Selector
class RatingSelector extends StatelessWidget {
  final int selectedRating;
  final ValueChanged<int> onRatingChanged;
  final String? errorText;
  final bool isBn;

  const RatingSelector({
    super.key,
    required this.selectedRating,
    required this.onRatingChanged,
    this.errorText,
    required this.isBn,
  });

  String _getRatingLabel(int rating) {
    if (rating <= 0) return '';
    if (isBn) {
      switch (rating) {
        case 1:
          return 'খুব খারাপ (১/৫)';
        case 2:
          return 'মোটামুটি (২/৫)';
        case 3:
          return 'ভালো (৩/৫)';
        case 4:
          return 'অনেক ভালো (৪/৫)';
        case 5:
          return 'চমৎকার (৫/৫)';
        default:
          return '';
      }
    } else {
      switch (rating) {
        case 1:
          return 'Poor (1/5)';
        case 2:
          return 'Fair (2/5)';
        case 3:
          return 'Good (3/5)';
        case 4:
          return 'Very Good (4/5)';
        case 5:
          return 'Excellent (5/5)';
        default:
          return '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _getRatingLabel(selectedRating);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: errorText != null ? AppColors.error : AppColors.borderGreen,
          width: errorText != null ? 1.4 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn
                ? 'আপনার অভিজ্ঞতা কেমন ছিল?'
                : 'How would you rate your experience?',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 12),

          // Star Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isFilled = starValue <= selectedRating;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Semantics(
                  label: isBn ? '$starValue স্টার' : '$starValue star',
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => onRatingChanged(starValue),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: AnimatedScale(
                          scale: isFilled ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: isFilled
                                ? AppColors.freshGreen
                                : const Color(0xFFD1D5DB),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Dynamic Rating Label
          if (label.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softNaturalGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGreen, width: 1),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Error Text
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
