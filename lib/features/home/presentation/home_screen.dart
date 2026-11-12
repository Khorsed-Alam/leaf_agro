import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/profile_provider.dart';
import 'widgets/dashboard_bottom_navigation.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_hero_card.dart';
import 'widgets/dashboard_statistics.dart';
import 'widgets/explore_crops_section.dart';
import 'widgets/recent_detections_section.dart';

/// Screen 06 – AgriCare AI Home Dashboard
/// Tailored for Bangladeshi farmers with clean agricultural tech aesthetic,
/// prominent Plant Health Detection hero action, real Supabase backend sync,
/// explore crops encyclopedia, recent scans history, and compact statistics.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.softNaturalGreen,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          backgroundColor: Colors.white,
          onRefresh: () async {
            ref.invalidate(cropProvider);
            ref.invalidate(historyProvider);
            ref.invalidate(profileProvider);
            ref.invalidate(unreadNotificationsCountProvider);
            await Future.wait([
              ref.read(cropProvider.future),
              ref.read(historyProvider.future),
              ref.read(profileProvider.future),
            ]);
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Section (Greeting, Name, Avatar, Bell, Language)
                DashboardHeader(),

                SizedBox(height: 18),

                // 2. Hero Action: Plant Health Detection (AI Scanner + Scan Plant CTA)
                DashboardHeroCard(),

                SizedBox(height: 18),

                // 3. Compact Statistics (Total Scans, Healthy, Diseases from actual scans)
                DashboardStatistics(),

                SizedBox(height: 22),

                // 4. Explore Crops Section (Rice, Mango, Potato, Tomato, Jute)
                ExploreCropsSection(),

                SizedBox(height: 24),

                // 5. Recent Detections Section (Newest first, status pills, details route)
                RecentDetectionsSection(),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const DashboardBottomNavigation(selectedIndex: 0),
    );
  }
}
