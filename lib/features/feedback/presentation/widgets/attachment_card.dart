import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class FeedbackAttachmentData {
  final Uint8List bytes;
  final String name;
  final int sizeInBytes;
  final String extension;

  FeedbackAttachmentData({
    required this.bytes,
    required this.name,
    required this.sizeInBytes,
    required this.extension,
  });

  String get formattedSize {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Screen 29 – Optional Attachment Card
class AttachmentCard extends StatelessWidget {
  final FeedbackAttachmentData? attachment;
  final ValueChanged<FeedbackAttachmentData?> onAttachmentChanged;
  final String? errorText;
  final bool isBn;

  const AttachmentCard({
    super.key,
    required this.attachment,
    required this.onAttachmentChanged,
    this.errorText,
    required this.isBn,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final name = picked.name;
        final size = bytes.length;

        // Size check (Max 5MB)
        if (size > 5 * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isBn
                      ? 'ফাইলের আকার ৫ মেগাবাইটের কম হতে হবে।'
                      : 'Attachment size must be under 5 MB.',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        final ext =
            name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';

        onAttachmentChanged(
          FeedbackAttachmentData(
            bytes: bytes,
            name: name,
            sizeInBytes: size,
            extension: ext,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn
                  ? 'ছবি নির্বাচন করতে সমস্যা হয়েছে।'
                  : 'Failed to select image.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isBn ? 'ছবি কীভাবে যুক্ত করবেন?' : 'Attach Image Source',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.softNaturalGreen,
                child: Icon(Icons.camera_alt_outlined,
                    color: AppColors.forestGreen),
              ),
              title: Text(
                isBn ? 'ক্যামেরা দিয়ে তুলুন' : 'Take a Photo',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => _pickImage(context, ImageSource.camera),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.softNaturalGreen,
                child: Icon(Icons.photo_library_outlined,
                    color: AppColors.forestGreen),
              ),
              title: Text(
                isBn ? 'গ্যালারি থেকে নির্বাচন করুন' : 'Choose from Gallery',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: errorText != null ? AppColors.error : AppColors.borderGreen,
          width: errorText != null ? 1.4 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isBn
                      ? 'ছবি যুক্ত করুন (ঐচ্ছিক)'
                      : 'Attach a Photo (Optional)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBn ? 'ঐচ্ছিক' : 'Optional',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isBn
                ? 'আপনার সমস্যাটি স্পষ্টভাবে বোঝাতে স্ক্রিনশট বা পাতার ছবি যুক্ত করতে পারেন।'
                : 'You can share a screenshot or plant photo to help explain your feedback.',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 14),

          // Attachment Container / Button
          if (attachment == null) ...[
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showSourceDialog(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderGreen,
                    style: BorderStyle.solid,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.forestGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBn ? 'ছবি নির্বাচন করুন' : 'Add Image or Screenshot',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Image Preview Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softNaturalGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGreen, width: 1),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      attachment!.bytes,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(
                        width: 52,
                        height: 52,
                        color: AppColors.borderGreen,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.forestGreen,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment!.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          attachment!.formattedSize,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    tooltip: isBn ? 'ছবি মুছে ফেলুন' : 'Remove attachment',
                    onPressed: () => onAttachmentChanged(null),
                  ),
                ],
              ),
            ),
          ],

          // Error Text
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
