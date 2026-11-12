import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class DetectionStartScreen extends ConsumerWidget {
  const DetectionStartScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024);

    if (pickedFile != null) {
      ref.read(detectionProvider.notifier).selectImage(pickedFile.path);
      if (context.mounted) {
        context.push('/detect/preview');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrop = ref.watch(selectedCropProvider);
    final isBn = ref.watch(settingsProvider).language == 'bn';

    return Scaffold(
      backgroundColor: AppColors.softNaturalGreen,
      appBar: AppBar(
        title: Text(isBn ? 'পাতার রোগ নির্ণয়' : 'New Leaf Diagnosis'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selected Crop Header Banner
              if (selectedCrop != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.freshGreen, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.freshGreen.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: selectedCrop.imageUrl != null
                              ? Image.network(
                                  selectedCrop.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.softNaturalGreen,
                                    child: const Icon(Icons.eco, color: AppColors.forestGreen),
                                  ),
                                )
                              : Container(
                                  color: AppColors.softNaturalGreen,
                                  child: const Icon(Icons.eco, color: AppColors.forestGreen),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isBn ? selectedCrop.nameBn : selectedCrop.nameEn,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'AI Ready',
                                    style: TextStyle(
                                      color: AppColors.forestGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isBn
                                  ? '${selectedCrop.supportedDiseaseCount}টি রোগ শনাক্তকরণ সমর্থিত'
                                  : '${selectedCrop.supportedDiseaseCount} diseases supported by AI model',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/crop-select'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.forestGreen,
                        ),
                        child: Text(
                          isBn ? 'পরিবর্তন' : 'Change',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.forestGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'নির্ভুল ফলাফলের জন্য ফসল নির্বাচন করুন'
                              : 'Select your crop for higher diagnostic accuracy',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/crop-select'),
                        child: Text(isBn ? 'বাছাই' : 'Select'),
                      ),
                    ],
                  ),
                ),

              // Guidelines Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGreen),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: AppColors.forestGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isBn ? 'রোগ পরীক্ষার নির্দেশিকা' : 'Diagnosis Guidelines',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isBn
                          ? '১. আক্রান্ত পাতায় পর্যাপ্ত সূর্যের আলো বা পরিষ্কার আলো নিশ্চিত করুন।\n'
                            '২. দাগ বা রোগাক্রান্ত অংশের ওপর সরাসরি ক্যামেরা ফোকাস করুন।\n'
                            '৩. ঝাপসা ছবি, ছায়া বা খুব দূর থেকে ছবি তোলা এড়িয়ে চলুন।'
                          : '1. Ensure proper daylight or natural lighting.\n'
                            '2. Focus clearly on the symptomatic leaf surface.\n'
                            '3. Avoid blurry photos, extreme shadows, or distant shots.',
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              CustomButton(
                text: isBn ? 'ক্যামেরা দিয়ে ছবি তুলুন' : 'Capture with Camera',
                icon: Icons.camera_alt_rounded,
                onPressed: () => _pickImage(context, ref, ImageSource.camera),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: isBn ? 'গ্যালারি থেকে আপলোড করুন' : 'Upload from Gallery',
                icon: Icons.photo_library_outlined,
                isOutlined: true,
                onPressed: () => _pickImage(context, ref, ImageSource.gallery),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

