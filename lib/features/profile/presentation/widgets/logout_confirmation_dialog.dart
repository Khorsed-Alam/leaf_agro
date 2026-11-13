import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';

/// Screen 24 – Logout Confirmation Dialog
/// Confirms before securely terminating the user's session.
class LogoutConfirmationDialog extends ConsumerStatefulWidget {
  final bool isBn;

  const LogoutConfirmationDialog({
    super.key,
    required this.isBn,
  });

  static Future<void> show(BuildContext context, bool isBn) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutConfirmationDialog(isBn: isBn),
    );
  }

  @override
  ConsumerState<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState
    extends ConsumerState<LogoutConfirmationDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogout() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = widget.isBn
            ? 'লগআউট করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।'
            : 'Failed to log out. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = widget.isBn;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: AppColors.surfaceContainerLowest,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isBn ? 'লগআউট করবেন?' : 'Log Out?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn
                ? 'আপনি কি নিশ্চিত যে আপনি আপনার অ্যাগ্রিকেয়ার অ্যাকাউন্ট থেকে লগআউট করতে চান?'
                : 'Are you sure you want to log out of your AgriCare AI account?',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Cancel Action
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isBn ? 'বাতিল' : 'Cancel',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText,
            ),
          ),
        ),

        // Confirm Logout Action
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  isBn ? 'লগআউট' : 'Log Out',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ],
    );
  }
}
