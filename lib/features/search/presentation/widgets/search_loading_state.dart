import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchLoadingState extends StatelessWidget {
  final bool isBn;

  const SearchLoadingState({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isBn ? 'ফসল ও রোগ অনুসন্ধান করা হচ্ছে...' : 'Searching crops and diseases...',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
