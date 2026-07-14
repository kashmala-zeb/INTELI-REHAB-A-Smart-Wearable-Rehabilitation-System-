import 'package:inteli_rehab/domain/entities/patient.dart';

class PatientModel extends RecoverySetupModel {
  final int targetPainScale;
  final int targetWeeklySessions;
  final double romGoalDegrees;
  final List<String> recoveryGoals;

  PatientModel({
    required this.targetPainScale,
    required this.targetWeeklySessions,
    required this.romGoalDegrees,
    required this.recoveryGoals,
    super.affectedArm,
    super.rehabArea,
    super.recoveryStage,
    super.therapistAssigned,
    super.therapistCode,
    super.exerciseFrequency,
    super.selectedDays = const [],
    super.reminderTime,
    super.profilePhoto,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      affectedArm: json['affectedArm'] as String?,
      rehabArea: json['rehabArea'] as String?,
      recoveryStage: json['recoveryStage'] as String?,
      therapistAssigned: json['therapistAssigned'] as bool?,
      therapistCode: json['therapistCode'] as String?,
      exerciseFrequency: json['exerciseFrequency'] as String?,
      selectedDays:
          (json['selectedDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      reminderTime: json['reminderTime'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      targetPainScale: json['targetPainScale'] as int? ?? 0,
      targetWeeklySessions: json['targetWeeklySessions'] as int? ?? 0,
      romGoalDegrees: (json['romGoalDegrees'] as num?)?.toDouble() ?? 0.0,
      recoveryGoals:
          (json['recoveryGoals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'affectedArm': affectedArm,
      'rehabArea': rehabArea,
      'recoveryStage': recoveryStage,
      'therapistAssigned': therapistAssigned,
      'therapistCode': therapistCode,
      'exerciseFrequency': exerciseFrequency,
      'selectedDays': selectedDays,
      'reminderTime': reminderTime,
      'profilePhoto': profilePhoto,
      'targetPainScale': targetPainScale,
      'targetWeeklySessions': targetWeeklySessions,
      'romGoalDegrees': romGoalDegrees,
      'recoveryGoals': recoveryGoals,
    };
  }
}
