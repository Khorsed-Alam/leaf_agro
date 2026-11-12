import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.energy_savings_leaf_outlined,
                  size: 72,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Protect Your Harvest with AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Diagnose crop diseases instantly with our offline neural network. Access certified treatments anytime, anywhere.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Get Started',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Login to Cloud Account',
                isOutlined: true,
                onPressed: () => context.push('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

