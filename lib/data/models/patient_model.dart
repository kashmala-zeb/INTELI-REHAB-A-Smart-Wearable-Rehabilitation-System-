import 'package:inteli_rehab/domain/entities/patient.dart';

class PatientModel extends PatientSetupModel {
  PatientModel({
    required super.targetPainScale,
    required super.targetWeeklySessions,
    required super.romGoalDegrees,
    required super.recoveryGoals,
  });
}
