import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/camera/camera_bottom_controls.dart';
import 'widgets/camera/camera_error_state.dart';
import 'widgets/camera/camera_loading_state.dart';
import 'widgets/camera/camera_permission_state.dart';
import 'widgets/camera/camera_top_controls.dart';
import 'widgets/camera/leaf_positioning_guide.dart';

/// Screen 12 – Camera Capture Screen for AgriCare AI (LeafAgro)
/// Full-screen live camera viewfinder optimized for farmers capturing leaf samples.
class CameraScreen extends ConsumerStatefulWidget {
  final List<CameraDescription>? cameras;
  final CameraController? controller;
  final ImagePicker? imagePicker;
  final bool autoInitialize;

  const CameraScreen({
    super.key,
    this.cameras,
    this.controller,
    this.imagePicker,
    this.autoInitialize = true,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;
  FlashMode _currentFlashMode = FlashMode.off;

  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _hasPermission = true;
  bool _isPermanentlyDenied = false;
  String? _errorMessage;

  late final ImagePicker _picker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _picker = widget.imagePicker ?? ImagePicker();

    if (widget.controller != null) {
      _controller = widget.controller;
      _isInitializing = false;
      _hasPermission = true;
    } else if (widget.autoInitialize) {
      _initCamera();
    } else {
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Only dispose if we own the controller (not injected from outside)
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // Do nothing if controller is not present or uninitialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (widget.controller == null) {
        cameraController.dispose();
        _controller = null;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (widget.controller == null) {
        _initCamera();
      }
    }
  }

  Future<void> _initCamera([int? targetIndex]) async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
      _hasPermission = true;
      _isPermanentlyDenied = false;
    });

    try {
      if (widget.cameras != null) {
        _availableCameras = widget.cameras!;
      } else {
        _availableCameras = await availableCameras();
      }

      if (_availableCameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = ref.read(settingsProvider).language == 'bn'
              ? 'ডিভাইসে কোনো ক্যামেরা পাওয়া যায়নি।'
              : 'No camera hardware found on this device.';
        });
        return;
      }

      // Default to rear camera if not specifically selected
      if (targetIndex != null &&
          targetIndex >= 0 &&
          targetIndex < _availableCameras.length) {
        _selectedCameraIndex = targetIndex;
      } else {
        final backIndex = _availableCameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        _selectedCameraIndex = backIndex != -1 ? backIndex : 0;
      }

      final cameraDesc = _availableCameras[_selectedCameraIndex];
      final newController = CameraController(
        cameraDesc,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await newController.initialize();

      // Configure default flash mode
      try {
        await newController.setFlashMode(_currentFlashMode);
      } catch (_) {
        // Flash might not be supported on this lens
      }

      if (!mounted) {
        await newController.dispose();
        return;
      }

      setState(() {
        _controller = newController;
        _isInitializing = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted') {
        setState(() {
          _isInitializing = false;
          _hasPermission = false;
          _isPermanentlyDenied = e.code == 'CameraAccessDeniedWithoutPrompt';
        });
      } else {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.description ?? 'Camera error';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleFlashModeChanged(FlashMode mode) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.setFlashMode(mode);
      setState(() {
        _currentFlashMode = mode;
      });
    } catch (_) {
      // Ignore unsupported flash mode exceptions gracefully
    }
  }

  Future<void> _handleSwitchCamera() async {
    if (_availableCameras.length < 2 || _isCapturing) return;

    final nextIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
    await _controller?.dispose();
    _controller = null;
    await _initCamera(nextIndex);
  }

  bool _validateCapturedFile(String path, bool isBn) {
    try {
      final file = File(path);
      if (!file.existsSync() || file.lengthSync() == 0) {
        _showErrorSnackBar(
          isBn
              ? 'ছবি ধারণ করা সম্ভব হয়নি। অনুগ্রহ করে আবার চেষ্টা করুন।'
              : 'Failed to capture image. Please try again.',
        );
        return false;
      }
      return true;
    } catch (_) {
      // In platforms or sandboxes where File(path) is not directly accessible
      return path.isNotEmpty;
    }
  }

  Future<void> _handleCapturePhoto() async {
    final isBn = ref.read(settingsProvider).language == 'bn';

    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile imageFile = await _controller!.takePicture();

      if (!mounted) return;

      final isValid = _validateCapturedFile(imageFile.path, isBn);
      if (!isValid) return;

      // Update detection state
      ref.read(detectionProvider.notifier).selectImage(imageFile.path);

      // Navigate to Image Preview screen
      if (mounted) {
        try {
          context.push('/detect/preview');
        } catch (_) {
          // In test environments without GoRouter host
        }
      }
    } on CameraException catch (e) {
      _showErrorSnackBar(
        isBn
            ? 'ছবি তুলতে সমস্যা হয়েছে: ${e.description ?? "আবার চেষ্টা করুন"}'
            : 'Error capturing photo: ${e.description ?? "Please try again"}',
      );
    } catch (e) {
      _showErrorSnackBar(
        isBn
            ? 'ছবি প্রক্রিয়া করতে ব্যর্থ হয়েছে। আবার চেষ্টা করুন।'
            : 'Could not process captured image. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _handleOpenGallery() async {
    if (_isCapturing) return;

    final isBn = ref.read(settingsProvider).language == 'bn';

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (picked == null || !mounted) return;

      final isValid = _validateCapturedFile(picked.path, isBn);
      if (!isValid) return;

      ref.read(detectionProvider.notifier).selectImage(picked.path);

      if (mounted) {
        try {
          context.push('/detect/preview');
        } catch (_) {}
      }
    } on PlatformException catch (e) {
      _showErrorSnackBar(
        isBn
            ? 'গ্যালারি খুলতে অনুমতি প্রয়োজন: ${e.message ?? ""}'
            : 'Gallery access error: ${e.message ?? ""}',
      );
    } catch (e) {
      _showErrorSnackBar(
        isBn
            ? 'ছবি লোড করতে সমস্যা হয়েছে।'
            : 'Failed to pick image from gallery.',
      );
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

  void _handleClose() {
    try {
      context.pop();
    } catch (_) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final selectedCrop = ref.watch(selectedCropProvider);
    final cropName = selectedCrop != null
        ? (isBn ? selectedCrop.nameBn : selectedCrop.nameEn)
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Viewfinder or Fallback State
          if (!_hasPermission)
            CameraPermissionState(
              onRequestPermission: () => _initCamera(),
              onOpenGallery: _handleOpenGallery,
              onClose: _handleClose,
              isPermanentlyDenied: _isPermanentlyDenied,
              isBn: isBn,
            )
          else if (_errorMessage != null)
            CameraErrorState(
              errorMessage: _errorMessage!,
              onRetry: () => _initCamera(),
              onOpenGallery: _handleOpenGallery,
              onClose: _handleClose,
              isBn: isBn,
            )
          else if (_isInitializing ||
              _controller == null ||
              !_controller!.value.isInitialized)
            CameraLoadingState(isBn: isBn)
          else
            _buildCameraPreview(),

          // 2. Leaf Viewfinder Guide (Only visible when camera is ready)
          if (_hasPermission &&
              _errorMessage == null &&
              !_isInitializing &&
              _controller != null &&
              _controller!.value.isInitialized)
            LeafPositioningGuide(isBn: isBn),

          // 3. Top Controls (Close, Crop badge, Flash toggle)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CameraTopControls(
              onClose: _handleClose,
              flashMode: _currentFlashMode,
              hasFlash: _controller?.value.isInitialized == true,
              onFlashModeChanged: _handleFlashModeChanged,
              selectedCropName: cropName,
              isBn: isBn,
            ),
          ),

          // 4. Bottom Controls (Gallery, Shutter, Switch Camera)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CameraBottomControls(
              onCapture:
                  (_controller != null && _controller!.value.isInitialized)
                      ? _handleCapturePhoto
                      : null,
              onOpenGallery: _handleOpenGallery,
              onSwitchCamera:
                  _availableCameras.length > 1 ? _handleSwitchCamera : null,
              isCapturing: _isCapturing,
              hasMultipleCameras: _availableCameras.length > 1,
              isBn: isBn,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final previewAspect = _controller!.value.aspectRatio;

        // In portrait mode, camera preview aspect ratio is typically height/width (> 1)
        var scale = size.aspectRatio * previewAspect;
        if (scale < 1) scale = 1 / scale;

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),
        );
      },
    );
  }
}
