import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

enum AnalyzeButtonState { ready, checking, analyzing, error }

/// Primary Analyze Image Button pinned at the bottom of Screen 14
class AnalyzeImageButton extends StatelessWidget {
  final VoidCallback? onAnalyze;
  final AnalyzeButtonState state;
  final bool isBn;

  const AnalyzeImageButton({
    super.key,
    required this.onAnalyze,
    this.state = AnalyzeButtonState.ready,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = state == AnalyzeButtonState.checking ||
        state == AnalyzeButtonState.analyzing;
    final isEnabled = onAnalyze != null && !isBusy;

    String buttonText() {
      switch (state) {
        case AnalyzeButtonState.checking:
          return isBn ? 'ছবি যাচাই হচ্ছে...' : 'Checking Image...';
        case AnalyzeButtonState.analyzing:
          return isBn ? 'AI বিশ্লেষণ চলছে...' : 'Analyzing Leaf with AI...';
        case AnalyzeButtonState.error:
          return isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry Analysis';
        case AnalyzeButtonState.ready:
          return isBn ? 'রোগ বিশ্লেষণ করুন' : 'Analyze Leaf with AI';
      }
    }

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
            color: AppColors.forestGreen.withValues(alpha: 0.05),
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
            onPressed: isEnabled ? onAnalyze : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: isBusy
                  ? AppColors.forestGreen.withValues(alpha: 0.7)
                  : Colors.grey.shade300,
              disabledForegroundColor: Colors.white70,
              elevation: isEnabled ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isBusy
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        buttonText(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.limeGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        buttonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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
