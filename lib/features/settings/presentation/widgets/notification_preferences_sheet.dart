import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/settings_provider.dart';

/// Screen 25 – Notification Preferences Bottom Sheet
/// Manages verified in-app alert categories: general alerts, plant care reminders, and detection updates.
class NotificationPreferencesSheet extends ConsumerWidget {
  const NotificationPreferencesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const NotificationPreferencesSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Heading
              Text(
                isBn ? 'নোটিফিকেশন পছন্দসমূহ' : 'Notification Preferences',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isBn
                    ? 'আপনার প্রয়োজন অনুযায়ী সতর্কতা ও পরামর্শের নোটিফিকেশন নিয়ন্ত্রণ করুন'
                    : 'Manage in-app notifications and agricultural alert preferences',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 16),

              // Master Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.forestGreen,
                title: Text(
                  isBn ? 'সব নোটিফিকেশন চালু রাখুন' : 'Allow Notifications',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                subtitle: Text(
                  isBn
                      ? 'অ্যাপের প্রয়োজনীয় কৃষি বার্তা গ্রহণ করুন'
                      : 'Receive helpful alerts and agricultural advice',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                value: settings.notificationsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsProvider.notifier)
                      .setNotificationsEnabled(val);
                },
              ),
              const Divider(color: Color(0xFFF0F4EF), height: 16),

              // Category 1: Plant Care Reminders
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.forestGreen,
                title: Text(
                  isBn
                      ? 'ফসলের যত্ন ও ফলো-আপ রিমাইন্ডার'
                      : 'Plant Care Reminders',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                subtitle: Text(
                  isBn
                      ? 'আক্রান্ত গাছের ফলো-আপ পর্যবেক্ষণ স্মরণ করিয়ে দেয়া'
                      : 'Reminders to check treated crops and log follow-ups',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                value: settings.notificationsEnabled &&
                    settings.plantCareReminders,
                onChanged: settings.notificationsEnabled
                    ? (val) {
                        ref
                            .read(settingsProvider.notifier)
                            .setPlantCareReminders(val);
                      }
                    : null,
              ),
              const Divider(color: Color(0xFFF0F4EF), height: 16),

              // Category 2: Detection Updates
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.forestGreen,
                title: Text(
                  isBn ? 'রোগ শনাক্তকরণ আপডেট' : 'Detection & Disease Alerts',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                subtitle: Text(
                  isBn
                      ? 'সংরক্ষিত স্ক্যান সংক্রান্ত জরুরি আপডেট'
                      : 'Alerts regarding saved diagnoses and agricultural advice',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                value:
                    settings.notificationsEnabled && settings.detectionAlerts,
                onChanged: settings.notificationsEnabled
                    ? (val) {
                        ref
                            .read(settingsProvider.notifier)
                            .setDetectionAlerts(val);
                      }
                    : null,
              ),
              const SizedBox(height: 12),

              // Advisory Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGreen),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.forestGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBn
                            ? 'সতর্কতা: অপারেটিং সিস্টেম লেভেলের নোটিফিকেশন অনুমতি আপনার ডিভাইসের সেটিংস থেকে কার্যকর হতে হবে।'
                            : 'Note: System-level notification permissions must also be granted in your device settings.',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondaryText,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
