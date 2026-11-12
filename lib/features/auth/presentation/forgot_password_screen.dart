import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/auth_service.dart';
import 'widgets/recovery_hero_illustration.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final AuthService? authService;

  const ForgotPasswordScreen({super.key, this.authService});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  late final AuthService _authService = widget.authService ?? AuthService();

  bool _isLoading = false;
  bool _isSuccess = false;
  String _sentToEmail = '';

  // Resend cooldown timer
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown([int seconds = 30]) {
    setState(() => _cooldownSeconds = seconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _handleSendResetLink({bool isResend = false}) async {
    FocusScope.of(context).unfocus();

    if (!isResend && !_formKey.currentState!.validate()) {
      return;
    }

    final targetEmail = isResend ? _sentToEmail : _emailController.text.trim();
    if (targetEmail.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.sendPasswordResetEmail(targetEmail);

      if (!mounted) return;

      if (result.isSuccess) {
        setState(() {
          _isSuccess = true;
          _sentToEmail = targetEmail;
        });
        _startCooldown(30);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ref.read(settingsProvider).language == 'bn'
                        ? 'পাসওয়ার্ড রিসেট লিঙ্ক পাঠানো হয়েছে!'
                        : 'Password reset link sent successfully!',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        _showErrorSnackBar(
          result.errorMessage ?? 'Unable to send reset link. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Request failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F1), // Master Soft Natural Green
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Bar: Back & Language Switcher ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF1F2937),
                    ),
                    tooltip: isBn ? 'ফিরে যান' : 'Back to Login',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFD1E7D2)),
                      ),
                    ),
                  ),

                  _buildLanguagePill(ref, isBn),
                ],
              ),

              const SizedBox(height: 24),

              // ── Animated Switcher: Form vs. Success Confirmation ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _isSuccess
                    ? _buildSuccessConfirmationState(isBn)
                    : _buildInitialFormState(isBn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── State 01: Initial Form State ─────────────────────────────────────
  Widget _buildInitialFormState(bool isBn) {
    return Column(
      key: const ValueKey('initial_form_state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Illustration with Security Lock
        const Center(
          child: RecoveryHeroIllustration(
            isConfirmed: false,
            size: 160,
          ),
        ),

        const SizedBox(height: 20),

        // Heading
        Text(
          isBn ? 'পাসওয়ার্ড ভুলে গেছেন?' : 'Forgot Password?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.forestGreen,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            isBn
                ? 'আপনার নিবন্ধিত ইমেইল ঠিকানা দিন। আমরা পাসওয়ার্ড রিসেট করার লিঙ্ক পাঠাবো।'
                : 'Enter your registered email address. We will send you a password reset link.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Card Container with Email Input
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'ইমেইল ঠিকানা' : 'Email Address',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),

                // Email TextFormField
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => _handleSendResetLink(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: isBn ? 'আপনার ইমেইল লিখুন' : 'farmer@example.com',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.alternate_email_rounded,
                      color: Color(0xFF166534),
                      size: 20,
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
                    if (value == null || value.trim().isEmpty) {
                      return isBn
                          ? 'দয়া করে আপনার নিবন্ধিত ইমেইল দিন'
                          : 'Please enter your registered email address';
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return isBn
                          ? 'সঠিক ইমেইল ঠিকানা দিন'
                          : 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Send Reset Link Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleSendResetLink(),
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
                                Icons.send_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isBn ? 'রিসেট লিঙ্ক পাঠান' : 'Send Reset Link',
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
        ),

        const SizedBox(height: 28),

        // Back to Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBn ? 'পাসওয়ার্ড মনে পড়েছে? ' : 'Remember your password? ',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/login');
                }
              },
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestGreen,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.forestGreen,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ── State 03: Email Confirmation State ───────────────────────────────
  Widget _buildSuccessConfirmationState(bool isBn) {
    return Column(
      key: const ValueKey('confirmation_state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Illustration with Green Checkmark
        const Center(
          child: RecoveryHeroIllustration(
            isConfirmed: true,
            size: 160,
          ),
        ),

        const SizedBox(height: 20),

        // Heading
        Text(
          isBn ? 'আপনার ইমেইল চেক করুন' : 'Check Your Email',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16A34A), // Success Green
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 10),

        // Subtitle Description with bolded email
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF4B5563),
                height: 1.55,
              ),
              children: [
                TextSpan(
                  text: isBn
                      ? 'আমরা একটি পাসওয়ার্ড রিসেট লিঙ্ক পাঠিয়েছি এই ঠিকানায়:\n'
                      : "We've sent a password reset link to your email address:\n",
                ),
                TextSpan(
                  text: _sentToEmail.isNotEmpty ? _sentToEmail : 'your email',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                TextSpan(
                  text: isBn
                      ? '\nঅনুগ্রহ করে আপনার ইনবক্স চেক করে নির্দেশাবলী অনুসরণ করুন।'
                      : '\nPlease check your inbox and follow the instructions to reset your password.',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Helper Note Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCFCE7)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isBn
                      ? 'ইমেইল খুঁজে পাচ্ছেন না? স্প্যাম/জাঙ্ক ফোল্ডার চেক করুন বা পুনরায় চেষ্টা করুন।'
                      : "Didn't receive the email? Check your spam folder or try resending.",
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF374151),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action 1: Back to Login Primary Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: AppColors.forestGreen.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isBn ? 'লগইন পেজে ফিরে যান' : 'Back to Login',
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

        const SizedBox(height: 14),

        // Action 2: Resend Email Button (with Cooldown)
        Center(
          child: TextButton.icon(
            onPressed: (_isLoading || _cooldownSeconds > 0)
                ? null
                : () => _handleSendResetLink(isResend: true),
            icon: _isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF166534),
                    ),
                  )
                : const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              _cooldownSeconds > 0
                  ? (isBn
                      ? 'পুনরায় পাঠাতে অপেক্ষা করুন ($_cooldownSeconds সে.)'
                      : 'Resend Email in $_cooldownSeconds s')
                  : (isBn ? 'পুনরায় লিঙ্ক পাঠান' : 'Resend Email'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _cooldownSeconds > 0
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF166534),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLanguagePill(WidgetRef ref, bool isBn) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1E7D2)),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langOption(
            text: 'EN',
            active: !isBn,
            onTap: () => ref.read(settingsProvider.notifier).setLanguage('en'),
          ),
          const SizedBox(width: 2),
          _langOption(
            text: 'বাংলা',
            active: isBn,
            onTap: () => ref.read(settingsProvider.notifier).setLanguage('bn'),
          ),
        ],
      ),
    );
  }

  Widget _langOption({
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.forestGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
