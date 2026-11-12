import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(
            title: Text('Does AgriCare AI work without internet?'),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Yes! The MobileNetV2 neural network is embedded directly in the app. Plant leaf diagnosis and local log history run completely offline.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Which crops are currently supported?'),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Rice, Potato, Tomato, Mango, and Jute covering both common fungal/bacterial diseases and healthy leaf recognition.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How should I photograph an infected leaf?'),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Hold the camera approximately 15-20 cm from the leaf surface. Ensure clear sunlight or steady daylight, avoiding blurry motions.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

