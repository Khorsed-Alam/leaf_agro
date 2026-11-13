import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/plant_observation_model.dart';

/// Screen 21 – Farmer Observation Journal & Note Input
/// Provides an intuitive, touch-friendly interface for farmers to record
/// visual observations, self-reported condition ratings, and notes over time.
class RecordObservationCard extends StatefulWidget {
  final bool isBn;
  final Future<void> Function({
    required String notes,
    required FarmerConditionLabel condition,
    DateTime? inspectionDate,
  }) onSave;

  const RecordObservationCard({
    super.key,
    required this.isBn,
    required this.onSave,
  });

  @override
  State<RecordObservationCard> createState() => _RecordObservationCardState();
}

class _RecordObservationCardState extends State<RecordObservationCard> {
  final TextEditingController _notesController = TextEditingController();
  FarmerConditionLabel _selectedCondition =
      FarmerConditionLabel.noNoticeableChange;
  DateTime _observationDate = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final text = _notesController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = widget.isBn
            ? 'অনুগ্রহ করে আপনার পর্যবেক্ষণ বা পরিবর্তন সংক্ষেপে লিখুন।'
            : 'Please enter a brief note describing what you noticed.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave(
        notes: text,
        condition: _selectedCondition,
        inspectionDate: _observationDate,
      );

      if (!mounted) return;

      _notesController.clear();
      setState(() {
        _isSaving = false;
        _selectedCondition = FarmerConditionLabel.noNoticeableChange;
        _observationDate = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isBn
                ? 'পর্যবেক্ষণ সফলভাবে সংরক্ষিত হয়েছে!'
                : 'Observation successfully recorded!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = widget.isBn
            ? 'সংরক্ষণ ব্যর্থ হয়েছে। আপনার নোট সংরক্ষিত রয়েছে, আবার চেষ্টা করুন।'
            : 'Failed to save observation. Your entered notes are preserved, please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isBn
                          ? 'আপনার পর্যবেক্ষণ লিখে রাখুন'
                          : 'Record Your Observation',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    Text(
                      widget.isBn
                          ? 'আপনার গাছে যে পরিবর্তন লক্ষ্য করছেন তা লিখুন'
                          : 'Write down what you notice about your plant',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Condition Selector Label
          Text(
            widget.isBn
                ? 'বর্তমান অবস্থা (আপনার নিজস্ব পর্যবেক্ষণ):'
                : 'Condition (Your Visual Observation):',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),

          // Condition Chips Grid / Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FarmerConditionLabel.values.map((condition) {
              final isSelected = _selectedCondition == condition;
              return ChoiceChip(
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCondition = condition;
                    });
                  }
                },
                avatar: Icon(
                  condition.icon,
                  size: 16,
                  color: isSelected ? Colors.white : condition.color,
                ),
                label: Text(
                  widget.isBn ? condition.labelBn() : condition.labelEn(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primaryText,
                  ),
                ),
                selectedColor: AppColors.forestGreen,
                backgroundColor: AppColors.surfaceContainerLow,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.forestGreen
                      : AppColors.borderGreen,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Date Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isBn ? 'পর্যবেক্ষণের তারিখ:' : 'Observation Date:',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _observationDate,
                    firstDate: now.subtract(const Duration(days: 30)),
                    lastDate: now,
                  );
                  if (picked != null) {
                    setState(() {
                      _observationDate = picked;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.forestGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatShortDate(_observationDate),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Multiline TextField
          TextField(
            controller: _notesController,
            maxLines: 4,
            minLines: 3,
            maxLength: 500,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: widget.isBn
                  ? 'আপনার গাছে লক্ষ্য করা পরিবর্তনগুলো বর্ণনা করুন (যেমন: নতুন কচি পাতা গজিয়েছে, দাগ কমছে, ইত্যাদি)...'
                  : 'Describe any changes you noticed in your plant (e.g., new leaves growing, spots reducing, etc.)...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.forestGreen,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Notice badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.isBn
                        ? 'এটি কৃষকের নিজস্ব নোট, কোনো কৃত্রিম বুদ্ধিমত্তা যাচাইকৃত চিকিৎসা বা নিরাময় প্রমাণ নয়।'
                        : 'This note is a farmer visual record, not a verified AI medical conclusion.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bookmark_added_outlined, size: 18),
              label: Text(
                _isSaving
                    ? (widget.isBn
                        ? 'সংরক্ষণ করা হচ্ছে...'
                        : 'Saving Observation...')
                    : (widget.isBn
                        ? 'পর্যবেক্ষণ সংরক্ষণ করুন'
                        : 'Save Observation'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

