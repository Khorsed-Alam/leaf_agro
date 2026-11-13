import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/academic_project_config.dart';

/// Screen 30 – Academic Team & Build Details Card
class AcademicTeamCard extends StatelessWidget {
  final bool isBn;

  const AcademicTeamCard({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final teamDetails = [
      {
        'label': isBn ? 'প্রকল্পের ধরন' : 'Project Type',
        'value': isBn
            ? AcademicProjectConfig.projectTypeBn
            : AcademicProjectConfig.projectTypeEn,
      },
      {
        'label': isBn ? 'গবেষণা ও উন্নয়ন দল' : 'Development Team',
        'value': isBn
            ? AcademicProjectConfig.developerTeamBn
            : AcademicProjectConfig.developerTeamEn,
      },
      {
        'label': isBn ? 'বিভাগ' : 'Department',
        'value': isBn
            ? AcademicProjectConfig.departmentBn
            : AcademicProjectConfig.departmentEn,
      },
      {
        'label': isBn ? 'অনুষদ / প্রতিষ্ঠান' : 'Faculty / University',
        'value': isBn
            ? AcademicProjectConfig.universityBn
            : AcademicProjectConfig.universityEn,
      },
      {
        'label': isBn ? 'তত্ত্বাবধায়ক' : 'Project Supervisor',
        'value': isBn
            ? AcademicProjectConfig.supervisorBn
            : AcademicProjectConfig.supervisorEn,
      },
      {
        'label': isBn ? 'শিক্ষাবর্ষ' : 'Academic Session',
        'value': AcademicProjectConfig.academicSession,
      },
      {
        'label': isBn ? 'অ্যাপ সংস্করণ' : 'App Version',
        'value':
            'v${AcademicProjectConfig.appVersion} (Build ${AcademicProjectConfig.buildNumber})',
      },
    ];

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
                  Icons.groups_rounded,
                  color: AppColors.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isBn
                      ? 'একাডেমিক প্রকল্প ও দল'
                      : 'Project Team & Academic Info',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Team Rows
          ...teamDetails.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      item['label']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['value']!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
