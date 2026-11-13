import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/help_models.dart';

/// Screen 28 – Quick Guide Card
class QuickGuideCard extends StatelessWidget {
  final HelpGuide guide;
  final bool isBn;
  final VoidCallback onTap;

  const QuickGuideCard({
    super.key,
    required this.guide,
    required this.isBn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual Theme Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.softNaturalGreen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGreen, width: 1),
                  ),
                  child: Icon(
                    guide.icon,
                    color: AppColors.forestGreen,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Guide Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              guide.title(isBn),
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestGreen,
                                height: 1.25,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.forestGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: AppColors.forestGreen,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  guide.readingTime(isBn),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        guide.description(isBn),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Visual Flow Pills Preview
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children:
                            guide.visualSequence(isBn).take(3).map((step) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F6F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              step,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Chevron indicating tap action
                const Padding(
                  padding: EdgeInsets.only(top: 14.0),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.forestGreen,
                    size: 22,
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
