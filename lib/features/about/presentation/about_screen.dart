import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About AgriCare AI')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.eco_rounded, size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'AgriCare AI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(
              'Version 1.0.0 (Final Year Project Edition)',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            SizedBox(height: 24),
            Text(
              'AgriCare AI is an intelligent agricultural decision-support application created to assist smallholder farmers, agronomists, and field extension officers across Bangladesh.\n\n'
              'Powered by an edge-quantized MobileNetV2 deep neural network and cloud PostgreSQL database, the system identifies 19 disease and healthy classes across Rice, Potato, Tomato, Mango, and Jute crops without requiring persistent cellular connectivity.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            SizedBox(height: 32),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Developed for Agricultural Research & Food Security',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

