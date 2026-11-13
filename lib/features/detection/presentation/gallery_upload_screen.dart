import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/gallery/gallery_continue_button.dart';
import 'widgets/gallery/gallery_header.dart';
import 'widgets/gallery/gallery_selection_card.dart';
import 'widgets/gallery/selected_image_preview_card.dart';
import 'widgets/image_quality_guide.dart';

/// Screen 13 – Gallery Upload Screen for AgriCare AI (LeafAgro)
/// Allows farmers to select an existing leaf photo via the native Android Photo Picker
/// and submit it to the offline AI disease detection pipeline.
class GalleryUploadScreen extends ConsumerStatefulWidget {
  final ImagePicker? imagePicker;
  final String? initialImagePath;

  const GalleryUploadScreen({
    super.key,
    this.imagePicker,
    this.initialImagePath,
  });

  @override
  ConsumerState<GalleryUploadScreen> createState() =>
      _GalleryUploadScreenState();
}

class _GalleryUploadScreenState extends ConsumerState<GalleryUploadScreen> {
  late final ImagePicker _picker;
  String? _selectedImagePath;
  int? _fileSizeBytes;
  String? _fileName;

  bool _isPicking = false;
  bool _isContinuing = false;

  @override
  void initState() {
    super.initState();
    _picker = widget.imagePicker ?? ImagePicker();

    if (widget.initialImagePath != null &&
        widget.initialImagePath!.isNotEmpty) {
      _processImageFile(widget.initialImagePath!);
    }
  }

  void _processImageFile(String path) {
    _selectedImagePath = path;
    try {
      final file = File(path);
      if (file.existsSync()) {
        _fileSizeBytes = file.lengthSync();
        _fileName = path.split(Platform.pathSeparator).last;
      } else {
        _fileName = path.split('/').last;
      }
    } catch (_) {
      _fileName = path.split('/').last;
    }
  }

  bool _validateImageFile(String path, bool isBn) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        final fileSize = file.lengthSync();

        // 0-byte corrupt file
        if (fileSize == 0) {
          _showErrorSnackBar(
            isBn
                ? 'ছবিটি সঠিক নয় বা খালি। অন্য একটি ছবি নির্বাচন করুন।'
                : 'The selected image is empty or corrupt. Please select another image.',
          );
          return false;
        }

        // Max 20MB limit
        if (fileSize > 20 * 1024 * 1024) {
          _showErrorSnackBar(
            isBn
                ? 'ছবির আকার ২০ মেগাবাইট এর বেশি। ছোট আকারের ছবি নির্বাচন করুন।'
                : 'Image size exceeds 20MB. Please choose a smaller photo.',
          );
          return false;
        }
      }

      // Supported extensions check
      final lower = path.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
      final hasValidExt = validExtensions.any((ext) => lower.endsWith(ext));

      if (!hasValidExt) {
        _showErrorSnackBar(
          isBn
              ? 'অসমর্থিত ছবির ফরম্যাট। শুধুমাত্র JPG, PNG বা WEBP সমর্থিত।'
              : 'Unsupported image format. Please use JPG, PNG, or WEBP.',
        );
        return false;
      }

      return true;
    } catch (_) {
      // In web or restricted sandboxes where File(path) is not directly inspectable,
      // allow fallback if path is non-empty.
      return path.isNotEmpty;
    }
  }

  Future<void> _handleBrowseGallery() async {
    if (_isPicking) return;

    final isBn = ref.read(settingsProvider).language == 'bn';

    setState(() {
      _isPicking = true;
    });

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (!mounted) return;

      // Handle user cancellation gracefully without showing an error
      if (pickedFile == null) {
        return;
      }

      final isValid = _validateImageFile(pickedFile.path, isBn);
      if (isValid) {
        setState(() {
          _processImageFile(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'photo_access_denied') {
        _showErrorSnackBar(
          isBn
              ? 'ছবি নির্বাচনের জন্য গ্যালারি ব্যবহারের অনুমতি প্রয়োজন।'
              : 'Gallery access is required to choose a photo.',
        );
      } else {
        _showErrorSnackBar(
          isBn
              ? 'গ্যালারি খুলতে সমস্যা হয়েছে: ${e.message ?? "আবার চেষ্টা করুন"}'
              : 'Unable to open gallery: ${e.message ?? "Please try again"}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(
        isBn
            ? 'ছবি লোড করতে ত্রুটি হয়েছে। আবার চেষ্টা করুন।'
            : 'Error picking image from gallery. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  Future<void> _handleContinue() async {
    if (_selectedImagePath == null || _isContinuing) return;

    final isBn = ref.read(settingsProvider).language == 'bn';

    setState(() {
      _isContinuing = true;
    });

    try {
      // Validate that file still exists
      if (!kIsWeb) {
        try {
          final file = File(_selectedImagePath!);
          if (!file.existsSync() || file.lengthSync() == 0) {
            _showErrorSnackBar(
              isBn
                  ? 'নির্বাচিত ফাইলটি খুঁজে পাওয়া যায়নি। অনুগ্রহ করে পুনরায় নির্বাচন করুন।'
                  : 'Selected photo could not be read. Please choose it again.',
            );
            setState(() {
              _selectedImagePath = null;
            });
            return;
          }
        } catch (_) {}
      }

      // Update global detection state
      ref.read(detectionProvider.notifier).selectImage(_selectedImagePath!);

      // Navigate to Image Preview & Confirmation screen
      if (mounted) {
        try {
          context.push('/detect/preview');
        } catch (_) {
          // Fallback in widget tests without GoRouter context
        }
      }
    } catch (e) {
      _showErrorSnackBar(
        isBn
            ? 'ছবি প্রস্তুতিতে সমস্যা হয়েছে। আবার চেষ্টা করুন।'
            : 'Error preparing image for detection.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isContinuing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final selectedCrop = ref.watch(selectedCropProvider);
    final cropName = selectedCrop != null
        ? (isBn ? selectedCrop.nameBn : selectedCrop.nameEn)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Back button, Crop badge, Title & Subtitle)
              GalleryHeader(
                isBn: isBn,
                selectedCropName: cropName,
              ),

              // 2. Primary Selection Area or Selected Image Preview
              if (_selectedImagePath == null)
                GallerySelectionCard(
                  onBrowse: _handleBrowseGallery,
                  isBusy: _isPicking,
                  isBn: isBn,
                )
              else
                SelectedImagePreviewCard(
                  imagePath: _selectedImagePath!,
                  fileSizeBytes: _fileSizeBytes,
                  fileName: _fileName,
                  onChangeImage: _handleBrowseGallery,
                  isBusy: _isPicking,
                  isBn: isBn,
                ),

              const SizedBox(height: 12),

              // 3. Compact Image Quality Guidelines
              ImageQualityGuide(isBn: isBn),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GalleryContinueButton(
        onContinue: _handleContinue,
        isEnabled: _selectedImagePath != null,
        isLoading: _isContinuing,
        isBn: isBn,
      ),
    );
  }
}
