import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language / ভাষা'),
            subtitle: Text(settings.language == 'bn' ? 'বাংলা' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/language'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_off_outlined),
            title: const Text('Force Offline Mode'),
            subtitle: const Text('Run only local TFLite neural network without network calls'),
            value: settings.offlineOnlyMode,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).toggleOfflineOnly(val);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).toggleDarkMode(val);
            },
          ),
        ],
      ),
    );
  }
}

