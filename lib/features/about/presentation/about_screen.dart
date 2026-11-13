import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/about_header.dart';
import 'widgets/academic_team_card.dart';
import 'widgets/ai_model_info_card.dart';
import 'widgets/brand_hero_card.dart';
import 'widgets/legal_section_card.dart';
import 'widgets/project_overview_card.dart';
import 'widgets/supported_crops_section.dart';
import 'widgets/tech_stack_section.dart';

/// Screen 30: About Application Screen — AgriCare AI (LeafAgro)
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Back button & About Header
              AboutHeader(isBn: isBn),
              const SizedBox(height: 16),

              // 2. Branding Hero Card
              BrandHeroCard(isBn: isBn),
              const SizedBox(height: 16),

              // 3. Academic Project Overview
              ProjectOverviewCard(isBn: isBn),
              const SizedBox(height: 16),

              // 4. Technology Stack
              TechStackSection(isBn: isBn),
              const SizedBox(height: 16),

              // 5. Supported Crops
              SupportedCropsSection(isBn: isBn),
              const SizedBox(height: 16),

              // 6. AI Model Information
              AiModelInfoCard(isBn: isBn),
              const SizedBox(height: 16),

              // 7. Academic Team & Build Details
              AcademicTeamCard(isBn: isBn),
              const SizedBox(height: 16),

              // 8. Legal Links & Academic Notice
              LegalSectionCard(isBn: isBn),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
