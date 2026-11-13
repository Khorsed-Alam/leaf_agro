import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Condition labels self-reported by the farmer.
/// These represent visual farmer observations and are NEVER automated AI conclusions.
enum FarmerConditionLabel {
  lookingBetter,
  noNoticeableChange,
  lookingWorse,
  notSure;

  String get key {
    switch (this) {
      case FarmerConditionLabel.lookingBetter:
        return 'better';
      case FarmerConditionLabel.noNoticeableChange:
        return 'no_change';
      case FarmerConditionLabel.lookingWorse:
        return 'worse';
      case FarmerConditionLabel.notSure:
        return 'not_sure';
    }
  }

  static FarmerConditionLabel fromKey(String? key) {
    switch (key) {
      case 'better':
      case 'looking_better':
        return FarmerConditionLabel.lookingBetter;
      case 'worse':
      case 'looking_worse':
        return FarmerConditionLabel.lookingWorse;
      case 'not_sure':
        return FarmerConditionLabel.notSure;
      case 'no_change':
      case 'no_noticeable_change':
      default:
        return FarmerConditionLabel.noNoticeableChange;
    }
  }

  String labelEn() {
    switch (this) {
      case FarmerConditionLabel.lookingBetter:
        return 'Looking Better';
      case FarmerConditionLabel.noNoticeableChange:
        return 'No Noticeable Change';
      case FarmerConditionLabel.lookingWorse:
        return 'Looking Worse';
      case FarmerConditionLabel.notSure:
        return 'Not Sure';
    }
  }

  String labelBn() {
    switch (this) {
      case FarmerConditionLabel.lookingBetter:
        return 'উন্নত হচ্ছে';
      case FarmerConditionLabel.noNoticeableChange:
        return 'কোনো দৃশ্যমান পরিবর্তন নেই';
      case FarmerConditionLabel.lookingWorse:
        return 'অবনতি হচ্ছে';
      case FarmerConditionLabel.notSure:
        return 'নিশ্চিত নই';
    }
  }

  Color get color {
    switch (this) {
      case FarmerConditionLabel.lookingBetter:
        return AppColors.forestGreen;
      case FarmerConditionLabel.noNoticeableChange:
        return const Color(0xFF2563EB); // Blue
      case FarmerConditionLabel.lookingWorse:
        return AppColors.error;
      case FarmerConditionLabel.notSure:
        return AppColors.secondaryText;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case FarmerConditionLabel.lookingBetter:
        return AppColors.secondaryContainer;
      case FarmerConditionLabel.noNoticeableChange:
        return const Color(0xFFEFF6FF); // Soft Blue
      case FarmerConditionLabel.lookingWorse:
        return AppColors.errorContainer;
      case FarmerConditionLabel.notSure:
        return const Color(0xFFF3F4F6); // Soft Grey
    }
  }

  IconData get icon {
    switch (this) {
      case FarmerConditionLabel.lookingBetter:
        return Icons.trending_up_rounded;
      case FarmerConditionLabel.noNoticeableChange:
        return Icons.trending_flat_rounded;
      case FarmerConditionLabel.lookingWorse:
        return Icons.trending_down_rounded;
      case FarmerConditionLabel.notSure:
        return Icons.help_outline_rounded;
    }
  }
}

/// Represents a farmer's recorded follow-up observation of a previously diagnosed plant.
class PlantObservationModel {
  final String id;
  final String scanId;
  final String userId;
  final String? cropName;
  final FarmerConditionLabel conditionLabel;
  final String notes;
  final String? imagePath;
  final DateTime? nextInspectionDate;
  final DateTime createdAt;
  final String syncStatus; // 'synced', 'pending', 'local_only'

  const PlantObservationModel({
    required this.id,
    required this.scanId,
    required this.userId,
    this.cropName,
    required this.conditionLabel,
    required this.notes,
    this.imagePath,
    this.nextInspectionDate,
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  factory PlantObservationModel.fromJson(Map<String, dynamic> json) {
    return PlantObservationModel(
      id: json['id'] as String,
      scanId: json['scan_id'] as String,
      userId: json['user_id'] as String,
      cropName: json['crop_name'] as String?,
      conditionLabel:
          FarmerConditionLabel.fromKey(json['condition_label'] as String?),
      notes: (json['notes'] as String?) ?? '',
      imagePath: json['image_path'] as String?,
      nextInspectionDate: json['next_inspection_date'] != null
          ? DateTime.tryParse(json['next_inspection_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      syncStatus: (json['sync_status'] as String?) ?? 'synced',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scan_id': scanId,
      'user_id': userId,
      if (cropName != null) 'crop_name': cropName,
      'condition_label': conditionLabel.key,
      'notes': notes,
      if (imagePath != null) 'image_path': imagePath,
      if (nextInspectionDate != null)
        'next_inspection_date': nextInspectionDate!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  PlantObservationModel copyWith({
    String? id,
    String? scanId,
    String? userId,
    String? cropName,
    FarmerConditionLabel? conditionLabel,
    String? notes,
    String? imagePath,
    DateTime? nextInspectionDate,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return PlantObservationModel(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      userId: userId ?? this.userId,
      cropName: cropName ?? this.cropName,
      conditionLabel: conditionLabel ?? this.conditionLabel,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      nextInspectionDate: nextInspectionDate ?? this.nextInspectionDate,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

