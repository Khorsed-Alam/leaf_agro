import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 24 – Profile Avatar Widget
/// Displays the genuine circular user profile photo with a subtle border.
/// Gracefully falls back to initials when avatar is missing or broken.
class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final double radius;
  final Color borderColor;
  final double borderWidth;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.radius = 44,
    this.borderColor = Colors.white,
    this.borderWidth = 2.5,
  });

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'A';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      final initials = '$first$second'.toUpperCase();
      if (initials.isNotEmpty) return initials;
    }
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasValidUrl = avatarUrl != null &&
        avatarUrl!.trim().isNotEmpty &&
        (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://'));

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: hasValidUrl
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingPlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials();
                },
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.secondaryContainer,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.forestGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(fullName);
    return Container(
      color: AppColors.secondaryContainer,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w800,
          color: AppColors.forestGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
