import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Language / ভাষা নির্বাচন')),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: const Text('English'),
            subtitle: const Text('Default interface'),
            value: 'en',
            groupValue: settings.language,
            onChanged: (val) {
              if (val != null) {
                ref.read(settingsProvider.notifier).setLanguage(val);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('বাংলা (Bangla)'),
            subtitle: const Text('সহজ বাংলা ইন্টারফেস ও পরামর্শ'),
            value: 'bn',
            groupValue: settings.language,
            onChanged: (val) {
              if (val != null) {
                ref.read(settingsProvider.notifier).setLanguage(val);
              }
            },
          ),
        ],
      ),
    );
  }
}

