import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/help_models.dart';

/// Screen 28 – FAQ Accordion Card
class FaqAccordionCard extends StatefulWidget {
  final FaqItem faq;
  final bool isBn;
  final bool initiallyExpanded;

  const FaqAccordionCard({
    super.key,
    required this.faq,
    required this.isBn,
    this.initiallyExpanded = false,
  });

  @override
  State<FaqAccordionCard> createState() => _FaqAccordionCardState();
}

class _FaqAccordionCardState extends State<FaqAccordionCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant FaqAccordionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? AppColors.forestGreen : AppColors.borderGreen,
          width: _isExpanded ? 1.3 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _toggle,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _isExpanded
                            ? AppColors.forestGreen
                            : AppColors.softNaturalGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderGreen,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _isExpanded
                                ? Colors.white
                                : AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.faq.question(widget.isBn),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _isExpanded
                              ? AppColors.forestGreen
                              : AppColors.primaryText,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _isExpanded
                            ? AppColors.forestGreen
                            : AppColors.secondaryText,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                // Expanded Answer View
                if (_isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 34.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(
                          height: 1,
                          thickness: 0.8,
                          color: AppColors.borderGreen,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.faq.answer(widget.isBn),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryText,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
