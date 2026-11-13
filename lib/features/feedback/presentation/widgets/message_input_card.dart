import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 29 – Feedback Message Input Card
class MessageInputCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isBn;

  const MessageInputCard({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
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
            isBn ? 'বিস্তারিত লিখুন' : 'Tell us more',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isBn
                ? 'আপনার পরামর্শ বা সমস্যার বিবরণ লিখুন।'
                : 'Share your suggestions or describe a problem you experienced.',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 12),

          // Multiline Text Area
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 5,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: isBn
                  ? 'আপনার মতামত বা সমস্যার বিবরণ এখানে লিখুন...'
                  : 'Write your feedback here...',
              hintStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
              ),
              fillColor: AppColors.softNaturalGreen,
              filled: true,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderGreen),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderGreen),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.forestGreen,
                  width: 1.4,
                ),
              ),
            ),
          ),

          // Error Text
          if (errorText != null) ...[
            const SizedBox(height: 4),
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
