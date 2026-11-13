import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum LegalDocumentType { privacyPolicy, termsAndConditions }

/// Screen 25 – Legal Document Dialog
/// Displays the genuine, verified Privacy Policy or Terms & Conditions in-app.
class LegalDocumentDialog extends StatelessWidget {
  final LegalDocumentType type;
  final bool isBn;

  const LegalDocumentDialog({
    super.key,
    required this.type,
    required this.isBn,
  });

  static Future<void> show(
    BuildContext context, {
    required LegalDocumentType type,
    required bool isBn,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => LegalDocumentDialog(type: type, isBn: isBn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == LegalDocumentType.privacyPolicy;

    final title = isPrivacy
        ? (isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy')
        : (isBn ? 'শর্তাবলী ও নীতিমালা' : 'Terms & Conditions');

    final icon =
        isPrivacy ? Icons.privacy_tip_outlined : Icons.description_outlined;

    final content = isPrivacy
        ? (isBn
            ? '১. তথ্য সুরক্ষা:\n'
                'আপনার তথ্যের নিরাপত্তা আমাদের সর্বোচ্চ অগ্রাধিকার। আপনার আপলোড করা পাতার ছবি ও খামারের তথ্য নিরাপদে এনক্রিপ্ট করে ক্লাউডে সংরক্ষিত থাকে।\n\n'
                '২. অন-ডিভাইস প্রসেসিং:\n'
                'অফলাইন মোডে পাতার রোগ নির্ণয় সম্পূর্ণভাবে আপনার ডিভাইসের লোকাল টেনসরফ্লো লাইট মডেলে প্রক্রিয়াজাত হয়। কোনো ব্যক্তিগত ডাটা বাইরের সার্ভারে প্রেরণ করা হয় না।\n\n'
                '৩. তৃতীয় পক্ষ:\n'
                'আমরা কোনো অবস্থাতেই কৃষকদের ব্যক্তিগত ডাটা বা ছবি বাণিজ্যিক বিজ্ঞাপনের উদ্দেশ্যে তৃতীয় পক্ষের নিকট হস্তান্তর বা বিক্রি করি না।'
            : '1. Data Protection:\n'
                'Your privacy is paramount. Captured leaf scans and profile details are encrypted and stored in private cloud storage.\n\n'
                '2. On-Device Edge Processing:\n'
                'In offline mode, AI diagnostics run completely on-device via TensorFlow Lite without external network transmission.\n\n'
                '3. Third-Party Sharing:\n'
                'We never sell, rent, or distribute farmer personal data or agricultural diagnostics to third-party commercial advertisers.')
        : (isBn
            ? '১. কৃষি নির্দেশিকা:\n'
                'AgriCare AI প্ল্যাটফর্মে আপনাকে স্বাগতম। এই অ্যাপটি ব্যবহারের মাধ্যমে আপনি সম্মত হচ্ছেন যে এআই মডেল দ্বারা প্রদত্ত ফসলের রোগ নির্ণয় ও সুপারিশসমূহ একটি সহায়ক পরামর্শক টুল মাত্র।\n\n'
                '২. ফিল্ড ভেরিফিকেশন:\n'
                'মাঠে যেকোনো সার, বালাইনাশক বা ছত্রাকনাশক ব্যবহারের পূর্বে স্থানীয় কৃষি সম্প্রসারণ কর্মকর্তা (DAE) বা অনুমোদিত কৃষিবিদের পরামর্শ গ্রহণ করা বাঞ্ছনীয়।\n\n'
                '৩. দায়িত্ব সীমাবদ্ধতা:\n'
                'আবহাওয়াজনিত বিপর্যয় বা অসাবধানতাবশত ভুল মাত্রায় বালাইনাশক প্রয়োগের ক্ষেত্রে ব্যবহারকারীর নিজস্ব দায়িত্বশীল আচরণ কাম্য।'
            : '1. Agricultural Advisory:\n'
                'Welcome to AgriCare AI. By using this service, you agree to utilize AI crop diagnostics as an educational and decision-support tool.\n\n'
                '2. Field Verification:\n'
                'Before applying any chemical fungicide, pesticide, or intensive cultural treatment, farmers should cross-verify recommendations with local DAE (Department of Agricultural Extension) block supervisors.\n\n'
                '3. Limitation of Liability:\n'
                'AgriCare AI provides verified research-backed agronomic guidance, but field execution remains at the discretion of the grower.');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: AppColors.surfaceContainerLowest,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.forestGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.primaryText,
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            isBn ? 'বন্ধ করুন' : 'Close',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
