import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 27 – Notification Category Filter
/// Horizontally scrollable Material 3 choice chip bar for filtering notifications.
class NotificationCategoryFilter extends StatelessWidget {
  final String activeFilter;
  final int unreadCount;
  final bool isBn;
  final ValueChanged<String> onFilterChanged;

  const NotificationCategoryFilter({
    super.key,
    required this.activeFilter,
    required this.unreadCount,
    required this.isBn,
    required this.onFilterChanged,
  });

  String _formatCount(int count) {
    if (!isBn) return count.toString();
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return count.toString().split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? bnDigits[digit] : char;
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    final countStr = _formatCount(unreadCount);
    final filters = [
      {'id': 'all', 'label': isBn ? 'সব' : 'All'},
      {
        'id': 'unread',
        'label': isBn
            ? (unreadCount > 0 ? 'অপঠিত ($countStr)' : 'অপঠিত')
            : (unreadCount > 0 ? 'Unread ($unreadCount)' : 'Unread'),
      },
      {'id': 'activity', 'label': isBn ? 'কার্যক্রম' : 'Activity'},
      {'id': 'reminder', 'label': isBn ? 'রিমাইন্ডার' : 'Reminders'},
      {'id': 'update', 'label': isBn ? 'আপডেট' : 'Updates'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: filters.map((f) {
          final id = f['id']!;
          final label = f['label']!;
          final isSelected = activeFilter == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(id),
              selectedColor: AppColors.forestGreen,
              backgroundColor: AppColors.surfaceContainerLowest,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.primaryText,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestGreen : AppColors.borderGreen,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          );
        }).toList(),
      ),
    );
  }
}

