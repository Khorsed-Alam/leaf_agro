import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/farmer_hero_illustration.dart';
import 'widgets/onboarding_language_selector.dart';
import 'widgets/onboarding_page_indicator.dart';

class OnboardingModel {
  final String titleEn;
  final String titleBn;
  final String descriptionEn;
  final String descriptionBn;
  final String tagEn;
  final String tagBn;

  const OnboardingModel({
    required this.titleEn,
    required this.titleBn,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.tagEn,
    required this.tagBn,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingModel> _pages = [
    OnboardingModel(
      titleEn: 'Smart Plant Disease Detection',
      titleBn: 'স্মার্ট ফসলের রোগ নির্ণয়',
      descriptionEn:
          'Identify plant diseases using artificial intelligence. Get helpful treatment and prevention recommendations.',
      descriptionBn:
          'কৃত্রিম বুদ্ধিমত্তা দিয়ে দ্রুত ফসলের রোগ শনাক্ত করুন এবং সঠিক নিরাময় ও প্রতিকার পরামর্শ পান।',
      tagEn: 'AI CROP DIAGNOSIS',
      tagBn: 'এআই ভিত্তিক রোগ পরীক্ষা',
    ),
    OnboardingModel(
      titleEn: 'Instant Offline Field Diagnosis',
      titleBn: 'ইন্টারনেট ছাড়াই ক্ষেতের মাঠে পরীক্ষা',
      descriptionEn:
          'Detect diseases anywhere, anytime without internet connectivity directly on your smartphone.',
      descriptionBn:
          'কোনো ইন্টারনেট সংযোগ ছাড়াই সরাসরি আপনার মোবাইলে মুহূর্তের মধ্যে ফসলের রোগ পরীক্ষা করুন।',
      tagEn: 'OFFLINE NEURAL NETWORK',
      tagBn: 'অফলাইন প্রযুক্তি',
    ),
    OnboardingModel(
      titleEn: 'Expert Care & Maximum Yield',
      titleBn: 'বিশেষজ্ঞ অনুমোদিত কৃষি সেবা',
      descriptionEn:
          'Access verified organic and chemical treatments, proper fertilizer dosages, and preventive guidelines.',
      descriptionBn:
          'কৃষি বিশেষজ্ঞদের অনুমোদিত সঠিক ওষুধ, সুষম সার ও নির্ভরযোগ্য পরামর্শ দিয়ে আপনার ফসল নিরাপদ রাখুন।',
      tagEn: 'VERIFIED RECOMMENDATIONS',
      tagBn: 'অনুমোদিত সমাধান',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.language == 'bn';

    return Scaffold(
      backgroundColor: AppColors.softNaturalGreen,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // 1. Top Header Bar (Logo Badge + Language Selector)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Identity
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14532D),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF14532D).withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'LeafAgro',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF14532D),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),

                      // Language Selector Pill
                      OnboardingLanguageSelector(
                        currentLanguage: settings.language,
                        onLanguageChanged: (newLang) {
                          ref.read(settingsProvider.notifier).setLanguage(newLang);
                        },
                      ),
                    ],
                  ),
                ),

                // 2. Hero Illustration (Upper-Middle Section)
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FarmerHeroIllustration(pageIndex: _currentPage),
                  ),
                ),

                // 3. Main Content Card (PageView with Titles & Descriptions)
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14532D).withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // PageView Content
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _pages.length,
                            onPageChanged: (idx) => setState(() => _currentPage = idx),
                            itemBuilder: (context, index) {
                              final item = _pages[index];

                              return SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Technology category pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        isBangla ? item.tagBn : item.tagEn,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF15803D),
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Heading
                                    Text(
                                      isBangla ? item.titleBn : item.titleEn,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF14532D),
                                        height: 1.25,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Description
                                    Text(
                                      isBangla ? item.descriptionBn : item.descriptionEn,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: Colors.grey.shade700,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Animated Page Indicators
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: OnboardingPageIndicator(
                            currentPage: _currentPage,
                            pageCount: _pages.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Action Buttons (Primary + Skip)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Primary Button (Get Started / Next)
                      ElevatedButton(
                        onPressed: _onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14532D),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF14532D).withOpacity(0.35),
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? (isBangla ? 'শুরু করুন' : 'Get Started')
                                  : (isBangla ? 'পরবর্তী' : 'Next'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),

                      // Secondary Button (Skip)
                      TextButton(
                        onPressed: _finishOnboarding,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: const Color(0xFF14532D),
                        ),
                        child: Text(
                          isBangla ? 'এড়িয়ে যান' : 'Skip',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF14532D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
