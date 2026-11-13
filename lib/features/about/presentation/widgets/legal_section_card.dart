import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/widgets/legal_document_dialog.dart';
import '../../data/academic_project_config.dart';

/// Screen 30 – Legal & Academic Project Notice Card
class LegalSectionCard extends StatelessWidget {
  final bool isBn;

  const LegalSectionCard({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Legal Rows Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            children: [
              // Privacy Policy Tile
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.softNaturalGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.forestGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: Text(
                    isBn
                        ? 'আপনার ডাটা সুরক্ষা ও ব্যবহারের নিয়ম'
                        : 'Learn how your information is handled',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  onTap: () => LegalDocumentDialog.show(
                    context,
                    type: LegalDocumentType.privacyPolicy,
                    isBn: isBn,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 0.8,
                indent: 48,
                color: AppColors.borderGreen,
              ),

              // Terms & Conditions Tile
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.softNaturalGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.forestGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    isBn ? 'শর্তাবলী ও নীতিমালা' : 'Terms & Conditions',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: Text(
                    isBn
                        ? 'অ্যাপ্লিকেশন ব্যবহারের নির্দেশিকা'
                        : 'Read the terms for using AgriCare AI',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  onTap: () => LegalDocumentDialog.show(
                    context,
                    type: LegalDocumentType.termsAndConditions,
                    isBn: isBn,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Academic Project Notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F6F1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGreen, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: AppColors.forestGreen,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'একাডেমিক প্রকল্প নোটিশ'
                          : 'Academic Project Notice',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBn
                          ? AcademicProjectConfig.academicDisclaimerBn
                          : AcademicProjectConfig.academicDisclaimerEn,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
