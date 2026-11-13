import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'profile_avatar.dart';

/// Screen 24 – Profile Header Widget
/// Displays a forest-green agricultural brand header with the user's avatar,
/// full name, account email, and account status badge.
class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final bool isBn;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.forestGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Screen Title
          Text(
            isBn ? 'আমার প্রোফাইল' : 'My Profile',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 18),

          // User Profile Photo / Avatar
          ProfileAvatar(
            avatarUrl: avatarUrl,
            fullName: fullName,
            radius: 46,
            borderColor: Colors.white.withValues(alpha: 0.85),
            borderWidth: 2.5,
          ),
          const SizedBox(height: 12),

          // Full Name
          Text(
            fullName.isNotEmpty ? fullName : (isBn ? 'কৃষক' : 'Farmer'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email Address
          if (email.isNotEmpty)
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 10),

          // Account Subtitle Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 14,
                  color: AppColors.limeGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  isBn ? 'আপনার অ্যাগ্রিকেয়ার অ্যাকাউন্ট' : 'Your AgriCare Account',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

