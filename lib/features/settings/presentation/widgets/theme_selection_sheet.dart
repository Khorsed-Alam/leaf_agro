import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/settings_provider.dart';

/// Screen 25 – Theme Selection Bottom Sheet
/// Allows farmers to select between System Default, Light, and Dark mode.
class ThemeSelectionSheet extends ConsumerWidget {
  const ThemeSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ThemeSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';
    final currentTheme = settings.themeMode;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Heading
            Text(
              isBn ? 'অ্যাপের থিম নির্বাচন' : 'Choose Appearance',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isBn
                  ? 'আপনার স্বাচ্ছন্দ্য অনুযায়ী অ্যাপের থিম নির্ধারণ করুন'
                  : 'Select your preferred visual mode for AgriCare AI',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),

            // 1. System Default
            _ThemeOptionTile(
              icon: Icons.brightness_auto_rounded,
              title: isBn ? 'ডিভাইস ডিফল্ট' : 'System Default',
              subtitle: isBn
                  ? 'ফোনের সেটিংস অনুযায়ী পরিবর্তিত হবে'
                  : 'Match your device settings',
              isSelected: currentTheme == 'system',
              onTap: () {
                ref.read(settingsProvider.notifier).setThemeMode('system');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 10),

            // 2. Light Mode
            _ThemeOptionTile(
              icon: Icons.light_mode_rounded,
              title: isBn ? 'লাইট মোড' : 'Light Mode',
              subtitle: isBn
                  ? 'দিনের বেলার জন্য উজ্জ্বল ব্যাকগ্রাউন্ড'
                  : 'Bright and clear display',
              isSelected: currentTheme == 'light',
              onTap: () {
                ref.read(settingsProvider.notifier).setThemeMode('light');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 10),

            // 3. Dark Mode
            _ThemeOptionTile(
              icon: Icons.dark_mode_rounded,
              title: isBn ? 'ডার্ক মোড' : 'Dark Mode',
              subtitle: isBn
                  ? 'রাতের বেলায় চোখের স্বস্তিদায়ক ব্যাকগ্রাউন্ড'
                  : 'Reduced glare in low-light environments',
              isSelected: currentTheme == 'dark',
              onTap: () {
                ref.read(settingsProvider.notifier).setThemeMode('dark');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.softNaturalGreen
          : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.forestGreen : AppColors.borderGreen,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: isSelected ? AppColors.forestGreen : AppColors.secondaryText,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.forestGreen : AppColors.primaryText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle_rounded,
                color: AppColors.forestGreen,
                size: 22,
              )
            : const Icon(
                Icons.radio_button_unchecked_rounded,
                color: AppColors.secondaryText,
                size: 22,
              ),
      ),
    );
  }
}
