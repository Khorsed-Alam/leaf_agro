import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';

/// Screen 18 – Important Safety Reminders Card
/// Critical guidelines for handling agricultural products safely and responsibly.
class SafeHandlingRemindersCard extends StatelessWidget {
  final bool isBn;

  const SafeHandlingRemindersCard({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final rules = [
      isBn
          ? 'যেকোনো বালাইনাশক ব্যবহারের পূর্বে মোড়কের গায়ে থাকা অনুমোদিত সরকারি লেবেল পুঙ্খানুপুঙ্খভাবে পড়ুন।'
          : 'Read and strictly follow the approved product label instructions before using any agricultural chemical.',
      isBn
          ? 'স্প্রে করার সময় মাস্ক, গ্লাভস ও উপযুক্ত সুরক্ষামূলক পোশাক পরিধান করুন।'
          : 'Always wear required personal protective equipment (mask, gloves, long sleeves) during spraying.',
      isBn
          ? 'কীটনাশক শিশু, গৃহপালিত পশু, খাবার ও পানীয় থেকে নিরাপদ দূরত্বে তালাবদ্ধ রাখুন।'
          : 'Keep all agricultural chemicals locked away from children, livestock, and drinking water sources.',
      isBn
          ? 'কখনোই খাবার বা পানীয়ের বোতলে কীটনাশক রাখবেন না।'
          : 'Never store agricultural chemicals in food, beverage, or soft-drink containers.',
      isBn
          ? 'অনুমোদিত নির্দেশনা ছাড়া একাধিক রাসায়নিক কীটনাশক বা ছত্রাকনাশক একসাথে মেশাবেন না।'
          : 'Never mix multiple agricultural chemicals unless explicitly verified by official product directions.',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn
                    ? 'নিরাপদ ব্যবহারের গুরুত্বপূর্ণ নির্দেশিকা'
                    : 'Important Safety Reminders',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bullet Rules
          Column(
            children: rules.map((rule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 15,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78350F),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Mandatory Extension Officer Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.contact_support_outlined,
                  size: 18,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'সর্বদা স্থানীয় কৃষি সম্প্রসারণ অধিদপ্তরের পরামর্শ ও অনুমোদিত লেবেল অনুসরণ করুন। কোনো বালাইনাশক ব্যবহারের পূর্বে নিশ্চিত হতে উপজেলা কৃষি কর্মকর্তার সহায়তা নিন।'
                        : 'Always follow local agricultural extension guidance and the approved product label. If you are unsure about a treatment, consult a qualified agricultural officer before applying it.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
