import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.secondaryContainer,
              child: const Icon(Icons.person, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              user?.email ?? 'Guest Farmer',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              user != null ? 'Authenticated Cloud Account' : 'Offline / Local Account',
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Field Diagnosis History'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/history'),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('App Language (English / বাংলা)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/language'),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Send Feedback to Agronomists'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/feedback'),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & FAQ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/help'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About AgriCare AI'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/about'),
            ),
            const SizedBox(height: 24),
            if (user != null)
              OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) context.go('/login');
                },
              )
            else
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Login or Create Account'),
              ),
          ],
        ),
      ),
    );
  }
}

