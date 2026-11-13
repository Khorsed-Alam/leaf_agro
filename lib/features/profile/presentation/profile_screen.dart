import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../home/presentation/widgets/dashboard_bottom_navigation.dart';
import 'widgets/account_information_card.dart';
import 'widgets/detection_activity_card.dart';
import 'widgets/language_selection_sheet.dart';
import 'widgets/logout_confirmation_dialog.dart';
import 'widgets/personal_information_card.dart';
import 'widgets/profile_action_tile.dart';
import 'widgets/profile_header.dart';

/// Screen 24 – User Profile Screen | AgriCare AI (LeafAgro)
/// A friendly, professional farmer profile hub displaying authenticated personal details,
/// total crop disease detections, account creation date, profile editor, settings, and secure logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    final profileAsync = ref.watch(profileProvider);
    final currentUser = ref.watch(currentUserProvider);
    final detectionCountAsync = ref.watch(userDetectionCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const DashboardBottomNavigation(selectedIndex: 3),
      body: SafeArea(
        top: false,
        child: profileAsync.when(
          data: (profileData) {
            final profile = profileData ?? currentUser;
            return _buildProfileContent(
              context: context,
              ref: ref,
              profile: profile,
              detectionCountAsync: detectionCountAsync,
              isBn: isBn,
            );
          },
          loading: () => currentUser != null
              ? _buildProfileContent(
                  context: context,
                  ref: ref,
                  profile: currentUser,
                  detectionCountAsync: detectionCountAsync,
                  isBn: isBn,
                )
              : _buildLoadingSkeleton(isBn),
          error: (err, stack) => currentUser != null
              ? _buildProfileContent(
                  context: context,
                  ref: ref,
                  profile: currentUser,
                  detectionCountAsync: detectionCountAsync,
                  isBn: isBn,
                )
              : _buildErrorState(context, ref, isBn, err.toString()),
        ),
      ),
    );
  }

  Widget _buildProfileContent({
    required BuildContext context,
    required WidgetRef ref,
    required UserProfileModel? profile,
    required AsyncValue<int> detectionCountAsync,
    required bool isBn,
  }) {
    final fullName = profile?.fullName ?? (isBn ? 'কৃষক' : 'Farmer');
    final email = profile?.email ?? '';
    final avatarUrl = profile?.avatarUrl;
    final phoneNumber = profile?.phoneNumber;
    final district = profile?.district;
    final createdAt = profile?.createdAt;

    final settings = ref.watch(settingsProvider);
    final languageSubtitle = settings.language == 'bn' ? 'বাংলা' : 'English';

    return RefreshIndicator(
      color: AppColors.forestGreen,
      onRefresh: () async {
        ref.invalidate(profileProvider);
        ref.invalidate(userDetectionCountProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A. Forest Green Profile Header
            ProfileHeader(
              fullName: fullName,
              email: email,
              avatarUrl: avatarUrl,
              isBn: isBn,
            ),
            const SizedBox(height: 8),

            // B. Personal Information Card
            PersonalInformationCard(
              fullName: fullName,
              email: email,
              phoneNumber: phoneNumber,
              district: district,
              isBn: isBn,
            ),

            // C. Total Plant Health Activity & Detection Count
            DetectionActivityCard(
              detectionCountAsync: detectionCountAsync,
              isBn: isBn,
            ),

            // D. Account Information (Member Since)
            AccountInformationCard(
              createdAt: createdAt,
              isBn: isBn,
            ),

            // E. Account & Preferences Card
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGreen, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Edit Profile
                  ProfileActionTile(
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
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    indent: 56,
                    endIndent: 16,
                    color: Color(0xFFF0F4EF),
                  ),

                  // 2. Settings
                  ProfileActionTile(
                    icon: Icons.settings_outlined,
                    title: isBn ? 'সেটিংস' : 'Settings',
                    subtitle: isBn
                        ? 'অ্যাপ সেটিংস ও নোটিফিকেশন পরিচালনা করুন'
                        : 'Manage your app preferences',
                    onTap: () {
                      try {
                        context.push('/settings');
                      } catch (_) {}
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    indent: 56,
                    endIndent: 16,
                    color: Color(0xFFF0F4EF),
                  ),

                  // 3. Language Preference
                  ProfileActionTile(
                    icon: Icons.language_rounded,
                    title: isBn ? 'ভাষা' : 'Language',
                    subtitle: languageSubtitle,
                    onTap: () => LanguageSelectionSheet.show(context),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    indent: 56,
                    endIndent: 16,
                    color: Color(0xFFF0F4EF),
                  ),

                  // 4. Help & Support
                  ProfileActionTile(
                    icon: Icons.help_outline_rounded,
                    title: isBn ? 'সহায়তা ও প্রশ্নোত্তর' : 'Help & FAQ',
                    subtitle: isBn
                        ? 'অ্যাপ ব্যবহারবিধি ও সাধারণ জিজ্ঞাসা'
                        : 'Guides, photography tips, and FAQs',
                    onTap: () {
                      try {
                        context.push('/help');
                      } catch (_) {}
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // F. Logout Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                onPressed: () => LogoutConfirmationDialog.show(context, isBn),
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 20),
                label: Text(
                  isBn ? 'লগআউট' : 'Log Out',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      AppColors.errorContainer.withValues(alpha: 0.25),
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isBn) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header Skeleton
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.forestGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Text(
                  isBn ? 'আমার প্রোফাইল' : 'My Profile',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: 140,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cards Skeletons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderGreen),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    bool isBn,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              isBn ? 'প্রোফাইল লোড করা সম্ভব হয়নি' : 'Failed to load profile',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isBn
                  ? 'ইন্টারনেট সংযোগ পরীক্ষা করে পুনরায় চেষ্টা করুন।'
                  : 'Please check your internet connection and try again.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(profileProvider);
                ref.invalidate(userDetectionCountProvider);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
