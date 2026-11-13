import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Top header for Screen 16 – AI Detection Result Screen
class DetectionResultHeader extends StatelessWidget {
  final bool isBn;
  final VoidCallback? onClose;

  const DetectionResultHeader({
    super.key,
    required this.isBn,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.freshGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'শনাক্তকরণ ফলাফল' : 'Detection Result',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    isBn ? 'AI বিশ্লেষণ সফল হয়েছে' : 'Analysis completed',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Close / Exit button
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 1,
            shadowColor: Colors.black12,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                if (onClose != null) {
                  onClose!();
                } else {
                  try {
                    context.go('/home');
                  } catch (_) {
                    Navigator.of(context).maybePop();
                  }
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderGreen,
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.primaryText,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
