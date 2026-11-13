import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Prominent Continue button pinned to the bottom of Screen 13
class GalleryContinueButton extends StatelessWidget {
  final VoidCallback? onContinue;
  final bool isEnabled;
  final bool isLoading;
  final bool isBn;

  const GalleryContinueButton({
    super.key,
    required this.onContinue,
    this.isEnabled = false,
    this.isLoading = false,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && !isLoading && onContinue != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderGreen.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: canTap ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              elevation: canTap ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.8,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isBn ? 'এগিয়ে যান' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
