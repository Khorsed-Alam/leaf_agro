import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/settings_provider.dart';

class DashboardBottomNavigation extends ConsumerWidget {
  final int selectedIndex;

  const DashboardBottomNavigation({
    super.key,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.borderGreen, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
                label: isBn ? 'হোম' : 'Home',
                isSelected: selectedIndex == 0,
                onTap: () {
                  if (selectedIndex != 0) context.go('/home');
                },
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.document_scanner_rounded,
                inactiveIcon: Icons.document_scanner_outlined,
                label: isBn ? 'রোগ স্ক্যান' : 'Detect',
                isSelected: selectedIndex == 1,
                onTap: () => context.push('/detect'),
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.history_rounded,
                inactiveIcon: Icons.history_outlined,
                label: isBn ? 'ইতিহাস' : 'History',
                isSelected: selectedIndex == 2,
                onTap: () => context.push('/history'),
              ),
              _buildNavItem(
                context: context,
                index: 3,
                icon: Icons.person_rounded,
                inactiveIcon: Icons.person_outline_rounded,
                label: isBn ? 'প্রোফাইল' : 'Profile',
                isSelected: selectedIndex == 3,
                onTap: () => context.push('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCFCE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? icon : inactiveIcon,
              color: isSelected ? AppColors.forestGreen : AppColors.secondaryText,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.forestGreen : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
