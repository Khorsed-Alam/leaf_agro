import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'profile_information_row.dart';

/// Screen 24 – Personal Information Card
/// Displays clean, private profile details: Full Name, Email, Phone, and District.
class PersonalInformationCard extends StatelessWidget {
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? district;
  final bool isBn;

  const PersonalInformationCard({
    super.key,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.district,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final notAddedText = isBn ? 'যোগ করা হয়নি' : 'Not added';
    final hasPhone = phoneNumber != null && phoneNumber!.trim().isNotEmpty;
    final hasDistrict = district != null && district!.trim().isNotEmpty;
    final hasEmail = email != null && email!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 18,
                color: AppColors.forestGreen,
              ),
              const SizedBox(width: 8),
              Text(
                isBn ? 'ব্যক্তিগত তথ্য' : 'Personal Information',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Full Name
          ProfileInformationRow(
            icon: Icons.person_outline_rounded,
            label: isBn ? 'পুরো নাম' : 'Full Name',
            value: fullName.isNotEmpty ? fullName : (isBn ? 'কৃষক' : 'Farmer'),
          ),

          // 2. Email Address
          ProfileInformationRow(
            icon: Icons.mail_outline_rounded,
            label: isBn ? 'ইমেইল ঠিকানা' : 'Email Address',
            value: hasEmail ? email! : notAddedText,
            isPlaceholder: !hasEmail,
          ),

          // 3. Phone Number
          ProfileInformationRow(
            icon: Icons.phone_outlined,
            label: isBn ? 'মোবাইল নম্বর' : 'Phone Number',
            value: hasPhone ? phoneNumber! : notAddedText,
            isPlaceholder: !hasPhone,
          ),

          // 4. District / Location
          ProfileInformationRow(
            icon: Icons.location_on_outlined,
            label: isBn ? 'জেলা / অবস্থান' : 'Location / District',
            value: hasDistrict ? district! : notAddedText,
            isPlaceholder: !hasDistrict,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
