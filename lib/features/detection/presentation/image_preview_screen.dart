import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/preview/analyze_image_button.dart';
import 'widgets/preview/image_preview_actions.dart';
import 'widgets/preview/image_preview_error_state.dart';
import 'widgets/preview/image_preview_header.dart';
import 'widgets/preview/image_quality_status.dart';
import 'widgets/preview/image_review_instruction.dart';
import 'widgets/preview/selected_crop_info.dart';
import 'widgets/preview/selected_leaf_image.dart';

/// Screen 14 – Image Preview Screen for AgriCare AI (LeafAgro)
/// Allows farmers to review their selected plant leaf photo, inspect quality status,
/// confirm crop context, and initiate offline AI disease analysis.
class ImagePreviewScreen extends ConsumerStatefulWidget {
  final String? initialImagePath;
  final ImagePicker? imagePicker;

  const ImagePreviewScreen({
    super.key,
    this.initialImagePath,
    this.imagePicker,
  });

  @override
  ConsumerState<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends ConsumerState<ImagePreviewScreen> {
  QualityState _qualityState = QualityState.checking;
  String? _qualityMessage;
  final AnalyzeButtonState _analyzeState = AnalyzeButtonState.ready;
  late final ImagePicker _picker;

  @override
  void initState() {
    super.initState();
    _picker = widget.imagePicker ?? ImagePicker();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialImagePath != null &&
          widget.initialImagePath!.isNotEmpty) {
        ref
            .read(detectionProvider.notifier)
            .selectImage(widget.initialImagePath!);
      }
      _validateCurrentImage();
    });
  }

  void _validateCurrentImage() {
    final imagePath = ref.read(detectionProvider).imagePath;
    final isBn = ref.read(settingsProvider).language == 'bn';

    if (imagePath == null || imagePath.isEmpty) {
      setState(() {
        _qualityState = QualityState.error;
        _qualityMessage =
            isBn ? 'কোনো ছবি পাওয়া যায়নি।' : 'No image file found.';
      });
      return;
    }

    if (kIsWeb) {
      setState(() {
        _qualityState = QualityState.ready;
        _qualityMessage = isBn
            ? 'ছবি বিশ্লেষণের জন্য প্রস্তুত।'
            : 'Image ready for analysis.';
      });
      return;
    }

    try {
      final file = File(imagePath);
      if (!file.existsSync() || file.lengthSync() == 0) {
        setState(() {
          _qualityState = QualityState.error;
          _qualityMessage = isBn
              ? 'ফাইলটি নষ্ট বা খালি। নতুন ছবি নির্বাচন করুন।'
              : 'File is missing or empty. Please select another image.';
        });
        return;
      }

      final fileSize = file.lengthSync();
      if (fileSize > 15 * 1024 * 1024) {
        setState(() {
          _qualityState = QualityState.warning;
          _qualityMessage = isBn
              ? 'ছবির আকার ১৫MB এর বেশি। প্রক্রিয়াকরণে অতিরিক্ত সময় লাগতে পারে।'
              : 'File size exceeds 15MB. Preprocessing may take longer.';
        });
        return;
      }

      setState(() {
        _qualityState = QualityState.ready;
        _qualityMessage = isBn
            ? 'ছবিটি স্পষ্ট ও রোগ নির্ণয়ের জন্য প্রস্তুত।'
            : 'Image verified and ready for AI analysis.';
      });
    } catch (_) {
      setState(() {
        _qualityState = QualityState.ready;
      });
    }
  }

  Future<void> _handleRetakePhoto() async {
    if (_analyzeState == AnalyzeButtonState.analyzing) return;

    if (widget.imagePicker != null) {
      try {
        final picked = await _picker.pickImage(source: ImageSource.camera);
        if (picked != null) {
          ref.read(detectionProvider.notifier).selectImage(picked.path);
          _validateCurrentImage();
        }
      } catch (_) {}
      return;
    }

    try {
      context.push('/detect/camera');
    } catch (_) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleChooseAnotherImage() async {
    if (_analyzeState == AnalyzeButtonState.analyzing) return;

    if (widget.imagePicker != null) {
      try {
        final picked = await _picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          ref.read(detectionProvider.notifier).selectImage(picked.path);
          _validateCurrentImage();
        }
      } catch (_) {}
      return;
    }

    try {
      context.push('/detect/gallery');
    } catch (_) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleAnalyze() async {
    final imagePath = ref.read(detectionProvider).imagePath;
    final isBn = ref.read(settingsProvider).language == 'bn';

    if (imagePath == null || _qualityState == QualityState.error) {
      _showErrorSnackBar(
        isBn
            ? 'দয়া করে বিশ্লেষণের পূর্বে একটি বৈধ ছবি নির্বাচন করুন।'
            : 'Please select a valid image before running analysis.',
      );
      return;
    }

    try {
      context.push('/detect/analyzing');
    } catch (_) {
      // In test environments without GoRouter host, run detection directly
      await ref.read(detectionProvider.notifier).runDetection();
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
    final detectionState = ref.watch(detectionProvider);
    final selectedCrop = ref.watch(selectedCropProvider);
    final imagePath = detectionState.imagePath;

    final isBusy = _analyzeState == AnalyzeButtonState.analyzing;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: imagePath == null || imagePath.isEmpty
            ? ImagePreviewErrorState(
                title:
                    isBn ? 'কোনো ছবি নির্বাচন করা হয়নি' : 'No Image Selected',
                description: isBn
                    ? 'গাছের পাতার রোগ নির্ণয় করতে ক্যামেরা দিয়ে ছবি তুলুন বা গ্যালারি থেকে নির্বাচন করুন।'
                    : 'To diagnose crop diseases, capture a leaf photo or pick an existing image from your device.',
                onPickCamera: _handleRetakePhoto,
                onPickGallery: _handleChooseAnotherImage,
                isBn: isBn,
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header (Back button, Title, Subtitle)
                    ImagePreviewHeader(
                      isBn: isBn,
                    ),

                    // 2. Selected Crop Information (if crop was selected)
                    SelectedCropInfo(
                      selectedCrop: selectedCrop,
                      isBn: isBn,
                    ),

                    // 3. Large Selected Leaf Photograph
                    SelectedLeafImage(
                      imagePath: imagePath,
                      isBn: isBn,
                    ),

                    // 4. Image Quality Status Banner
                    ImageQualityStatus(
                      state: _qualityState,
                      customMessage: _qualityMessage,
                      isBn: isBn,
                    ),

                    // 5. Image Review Instruction Box
                    ImageReviewInstruction(isBn: isBn),

                    const SizedBox(height: 6),

                    // 6. Action Options (Retake Photo & Choose Another Image)
                    ImagePreviewActions(
                      onRetakePhoto: _handleRetakePhoto,
                      onChooseAnotherImage: _handleChooseAnotherImage,
                      isBusy: isBusy,
                      isBn: isBn,
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: imagePath != null && imagePath.isNotEmpty
          ? AnalyzeImageButton(
              onAnalyze:
                  _qualityState != QualityState.error ? _handleAnalyze : null,
              state: _analyzeState,
              isBn: isBn,
            )
          : null,
    );
  }
}
