import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/ai_crop_catalog.dart';
import '../../../data/models/crop_model.dart';
import '../../../data/models/plant_observation_model.dart';
import '../../../data/models/prediction_history_model.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/observation_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/follow_up_reminder_card.dart';
import 'widgets/follow_up_suggestions_section.dart';
import 'widgets/latest_observation_card.dart';
import 'widgets/observation_timeline_section.dart';
import 'widgets/original_detection_card.dart';
import 'widgets/record_observation_card.dart';
import 'widgets/recovery_disclaimer_card.dart';
import 'widgets/recovery_header.dart';
import 'widgets/scan_again_section.dart';

/// Screen 21 – Plant Recovery & Follow-up Screen
/// A farmer-friendly plant monitoring and observation journal.
/// Helps farmers revisit previous AI disease detections, record visible field changes,
/// track inspection milestones, and decide when to scan their plants again.
///
/// Strictly authentic:
/// Never fabricates recovery status, cure guarantees, or upward recovery graphs.
/// Fully distinguishes initial AI predictions from farmer self-reported notes.
class RecoveryScreen extends ConsumerStatefulWidget {
  final String? scanId;
  final PredictionHistoryModel? initialScan;
  final List<PlantObservationModel>? initialObservations;

  const RecoveryScreen({
    super.key,
    this.scanId,
    this.initialScan,
    this.initialObservations,
  });

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  DateTime? _reminderDate;
  bool _isLoadingReminder = true;

  @override
  void initState() {
    super.initState();
    _loadStoredReminder();
  }

  Future<void> _loadStoredReminder() async {
    final effectiveId = widget.scanId ?? widget.initialScan?.id;
    if (effectiveId != null) {
      final date =
          await ObservationNotifier.getInspectionReminder(effectiveId);
      if (mounted) {
        setState(() {
          _reminderDate = date;
          _isLoadingReminder = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingReminder = false;
        });
      }
    }
  }

  Future<void> _handleReminderChanged(
      String effectiveScanId, DateTime? newDate) async {
    setState(() {
      _reminderDate = newDate;
    });

    if (newDate != null) {
      await ObservationNotifier.saveInspectionReminder(
          effectiveScanId, newDate);
    } else {
      await ObservationNotifier.clearInspectionReminder(effectiveScanId);
    }
  }

  CropModel? _resolveCrop(String cropName) {
    try {
      final normalized = cropName.toLowerCase().trim();
      return AiCropCatalog.verifiedSupportedCrops.firstWhere(
        (c) =>
            c.nameEn.toLowerCase() == normalized ||
            c.nameBn.toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';

    // 1. Resolve Target Scan
    final historyAsync = ref.watch(historyProvider);

    PredictionHistoryModel? targetScan = widget.initialScan;
    if (targetScan == null && historyAsync.hasValue) {
      final list = historyAsync.value ?? [];
      if (widget.scanId != null && widget.scanId!.isNotEmpty) {
        try {
          targetScan = list.firstWhere((s) => s.id == widget.scanId);
        } catch (_) {
          targetScan = list.isNotEmpty ? list.first : null;
        }
      } else if (list.isNotEmpty) {
        targetScan = list.first;
      }
    }

    final effectiveScanId = targetScan?.id ?? widget.scanId ?? 'default_scan';

    // 2. Resolve Crop Model for Scan Again Context
    CropModel? crop;
    if (targetScan != null) {
      final parts = targetScan.predictedClass.split('___');
      crop = _resolveCrop(parts[0]);
    }

    // 3. Resolve Observations
    List<PlantObservationModel> observations = [];
    if (widget.initialObservations != null) {
      observations = widget.initialObservations!;
    } else {
      final obsAsync =
          ref.watch(observationNotifierProvider(effectiveScanId));
      observations = obsAsync.valueOrNull ?? [];
    }

    final latestObservation =
        observations.isNotEmpty ? observations.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RecoveryHeader(isBn: isBn),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // 1. Original Detection Summary Card
              OriginalDetectionCard(
                scan: targetScan,
                isBn: isBn,
              ),

              // 2. Latest Farmer Observation Summary
              LatestObservationCard(
                observation: latestObservation,
                isBn: isBn,
              ),

              // 3. Follow-up Inspection Suggestions (5 Topics)
              FollowUpSuggestionsSection(isBn: isBn),

              // 4. Time to Check Plant Again? Reminder Card
              FollowUpReminderCard(
                reminderDate: _reminderDate,
                isBn: isBn,
                onReminderChanged: (newDate) =>
                    _handleReminderChanged(effectiveScanId, newDate),
              ),

              // 5. Record Farmer Observation Journal Note
              RecordObservationCard(
                isBn: isBn,
                onSave: ({
                  required String notes,
                  required FarmerConditionLabel condition,
                  DateTime? inspectionDate,
                }) async {
                  await ref
                      .read(
                          observationNotifierProvider(effectiveScanId).notifier)
                      .addObservation(
                        notes: notes,
                        condition: condition,
                        cropName: targetScan?.predictedClass.split('___').first,
                        nextInspectionDate: _reminderDate,
                      );
                },
              ),

              // 6. Chronological Observation Timeline
              ObservationTimelineSection(
                originalScan: targetScan,
                observations: observations,
                isBn: isBn,
              ),

              // 7. Neutral Scientific Monitoring Disclaimer Card
              RecoveryDisclaimerCard(isBn: isBn),

              const SizedBox(height: 4),

              // 8. Prominent Primary "Scan Again" Button
              ScanAgainSection(
                isBn: isBn,
                crop: crop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

