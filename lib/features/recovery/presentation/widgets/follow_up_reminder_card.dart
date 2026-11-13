import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';

/// Screen 21 – Follow-up Inspection Reminder Card
/// Allows farmers to self-schedule their next inspection target date and time.
/// Operates transparently without inventing non-existent notification backends.
class FollowUpReminderCard extends StatelessWidget {
  final DateTime? reminderDate;
  final bool isBn;
  final ValueChanged<DateTime?> onReminderChanged;

  const FollowUpReminderCard({
    super.key,
    required this.reminderDate,
    required this.isBn,
    required this.onReminderChanged,
  });

  Future<void> _pickInspectionDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = reminderDate != null && reminderDate!.isAfter(now)
        ? reminderDate!
        : now.add(const Duration(days: 4));

    // 1. Pick Date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: isBn
          ? 'পরবর্তী পরিদর্শনের তারিখ নির্বাচন করুন'
          : 'Select Next Inspection Date',
      confirmText: isBn ? 'পরবর্তী' : 'Next',
      cancelText: isBn ? 'বাতিল' : 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.forestGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !context.mounted) return;

    // 2. Pick Time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: isBn
          ? 'পরিদর্শনের সময় নির্বাচন করুন'
          : 'Select Inspection Time',
      confirmText: isBn ? 'নিশ্চিত করুন' : 'Confirm',
      cancelText: isBn ? 'বাতিল' : 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.forestGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!context.mounted) return;

    final finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime?.hour ?? 9,
      pickedTime?.minute ?? 0,
    );

    onReminderChanged(finalDateTime);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBn
              ? 'পরবর্তী পরিদর্শনের সময় নির্ধারণ করা হয়েছে: ${DateFormatter.formatTimestamp(finalDateTime)}'
              : 'Next inspection scheduled: ${DateFormatter.formatTimestamp(finalDateTime)}',
        ),
        backgroundColor: AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasReminder = reminderDate != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.freshGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.freshGreen.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alarm_add_rounded,
                  color: AppColors.forestGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'গাছটি আবার পরীক্ষা করার সময় হয়েছে কি?'
                          : 'Time to Check Your Plant Again?',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'আপনার গাছটি আবার পর্যবেক্ষণ করার জন্য সময় নির্ধারণ করুন। পূর্বের পর্যবেক্ষণের সাথে মিলিয়ে পরিবর্তনগুলো লিপিবদ্ধ করুন।'
                          : 'Make time to inspect your plant again. Compare its current appearance with previous observations and record changes.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Scheduled Target Display
          if (hasReminder) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGreen),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.forestGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'নির্ধারিত তারিখ: ${DateFormatter.formatTimestamp(reminderDate!)}'
                          : 'Scheduled Target: ${DateFormatter.formatTimestamp(reminderDate!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                  // Clear button
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.secondaryText,
                    ),
                    tooltip: isBn ? 'মুছে ফেলুন' : 'Clear',
                    onPressed: () => onReminderChanged(null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => _pickInspectionDateTime(context),
              icon: Icon(
                hasReminder
                    ? Icons.edit_calendar_rounded
                    : Icons.calendar_month_outlined,
                size: 18,
              ),
              label: Text(
                hasReminder
                    ? (isBn ? 'তারিখ পরিবর্তন করুন' : 'Change Target Date')
                    : (isBn
                        ? 'ফলো-আপ রিমাইন্ডার নির্ধারণ করুন'
                        : 'Set Follow-up Reminder'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestGreen,
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: AppColors.forestGreen,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

