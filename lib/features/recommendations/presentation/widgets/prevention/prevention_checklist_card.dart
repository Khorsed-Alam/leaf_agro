import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screen 19 – Interactive Prevention Checklist & Progress Card
/// Allows farmers to track routine field prevention tasks with visual progress feedback.
class PreventionChecklistCard extends StatefulWidget {
  final CropModel? crop;
  final bool isBn;

  const PreventionChecklistCard({
    super.key,
    required this.crop,
    required this.isBn,
  });

  @override
  State<PreventionChecklistCard> createState() =>
      _PreventionChecklistCardState();
}

class _PreventionChecklistCardState extends State<PreventionChecklistCard> {
  final Set<int> _checkedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadSavedChecklist();
  }

  @override
  void didUpdateWidget(covariant PreventionChecklistCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.crop?.id != widget.crop?.id) {
      _loadSavedChecklist();
    }
  }

  Future<void> _loadSavedChecklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cropKey = 'prevention_checklist_${widget.crop?.id ?? 0}';
      final savedList = prefs.getStringList(cropKey) ?? [];
      if (mounted) {
        setState(() {
          _checkedIndices.clear();
          for (final s in savedList) {
            final idx = int.tryParse(s);
            if (idx != null) _checkedIndices.add(idx);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleItem(int index) async {
    setState(() {
      if (_checkedIndices.contains(index)) {
        _checkedIndices.remove(index);
      } else {
        _checkedIndices.add(index);
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cropKey = 'prevention_checklist_${widget.crop?.id ?? 0}';
      final stringList = _checkedIndices.map((i) => i.toString()).toList();
      await prefs.setStringList(cropKey, stringList);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final items = _getChecklistItems();
    final total = items.length;
    final completed = _checkedIndices.where((i) => i < total).length;
    final double progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.isBn
                    ? 'আমার রোগ প্রতিরোধ চেকলিস্ট'
                    : 'My Prevention Checklist',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Prevention Progress Summary Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isBn
                          ? 'আপনার প্রতিরোধ অগ্রগতি'
                          : 'Your Prevention Progress',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      widget.isBn
                          ? '$completed / $total সম্পন্ন'
                          : '$completed of $total Completed',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.freshGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Checklist Rows
          Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isChecked = _checkedIndices.contains(index);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _toggleItem(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: isChecked
                          ? AppColors.softNaturalGreen.withValues(alpha: 0.5)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isChecked
                            ? AppColors.freshGreen.withValues(alpha: 0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (_) => _toggleItem(index),
                          activeColor: AppColors.forestGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isChecked
                                      ? AppColors.forestGreen
                                      : AppColors.primaryText,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              if (item.explanation.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.explanation,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.secondaryText,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  List<_ChecklistItem> _getChecklistItems() {
    if (widget.isBn) {
      return [
        const _ChecklistItem(
          title: 'সকালে ও বিকেলে পাতার ওপর দাগ বা পরিবর্তন পরীক্ষা করা',
          explanation:
              'পাতায় কোনো হলুদ বলয়, বাদামী দাগ বা অস্বাভাবিক লক্ষণ আছে কি না দেখুন।',
        ),
        const _ChecklistItem(
          title: 'জমির আইল ও চারপাশের আগাছা পরিষ্কার রাখা',
          explanation:
              'আগাছা জীবাণুর আশ্রয়স্থল, তাই ক্ষেতের চারপাশ পরিচ্ছন্ন রাখুন।',
        ),
        const _ChecklistItem(
          title: 'পানি জমে থাকা রোধে নিকাশ নালা সচল রাখা',
          explanation:
              'অতিরিক্ত বৃষ্টির পানি বা সেচের পানি দ্রুত বের হওয়ার ব্যবস্থা নিশ্চিত করুন।',
        ),
        const _ChecklistItem(
          title: 'সুষম মাত্রায় পটাশ সার প্রয়োগ ও অতিরিক্ত ইউরিয়া বর্জন',
          explanation:
              'সঠিক মাত্রার পটাশ গাছের কোষপ্রাচীর মজবুত করে রোগ প্রতিরোধ ক্ষমতা বাড়ায়।',
        ),
        const _ChecklistItem(
          title: 'গাছের উপযুক্ত দূরত্ব ও আলো-বাতাস চলাচল নিশ্চিত করা',
          explanation:
              'পর্যাপ্ত রোদ ও বায়ুপ্রবাহ আর্দ্রতা কমিয়ে ছত্রাকের বিস্তার রোধ করে।',
        ),
      ];
    } else {
      return [
        const _ChecklistItem(
          title: 'Scout leaf foliage twice weekly for spots or chlorosis',
          explanation:
              'Check leaf undersides in morning light to catch early symptoms.',
        ),
        const _ChecklistItem(
          title: 'Clean weed growth along field levees and furrows',
          explanation:
              'Remove alternative volunteer hosts that harbor bacterial pathogens.',
        ),
        const _ChecklistItem(
          title: 'Clear drainage furrows to prevent standing surface water',
          explanation:
              'Fast water run-off eliminates vector movement between plant rows.',
        ),
        const _ChecklistItem(
          title: 'Apply balanced potassium and avoid excess nitrogen',
          explanation:
              'Balanced split fertilizer maintains sturdy vegetative cell walls.',
        ),
        const _ChecklistItem(
          title: 'Maintain plant-to-plant spacing for canopy ventilation',
          explanation:
              'Good air movement accelerates foliar drying after dew and rain.',
        ),
      ];
    }
  }
}

class _ChecklistItem {
  final String title;
  final String explanation;

  const _ChecklistItem({
    required this.title,
    required this.explanation,
  });
}
