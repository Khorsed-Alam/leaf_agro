import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/settings_provider.dart';
import '../data/models/selected_plant_image.dart';
import 'providers/selected_image_provider.dart';
import 'widgets/active_selected_image_card.dart';
import 'widgets/ai_scanning_illustration.dart';
import 'widgets/detection_action_card.dart';
import 'widgets/detection_screen_header.dart';
import 'widgets/image_quality_guide.dart';
import 'widgets/offline_ai_status_indicator.dart';
import 'widgets/selected_crop_context_bar.dart';

/// Screen 11 – Detection Start Screen | AgriCare AI (LeafAgro)
/// Main entry point for plant disease detection. Farmers can capture a leaf photo
/// using their camera or select an existing photo from their gallery to proceed to
/// the on-device AI disease detection workflow.
class DetectionStartScreen extends ConsumerStatefulWidget {
  final ImagePicker? imagePicker;
  final bool animateIllustration;

  const DetectionStartScreen({
    super.key,
    this.imagePicker,
    this.animateIllustration = true,
  });

  @override
  ConsumerState<DetectionStartScreen> createState() =>
      _DetectionStartScreenState();
}

class _DetectionStartScreenState extends ConsumerState<DetectionStartScreen> {
  late final ImagePicker _picker;
  bool _isPickingImage = false;
  ImageSource? _activeSource;

