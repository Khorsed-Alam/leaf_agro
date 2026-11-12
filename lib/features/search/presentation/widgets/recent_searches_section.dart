import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RecentSearchesSection extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;
  final bool isBn;

  const RecentSearchesSection({
    super.key,
    required this.recentSearches,
    required this.onSelect,
    required this.onRemove,
    required this.onClearAll,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Clear All Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: AppColors.forestGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBn ? 'সাম্প্রতিক অনুসন্ধান' : 'Recent Searches',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppColors.secondaryText,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  isBn ? 'সব মুছুন' : 'Clear All',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // List of recent searches
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentSearches.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final term = recentSearches[index];
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: AppColors.secondaryText,
                  ),
                  title: Text(
                    term,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: () => onRemove(term),
                    tooltip: isBn ? 'মুছুন' : 'Remove',
                  ),
                  onTap: () => onSelect(term),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
