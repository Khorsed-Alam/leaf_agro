import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/auth_logo_badge.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _termsError = false;
  bool _isLoading = false;

  // Real-time password criteria tracking
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
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Formats raw phone input into standardized international format: +8801XXXXXXXXX
  String _formatPhoneNumber(String raw) {
    var cleaned = raw.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('880')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    return '+880$cleaned';
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _termsError = !_agreeToTerms;
    });

    if (!_formKey.currentState!.validate() || !_agreeToTerms) {
      if (!_agreeToTerms) {
        _showErrorSnackBar(
          ref.read(settingsProvider).language == 'bn'
              ? 'অনুগ্রহ করে শর্তাবলী ও গোপনীয়তা নীতিতে সম্মতি দিন'
              : 'Please accept the Terms & Conditions and Privacy Policy',
        );
      }
      return;
    }

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final rawPhone = _phoneController.text.trim();
    final phone = _formatPhoneNumber(rawPhone);
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).signUpWithEmail(
            email: email,
            password: password,
            fullName: fullName,
            phoneNumber: phone,
            termsAccepted: _agreeToTerms,
          );

      final authState = ref.read(authProvider).value;

      if (!mounted) return;

      if (authState?.status == AuthStatus.error) {
        _showErrorSnackBar(
          authState?.errorMessage ?? 'Registration failed. Please try again.',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ref.read(settingsProvider).language == 'bn'
                        ? 'অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে! অনুগ্রহ করে সাইন ইন করুন।'
                        : 'Account created successfully! Please sign in.',
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
        // Navigate to Login screen
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Registration failed: ${e.toString()}');
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

  void _showTermsDialog(bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.description_outlined, color: AppColors.forestGreen),
            const SizedBox(width: 8),
            Text(
              isBn ? 'শর্তাবলী ও নীতিমালা' : 'Terms & Conditions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            isBn
                ? 'AgriCare AI প্ল্যাটফর্মে আপনাকে স্বাগতম। এই অ্যাপটি ব্যবহারের মাধ্যমে আপনি সম্মত হচ্ছেন যে AI দ্বারা প্রদত্ত ফসলের রোগ নির্ণয় ও সুপারিশসমূহ সতর্কতার সাথে যাচাই করে মাঠে প্রয়োগ করবেন। আপনার খামার ও ফসলের নিরাপত্তা নিশ্চিত করতে পরামর্শক নির্দেশনাবলী মেনে চলুন।'
                : 'Welcome to AgriCare AI. By using this service, you agree to utilize AI crop diagnostics as an advisory tool alongside field agricultural practices. We strive to provide the most accurate multi-crop diagnostics for Bangladeshi farmers.',
            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF374151)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isBn ? 'সম্মত আছি' : 'Got it',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, color: AppColors.forestGreen),
            const SizedBox(width: 8),
            Text(
              isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            isBn
                ? 'আপনার তথ্যের নিরাপত্তা আমাদের সর্বোচ্চ অগ্রাধিকার। আপনার আপলোড করা পাতার ছবি ও খামারের তথ্য নিরাপদে সংরক্ষিত থাকে এবং তৃতীয় পক্ষের কাছে উন্মুক্ত করা হয় না। অফলাইন মোডে আপনার কোনো ব্যক্তিগত ডাটা ক্লাউডে পাঠানো হয় না।'
                : 'Your privacy is paramount. Captured leaf scans and profile details are encrypted and stored in private cloud storage. In offline mode, diagnostics run completely on-device without data transmission.',
            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF374151)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isBn ? 'ঠিক আছে' : 'Understood',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen),
            ),
          ),
        ],
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
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top Navigation & Language Switcher ─────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back to Login
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
                        tooltip: isBn ? 'ফিরে যান' : 'Back',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFD1E7D2)),
                          ),
                        ),
                      ),

                      // Language Toggle Pill
                      _buildLanguagePill(ref, isBn),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Top Branding Section ──────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        const AuthLogoBadge(size: 64),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'AgriCare',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestGreen,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF14532D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isBn ? 'নতুন অ্যাকাউন্ট তৈরি করুন' : 'Create Your Account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBn
                              ? 'AgriCare AI-এ যোগ দিন এবং আপনার ফসল সুরক্ষিত রাখুন।'
                              : 'Join AgriCare AI and protect your crops.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Registration Form Card ────────────────────────────
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
                        // Field 01: Full Name
                        _buildFieldLabel(isBn ? 'পুরো নাম' : 'Full Name'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _fullNameController,
                          focusNode: _fullNameFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          style: _inputTextStyle(),
                          decoration: _inputDecoration(
                            hintText: isBn ? 'আপনার পূর্ণ নাম লিখুন' : 'Enter your full name',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isBn
                                  ? 'দয়া করে আপনার পূর্ণ নাম লিখুন'
                                  : 'Please enter your full name';
                            }
                            if (value.trim().length < 2) {
                              return isBn
                                  ? 'নাম অন্তত ২ অক্ষরের হতে হবে'
                                  : 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Field 02: Email Address
                        _buildFieldLabel(isBn ? 'ইমেইল ঠিকানা' : 'Email Address'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          style: _inputTextStyle(),
                          decoration: _inputDecoration(
                            hintText: 'farmer@example.com',
                            prefixIcon: Icons.alternate_email_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isBn
                                  ? 'দয়া করে আপনার ইমেইল প্রদান করুন'
                                  : 'Please enter your email address';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return isBn
                                  ? 'সঠিক ইমেইল ঠিকানা প্রদান করুন'
                                  : 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Field 03: Bangladesh Phone Number (+880)
                        _buildFieldLabel(isBn ? 'মোবাইল নম্বর' : 'Phone Number'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          style: _inputTextStyle(),
                          decoration: InputDecoration(
                            hintText: '1XXXXXXXXX',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FBF8),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            // Separate Bangladesh country code prefix
                            prefixIcon: Container(
                              padding: const EdgeInsets.only(left: 12, right: 8),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Color(0xFFD1E7D2), width: 1.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Bangladesh Flag icon badge
                                  Container(
                                    width: 22,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006A4E), // BD Forest Green
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF42A41), // BD Red Circle
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '+880',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            border: _inputBorder(const Color(0xFFD1E7D2)),
                            enabledBorder: _inputBorder(const Color(0xFFD1E7D2)),
                            focusedBorder: _inputBorder(AppColors.forestGreen, width: 2),
                            errorBorder: _inputBorder(const Color(0xFFDC2626)),
                            focusedErrorBorder: _inputBorder(const Color(0xFFDC2626), width: 2),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isBn
                                  ? 'দয়া করে মোবাইল নম্বর প্রদান করুন'
                                  : 'Please enter your phone number';
                            }
                            final clean = value.replaceAll(RegExp(r'\D'), '');
                            // Must be valid 10 digits starting with 1 (e.g. 1712345678) or 11 starting with 01
                            final isValid10 = clean.length == 10 && clean.startsWith('1');
                            final isValid11 = clean.length == 11 && clean.startsWith('01');
                            if (!isValid10 && !isValid11) {
                              return isBn
                                  ? 'সঠিক বাংলাদেশী নম্বর দিন (যেমন: 17XXXXXXXX)'
                                  : 'Enter a valid BD number (e.g. 17XXXXXXXX)';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Field 04: Password
                        _buildFieldLabel(isBn ? 'পাসওয়ার্ড' : 'Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          style: _inputTextStyle(),
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
                              tooltip: _obscurePassword
                                  ? (isBn ? 'পাসওয়ার্ড দেখুন' : 'Show password')
                                  : (isBn ? 'পাসওয়ার্ড লুকান' : 'Hide password'),
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
                            focusedErrorBorder: _inputBorder(const Color(0xFFDC2626), width: 2),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isBn
                                  ? 'দয়া করে একটি পাসওয়ার্ড দিন'
                                  : 'Please create a password';
                            }
                            if (value.length < 8) {
                              return isBn
                                  ? 'পাসওয়ার্ড অন্তত ৮ অক্ষরের হতে হবে'
                                  : 'Password must be at least 8 characters';
                            }
                            if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                              return isBn
                                  ? 'কমপক্ষে একটি বর্ণ (letter) থাকতে হবে'
                                  : 'Must include at least one letter';
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return isBn
                                  ? 'কমপক্ষে একটি সংখ্যা (number) থাকতে হবে'
                                  : 'Must include at least one number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // Password Strength Checklist Helper
                        _buildPasswordCriteriaHelper(isBn),

                        const SizedBox(height: 16),

                        // Field 05: Confirm Password
                        _buildFieldLabel(isBn ? 'পাসওয়ার্ড নিশ্চিত করুন' : 'Confirm Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _handleRegister(),
                          style: _inputTextStyle(),
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
                              tooltip: _obscureConfirmPassword
                                  ? (isBn ? 'পাসওয়ার্ড দেখুন' : 'Show password')
                                  : (isBn ? 'পাসওয়ার্ড লুকান' : 'Hide password'),
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
                            focusedErrorBorder: _inputBorder(const Color(0xFFDC2626), width: 2),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isBn
                                  ? 'পাসওয়ার্ড নিশ্চিত করুন'
                                  : 'Please re-enter your password';
                            }
                            if (value != _passwordController.text) {
                              return isBn
                                  ? 'পাসওয়ার্ড দুটি মিলছে না'
                                  : 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ── Terms & Conditions Checkbox ────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                activeColor: AppColors.forestGreen,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  color: _termsError
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF9CA3AF),
                                  width: 1.5,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _agreeToTerms = val ?? false;
                                    if (_agreeToTerms) _termsError = false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    isBn ? 'আমি ' : 'I agree to the ',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showTermsDialog(isBn),
                                    child: const Text(
                                      'Terms & Conditions',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.forestGreen,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.forestGreen,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    isBn ? ' এবং ' : ' and ',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showPrivacyDialog(isBn),
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.forestGreen,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.forestGreen,
                                      ),
                                    ),
                                  ),
                                  if (isBn)
                                    const Text(
                                      ' মেনে নিচ্ছি।',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Create Account Button ──────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
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
                                        Icons.person_add_alt_1_rounded,
                                        size: 19,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isBn ? 'অ্যাকাউন্ট তৈরি করুন' : 'Create Account',
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

                  const SizedBox(height: 24),

                  // ── Already have an account? Login ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isBn ? 'ইতিমধ্যে অ্যাকাউন্ট আছে? ' : 'Already have an account? ',
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
                          'Login',
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  TextStyle _inputTextStyle() {
    return const TextStyle(
      fontSize: 14,
      color: Color(0xFF1F2937),
      fontWeight: FontWeight.w500,
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF166534),
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
      focusedErrorBorder: _inputBorder(const Color(0xFFDC2626), width: 2),
    );
  }

  Widget _buildPasswordCriteriaHelper(bool isBn) {
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
