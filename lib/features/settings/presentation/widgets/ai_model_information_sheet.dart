import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 25 – Offline AI Model Information Sheet
/// Displays authentic, verified TensorFlow Lite model specifications: architecture,
/// version, on-device edge execution capability, supported crops, and pathology classes.
class AiModelInformationSheet extends StatelessWidget {
  final bool isBn;

  const AiModelInformationSheet({
    super.key,
    required this.isBn,
  });

  static Future<void> show(BuildContext context, bool isBn) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AiModelInformationSheet(isBn: isBn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.memory_rounded,
                      color: AppColors.forestGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'অফলাইন এআই মডেল তথ্য' : 'Offline AI Model Information',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Text(
                          isBn ? 'অন-ডিভাইস নিউরাল নেটওয়ার্ক' : 'On-Device Neural Network Engine',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Spec List Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGreen),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildSpecRow(
                      label: isBn ? 'মডেল নাম' : 'Model Name',
                      value: 'AgriCare AI Leaf Disease Detector',
                    ),
                    const Divider(color: Color(0xFFE2EDE4), height: 1),
                    _buildSpecRow(
                      label: isBn ? 'আর্কিটেকচার' : 'Architecture',
                      value: 'MobileNetV2 (Edge Quantized)',
                    ),
                    const Divider(color: Color(0xFFE2EDE4), height: 1),
                    _buildSpecRow(
                      label: isBn ? 'মডেল সংস্করণ' : 'Model Version',
                      value: 'v1.0.0 (Production Release)',
                    ),
                    const Divider(color: Color(0xFFE2EDE4), height: 1),
                    _buildSpecRow(
                      label: isBn ? 'অফলাইন সক্ষমতা' : 'Offline Edge Inference',
                      value: isBn
                          ? 'হ্যাঁ (সম্পূর্ণ ইন্টারনেটবিহীন ডিভাইসে চলে)'
                          : 'Yes (Fully on-device, no internet required)',
                      isHighlighted: true,
                    ),
                    const Divider(color: Color(0xFFE2EDE4), height: 1),
                    _buildSpecRow(
                      label: isBn ? 'ইনপুট রেজোলিউশন' : 'Input Resolution',
                      value: '224 × 224 RGB (3 Channels)',
                    ),
                    const Divider(color: Color(0xFFE2EDE4), height: 1),
                    _buildSpecRow(
                      label: isBn ? 'সমর্থিত ফসল' : 'Supported Crops (5)',
                      value: isBn
                          ? 'ধান, আলু, টমেটো, আম, পাট'
                          : 'Rice, Potato, Tomato, Mango, Jute',
                    ),
                    const Divider(color: Color(0xFFE2EDE4), height: 1),
                    _buildSpecRow(
                      label: isBn ? 'রোগ ও স্বাস্থ্য ক্লাস' : 'Pathology Classes',
                      value: isBn
                          ? '১৯টি রোগ ও সুস্থ পাতার ক্যাটাগরি'
                          : '19 verified disease & healthy classes',
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Transparency Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGreen),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: AppColors.forestGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBn
                            ? 'এই মডেলটি আপনার ডিভাইসের লোকাল প্রসেসর ব্যবহার করে কাজ করে। আপনার কোনো পাতার ছবি ডায়াগনসিসের সময় ইন্টারনেটে পাঠানোর প্রয়োজন হয় না।'
                            : 'This AI model executes directly using your local device hardware. Image diagnosis does not depend on cloud processing or active data connectivity.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isBn ? 'ঠিক আছে' : 'Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow({
    required String label,
    required String value,
    bool isHighlighted = false,
    bool showDivider = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isHighlighted ? AppColors.forestGreen : AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

