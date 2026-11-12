import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;

class LeafImageView extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LeafImageView({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (imagePath.startsWith('http') || imagePath.startsWith('blob:')) {
        return Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
      return _buildPlaceholder();
    }

    try {
      final file = io.File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
    } catch (_) {}

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.eco, size: 48, color: Color(0xFF006030)),
      ),
    );
  }
}
