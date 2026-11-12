import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/detection_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/leaf_image_view.dart';

class ImagePreviewScreen extends ConsumerWidget {
  const ImagePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detectionProvider);

    if (state.imagePath == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: const Center(child: Text('No image selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Leaf Sample')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LeafImageView(
                    imagePath: state.imagePath!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Analyze Leaf with AI',
                icon: Icons.auto_awesome,
                onPressed: () {
                  context.push('/detect/analyzing');
                  ref.read(detectionProvider.notifier).runDetection().then((_) {
                    if (context.mounted) {
                      context.go('/detect/result');
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Retake Photo',
                isOutlined: true,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
