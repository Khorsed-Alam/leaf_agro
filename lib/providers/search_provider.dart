import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/crop_model.dart';
import '../data/models/disease_model.dart';
import 'crop_provider.dart';
import 'disease_provider.dart';
import 'settings_provider.dart';

// ── Search State ─────────────────────────────────────────────────────────────

class GlobalSearchState {
  final String query;
  final bool isLoading;
  final List<CropModel> matchedCrops;
  final List<DiseaseModel> matchedDiseases;
  final String? errorMessage;

  const GlobalSearchState({
    this.query = '',
    this.isLoading = false,
    this.matchedCrops = const [],
    this.matchedDiseases = const [],
    this.errorMessage,
  });

  bool get isEmpty => query.trim().isEmpty;
  bool get hasResults => matchedCrops.isNotEmpty || matchedDiseases.isNotEmpty;
  bool get hasNoResults => !isEmpty && !isLoading && !hasResults;
  int get totalResultCount => matchedCrops.length + matchedDiseases.length;

  GlobalSearchState copyWith({
    String? query,
    bool? isLoading,
    List<CropModel>? matchedCrops,
    List<DiseaseModel>? matchedDiseases,
    String? errorMessage,
  }) {
    return GlobalSearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      matchedCrops: matchedCrops ?? this.matchedCrops,
      matchedDiseases: matchedDiseases ?? this.matchedDiseases,
      errorMessage: errorMessage,
    );
  }
}

// ── Recent Searches Notifier ──────────────────────────────────────────────────

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  static const String _keyRecent = 'recent_search_history';
  static const int _maxRecent = 8;
  final SharedPreferences? _prefs;

  RecentSearchesNotifier(this._prefs)
      : super(_prefs?.getStringList(_keyRecent) ?? []);

  Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final updated = List<String>.from(state);
    updated.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    updated.insert(0, trimmed);

    if (updated.length > _maxRecent) {
      updated.removeRange(_maxRecent, updated.length);
    }

    state = updated;
    await _prefs?.setStringList(_keyRecent, updated);
  }

  Future<void> removeSearch(String query) async {
    final updated = List<String>.from(state)..remove(query);
    state = updated;
    await _prefs?.setStringList(_keyRecent, updated);
  }

  Future<void> clearAll() async {
    state = [];
    await _prefs?.remove(_keyRecent);
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPreferencesProvider);
  } catch (_) {
    prefs = null;
  }
  return RecentSearchesNotifier(prefs);
});

// ── Global Search Notifier ────────────────────────────────────────────────────

class GlobalSearchNotifier extends StateNotifier<GlobalSearchState> {
  final Ref _ref;
  Timer? _debounceTimer;

  GlobalSearchNotifier(this._ref) : super(const GlobalSearchState());

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      state = const GlobalSearchState();
      return;
    }

    // Indicate loading while waiting for debounce
    state = state.copyWith(query: query, isLoading: true, errorMessage: null);

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      executeSearch(trimmed);
    });
  }

  Future<void> executeSearch(String rawQuery) async {
    _debounceTimer?.cancel();
    final query = rawQuery.trim().toLowerCase();

    if (query.isEmpty) {
      state = const GlobalSearchState();
      return;
    }

    state = state.copyWith(query: rawQuery, isLoading: true, errorMessage: null);

    try {
      // 1. Fetch available crops and diseases from existing providers
      final cropsAsync = await _ref.read(cropProvider.future);
      final diseasesAsync = await _ref.read(allDiseasesProvider.future);

      // 2. Perform robust partial-text matching on Crops
      final matchedCrops = cropsAsync.where((crop) {
        final nameEn = crop.nameEn.toLowerCase();
        final nameBn = crop.nameBn.toLowerCase();
        final descEn = crop.descriptionEn.toLowerCase();
        final descBn = crop.descriptionBn.toLowerCase();

        return nameEn.contains(query) ||
            nameBn.contains(query) ||
            descEn.contains(query) ||
            descBn.contains(query);
      }).toList();

      // 3. Perform robust partial-text matching on Diseases
      final matchedDiseases = diseasesAsync.where((disease) {
        final dNameEn = disease.diseaseNameEn.toLowerCase();
        final dNameBn = disease.diseaseNameBn.toLowerCase();
        final sEn = disease.symptomsEn.toLowerCase();
        final sBn = disease.symptomsBn.toLowerCase();

        // Match associated crop name if available
        final crop = cropsAsync.cast<CropModel?>().firstWhere(
              (c) => c?.id == disease.cropId,
              orElse: () => null,
            );
        final cNameEn = crop?.nameEn.toLowerCase() ?? '';
        final cNameBn = crop?.nameBn.toLowerCase() ?? '';

        return dNameEn.contains(query) ||
            dNameBn.contains(query) ||
            sEn.contains(query) ||
            sBn.contains(query) ||
            cNameEn.contains(query) ||
            cNameBn.contains(query);
      }).toList();

      state = state.copyWith(
        query: rawQuery,
        isLoading: false,
        matchedCrops: matchedCrops,
        matchedDiseases: matchedDiseases,
      );

      // Add to recent searches when query produces matches
      if (matchedCrops.isNotEmpty || matchedDiseases.isNotEmpty) {
        _ref.read(recentSearchesProvider.notifier).addSearch(rawQuery.trim());
      }
    } catch (e) {
      state = state.copyWith(
        query: rawQuery,
        isLoading: false,
        errorMessage: 'Failed to search: $e',
      );
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = const GlobalSearchState();
  }
}

final globalSearchProvider =
    StateNotifierProvider<GlobalSearchNotifier, GlobalSearchState>((ref) {
  return GlobalSearchNotifier(ref);
});

// ── Search Suggestions Provider ───────────────────────────────────────────────

final searchSuggestionsProvider = Provider<List<String>>((ref) {
  final isBn = ref.watch(settingsProvider).language == 'bn';
  if (isBn) {
    return [
      'ধান',
      'আলু',
      'নাবী ধসা রোগ',
      'টমেটো',
      'আম',
      'বাদামী দাগ রোগ',
      'পাট',
      'ব্যাকটেরিয়াল লিফ ব্লাইট',
    ];
  }
  return [
    'Rice',
    'Late Blight',
    'Potato',
    'Bacterial Leaf Blight',
    'Tomato',
    'Brown Spot',
    'Mango',
    'Anthracnose',
  ];
});

