import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 24 – Account Information Card
/// Displays the genuine account creation date: "Member since <Date>".
class AccountInformationCard extends StatelessWidget {
  final DateTime? createdAt;
  final bool isBn;

  const AccountInformationCard({
    super.key,
    this.createdAt,
    required this.isBn,
  });

  String _formatMemberSince(DateTime? date, bool isBn) {
    if (date == null) {
      return isBn ? 'তথ্য পাওয়া যায়নি' : 'Information unavailable';
    }

    final enMonth = DateFormat('MMMM yyyy').format(date);
    if (!isBn) {
      return 'Member since $enMonth';
    }

    // Bengali Month Mapping
    const bnMonths = {
      1: 'জানুয়ারি',
      2: 'ফেব্রুয়ারি',
      3: 'মার্চ',
      4: 'এপ্রিল',
      5: 'মে',
      6: 'জুন',
      7: 'জুলাই',
      8: 'আগস্ট',
      9: 'সেপ্টেম্বর',
      10: 'অক্টোবর',
      11: 'নভেম্বর',
      12: 'ডিসেম্বর',
    };
    const enToBnDigits = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };

    final bnMonth = bnMonths[date.month] ?? enMonth;
    final bnYear = date.year
        .toString()
        .split('')
        .map((d) => enToBnDigits[d] ?? d)
        .join('');
    return '$bnMonth $bnYear থেকে সদস্য';
  }

  @override
  Widget build(BuildContext context) {
    final memberSinceText = _formatMemberSince(createdAt, isBn);

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
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.forestGreen,
              ),
              const SizedBox(width: 8),
              Text(
                isBn ? 'অ্যাকাউন্টের তথ্য' : 'Account Information',
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGreen, width: 0.8),
                ),
                child: const Icon(
                  Icons.person_pin_circle_outlined,
                  size: 18,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'যোগদানের তারিখ' : 'Member Since',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      memberSinceText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
