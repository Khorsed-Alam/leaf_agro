import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

enum QualityState { checking, ready, warning, error }

/// Compact status banner showing real file validation state
class ImageQualityStatus extends StatelessWidget {
  final QualityState state;
  final String? customMessage;
  final bool isBn;

  const ImageQualityStatus({
    super.key,
    required this.state,
    this.customMessage,
    required this.isBn,
  });

  Color _getBackgroundColor() {
    switch (state) {
      case QualityState.ready:
        return AppColors.freshGreen.withValues(alpha: 0.12);
      case QualityState.warning:
        return Colors.amber.shade50;
      case QualityState.error:
        return Colors.red.shade50;
      case QualityState.checking:
        return Colors.blue.shade50;
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case QualityState.ready:
        return AppColors.freshGreen.withValues(alpha: 0.4);
      case QualityState.warning:
        return Colors.amber.shade300;
      case QualityState.error:
        return Colors.red.shade300;
      case QualityState.checking:
        return Colors.blue.shade200;
    }
  }

  Color _getIconColor() {
    switch (state) {
      case QualityState.ready:
        return AppColors.forestGreen;
      case QualityState.warning:
        return Colors.amber.shade800;
      case QualityState.error:
        return Colors.red.shade700;
      case QualityState.checking:
        return Colors.blue.shade700;
    }
  }

  IconData _getIcon() {
    switch (state) {
      case QualityState.ready:
        return Icons.check_circle_rounded;
      case QualityState.warning:
        return Icons.warning_amber_rounded;
      case QualityState.error:
        return Icons.error_outline_rounded;
      case QualityState.checking:
        return Icons.hourglass_top_rounded;
    }
  }

  String _getDefaultTitle() {
    switch (state) {
      case QualityState.ready:
        return isBn ? 'ছবি প্রস্তুত' : 'Image Ready';
      case QualityState.warning:
        return isBn ? 'ছবির সতর্কতা' : 'Image Quality Warning';
      case QualityState.error:
        return isBn ? 'ছবি পড়া যায়নি' : 'Unable to Read Image';
      case QualityState.checking:
        return isBn ? 'ছবি যাচাই করা হচ্ছে...' : 'Checking Image...';
    }
  }

  String _getDefaultSubtitle() {
    switch (state) {
      case QualityState.ready:
        return isBn
            ? 'ছবিটি AI মডেলের বিশ্লেষণের জন্য প্রস্তুত।'
            : 'Image verified and ready for AI analysis.';
      case QualityState.warning:
        return isBn
            ? 'ছবির আকার বেশ বড়, প্রক্রিয়াকরণে সময় লাগতে পারে।'
            : 'Image size is large, preprocessing may take longer.';
      case QualityState.error:
        return isBn
            ? 'ফাইলটি খালি বা বিনষ্ট। দয়া করে নতুন ছবি দিন।'
            : 'Image file is missing or invalid. Please choose another.';
      case QualityState.checking:
        return isBn
            ? 'ফাইলের গুণমান ও আকার পরীক্ষা চলছে।'
            : 'Validating format and file integrity...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDefaultTitle(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _getIconColor(),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  customMessage ?? _getDefaultSubtitle(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _getIconColor().withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
