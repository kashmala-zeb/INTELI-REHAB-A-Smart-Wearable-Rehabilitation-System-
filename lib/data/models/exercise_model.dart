import 'package:inteli_rehab/domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  ExerciseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.difficulty,
    required super.diffColor,
    required super.durationMinutes,
    required super.reps,
    required super.sets,
    required super.restSeconds,
    required super.targetJoint,
    required super.targetMuscles,
    required super.targetAngleDegrees,
    required super.tips,
    required super.physio,
    required super.fallbackIcon,
    required super.progress,
    required super.status,
    required super.createdAt,
  });
}
