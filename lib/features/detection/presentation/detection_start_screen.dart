import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/detection_provider.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('New Leaf Diagnosis')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Diagnosis Guidelines',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '1. Ensure proper daylight or natural lighting.\n'
                      '2. Focus clearly on the symptomatic leaf surface.\n'
                      '3. Avoid blurry photos, extreme shadows, or distant shots.',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Capture with Camera',
                icon: Icons.camera_alt_rounded,
                onPressed: () => _pickImage(context, ref, ImageSource.camera),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Upload from Gallery',
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