  @override
  void initState() {
    super.initState();
    _picker = widget.imagePicker ?? ImagePicker();

    // Check for any recovered lost camera data after Android low-memory recreation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedImageProvider.notifier).checkLostData();
    });
  }

  /// Validates that the picked file exists, is non-empty, and has a supported image extension
  bool _validateImageFile(String path, bool isBn) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        _showErrorSnackBar(
          isBn
              ? 'নির্বাচিত ফাইলটি খুঁজে পাওয়া যায়নি।'
              : 'The selected file could not be accessed.',
        );
        return false;
      }

      final fileSize = file.lengthSync();
      if (fileSize == 0) {
        _showErrorSnackBar(
          isBn
              ? 'ফাইলটি খালি বা ত্রুটিপূর্ণ। অনুগ্রহ করে অন্য ছবি নির্বাচন করুন।'
              : 'This image file is empty or corrupted. Please try another photo.',
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

  Future<void> _handlePickImage(ImageSource source) async {
    if (_isPickingImage) return;

    final isBn = ref.read(settingsProvider).language == 'bn';

    setState(() {
      _isPickingImage = true;
      _activeSource = source;
    });

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        final isValid = _validateImageFile(pickedFile.path, isBn);
        if (isValid) {
          // Update both providers for complete consistency
          ref.read(detectionProvider.notifier).selectImage(pickedFile.path);

          final selectedModel = SelectedPlantImage(
            imagePath: pickedFile.path,
            sourceType: source == ImageSource.camera
                ? ImageSourceType.camera
                : ImageSourceType.gallery,
            fileSizeBytes: (tryGetFileSize(pickedFile.path)),
            width: 1024,
            height: 1024,
            selectedAt: DateTime.now(),
          );
          ref.read(selectedImageProvider.notifier).setExplicitImage(selectedModel);

          // Navigate to existing confirmation & preview screen
          if (mounted) {
            try {
              context.push('/detect/preview');
            } catch (_) {
              // Safe fallback when running in tests without GoRouter host
            }
          }
        }
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'camera_access_denied') {
        _showErrorSnackBar(
          isBn
              ? 'ছবি তোলার জন্য ক্যামেরা ব্যবহারের অনুমতি প্রয়োজন।'
              : 'Camera access is required to take a photo.',
        );
      } else if (e.code == 'photo_access_denied') {
        _showErrorSnackBar(
          isBn
              ? 'ছবি নির্বাচনের জন্য গ্যালারি ব্যবহারের অনুমতি প্রয়োজন।'
              : 'Gallery access is required to choose a photo.',
        );
      } else {
        _showErrorSnackBar(
          isBn
              ? 'ছবি লোড করতে সমস্যা হয়েছে: ${e.message ?? "আবার চেষ্টা করুন"}'
              : 'Unable to open image: ${e.message ?? "Please try again"}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(
        isBn
            ? 'ছবি প্রক্রিয়াকরণে ত্রুটি হয়েছে। আবার চেষ্টা করুন।'
            : 'Error processing image. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
          _activeSource = null;
        });
      }
    }
  }

  int tryGetFileSize(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) return file.lengthSync();
    } catch (_) {}
    return 1024;
  }

  void _showReplaceBottomSheet(bool isBn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isBn ? 'নতুন ছবি বেছে নিন' : 'Choose Replacement Photo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.forestGreen),
                title: Text(isBn ? 'ক্যামেরা দিয়ে নতুন ছবি তুলুন' : 'Take new photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (widget.imagePicker != null) {
                    _handlePickImage(ImageSource.camera);
                  } else {
                    ref.read(selectedImageProvider.notifier).captureImage();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.forestGreen),
                title: Text(isBn ? 'গ্যালারি থেকে নির্বাচন করুন' : 'Select from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (widget.imagePicker != null) {
                    _handlePickImage(ImageSource.gallery);
                  } else {
                    ref.read(selectedImageProvider.notifier).selectFromGallery();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final selectedCrop = ref.watch(selectedCropProvider);
    final selectedImageState = ref.watch(selectedImageProvider);

    // Listen for selection errors and display floating SnackBar
    ref.listen<SelectedImageState>(selectedImageProvider, (prev, next) {
      if (next.hasError && next.getErrorMessage(isBn) != null) {
        _showErrorSnackBar(next.getErrorMessage(isBn)!);
      }
    });

    final hasValidImage = selectedImageState.hasImage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Heading, Subtitle, Back button)
              DetectionScreenHeader(isBn: isBn),

              // 2. Selected Crop Context Bar (Preserves selected crop context)
              SelectedCropContextBar(
                selectedCrop: selectedCrop,
                isBn: isBn,
              ),

              // 3. Central AI Scanning Illustration
              AiScanningIllustration(
                isBn: isBn,
                animate: widget.animateIllustration,
              ),

              const SizedBox(height: 12),

              // 4. If image is selected, show ActiveSelectedImageCard
              if (hasValidImage) ...[
                ActiveSelectedImageCard(
                  image: selectedImageState.selectedImage!,
                  isBn: isBn,
                  onReplace: () => _showReplaceBottomSheet(isBn),
                  onRemove: () {
                    ref.read(selectedImageProvider.notifier).clearSelection();
                  },
                  onContinue: () {
                    try {
                      context.push('/detect/preview');
                    } catch (_) {}
                  },
                ),
              ] else ...[
                // 5. Primary Action Card 1 – Take Photo (Camera)
                DetectionActionCard(
                  title: isBn ? 'ছবি তুলুন' : 'Take Photo',
                  description: isBn
                      ? 'আপনার ক্যামেরা দিয়ে পাতার স্পষ্ট ছবি তুলুন।'
                      : 'Capture a leaf photo using your camera.',
                  icon: Icons.camera_alt_rounded,
                  isPrimary: true,
                  isLoading: _isPickingImage && _activeSource == ImageSource.camera,
                  onTap: _isPickingImage
                      ? null
                      : () {
                          if (widget.imagePicker != null) {
                            _handlePickImage(ImageSource.camera);
                          } else {
                            context.push('/detect/camera');
                          }
                        },
                  isBn: isBn,
                ),

                // 6. Primary Action Card 2 – Choose from Gallery
                DetectionActionCard(
                  title: isBn ? 'গ্যালারি থেকে নির্বাচন' : 'Choose from Gallery',
                  description: isBn
                      ? 'ডিভাইস থেকে বিদ্যমান পাতার ছবি বেছে নিন।'
                      : 'Select an existing leaf photo from your device.',
                  icon: Icons.photo_library_outlined,
                  isPrimary: false,
                  isLoading: _isPickingImage && _activeSource == ImageSource.gallery,
                  onTap: _isPickingImage
                      ? null
                      : () {
                          if (widget.imagePicker != null) {
                            _handlePickImage(ImageSource.gallery);
                          } else {
                            context.push('/detect/gallery');
                          }
                        },
                  isBn: isBn,
                ),
              ],

              const SizedBox(height: 10),

              // 7. Image Quality Guide (4 Tips with Icons)
              ImageQualityGuide(isBn: isBn),

              const SizedBox(height: 6),

              // 8. Offline AI Availability Indicator
              OfflineAiStatusIndicator(isBn: isBn),
            ],
          ),
        ),
      ),
    );
  }
}
