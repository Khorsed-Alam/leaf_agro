import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../data/help_content.dart';
import 'widgets/contact_support_card.dart';
import 'widgets/empty_help_search_state.dart';
import 'widgets/faq_accordion_card.dart';
import 'widgets/guide_detail_dialog.dart';
import 'widgets/help_header.dart';
import 'widgets/help_search_bar.dart';
import 'widgets/quick_guide_card.dart';

/// Screen 28: Help & FAQ Screen — AgriCare AI (LeafAgro)
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    final isSearching = _searchQuery.isNotEmpty;

    // Filter Guides & FAQs based on query
    final filteredGuides = isSearching
        ? HelpContent.guides.where((g) => g.matchesQuery(_searchQuery)).toList()
        : HelpContent.guides;

    final filteredFaqs = isSearching
        ? HelpContent.faqs.where((f) => f.matchesQuery(_searchQuery)).toList()
        : HelpContent.faqs;

    final hasNoResults =
        isSearching && filteredGuides.isEmpty && filteredFaqs.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1 & 2. Back Navigation & Welcoming Header Banner
              HelpHeader(isBn: isBn),
              const SizedBox(height: 16),

              // 3. Search Help Field
              HelpSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
                isBn: isBn,
              ),
              const SizedBox(height: 20),

              // Empty Search State
              if (hasNoResults) ...[
                EmptyHelpSearchState(
                  isBn: isBn,
                  onClear: _clearSearch,
                ),
                const SizedBox(height: 24),
              ],

              // 4 & 5. Quick Help Guides Section
              if (filteredGuides.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isBn ? 'সহজ সহায়িকা নির্দেশিকা' : 'Quick Help Guides',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${filteredGuides.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isBn
                      ? 'এগ্রিকেয়ার এআই-এর মূল বৈশিষ্ট্যসমূহ ব্যবহারের নিয়ম জানুন।'
                      : 'Learn how to use the main features of AgriCare AI.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),

                // Guide Cards
                ...filteredGuides.map((guide) {
                  return QuickGuideCard(
                    guide: guide,
                    isBn: isBn,
                    onTap: () =>
                        GuideDetailBottomSheet.show(context, guide, isBn),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // 6 & 7. Frequently Asked Questions Section
              if (filteredFaqs.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isBn
                          ? 'সাধারণ জিজ্ঞাসা ও উত্তর'
                          : 'Frequently Asked Questions',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${filteredFaqs.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isBn
                      ? 'সচরাচর জানতে চাওয়া প্রশ্নের সহজ উত্তর খুঁজুন।'
                      : 'Find answers to common questions.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),

                // FAQ Accordion Cards (auto-expand during search so answers are visible)
                ...filteredFaqs.map((faq) {
                  return FaqAccordionCard(
                    key: ValueKey('${faq.id}_$isSearching'),
                    faq: faq,
                    isBn: isBn,
                    initiallyExpanded: isSearching,
                  );
                }),
                const SizedBox(height: 20),
              ],

              // 8. Contact Support & Feedback Section
              ContactSupportCard(isBn: isBn),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
