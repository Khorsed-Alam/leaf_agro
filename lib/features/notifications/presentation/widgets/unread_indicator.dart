import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 27 – Unread Indicator Dot
/// Renders a small fresh green dot with accessibility semantic labeling.
class UnreadIndicator extends StatelessWidget {
  final bool isUnread;

  const UnreadIndicator({
    super.key,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUnread) return const SizedBox.shrink();

    return Semantics(
      label: 'Unread notification indicator',
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.freshGreen,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

