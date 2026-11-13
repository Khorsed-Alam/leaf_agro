import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../../profile/presentation/widgets/language_selection_sheet.dart';
import '../../profile/presentation/widgets/logout_confirmation_dialog.dart';
import 'widgets/ai_model_information_sheet.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/legal_document_dialog.dart';
import 'widgets/notification_preferences_sheet.dart';
import 'widgets/settings_card_group.dart';
import 'widgets/settings_list_tile.dart';
import 'widgets/storage_cache_sheet.dart';
import 'widgets/theme_selection_sheet.dart';

/// Screen 25 – Settings Screen | AgriCare AI (LeafAgro)
/// Central hub for account settings, application preferences (Language, Notifications, Appearance),
/// offline AI model inspection, temporary cache management, and verified legal documentation.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getThemeName(String mode, bool isBn) {
    switch (mode) {
      case 'dark':
        return isBn ? 'ডার্ক মোড' : 'Dark';
      case 'light':
        return isBn ? 'লাইট মোড' : 'Light';
      default:
        return isBn ? 'ডিভাইস ডিফল্ট' : 'System Default';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    final languageName = isBn ? 'বাংলা' : 'English';
    final themeName = _getThemeName(settings.themeMode, isBn);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.primaryText),
          tooltip: isBn ? 'ফিরে যান' : 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          isBn ? 'সেটিংস' : 'Settings',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.forestGreen,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── B. Account Section ─────────────────────────────────────────
              SettingsCardGroup(
                title: isBn ? 'অ্যাকাউন্ট' : 'Account',
                children: [
                  SettingsListTile(
                    icon: Icons.person_outline_rounded,
                    title: isBn ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile',
                    subtitle: isBn
                        ? 'ব্যক্তিগত তথ্য ও জেলা পরিবর্তন করুন'
                        : 'Update your personal information',
                    onTap: () {
                      try {
                        context.push('/profile/edit');
                      } catch (_) {}
                    },
                  ),
                  SettingsListTile(
                    icon: Icons.lock_outline_rounded,
                    title: isBn ? 'পাসওয়ার্ড পরিবর্তন' : 'Change Password',
                    subtitle: isBn
                        ? 'অ্যাকাউন্টের নতুন পাসওয়ার্ড সেট করুন'
                        : 'Update your account password',
                    onTap: () => ChangePasswordDialog.show(context, isBn),
                  ),
                  SettingsListTile(
                    icon: Icons.logout_rounded,
                    iconColor: AppColors.error,
                    iconBgColor:
                        AppColors.errorContainer.withValues(alpha: 0.5),
                    title: isBn ? 'লগআউট' : 'Log Out',
                    subtitle: isBn
                        ? 'অ্যাকাউন্ট থেকে নিরাপদে বের হয়ে যান'
                        : 'Sign out of your AgriCare account',
                    showDivider: false,
                    onTap: () => LogoutConfirmationDialog.show(context, isBn),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── C. Preferences Section ─────────────────────────────────────
              SettingsCardGroup(
                title: isBn ? 'পছন্দসমূহ' : 'Preferences',
                children: [
                  SettingsListTile(
                    icon: Icons.language_rounded,
                    title: isBn ? 'ভাষা' : 'Language',
                    subtitle: isBn
                        ? 'বর্তমান ভাষা: $languageName'
                        : 'Current language: $languageName',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          languageName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.secondaryText,
                          size: 20,
                        ),
                      ],
                    ),
                    onTap: () => LanguageSelectionSheet.show(context),
                  ),
                  SettingsListTile(
                    icon: Icons.notifications_none_rounded,
                    title: isBn ? 'নোটিফিকেশন' : 'Notifications',
                    subtitle: isBn
                        ? 'সতর্কতা ও কৃষি পরামর্শের নোটিফিকেশন'
                        : 'Manage app notification preferences',
                    onTap: () => NotificationPreferencesSheet.show(context),
                  ),
                  SettingsListTile(
                    icon: Icons.palette_outlined,
                    title: isBn ? 'থিম ও ডিসপ্লে' : 'Appearance',
                    subtitle: themeName,
                    showDivider: false,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          themeName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.secondaryText,
                          size: 20,
                        ),
                      ],
                    ),
                    onTap: () => ThemeSelectionSheet.show(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── D. Application Section ─────────────────────────────────────
              SettingsCardGroup(
                title: isBn ? 'অ্যাপ্লিকেশন' : 'Application',
                children: [
                  SettingsListTile(
                    icon: Icons.memory_rounded,
                    title: isBn ? 'অফলাইন এআই মডেল' : 'Offline AI Model',
                    subtitle: isBn
                        ? 'অন-ডিভাইস নিউরাল নেটওয়ার্ক স্পেসিফিকেশন'
                        : 'View AI model information',
                    onTap: () => AiModelInformationSheet.show(context, isBn),
                  ),
                  SettingsListTile(
                    icon: Icons.storage_rounded,
                    title: isBn ? 'স্টোরেজ ও ক্যাশ' : 'Storage & Cache',
                    subtitle: isBn
                        ? 'অস্থায়ী ক্যাশ মেমরি পর্যবেক্ষণ ও মুছুন'
                        : 'View storage usage and manage temporary files',
                    onTap: () => StorageCacheSheet.show(context, isBn),
                  ),
                  SettingsListTile(
                    icon: Icons.help_outline_rounded,
                    title: isBn ? 'সহায়তা ও প্রশ্নোত্তর' : 'Help & FAQ',
                    subtitle: isBn
                        ? 'ব্যবহারবিধি, ছবি তোলার নিয়ম ও সাধারণ প্রশ্ন'
                        : 'Guides, photography tips, and FAQs',
                    onTap: () {
                      try {
                        context.push('/help');
                      } catch (_) {}
                    },
                  ),
                  SettingsListTile(
                    icon: Icons.privacy_tip_outlined,
                    title: isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
                    subtitle: isBn
                        ? 'আপনার ডাটা সুরক্ষা ও ব্যবহার সংক্রান্ত নিয়ম'
                        : 'Learn how your data is handled',
                    onTap: () => LegalDocumentDialog.show(
                      context,
                      type: LegalDocumentType.privacyPolicy,
                      isBn: isBn,
                    ),
                  ),
                  SettingsListTile(
                    icon: Icons.description_outlined,
                    title: isBn ? 'শর্তাবলী ও নীতিমালা' : 'Terms & Conditions',
                    subtitle: isBn
                        ? 'অ্যাপ্লিকেশন ব্যবহারের নির্দেশিকা'
                        : 'Read the application terms',
                    showDivider: false,
                    onTap: () => LegalDocumentDialog.show(
                      context,
                      type: LegalDocumentType.termsAndConditions,
                      isBn: isBn,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── E. App Version Footer ──────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'সংস্করণ ${AppConstants.appVersion} (বিল্ড ১)'
                          : 'Version ${AppConstants.appVersion} (Build 1)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'বাংলাদেশি কৃষকদের জন্য নিবেদিত'
                          : 'Dedicated to Bangladeshi Farmers',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
