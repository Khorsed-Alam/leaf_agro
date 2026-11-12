import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';
import 'crop_selection_indicator.dart';

class CropSelectionCard extends StatefulWidget {
  final CropModel crop;
  final bool isSelected;
  final bool isBn;
  final VoidCallback onTap;

  const CropSelectionCard({
    super.key,
    required this.crop,
    required this.isSelected,
    required this.isBn,
    required this.onTap,
  });

  @override
  State<CropSelectionCard> createState() => _CropSelectionCardState();
}

class _CropSelectionCardState extends State<CropSelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryName = widget.isBn ? widget.crop.nameBn : widget.crop.nameEn;
    final secondaryName = widget.isBn ? widget.crop.nameEn : widget.crop.nameBn;
    final diseaseCount = widget.crop.supportedDiseaseCount;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? AppColors.freshGreen : AppColors.borderGreen,
              width: widget.isSelected ? 2.4 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppColors.freshGreen.withOpacity(0.18)
                    : Colors.black.withOpacity(0.04),
                blurRadius: widget.isSelected ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Image Area with Top-Right Indicator & AI Tag
              Expanded(
                flex: 11,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: widget.crop.imageUrl != null && widget.crop.imageUrl!.isNotEmpty
                          ? Image.network(
                              widget.crop.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: AppColors.softNaturalGreen,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.forestGreen,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),

                    // Top Gradient Sheen for high contrast indicators
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 38,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.28),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top-Left AI Model Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.limeGreen.withOpacity(0.6), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.limeGreen, size: 10),
                            SizedBox(width: 4),
                            Text(
                              'AI Ready',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top-Right Check Circle Indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CropSelectionIndicator(isSelected: widget.isSelected),
                    ),
                  ],
                ),
              ),

              // Bottom Content Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            primaryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: widget.isSelected
                                  ? AppColors.forestGreen
                                  : AppColors.primaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          secondaryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.bug_report_outlined,
                          size: 11,
                          color: AppColors.forestGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.isBn
                              ? '$diseaseCountটি রোগ নির্ণয়'
                              : '$diseaseCount diseases supported',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.softNaturalGreen,
      child: const Center(
        child: Icon(
          Icons.grass_rounded,
          size: 40,
          color: AppColors.forestGreen,
        ),
      ),
    );
  }
}
