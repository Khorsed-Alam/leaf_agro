import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnalyzingScreen extends StatelessWidget {
  const AnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 56,
              width: 56,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Running Neural Network...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Preprocessing 224x224 RGB image & computing on-device TFLite inference',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

