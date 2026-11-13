import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentLang = settings.language;
    final isBn = currentLang == 'bn';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: Text(
          isBn ? 'ভাষা নির্বাচন' : 'Select Language',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.forestGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageTile(
            context: context,
            ref: ref,
            code: 'en',
            title: 'English',
            subtitle: 'Default interface',
            isSelected: currentLang == 'en',
          ),
          const SizedBox(height: 12),
          _buildLanguageTile(
            context: context,
            ref: ref,
            code: 'bn',
            title: 'বাংলা (Bangla)',
            subtitle: 'সহজ বাংলা ইন্টারফেস ও পরামর্শ',
            isSelected: currentLang == 'bn',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required WidgetRef ref,
    required String code,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Material(
      color: isSelected ? AppColors.softNaturalGreen : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.forestGreen : AppColors.borderGreen,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          ref.read(settingsProvider.notifier).setLanguage(code);
        },
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
