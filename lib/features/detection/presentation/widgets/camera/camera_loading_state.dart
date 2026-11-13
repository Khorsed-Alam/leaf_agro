import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Loading indicator state while camera hardware initializes
class CameraLoadingState extends StatelessWidget {
  final bool isBn;

  const CameraLoadingState({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: AppColors.freshGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isBn ? 'ক্যামেরা চালু হচ্ছে...' : 'Initializing camera...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

