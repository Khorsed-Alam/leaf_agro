import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/settings_provider.dart';
import 'scan_plant_button.dart';

class DashboardHeroCard extends ConsumerStatefulWidget {
  const DashboardHeroCard({super.key});

  @override
  ConsumerState<DashboardHeroCard> createState() => _DashboardHeroCardState();
}

class _DashboardHeroCardState extends ConsumerState<DashboardHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.forestGreen,
            Color(0xFF1B6638),
            AppColors.freshGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.freshGreen.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background circuit & leaf rings
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: AppColors.limeGreen.withOpacity(0.12),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.limeGreen.withOpacity(0.05),
                ),
              ),
            ),

            // Main Card Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.limeGreen.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.limeGreen,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          isBn
                              ? 'অন-ডিভাইস AI প্রস্তুত • ইন্টারনেট ছাড়া সচল'
                              : 'AI Vision Engine • Offline Ready',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Heading and Subtitle with Animated Scanner graphic
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn
                                  ? 'ফসলের স্বাস্থ্য পরীক্ষা করুন'
                                  : 'Check Your Plant Health',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isBn
                                  ? 'আক্রান্ত পাতার ছবি তুলুন এবং AI প্রযুক্তির মাধ্যমে তাত্ক্ষণিকভাবে সঠিক রোগ ও প্রতিষেধক জানুন।'
                                  : 'Take a photo of an affected leaf to detect diseases and get verified treatments with AI.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Animated Leaf & AI Laser Scanning Visual Effect
                      _buildAnimatedAiScanner(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Prominent CTA Button
                  ScanPlantButton(
                    label: isBn ? 'উদ্ভিদ স্ক্যান করুন' : 'Scan Plant',
                    onTap: () => context.push('/detect'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAiScanner() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        final sweepProgress = _scanController.value;

        return Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.limeGreen.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.limeGreen.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Central Plant Leaf Silhouette
              Transform.rotate(
                angle: -math.pi / 12,
                child: const Icon(
                  Icons.eco_rounded,
                  size: 44,
                  color: AppColors.limeGreen,
                ),
              ),

              // Camera viewfinder reticle corners
              Positioned(
                top: 6,
                left: 6,
                child: Icon(
                  Icons.crop_free_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Icon(
                  Icons.crop_free_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              // Animated Scanning Laser Beam
              Positioned(
                top: 10 + (sweepProgress * 60),
                left: 8,
                right: 8,
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.limeGreen,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
