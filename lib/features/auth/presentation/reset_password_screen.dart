import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/auth_service.dart';
import 'widgets/auth_logo_badge.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Real-time strength criteria
  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasLetter = RegExp(r'[a-zA-Z]').hasMatch(text);
      _hasNumber = RegExp(r'[0-9]').hasMatch(text);
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPassword = _passwordController.text;
    setState(() => _isLoading = true);

    try {
      await _authService.updatePassword(newPassword);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ref.read(settingsProvider).language == 'bn'
                      ? 'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে! অনুগ্রহ করে লগইন করুন।'
                      : 'Password updated successfully! Please login with your new password.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );

      // Navigate to Login Screen
      context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F1),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF1F2937),
                      ),
                      tooltip: isBn ? 'লগইনে ফিরে যান' : 'Back to Login',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFD1E7D2)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Top Branding Section
                Center(
                  child: Column(
                    children: [
                      const AuthLogoBadge(size: 64),
                      const SizedBox(height: 14),
                      Text(
                        isBn ? 'নতুন পাসওয়ার্ড সেট করুন' : 'Set New Password',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forestGreen,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isBn
                            ? 'আপনার অ্যাকাউন্টের সুরক্ষায় একটি শক্তিশালী পাসওয়ার্ড তৈরি করুন।'
                            : 'Create a strong, secure password to regain account access.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Card Container
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2EDE4)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14532D).withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // New Password Field
                      Text(
                        isBn ? 'নতুন পাসওয়ার্ড' : 'New Password',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF166534),
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF6B7280),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FBF8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: _inputBorder(const Color(0xFFD1E7D2)),
                          enabledBorder: _inputBorder(const Color(0xFFD1E7D2)),
                          focusedBorder: _inputBorder(AppColors.forestGreen, width: 2),
                          errorBorder: _inputBorder(const Color(0xFFDC2626)),
                          focusedErrorBorder:
                              _inputBorder(const Color(0xFFDC2626), width: 2),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isBn
                                ? 'দয়া করে একটি পাসওয়ার্ড দিন'
                                : 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return isBn
                                ? 'পাসওয়ার্ড অন্তত ৮ অক্ষরের হতে হবে'
                                : 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                            return isBn
                                ? 'কমপক্ষে একটি বর্ণ থাকতে হবে'
                                : 'Must contain at least one letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return isBn
                                ? 'কমপক্ষে একটি সংখ্যা থাকতে হবে'
                                : 'Must contain at least one number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Criteria checklist
                      _buildCriteriaHelper(isBn),

                      const SizedBox(height: 16),

                      // Confirm New Password Field
                      Text(
                        isBn ? 'পাসওয়ার্ড নিশ্চিত করুন' : 'Confirm New Password',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleUpdatePassword(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF166534),
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF6B7280),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscureConfirmPassword = !_obscureConfirmPassword,
                              );
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FBF8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: _inputBorder(const Color(0xFFD1E7D2)),
                          enabledBorder: _inputBorder(const Color(0xFFD1E7D2)),
                          focusedBorder: _inputBorder(AppColors.forestGreen, width: 2),
                          errorBorder: _inputBorder(const Color(0xFFDC2626)),
                          focusedErrorBorder:
                              _inputBorder(const Color(0xFFDC2626), width: 2),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isBn
                                ? 'পাসওয়ার্ড পুনরায় লিখুন'
                                : 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return isBn
                                ? 'পাসওয়ার্ড দুটি মিলছে না'
                                : 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      // Update Password Primary Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleUpdatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forestGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.forestGreen.withValues(alpha: 0.6),
                            elevation: 2,
                            shadowColor: AppColors.forestGreen.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 19,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isBn ? 'পাসওয়ার্ড আপডেট করুন' : 'Update Password',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCriteriaHelper(bool isBn) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _criteriaRow(
            met: _hasMinLength,
            label: isBn ? 'কমপক্ষে ৮ অক্ষর' : 'At least 8 characters',
          ),
          const SizedBox(height: 4),
          _criteriaRow(
            met: _hasLetter,
            label: isBn ? 'কমপক্ষে একটি বর্ণ (A-Z, a-z)' : 'At least one letter (A-Z, a-z)',
          ),
          const SizedBox(height: 4),
          _criteriaRow(
            met: _hasNumber,
            label: isBn ? 'কমপক্ষে একটি সংখ্যা (0-9)' : 'At least one number (0-9)',
          ),
        ],
      ),
    );
  }

  Widget _criteriaRow({required bool met, required String label}) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 14,
          color: met ? AppColors.forestGreen : const Color(0xFF9CA3AF),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            color: met ? AppColors.forestGreen : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

