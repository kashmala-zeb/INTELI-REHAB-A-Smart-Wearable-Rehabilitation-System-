import 'package:inteli_rehab/domain/entities/patient.dart';

class PatientModel extends RecoverySetupModel {
  PatientModel({
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
      selectedDays: (json['selectedDays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      reminderTime: json['reminderTime'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
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
    };
  }
}
