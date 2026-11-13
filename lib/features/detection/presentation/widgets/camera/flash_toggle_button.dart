import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Flash Toggle Button for Camera Screen
/// Cycles between Off, Torch, and Auto modes with visual feedback.
class FlashToggleButton extends StatelessWidget {
  final FlashMode currentMode;
  final bool hasFlash;
  final ValueChanged<FlashMode> onModeChanged;
  final bool isBn;

  const FlashToggleButton({
    super.key,
    required this.currentMode,
    this.hasFlash = true,
    required this.onModeChanged,
    required this.isBn,
  });

  void _cycleFlashMode() {
    if (!hasFlash) return;
    switch (currentMode) {
      case FlashMode.off:
        onModeChanged(FlashMode.torch);
        break;
      case FlashMode.torch:
      case FlashMode.always:
        onModeChanged(FlashMode.auto);
        break;
      case FlashMode.auto:
        onModeChanged(FlashMode.off);
        break;
    }
  }

  IconData _getIcon() {
    if (!hasFlash) return Icons.flash_off_rounded;
    switch (currentMode) {
      case FlashMode.torch:
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.off:
        return Icons.flash_off_rounded;
    }
  }

  Color _getIconColor() {
    if (!hasFlash) return Colors.white38;
    switch (currentMode) {
      case FlashMode.torch:
      case FlashMode.always:
        return AppColors.limeGreen;
      case FlashMode.auto:
        return AppColors.freshGreen;
      case FlashMode.off:
        return Colors.white;
    }
  }

  String _getTooltip() {
    if (!hasFlash) return isBn ? 'ফ্ল্যাশ উপলব্ধ নেই' : 'Flash unavailable';
    switch (currentMode) {
      case FlashMode.torch:
      case FlashMode.always:
        return isBn ? 'ফ্ল্যাশ চালু' : 'Flash Torch';
      case FlashMode.auto:
        return isBn ? 'অটো ফ্ল্যাশ' : 'Flash Auto';
      case FlashMode.off:
        return isBn ? 'ফ্ল্যাশ বন্ধ' : 'Flash Off';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _getTooltip(),
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: hasFlash ? _cycleFlashMode : null,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: currentMode != FlashMode.off && hasFlash
                    ? AppColors.freshGreen.withValues(alpha: 0.8)
                    : Colors.white24,
                width: 1.2,
              ),
            ),
            child: Icon(
              _getIcon(),
              color: _getIconColor(),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
