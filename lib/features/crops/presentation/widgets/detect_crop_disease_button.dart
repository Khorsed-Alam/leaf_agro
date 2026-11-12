import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../providers/crop_provider.dart';

class DetectCropDiseaseButton extends ConsumerStatefulWidget {
  final CropModel crop;
  final bool isBn;

  const DetectCropDiseaseButton({
    super.key,
    required this.crop,
    required this.isBn,
  });

  @override
  ConsumerState<DetectCropDiseaseButton> createState() => _DetectCropDiseaseButtonState();
}

class _DetectCropDiseaseButtonState extends ConsumerState<DetectCropDiseaseButton> {
  bool _isPressed = false;

  void _handleDetect() {
    if (!widget.crop.isAiSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isBn
                ? 'এই ফসলের জন্য AI রোগ নির্ণয় মডেল বর্তমানে উপলব্ধ নেই।'
                : 'AI disease detection is not yet supported for this crop.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Set selected crop in global state to preserve selection
    ref.read(selectedCropProvider.notifier).state = widget.crop;

    // Navigate to Screen 09: Plant Image Capture & AI Detection
    if (context.mounted) {
      try {
        context.push('/detect');
      } catch (_) {
        // Safe fallback when running in widget tests without GoRouter host
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSupported = widget.crop.isAiSupported;
    final cropName = widget.isBn ? widget.crop.nameBn : widget.crop.nameEn;
    final buttonLabel = widget.isBn
        ? '$cropName-এর রোগ পরীক্ষা করুন'
        : 'Detect ${widget.crop.nameEn} Disease';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTapDown: isSupported ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: isSupported ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: isSupported ? () => setState(() => _isPressed = false) : null,
          onTap: isSupported ? _handleDetect : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isSupported
                    ? const LinearGradient(
                        colors: [
                          AppColors.forestGreen,
                          Color(0xFF1B6336),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSupported ? null : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSupported
                    ? [
                        BoxShadow(
                          color: AppColors.forestGreen.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.limeGreen,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
