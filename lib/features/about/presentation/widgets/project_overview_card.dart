import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/academic_project_config.dart';

/// Screen 30 – Academic Project Overview Card
class ProjectOverviewCard extends StatelessWidget {
  final bool isBn;

  const ProjectOverviewCard({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGreen, width: 1),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isBn ? 'প্রকল্পের সারসংক্ষেপ' : 'Project Overview',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBn
                      ? AcademicProjectConfig.projectTypeBn
                      : AcademicProjectConfig.projectTypeEn,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Exact Project Title
          Text(
            isBn
                ? AcademicProjectConfig.projectTitleBn
                : AcademicProjectConfig.projectTitleEn,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            isBn
                ? AcademicProjectConfig.projectDescriptionBn
                : AcademicProjectConfig.projectDescriptionEn,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
