import 'package:flutter/material.dart';

/// Camera Switch / Flip Button
/// Toggles between Rear and Front cameras when multiple lenses are available.
class CameraSwitchButton extends StatelessWidget {
  final VoidCallback? onSwitch;
  final bool hasMultipleCameras;
  final bool isBusy;
  final bool isBn;

  const CameraSwitchButton({
    super.key,
    required this.onSwitch,
    this.hasMultipleCameras = true,
    this.isBusy = false,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = hasMultipleCameras && !isBusy && onSwitch != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: isBn ? 'ক্যামেরা পরিবর্তন' : 'Switch camera',
      child: GestureDetector(
        onTap: isEnabled ? onSwitch : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEnabled
                    ? Colors.black.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.2),
                border: Border.all(
                  color: isEnabled ? Colors.white30 : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.flip_camera_ios_rounded,
                color: isEnabled ? Colors.white : Colors.white30,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isBn ? 'ক্যামেরা' : 'Switch',
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
