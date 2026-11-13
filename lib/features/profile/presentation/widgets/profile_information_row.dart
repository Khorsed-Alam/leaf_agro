import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 24 – Profile Information Row
/// Displays an individual information row with an icon, field label, value,
/// and an optional bottom divider.
class ProfileInformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;
  final bool showDivider;

  const ProfileInformationRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGreen, width: 0.8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 14),

              // Field Label & Value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isPlaceholder
                            ? AppColors.secondaryText.withValues(alpha: 0.75)
                            : AppColors.primaryText,
                        fontStyle:
                            isPlaceholder ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFF0F4EF),
          ),
      ],
    );
  }
}

