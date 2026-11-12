import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/settings_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  String _getGreeting(bool isBn) {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return isBn ? 'শুভ সকাল' : 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return isBn ? 'শুভ অপরাহ্ন' : 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return isBn ? 'শুভ সন্ধ্যা' : 'Good Evening';
    } else {
      return isBn ? 'শুভ রাত্রি' : 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';
    final profileAsync = ref.watch(profileProvider);
    final currentUser = ref.watch(currentUserProvider);
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);

    final fullName = profileAsync.value?.fullName ??
        currentUser?.fullName ??
        (isBn ? 'কৃষক ভাই' : 'Farmer');

    final avatarUrl = profileAsync.value?.avatarUrl ?? currentUser?.avatarUrl;
    final initialLetter = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'F';
    final greeting = _getGreeting(isBn);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Dynamic Greeting & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$greeting, $fullName!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isBn
                    ? 'আজ আপনার ফসল সুস্থ ও রোগমুক্ত রাখি।'
                    : "Let's keep your crops healthy today.",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right Actions: Language Toggle, Notification Bell, Profile Avatar
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language Toggle Pill
            InkWell(
              onTap: () {
                final newLang = isBn ? 'en' : 'bn';
                ref.read(settingsProvider.notifier).setLanguage(newLang);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderGreen),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  isBn ? 'EN' : 'বাংলা',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Notification Bell with dynamic unread indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  color: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.borderGreen),
                  ),
                  child: InkWell(
                    onTap: () => context.push('/notifications'),
                    borderRadius: BorderRadius.circular(12),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primaryText,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                unreadCountAsync.maybeWhen(
                  data: (count) {
                    if (count <= 0) return const SizedBox.shrink();
                    return Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.freshGreen,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Profile Avatar
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.freshGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(initialLetter),
                        )
                      : _buildDefaultAvatar(initialLetter),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String letter) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.forestGreen, AppColors.freshGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

