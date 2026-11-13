import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 21 – Header Component
/// Displays the title, subtitle, back navigation, and optional Field History shortcut.
class RecoveryHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isBn;
  final VoidCallback? onBack;

  const RecoveryHeader({
    super.key,
    required this.isBn,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderGreen,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primaryText,
                ),
                tooltip: isBn ? 'ফিরে যান' : 'Back',
                onPressed: () {
                  if (onBack != null) {
                    onBack!();
                  } else {
                    try {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/history');
                      }
                    } catch (_) {
                      Navigator.of(context).maybePop();
                    }
                  }
                },
              ),
              const SizedBox(width: 8),

              // Title and Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'গাছের পুনরুদ্ধার ও ফলো-আপ'
                          : 'Plant Recovery & Follow-up',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'গাছের অবস্থা ট্র্যাক করুন ও পরিবর্তন লিখে রাখুন'
                          : "Keep track of your plant's condition over time",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // History Shortcut Button
              IconButton(
                icon: const Icon(
                  Icons.history_rounded,
                  color: AppColors.forestGreen,
                ),
                tooltip: isBn ? 'ফিল্ড হিস্ট্রি' : 'Field History',
                onPressed: () {
                  try {
                    context.push('/history');
                  } catch (_) {}
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

