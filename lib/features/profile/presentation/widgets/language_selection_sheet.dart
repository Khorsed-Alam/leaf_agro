import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/settings_provider.dart';

/// Screen 24 – Language Selection Bottom Sheet
/// Lets the farmer switch seamlessly between English and বাংলা with immediate application.
class LanguageSelectionSheet extends ConsumerWidget {
  const LanguageSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LanguageSelectionSheet(),
    );
  }

  Future<void> _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    String languageCode,
  ) async {
    await ref.read(settingsProvider.notifier).setLanguage(languageCode);

    // Sync preferred language to profile row in Supabase if profile is available
    try {
      final currentProfile = ref.read(profileProvider).value;
      if (currentProfile != null && currentProfile.preferredLanguage != languageCode) {
        final userService = ref.read(userServiceProvider);
        final updated = currentProfile.copyWith(preferredLanguage: languageCode);
        await userService.updateProfile(updated);
        ref.invalidate(profileProvider);
      }
    } catch (_) {}

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentLang = settings.language;
    final isBn = currentLang == 'bn';

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

            // Sheet Title
            Text(
              isBn ? 'ভাষা নির্বাচন করুন' : 'Select Language',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isBn
                  ? 'আপনার পছন্দের ভাষায় অ্যাপ ব্যবহার করুন'
                  : 'Choose your preferred display language',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),

            // English Option
            _LanguageOptionTile(
              title: 'English',
              subtitle: 'Default language',
              isSelected: currentLang == 'en',
              onTap: () => _selectLanguage(context, ref, 'en'),
            ),
            const SizedBox(height: 10),

            // Bangla Option
            _LanguageOptionTile(
              title: 'বাংলা (Bangla)',
              subtitle: 'সহজ বাংলা ইন্টারফেস ও পরামর্শ',
              isSelected: currentLang == 'bn',
              onTap: () => _selectLanguage(context, ref, 'bn'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
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
