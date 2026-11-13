import 'package:flutter/material.dart';
import 'camera_capture_button.dart';
import 'camera_switch_button.dart';
import 'gallery_shortcut_button.dart';

/// Bottom Control Bar for Camera Screen
/// Houses Gallery picker, large Shutter button, and Camera lens switch button.
class CameraBottomControls extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onOpenGallery;
  final VoidCallback? onSwitchCamera;
  final bool isCapturing;
  final bool hasMultipleCameras;
  final bool isBn;

  const CameraBottomControls({
    super.key,
    required this.onCapture,
    required this.onOpenGallery,
    required this.onSwitchCamera,
    this.isCapturing = false,
    this.hasMultipleCameras = true,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 28,
        right: 28,
        top: 24,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.45),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gallery Shortcut
            SizedBox(
              width: 70,
              child: GalleryShortcutButton(
                onOpenGallery: onOpenGallery,
                isBusy: isCapturing,
                isBn: isBn,
              ),
            ),

            // Shutter Button (Center)
            CameraCaptureButton(
              onCapture: onCapture,
              isCapturing: isCapturing,
              isBn: isBn,
            ),

            // Switch Camera (Right)
            SizedBox(
              width: 70,
              child: CameraSwitchButton(
                onSwitch: onSwitchCamera,
                hasMultipleCameras: hasMultipleCameras,
                isBusy: isCapturing,
                isBn: isBn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

