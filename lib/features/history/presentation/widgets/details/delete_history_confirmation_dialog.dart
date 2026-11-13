import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 23 – Delete History Confirmation Dialog
/// Confirms before permanently removing an authentic scan record from SQLite & Supabase.
class DeleteHistoryConfirmationDialog extends StatefulWidget {
  final bool isBn;
  final Future<void> Function() onConfirmDelete;

  const DeleteHistoryConfirmationDialog({
    super.key,
    required this.isBn,
    required this.onConfirmDelete,
  });

  static Future<bool?> show({
    required BuildContext context,
    required bool isBn,
    required Future<void> Function() onConfirmDelete,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteHistoryConfirmationDialog(
        isBn: isBn,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  State<DeleteHistoryConfirmationDialog> createState() =>
      _DeleteHistoryConfirmationDialogState();
}

class _DeleteHistoryConfirmationDialogState
    extends State<DeleteHistoryConfirmationDialog> {
  bool _isDeleting = false;
  String? _errorMessage;

  Future<void> _handleDelete() async {
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirmDelete();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _errorMessage = widget.isBn
              ? 'মুছে ফেলা সম্ভব হয়নি। অনুগ্রহ করে আবার চেষ্টা করুন।'
              : 'Failed to delete record. Please check connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.isBn
                  ? 'এই রেকর্ডটি মুছে ফেলবেন?'
                  : 'Delete This History Record?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isBn
                ? 'এটি আপনার ইতিহাস থেকে এই সংরক্ষিত রোগ পরীক্ষার রেকর্ড স্থায়ীভাবে মুছে ফেলবে। এই কাজটি আর ফিরিয়ে আনা যাবে না।'
                : 'This will permanently remove this saved detection record from your history. This action cannot be undone.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(false),
          child: Text(
            widget.isBn ? 'বাতিল' : 'Cancel',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.isBn ? 'মুছে ফেলুন' : 'Delete',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }
}
