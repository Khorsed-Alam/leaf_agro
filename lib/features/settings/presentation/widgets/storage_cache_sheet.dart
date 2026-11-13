import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 25 – Storage & Cache Management Sheet
/// Calculates genuine temporary files and cache size and allows farmers to clear
/// temporary data safely without affecting saved diagnosis history or account details.
class StorageCacheSheet extends StatefulWidget {
  final bool isBn;

  const StorageCacheSheet({
    super.key,
    required this.isBn,
  });

  static Future<void> show(BuildContext context, bool isBn) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StorageCacheSheet(isBn: isBn),
    );
  }

  @override
  State<StorageCacheSheet> createState() => _StorageCacheSheetState();
}

class _StorageCacheSheetState extends State<StorageCacheSheet> {
  int _cacheSizeBytes = 0;
  bool _isCalculating = true;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    setState(() => _isCalculating = true);

    int totalSize = 0;
    try {
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        if (tempDir.existsSync()) {
          final files = tempDir.listSync(recursive: true, followLinks: false);
          for (final file in files) {
            if (file is File) {
              totalSize += file.lengthSync();
            }
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _cacheSizeBytes = totalSize;
        _isCalculating = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0.0 KB';
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }

  Future<void> _confirmClearCache() async {
    final isBn = widget.isBn;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isBn ? 'অস্থায়ী ক্যাশ মুছবেন?' : 'Clear Temporary Cache?',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          isBn
              ? 'এটি কেবল অস্থায়ী ফাইল ও ব্রাউজিং ক্যাশ মুছে ফেলবে। আপনার সংরক্ষিত স্ক্যান হিস্ট্রি এবং অ্যাকাউন্টের তথ্যের কোনো ক্ষতি হবে না।'
              : 'This will remove temporary files and cached content. Your saved detections and account information will remain unchanged.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.secondaryText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              isBn ? 'বাতিল' : 'Cancel',
              style: const TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(isBn ? 'ক্যাশ মুছুন' : 'Clear Cache', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeClearCache();
    }
  }

  Future<void> _executeClearCache() async {
    setState(() => _isClearing = true);

    try {
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        if (tempDir.existsSync()) {
          final files = tempDir.listSync(recursive: true, followLinks: false);
          for (final file in files) {
            try {
              if (file is File) {
                file.deleteSync();
              }
            } catch (_) {}
          }
        }
      }

      await _calculateCacheSize();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isBn
                ? 'অস্থায়ী ক্যাশ সফলভাবে মুছে ফেলা হয়েছে।'
                : 'Temporary cache cleared successfully.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = widget.isBn;

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storage_rounded,
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
                        isBn ? 'স্টোরেজ ও ক্যাশ তথ্য' : 'Storage & Cache Management',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        isBn ? 'অস্থায়ী ফাইল ও মেমরি পর্যবেক্ষণ' : 'Manage temporary file storage',
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
            const SizedBox(height: 20),

            // Storage Details Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softNaturalGreen,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGreen),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'অস্থায়ী ক্যাশ ফাইলের আকার' : 'Temporary Cache Size',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      _isCalculating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.forestGreen,
                              ),
                            )
                          : Text(
                              _formatBytes(_cacheSizeBytes),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestGreen,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBn
                        ? 'ক্যামেরা স্ক্যান প্রিভিউ এবং নেটওয়ার্ক ইমেজ লোড করার সময় তৈরি হওয়া অস্থায়ী ফাইল।'
                        : 'Temporary files created during camera preview buffering and network image caching.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Safety Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGreen),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    size: 18,
                    color: AppColors.forestGreen,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'নিরাপত্তা বার্তা: ক্যাশ পরিষ্কার করলে আপনার কোনো সংরক্ষিত রোগ শনাক্তকরণ ডাটা বা অ্যাকাউন্ট মুছে যাবে না।'
                          : 'Safety notice: Clearing cache will never delete your saved detection history or account credentials.',
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
            const SizedBox(height: 20),

            // Clear Cache Action Button
            ElevatedButton.icon(
              onPressed: _isClearing ? null : _confirmClearCache,
              icon: _isClearing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.delete_sweep_rounded, size: 20),
              label: Text(
                isBn ? 'অস্থায়ী ক্যাশ মুছে ফেলুন' : 'Clear Temporary Cache',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

